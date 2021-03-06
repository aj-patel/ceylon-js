import assert {...}

void testIntegerOperators() {
    
    variable Integer i1 := -4;
    i1 := -i1;
    assert(i1==4, "negation");
    i1 := + (-987654);
    assert(i1==-987654, "positive");
    i1 := +0;
    assert(i1==0, "+0=0");
    i1 := -0;
    assert(i1==0, "+0=0");
        
    variable Integer i2 := 123 + 456;
    assert(i2==579, "addition");
    i1 := i2 - 16;
    assert(i1==563, "subtraction");
    i2 := -i1 + i2 - 1;
    assert(i2==15, "-i1+i2-1");
        
    i1 := 3 * 7;
    assert(i1==21, "multiplication");
    i2 := i1 * 2;
    assert(i2==42, "multiplication");
    i2 := 17 / 4;
    assert(i2==4, "integer division");
    i1 := i2 * 516 / -i1;
    assert(i1==-98, "i2*516/-i1");
    
    i1 := 15 % 4;
    assert(i1==3, "modulo");
    i2 := 312 % 12;
    assert(i2==0, "modulo");

    i1 := 2 ** 10;
    assert(i1==1024, "power");
    i2 := 10 ** 6;
    assert(i2==1000000, "power");
}

void testFloatOperators() {
    
    variable Float f1 := -4.2;
    f1 := -f1;
    assert(f1==4.2, "negation");
    f1 := + (-987654.9925567);
    assert(f1==-987654.9925567, "positive");
    f1 := +0.0;
    assert(f1==0.0, "+0.0=0.0");
    f1 := -0.0;
    assert(f1==0.0, "-0.0=0.0");
        
    variable Float f2 := 3.14159265 + 456.0;
    assert(f2==459.14159265, "addition");
    f1 := f2 - 0.0016;
    assert(f1==459.13999265, "subtraction");
    f2 := -f1 + f2 - 1.2;
    assert(f2==-1.1984000000000037, "-f1+f2-1.2");
    
    f1 := 3.0 * 0.79;
    assert(f1==2.37, "multiplication");
    f2 := f1 * 2.0e13;
    assert(f2==47400000000000.0, "multiplication");
    f2 := 17.1 / 4.0E-18;
    assert(f2==4275000000000000000.0, "division");
    f1 := f2 * 51.6e2 / -f1;
    assert(f2==4275000000000000000.0, "f2*51.6e2/-f1");
        
    f1 := 150.0 ** 0.5;
    assert(f1==12.24744871391589, "power");
}

class OpTest1() {}

void testBooleanOperators() {
    value o1 = OpTest1();
    value o2 = OpTest1();
    variable Boolean b1 := o1 === o2;
    assert(!b1, "identity");
    variable Boolean b2 := o1 === o1;
    assert(b2, "identity");

    b1 := o1 == o2;
    assert(!b1, "equals");
    b2 := o1 == o1;    
    assert(b2, "equals");
    b1 := 1 == 2;
    assert(!b1, "equals");
    b2 := 1 != 2;
    assert(b2, "not equal");
    variable Boolean b3 := !b2;
    assert(!b3, "not");
        
    b1 := true && false;
    assert(!b1, "and");
    b2 := b1 && true;
    assert(!b2, "and");
    b3 := true && true;
    assert(b3, "and");
    b1 := true || false;
    assert(b1, "or");
    b2 := false || b1;
    assert(b2, "or");
    b3 := false || false;
    assert(!b3, "or");
}

void testComparisonOperators() {
    Comparison c1 = "str1" <=> "str2";
    assert(c1==smaller, "compare");
    Comparison c2 = "str2" <=> "str1";
    assert(c2==larger, "compare");
    Comparison c3 = "str1" <=> "str1";
    assert(c3==equal, "compare");
    Comparison c4 = "" <=> "";
    assert(c4==equal, "compare");
    Comparison c5 = "str1" <=> "";
    assert(c5==larger, "compare");
    Comparison c6 = "" <=> "str2";
    assert(c6==smaller, "compare");
    
    variable Boolean b1 := "str1" < "str2";
    assert(b1, "smaller");
    variable Boolean b2 := "str1" > "str2";
    assert(!b2, "larger");
    variable Boolean b3 := "str1" <= "str2";
    assert(b3, "small as");
    variable Boolean b4 := "str1" >= "str2";
    assert(!b4, "large as");
    b1 := "str1" < "str1";
    assert(!b1, "smaller");
    b2 := "str1" > "str1";
    assert(!b2, "larger");
    b3 := "str1" <= "str1";
    assert(b3, "small as");
    b4 := "str1" >= "str1";
    assert(b4, "large as");
}

