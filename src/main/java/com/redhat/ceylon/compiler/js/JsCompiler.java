package com.redhat.ceylon.compiler.js;

import java.io.File;
import java.io.IOException;
import java.io.PrintStream;
import java.io.FileWriter;
import java.io.Writer;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.redhat.ceylon.cmr.api.ArtifactContext;
import com.redhat.ceylon.cmr.api.RepositoryManager;
import com.redhat.ceylon.cmr.api.SourceArchiveCreator;
import com.redhat.ceylon.cmr.ceylon.CeylonUtils;
import com.redhat.ceylon.cmr.impl.JULLogger;
import com.redhat.ceylon.cmr.impl.ShaSigner;
import com.redhat.ceylon.compiler.Options;
import com.redhat.ceylon.compiler.SimpleJsonEncoder;
import com.redhat.ceylon.compiler.typechecker.TypeChecker;
import com.redhat.ceylon.compiler.typechecker.context.PhasedUnit;
import com.redhat.ceylon.compiler.typechecker.tree.AnalysisMessage;
import com.redhat.ceylon.compiler.typechecker.analyzer.AnalysisWarning;
import com.redhat.ceylon.compiler.typechecker.analyzer.AnalysisError;
import com.redhat.ceylon.compiler.typechecker.model.Module;
import com.redhat.ceylon.compiler.typechecker.parser.RecognitionError;
import com.redhat.ceylon.compiler.typechecker.tree.Message;
import com.redhat.ceylon.compiler.typechecker.tree.Node;
import com.redhat.ceylon.compiler.typechecker.tree.Visitor;

public class JsCompiler {
    
    protected final TypeChecker tc;
    protected final Options opts;
    protected final RepositoryManager outRepo;

    private boolean stopOnErrors = true;
    private int errCount = 0;

    protected List<Message> errors = new ArrayList<Message>();
    protected List<Message> unitErrors = new ArrayList<Message>();
    protected Set<String> files;
    private final Map<Module, JsOutput> output = new HashMap<Module, JsOutput>();

    /** A container for things we need to keep per-module. */
    private final class JsOutput {
        private final File f = File.createTempFile("jsout", ".tmp");
        private final Writer w = new FileWriter(f);
        private final Set<String> s = new HashSet<String>();
        private final MetamodelGenerator mmg;
        private JsOutput(Module m) throws IOException {
            mmg = new MetamodelGenerator(m);
        }
        Writer getWriter() { return w; }
        File close() throws IOException {
            w.close();
            return f;
        }
        void addSource(String src) {
            s.add(src);
        }
        Set<String> getSources() { return s; }
    }

    private final Visitor unitVisitor = new Visitor() {
        @Override
        public void visitAny(Node that) {
            for (Message err: that.getErrors()) {
                unitErrors.add(err);
            }
            super.visitAny(that);
        }
    };

    public JsCompiler(TypeChecker tc, Options options) {
        this.tc = tc;
        opts = options;
        outRepo = CeylonUtils.makeOutputRepositoryManager(
                options.getOutDir(), new JULLogger(), options.getUser(), options.getPass());
        String outDir = options.getOutDir();
        if(!isURL(outDir)){
        	File root = new File(outDir);
        	if (root.exists()) {
        		if (!(root.isDirectory() && root.canWrite())) {
        			System.err.printf("Cannot write to %s. Stop.%n", root);
        		}
        	} else {
        		if (!root.mkdirs()) {
        			System.err.printf("Cannot create %s. Stop.%n", root);
        		}
        	}
        }
    }

    private boolean isURL(String path) {
    	try {
			new URL(path);
			return true;
		} catch (MalformedURLException e) {
			return false;
		}
	}

	/** Specifies whether the compiler should stop when errors are found in a compilation unit (default true). */
    public JsCompiler stopOnErrors(boolean flag) {
        stopOnErrors = flag;
        return this;
    }

