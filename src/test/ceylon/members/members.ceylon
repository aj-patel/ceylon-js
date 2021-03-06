import assert {...}

shared class Counter(Integer initCount=0) {
    variable value currentCount:=initCount;
    shared Integer count {
        return currentCount;
    }
    shared void inc() {
        currentCount:=currentCount+1; 
    }
    shared Integer initialCount {
        return initCount;
    }
    shared actual String string {
        return "Counter[" + count.string + "]";
    }
}

class Issue10C1(Integer arg1) {
    Integer i1 = 3;
    Integer i2 = 5;
    shared default Integer i3 = 7;
    shared Integer f1() { return arg1; }
    shared Integer f2() { return i1; }
    shared Integer f3() { return i2; } 
    shared Integer f4() { return i3; }
    Integer f5() { return 9; }
    shared Integer f6() { return f5(); }
    Integer f7() { return 11; }
    shared Integer f8() { return f7(); }
    shared default Integer f9() { return 13; }
    shared Integer f10() { return f9(); }
}
class Issue10C2(Integer arg1) extends Issue10C1(1) {
    Integer i1 = 4;
    shared Integer i2 = 6;
    shared actual Integer i3 = 8;
    shared Integer f11() { return arg1; }
    shared Integer f12() { return i1; }
    Integer f5() { return 10; }
    shared Integer f13() { return f5(); }
    shared Integer f7() { return 12; }
    shared actual Integer f9() { return 14; }
}

void testIssue10() {
    value obj = Issue10C2(2);
    assert(obj.f1()==1, "Issue #10 (parameter)");
    assert(obj.f11()==2, "Issue #10 (parameter)");
    assert(obj.f2()==3, "Issue #10 (non-shared attribute)");
    assert(obj.f12()==4, "Issue #10 (non-shared attribute)");
    assert(obj.f3()==5, "Issue #10 (non-shared attribute)");
    assert(obj.i2==6, "Issue #10 (shared attribute)");
    assert(obj.f4()==8, "Issue #10 (shared attribute)");
    assert(obj.i3==8, "Issue #10 (shared attribute)");
    assert(obj.f6()==9, "Issue #10 (non-shared method)");
    assert(obj.f13()==10, "Issue #10 (non-shared method)");
    assert(obj.f8()==11, "Issue #10 (non-shared method)");
    assert(obj.f7()==12, "Issue #10 (shared method)");
    assert(obj.f10()==14, "Issue #10 (shared method)");
    assert(obj.f9()==14, "Issue #10 (shared method)");
    assert(nonempty obj.string, "Issue #113 (inheritance)");
}

class AssignTest() {
    shared variable Integer x := 1;
    shared Integer y { return x; }
    assign y { x := y; }
}

class Issue50() {
    shared String z;
    z = "ok";
}

class Util() {
    shared String s = "123";
}
class AliasMemberTest() {
    shared interface I1 {shared String s {return "A";} }
    shared interface I1Alias = I1;
    interface I2 {shared String s {return "B";} }
    interface I2Alias = I2;
    shared class A() satisfies I1Alias {}
    class B() satisfies I2Alias {}
    shared class AliasA() = A;
    class AliasB() = B;
    shared String b() { return AliasB().s; }
 
    shared Util f1() = Util;   
    shared A f2() = AliasA;
}

shared void test() {
    value c = Counter(0);
    assert(c.count==0,"counter 1");
    c.inc(); c.inc();
    assert(c.count==2, "counter 2");
    assert(c.string=="Counter[2]", "counter.string");
    
    testIssue10();
    
    value at = AssignTest();
    at.x := 5;
    assert(at.x==5, "assign to member");
    at.y := 2;
    assert(at.y==2, "assign using setter");
    assert(Issue50().z=="ok", "Issue #50");
    test_outer_inner_safety();
    
    assert(AliasMemberTest().AliasA().s=="A", "shared inner alias class");
    assert(AliasMemberTest().b()=="B", "non-shared inner alias class");
    assert(AliasMemberTest().f1().s=="123", "alias method member 1");
    assert(AliasMemberTest().f2().s=="A", "alias method member 2");
    results();
}