void testOtherOperators() {
    Integer->String entry = 47->"hi there";
    assert(entry.key==47, "entry key");
    assert(entry.item=="hi there", "entry item");
    value entry2 = true->entry;
    assert(entry2.key==true, "entry key");
    assert(entry2.item==47->"hi there", "entry item");
            
    String s1 = true then "ok" else "noo";
    assert(s1=="ok", "then/else 1");
    String s2 = false then "what?" else "great"; 
    assert(s2=="great", "then/else 2");
}

void testCollectionOperators() {
    value seq1 = { "one", "two" };
    String s1 = seq1[0]?"null";
    assert(s1=="one", "lookup");
    String s2 = seq1[2]?"null";
    assert(s2=="null", "lookup");
    String s3 = seq1[-1]?"null";
    assert(s3=="null", "lookup");
    variable Sequence<String>? unsafe := seq1;
    assert(exists unsafe?[0], "safe index");
    unsafe := null;
    assert(!exists unsafe?[0], "safe index");
}

class NullsafeTest() {
    shared Integer f() {return 1;}
    shared Integer? f2(Integer? x()) {
        return x();
    }
}

Integer? nullsafeTest(Integer? f()) {
    return f();
}

void testNullsafeOperators() {
    String[] seq = { "hi" };
    String s1 = seq[0]?"null";
    assert(s1=="hi", "default 1");
    String s2 = seq[1]?"null";
    assert(s2=="null", "default 2");
    
    String? s3 = null;
    String? s4 = "test";
    String s5 = s3?.uppercased ? "null";
    String s6 = s4?.uppercased ? "null";
    assert(s5=="null", "nullsafe member 1");
    assert(s6=="TEST", "nullsafe member 2");
    NullsafeTest? obj = null;
    Integer? i = obj?.f();
    assert(!exists i, "nullsafe invoke");
    Callable<Integer?> f2 = obj?.f;
    assert(!exists nullsafeTest(f2), "nullsafe method ref");
    Callable<Integer?>? f3 = obj?.f;
    assert(exists f3, "nullsafe method ref 2");
    obj?.f();
    assert(!exists obj?.f(), "nullsafe simple call");
    NullsafeTest? getNullsafe() { return obj; }
    function f4() = getNullsafe()?.f;
    Integer? result_f4 = f4();
    assert(!exists result_f4, "nullsafe invoke 2");
    Integer? i2 = getNullsafe()?.f();
    assert(!exists i2, "nullsafe invoke 3");
    assert(!exists NullsafeTest().f2(getNullsafe()?.f), "nullsafe method ref 3");
    NullsafeTest? obj2 = NullsafeTest();
    if (exists i3 = obj2?.f()) {
        assert(i3==1, "nullsafe invoke 4 (result)");
    } else {
        fail("nullsafe invoke 4 (null)");
    }
    Integer? obj2_f() = obj2?.f;
    if (exists i3 = obj2_f()) {
        assert(i3==1, "nullsafe method ref 4 (result)");
    } else {
        fail("nullsafe method ref 4 (null)");
    }
}

