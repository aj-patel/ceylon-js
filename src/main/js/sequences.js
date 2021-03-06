function initTypeProto(a,b,c,d,e,f,g,h,i,j,k,l);//IGNORE
function initTypeProtoI(a,b,c,d,e,f,g,h,i,j,k,l);//IGNORE
function String$(x){}//IGNORE
function Character(x){}//IGNORE
function isOfType(a,b){}//IGNORE
function smallest(x,y){}//IGNORE
function largest(x,y){}//IGNORE
function Exception(){}//IGNORE
var List,Some,Cloneable,Ranged,exports,larger,smaller,equal,Object$,$empty,$finished,Iterator;//IGNORE
var IdentifiableObject,Category,Sized;//IGNORE

function Sequence($$sequence) {
    return $$sequence;
}
initTypeProtoI(Sequence, 'ceylon.language.Sequence', Some, Cloneable, Ranged, List);
var Sequence$proto = Sequence.$$.prototype;
Sequence$proto.getLast = function() {
    var last = this.item(this.getLastIndex());
    if (last === null) throw Exception();
    return last;
}

function Array$() {
    var that = new Array$.$$;
    return that;
}
initExistingType(Array$, Array, 'ceylon.language.Array', Object$, FixedSized,
        Cloneable, Ranged, List);
var Array$proto = Array.prototype;
var origArrToString = Array$proto.toString;
inheritProtoI(Array$, Object$, FixedSized, Cloneable, Ranged, List);
Array$proto.toString = origArrToString;
exports.Array=Array$;

function EmptyArray() {
    return [];
}
initTypeProto(EmptyArray, 'ceylon.language.EmptyArray', Array$, None);
function ArrayList(items) {
    return items;
}
initTypeProto(ArrayList, 'ceylon.language.ArrayList', Array$, List);
function ArraySequence(/* js array */value) {
    value.$seq = true;
    return value;
}
initTypeProto(ArraySequence, 'ceylon.language.ArraySequence', IdentifiableObject, Sequence);

Array$proto.getT$name$ = function() {
    return (this.$seq ? ArraySequence : (this.length>0?ArrayList:EmptyArray)).$$.T$name;
}
Array$proto.getT$all$ = function() {
    return (this.$seq ? ArraySequence : (this.length>0?ArrayList:EmptyArray)).$$.T$all;
}

exports.EmptyArray=EmptyArray;

Array$proto.getSize = function() { return this.length; }
Array$proto.setItem = function(idx,elem) {
    if (idx >= 0 && idx < this.length) {
        this[idx] = elem;
    }
}
Array$proto.item = function(idx) {
    var result = this[idx];
    return result!==undefined ? result:null;
}
Array$proto.getLastIndex = function() {
    return this.length>0 ? (this.length-1) : null;
}
Array$proto.getReversed = function() {
    if (this.length === 0) { return this; }
    var arr = this.slice(0);
    arr.reverse();
    return this.$seq ? ArraySequence(arr) : arr;
}
Array$proto.chain = function(other) {
    if (this.length === 0) { return other; }
    return Iterable.$$.prototype.chain.call(this, other);
}
Array$proto.getFirst = function() { return this.length>0 ? this[0] : null; }
Array$proto.getLast = function() { return this.length>0 ? this[this.length-1] : null; }
Array$proto.segment = function(from, len) {
    var seq = [];
    if (len > 0) {
        var stop = from + len;
        for (var i=from; i < stop; i++) {
            var x = this.item(i);
            if (x !== null) { seq.push(x); }
        }
    }
    return ArraySequence(seq);
}
Array$proto.span = function(from, to) {
    var fromIndex = largest(0,from);
    var toIndex = to === null || to === undefined ? this.getLastIndex() : smallest(to, this.getLastIndex());
    var seq = [];
    if (fromIndex == toIndex) {
        return Singleton(this.item(from));
    } else if (toIndex > fromIndex) {
        for (var i = fromIndex; i <= toIndex && this.defines(i); i++) {
            seq.push(this.item(i));
        }
    } else {
        //Negative span, reverse seq returned
        for (var i = fromIndex; i >= toIndex && this.defines(i); i--) {
            seq.push(this.item(i));
        }
    }
    return ArraySequence(seq);
}
Array$proto.getRest = function() {
    return this.length<=1 ? $empty : ArraySequence(this.slice(1));
}
Array$proto.items = function(keys) {
    if (keys === undefined) return $empty;
    var seq = [];
    for (var i = 0; i < keys.getSize(); i++) {
        var key = keys.item(i);
        seq.push(this.item(key));
    }
    return ArraySequence(seq);
}
Array$proto.getKeys = function() { return TypeCategory(this, 'ceylon.language.Integer'); }
Array$proto.contains = function(elem) {
    for (var i=0; i<this.length; i++) {
        if (elem.equals(this[i])) {
            return true;
        }
    }
    return false;
}

exports.ArrayList=ArrayList;
exports.arrayOfNone=function() { return []; }
exports.arrayOfSome=function(/*Sequence*/elems) { //In practice it's an ArraySequence
    return elems;
}
exports.array=function(elems) {
    if (elems === null || elems === undefined) {
        return [];
    } else {
        var e=[];
        var iter=elems.getIterator();
        var item;while((item=iter.next())!==$finished) {
            e.push(item);
        }
        return e;
    }
}
exports.arrayOfSize=function(size, elem) {
    if (size > 0) {
        var elems = [];
        for (var i = 0; i < size; i++) {
            elems.push(elem);
        }
        return elems;
    } else return [];
}