    /** Sets the names of the files to compile. By default this is null, which means all units from the typechecker
     * will be compiled. */
    public void setFiles(Set<String> files) {
        this.files = files;
    }

    public List<Message> listErrors() {
        return Collections.unmodifiableList(errors);
    }

    /** Compile one phased unit.
     * @return The errors found for the unit. */
    public List<Message> compileUnit(PhasedUnit pu, JsIdentifierNames names) throws IOException {
        unitErrors.clear();
        pu.getCompilationUnit().visit(unitVisitor);
        if (errCount == 0 || !stopOnErrors) {
            if (opts.isVerbose()) {
                System.out.printf("%nCompiling %s to JS%n", pu.getUnitFile().getPath());
            }
            pu.getCompilationUnit().visit(unitVisitor);
            GenerateJsVisitor jsv = new GenerateJsVisitor(getWriter(pu), opts.isOptimize(), names);
            jsv.setAddComments(opts.isComment());
            jsv.setIndent(opts.isIndent());
            jsv.setVerbose(opts.isVerbose());
            pu.getCompilationUnit().visit(jsv);
        }
        return unitErrors;
    }

    /** Indicates if compilation should stop, based on whether there were errors
     * in the last compilation unit and the stopOnErrors flag is set. */
    protected boolean stopOnError() {
        for (Message err : unitErrors) {
            if (err instanceof AnalysisError || !(err instanceof AnalysisWarning)) {
                errCount++;
            }
            errors.add(err);
        }
        return stopOnErrors && errCount > 0;
    }

    /** Compile all the phased units in the typechecker.
     * @return true is compilation was successful (0 errors/warnings), false otherwise. */
    public boolean generate() throws IOException {
        errors.clear();
        output.clear();
        try {
            if (opts.isVerbose()) {
                System.out.println("Generating metamodel...");
            }
            //First generate the metamodel
            for (PhasedUnit pu: tc.getPhasedUnits().getPhasedUnits()) {
                String pathFromVFS = pu.getUnitFile().getPath();
                // VFS talks in terms of URLs while files are platform-dependent, so make it 
                // platform-dependent too
                String path = pathFromVFS.replace('/', File.separatorChar);
                if (files == null || files.contains(path)) {
                    String name = pu.getUnitFile().getName();
                    if (!"module.ceylon".equals(name) && !"package.ceylon".equals(name)) {
                        pu.getCompilationUnit().visit(getOutput(pu).mmg);
                    }
                }
            }
            //Then write it out
            final SimpleJsonEncoder json = new SimpleJsonEncoder();
            for (Map.Entry<Module,JsOutput> e : output.entrySet()) {
                e.getValue().getWriter().write("$$metamodel$$=");
                json.encode(e.getValue().mmg.getModel(), e.getValue().getWriter());
                e.getValue().getWriter().write(";\n");
            }

            //Then generate the JS code
            JsIdentifierNames names = new JsIdentifierNames(opts.isOptimize());
            for (PhasedUnit pu: tc.getPhasedUnits().getPhasedUnits()) {
            	String pathFromVFS = pu.getUnitFile().getPath();
            	// VFS talks in terms of URLs while files are platform-dependent, so make it 
            	// platform-dependent too
            	String path = pathFromVFS.replace('/', File.separatorChar);
                if (files == null || files.contains(path)) {
                    String name = pu.getUnitFile().getName();
                    if (!"module.ceylon".equals(name) && !"package.ceylon".equals(name)) {
                        compileUnit(pu, names);
                        if (stopOnError()) {
                            System.err.println("Errors found. Compilation stopped.");
                            break;
                        }
                    }
                    getOutput(pu).addSource(pu.getUnit().getFullPath());
                } else {
                    if (opts.isVerbose()) {
                    	System.err.println("Files does not contain "+path);
                    	for (String p : files) {
                    		System.err.println(" Files: "+p);
                    	}
                    }
                }
            }
        } finally {
            finish();
        }
        return errCount == 0;
    }