void testIncDecOperators() {
    variable Integer x0 := 1;
    Integer x { return x0; } assign x { x0 := x; }
    
    variable Integer i1 := 1;
    void f1() {
        Integer i2 = ++i1;
        Integer x2 = ++x;
        assert(i1==2, "prefix increment 1");
        assert(i2==2, "prefix increment 2");
        assert(x==2, "prefix increment 3");
        assert(x2==2, "prefix increment 4");
    }
    f1();
    
    class C1() {
        shared variable Integer i := 1;
        variable Integer x0 := 1;
        shared Integer x { return x0; } assign x { x0 := x; }
    }
    C1 c1 = C1();
    variable Integer i3 := 0;
    C1 f2() {
        ++i3;
        return c1;
    }
    Integer i4 = ++f2().i;
    Integer x4 = ++f2().x;
    assert(i4==2, "prefix increment 5");
    assert(c1.i==2, "prefix increment 6");
    assert(x4==2, "prefix increment 7");
    assert(c1.x==2, "prefix increment 8");
    assert(i3==2, "prefix increment 9");
    
    void f3() {
        Integer i2 = --i1;
        assert(i1==1, "prefix decrement");
        assert(i2==1, "prefix decrement");
    }
    f3();
    
    Integer i5 = --f2().i;
    assert(i5==1, "prefix decrement");
    assert(c1.i==1, "prefix decrement");
    assert(i3==3, "prefix decrement");
    
    void f4() {
        Integer i2 = i1++;
        Integer x2 = x++;
        assert(i1==2, "postfix increment 1");
        assert(i2==1, "postfix increment 2");
        assert(x==3, "postfix increment 3");
        assert(x2==2, "postfix increment 4");
    }
    f4();
    
    Integer i6 = f2().i++;
    Integer x6 = f2().x++;
    assert(i6==1, "postfix increment 5");
    assert(c1.i==2, "postfix increment 6");
    assert(x6==2, "postfix increment 7 ");
    assert(c1.x==3, "postfix increment 8 ");
    assert(i3==5, "postfix increment 9");
    
    void f5() {
        Integer i2 = i1--;
        assert(i1==1, "postfix decrement");
        assert(i2==2, "postfix decrement");
    }
    f5();
    
    Integer i7 = f2().i--;
    assert(i7==2, "postfix decrement");
    assert(c1.i==1, "postfix decrement");
    assert(i3==6, "postfix decrement");
}

void testArithmeticAssignOperators() {
    variable Integer i1 := 1;
    variable Integer x0 := 1;
    Integer x { return x0; } assign x { x0:=x; } 
    i1 += 10;
    x += 10;
    assert(i1==11, "+= operator 1");
    assert(x==11, "+= operator 2");
    
    variable Integer i2 := (i1 += -5);
    variable Integer x2 := (x += -5);
    assert(i2==6, "+= operator 3");
    assert(i1==6, "+= operator 4");
    assert(x2==6, "+= operator 5");
    assert(x==6, "+= operator 6");
    
    class C1() {
        shared variable Integer i := 1;
        variable Integer x0 := 1;
        shared Integer x { return x0; } assign x { x0:=x; }
    }
    C1 c1 = C1();
    variable Integer i3 := 0;
    C1 f() {
        ++i3;
        return c1;
    }
    
    i2 := (f().i += 11);
    x2 := (f().x += 11);
    assert(i2==12, "+= operator 7");
    assert(c1.i==12, "+= operator 8");
    assert(x2==12, "+= operator 9");
    assert(c1.x==12, "+= operator 10");
    assert(i3==2, "+= operator 11");
    
    i2 := (i1 -= 14);
    assert(i1==-8, "-= operator");
    assert(i2==-8, "-= operator");
    
    i2 := (i1 *= -3);
    assert(i1==24, "*= operator");
    assert(i2==24, "*= operator");
    
    i2 := (i1 /= 5);
    assert(i1==4, "/= operator");
    assert(i2==4, "/= operator");
    
    i2 := (i1 %= 3);
    assert(i1==1, "%= operator");
    assert(i2==1, "%= operator");
}

void testAssignmentOperator() {
    variable Integer i1 := 1;
    variable Integer i2 := 2;
    variable Integer i3 := 3;
    assert((i1:=i2:=i3)==3, "assignment 1");
    assert(i1==3, "assignment 2");
    assert(i2==3, "assignment 3");
    
    Integer x1 { return i1; } assign x1 { i1 := x1; }
    Integer x2 { return i2; } assign x2 { i2 := x2; }
    Integer x3 { return i3; } assign x3 { i3 := x3; }
    i1 := 1;
    i2 := 2;
    assert((x1:=x2:=x3)==3, "assignment 4");
    assert(x1==3, "assignment 5");
    assert(x2==3, "assignment 6");
    
    class C() {
        shared variable Integer i := 1;
        variable Integer x0 := 1;
        shared Integer x { return x0; } assign x { x0:=x; }
    }
    C o1 = C();
    C o2 = C();
    assert((o1.i:=o2.i:=3)==3, "assignment 7");
    assert(o1.i==3, "assignment 8");
    assert(o2.i==3, "assignment 9");
    assert((o1.x:=o2.x:=3)==3, "assignment 10");
    assert(o1.x==3, "assignment 11");
    assert(o2.x==3, "assignment 12");
}

shared void test() {
    testIntegerOperators();
    testFloatOperators();
    testBooleanOperators();
    testComparisonOperators();
    testOtherOperators();
    testCollectionOperators();
    testNullsafeOperators();
    testIncDecOperators();
    testArithmeticAssignOperators();
    testAssignmentOperator();
    results();
}