function TypeCategory(seq, type) {
    var that = new TypeCategory.$$;
    that.type = type;
    that.seq = seq;
    return that;
}
initTypeProto(TypeCategory, 'ceylon.language.TypeCategory', IdentifiableObject, Category);
var TypeCategory$proto = TypeCategory.$$.prototype;
TypeCategory$proto.contains = function(k) {
    return isOfType(k, this.type) && this.seq.defines(k);
}

function SequenceBuilder() {
    var that = new SequenceBuilder.$$;
    that.seq = [];
    return that;
}
initTypeProto(SequenceBuilder, 'ceylon.language.SequenceBuilder', IdentifiableObject, Sized);
var SequenceBuilder$proto = SequenceBuilder.$$.prototype;
SequenceBuilder$proto.getSequence = function() { return ArraySequence(this.seq); }
SequenceBuilder$proto.append = function(e) { this.seq.push(e); }
SequenceBuilder$proto.appendAll = function(/*Iterable*/arr) {
    if (arr === undefined) return;
    var iter = arr.getIterator();
    var e; while ((e = iter.next()) !== $finished) {
        this.seq.push(e);
    }
}
SequenceBuilder$proto.getSize = function() { return this.seq.length; }

function SequenceAppender(other) {
    var that = new SequenceAppender.$$;
    that.seq = [];
    that.appendAll(other);
    return that;
}
initTypeProto(SequenceAppender, 'ceylon.language.SequenceAppender', SequenceBuilder);

function Singleton(elem) {
    var that = new Singleton.$$;
    that.value = [elem];
    that.elem = elem;
    return that;
}
initTypeProto(Singleton, 'ceylon.language.Singleton', Object$, Sequence);
var Singleton$proto = Singleton.$$.prototype;
Singleton$proto.getString = function() { return String$("{ " + this.elem.getString() + " }") }
Singleton$proto.item = function(index) {
    return index===0 ? this.value[0] : null;
}
Singleton$proto.getSize = function() { return 1; }
Singleton$proto.getLastIndex = function() { return 0; }
Singleton$proto.getFirst = function() { return this.elem; }
Singleton$proto.getLast = function() { return this.elem; }
Singleton$proto.getEmpty = function() { return false; }
Singleton$proto.getRest = function() { return $empty; }
Singleton$proto.defines = function(idx) { return idx.equals(0); }
Singleton$proto.getKeys = function() { return TypeCategory(this, 'ceylon.language.Integer'); }
Singleton$proto.span = function(from, to) {
    if (to === undefined || to === null) to = from;
    return (from.equals(0) || to.equals(0)) ? this : $empty;
}
Singleton$proto.segment = function(idx, len) {
    if (idx.equals(0) && len.compare(0) === larger) {
        return this;
    }
    return $empty;
}
Singleton$proto.getIterator = function() { return SingletonIterator(this.elem); }
Singleton$proto.getReversed = function() { return this; }
Singleton$proto.equals = function(other) {
    if (isOfType(other, 'ceylon.language.List')) {
        if (other.getSize() !== 1) {
            return false;
        }
        var o = other.item(0);
        return o !== null && o.equals(this.elem);
    }
    return false;
}
Singleton$proto.$map = function(f) { return ArraySequence([ f(this.elem) ]); }
Singleton$proto.$filter = function(f) {
    return f(this.elem) ? this : $empty;
}
Singleton$proto.fold = function(v,f) {
    return f(v, this.elem);
}
Singleton$proto.find = function(f) {
    return f(this.elem) ? this.elem : null;
}
Singleton$proto.findLast = function(f) {
    return f(this.elem) ? this.elem : null;
}
Singleton$proto.any = function(f) {
    return f(this.elem);
}
Singleton$proto.$every = function(f) {
    return f(this.elem);
}
Singleton$proto.skipping = function(skip) {
    return skip==0 ? this : $empty;
}
Singleton$proto.taking = function(take) {
    return take>0 ? this : $empty;
}
Singleton$proto.by = function(step) {
    return this;
}
Singleton$proto.$sort = function(f) { return this; }
Singleton$proto.count = function(f) {
	return f(this.elem) ? 1 : 0;
}
Singleton$proto.contains = function(o) {
	return this.elem.equals(o);
}
Singleton$proto.getCoalesced = function() { return this; }

function SingletonIterator(elem) {
    var that = new SingletonIterator.$$;
    that.elem = elem;
    that.done = false;
    return that;
}
initTypeProto(SingletonIterator, 'ceylon.language.SingletonIterator', IdentifiableObject, Iterator);
var $SingletonIterator$proto = SingletonIterator.$$.prototype;
$SingletonIterator$proto.next = function() {
    if (this.done) {
        return $finished;
    }
    this.done = true;
    return this.elem;
}

exports.Sequence=Sequence;
exports.SequenceBuilder=SequenceBuilder;
exports.SequenceAppender=SequenceAppender;
exports.ArraySequence=ArraySequence;
exports.Singleton=Singleton;