    /** Creates a JsOutput if needed, for the PhasedUnit.
     * Right now it's one file per module. */
    private JsOutput getOutput(PhasedUnit pu) throws IOException {
        Module mod = pu.getPackage().getModule();
        JsOutput jsout = output.get(mod);
        if (jsout==null) {
            jsout = new JsOutput(mod);
            output.put(mod, jsout);
            if (opts.isModulify()) {
                beginWrapper(jsout.getWriter());
            }
        }
        return jsout;
    }
    /** Returns the writer for the Phased Unit. */
    protected Writer getWriter(PhasedUnit pu) throws IOException {
        return getOutput(pu).getWriter();
    }

    /** Closes all output writers and puts resulting artifacts in the output repo. */
    protected void finish() throws IOException {
        for (Map.Entry<Module,JsOutput> entry: output.entrySet()) {
            JsOutput jsout = entry.getValue();

            if (opts.isModulify()) {
                jsout.getWriter().write("exports.$$metamodel$$=$$metamodel$$;\n");
                endWrapper(jsout.getWriter());
            }
            String moduleName = entry.getKey().getNameAsString();
            String moduleVersion = entry.getKey().getVersion();
            //Create the JS file
            File jsart = entry.getValue().close();
            ArtifactContext artifact = new ArtifactContext(moduleName, moduleVersion);
            artifact.setSuffix(".js");
            if(opts.isVerbose()){
            	System.err.println("Outputting for "+moduleName);
            }
            outRepo.putArtifact(artifact, jsart);
            //js file signature
            artifact.setForceOperation(true);
            ArtifactContext sha1Context = artifact.getSha1Context();
            sha1Context.setForceOperation(true);
            File sha1File = ShaSigner.sign(jsart, new JULLogger(), opts.isVerbose());
            outRepo.putArtifact(sha1Context, sha1File);
            //Create the src archive
            if (opts.isGenerateSourceArchive()) {
                Set<File> sourcePaths = new HashSet<File>();
                for (String sp : opts.getSrcDirs()) {
                    sourcePaths.add(new File(sp));
                }
                SourceArchiveCreator sac = CeylonUtils.makeSourceArchiveCreator(outRepo, sourcePaths,
                        moduleName, moduleVersion, opts.isVerbose(), new JULLogger());
                sac.copySourceFiles(jsout.getSources());
            }
            sha1File.deleteOnExit();
            jsart.deleteOnExit();
        }
    }

    /** Print all the errors found during compilation to the specified stream. */
    public void printErrors(PrintStream out) {
        int count = 0;
        for (Message err: errors) {
            if (err instanceof AnalysisWarning && !(err instanceof AnalysisError)) {
                out.print("warning");
            } else {
                out.print("error");
            }
            out.printf(" encountered [%s]", err.getMessage());
            if (err instanceof AnalysisMessage) {
                Node n = ((AnalysisMessage)err).getTreeNode();
                out.printf(" at %s of %s", n.getLocation(), n.getUnit().getFilename());
            } else if (err instanceof RecognitionError) {
                RecognitionError rer = (RecognitionError)err;
                out.printf(" at %d:%d", rer.getLine(), rer.getCharacterInLine());
            }
            out.println();
            count++;
        }
        out.printf("%d errors.%n", count);
    }

    /** Writes the beginning of the wrapper function for a JS module. */
    public void beginWrapper(Writer writer) throws IOException {
        writer.write("(function(define) { define(function(require, exports, module) {\n");
    }

    /** Writes the ending of the wrapper function for a JS module. */
    public void endWrapper(Writer writer) throws IOException {
        //Finish the wrapper
        writer.write("});\n");
        writer.write("}(typeof define==='function' && define.amd ? define : function (factory) {\n");
        writer.write("if (typeof exports!=='undefined') { factory(require, exports, module);\n");
        writer.write("} else { throw 'no module loader'; }\n");
        writer.write("}));\n");
    }

}
