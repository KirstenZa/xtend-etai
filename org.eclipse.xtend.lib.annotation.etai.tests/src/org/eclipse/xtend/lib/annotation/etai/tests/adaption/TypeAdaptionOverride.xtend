package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import org.eclipse.xtend.lib.annotation.etai.AdaptedMethod
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.CopyConstructorRule
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.junit.Test

import static org.junit.Assert.*

class Base {
}

class Derived extends Base {
}

@ExtractInterface
@ApplyRules
abstract class TypeAdaptionOverrideBase1 {

	@CopyConstructorRule
	new(Base obj) {
	}

	@TypeAdaptionRule
	override Base method1() {
		null
	}

	@TypeAdaptionRule
	override Base method2() {
		null
	}

	@TypeAdaptionRule
	override Base method3() {
		null
	}

	@TypeAdaptionRule
	override Base method4() {
		null
	}

	override void method5(
		@TypeAdaptionRule
		int x
	) {
	}
	
	@TypeAdaptionRule("apply(Base);replaceAll(Base,Derived)")
	override Base method6() {
		null
	}
	
	@TypeAdaptionRule
	abstract override Base method7()
	
	@TypeAdaptionRule
	abstract override Base method8()
	
	@TypeAdaptionRule("apply(Base);replaceAll(Base,Derived)")
	abstract override Base method9()

}

@ExtractInterface
@ApplyRules
abstract class TypeAdaptionOverrideBase2 extends TypeAdaptionOverrideBase1 {

	@CopyConstructorRule
	new(Derived obj) {
		super(obj);
	}

	@TypeAdaptionRule
	override Derived method1() {
		null
	}

	@AdaptedMethod
	override Base method3() {
		null
	}

	override Base method4() {
		null
	}
	
	@TypeAdaptionRule
	abstract override Derived method8()

}

@ExtractInterface
@ApplyRules
class TypeAdaptionOverrideBase3 extends TypeAdaptionOverrideBase2 {

	new() {
		super(null)
	}

	@TypeAdaptionRule
	override Derived method1() {
		null
	}
	
	@TypeAdaptionRule
	override Derived method7() {
		null
	}
	
	@AdaptedMethod
	override Derived method8() {
		null
	}
	
	@AdaptedMethod
	override Derived method9() {
		null
	}

}

@ExtractInterface
@ApplyRules
class TypeAdaptionOverrideBase4 extends TypeAdaptionOverrideBase3 {
}

@ExtractInterface
@ApplyRules
class TypeAdaptionOverride extends TypeAdaptionOverrideBase4 {
}

class TypeAdaptionOverrideTests {

	@Test
	def void testNoReimplementation() {
		
		// check that no method is re-implemented if there is no type change
		assertEquals(0, TypeAdaptionOverride.declaredMethods.filter[name == "method1" && synthetic == false].size)
		assertEquals(0, TypeAdaptionOverride.declaredMethods.filter[name == "method2" && synthetic == false].size)
		assertEquals(0, TypeAdaptionOverride.declaredMethods.filter[name == "method3" && synthetic == false].size)
		assertEquals(0, TypeAdaptionOverride.declaredMethods.filter[name == "method4" && synthetic == false].size)
		assertEquals(0, TypeAdaptionOverride.declaredMethods.filter[name == "method5" && synthetic == false].size)
		assertEquals(0, TypeAdaptionOverride.declaredMethods.filter[name == "method6" && synthetic == false].size)
		assertEquals(0, TypeAdaptionOverride.declaredMethods.filter[name == "method7" && synthetic == false].size)
		assertEquals(0, TypeAdaptionOverride.declaredMethods.filter[name == "method8" && synthetic == false].size)
		assertEquals(0, TypeAdaptionOverride.declaredMethods.filter[name == "method9" && synthetic == false].size)
		
	}

	@Test
	def void testContollerComponentAdaptions() {

		// check return type of methods in derived class
		assertEquals(1, TypeAdaptionOverride.methods.filter[name == "method1" && synthetic == false].size)
		assertSame(Derived, TypeAdaptionOverride.methods.filter[name == "method1" && synthetic == false].get(0).returnType)
		assertEquals(1, TypeAdaptionOverride.methods.filter[name == "method2" && synthetic == false].size)
		assertSame(Base, TypeAdaptionOverride.methods.filter[name == "method2" && synthetic == false].get(0).returnType)
		assertEquals(1, TypeAdaptionOverride.methods.filter[name == "method3" && synthetic == false].size)
		assertSame(Base, TypeAdaptionOverride.methods.filter[name == "method3" && synthetic == false].get(0).returnType)
		assertEquals(1, TypeAdaptionOverride.methods.filter[name == "method4" && synthetic == false].size)
		assertSame(Base, TypeAdaptionOverride.methods.filter[name == "method4" && synthetic == false].get(0).returnType)
		assertEquals(1, TypeAdaptionOverride.methods.filter[name == "method6" && synthetic == false].size)
		assertSame(Derived, TypeAdaptionOverride.methods.filter[name == "method6" && synthetic == false].get(0).returnType)
		assertEquals(1, TypeAdaptionOverride.methods.filter[name == "method7" && synthetic == false].size)
		assertSame(Derived, TypeAdaptionOverride.methods.filter[name == "method7" && synthetic == false].get(0).returnType)
		assertEquals(1, TypeAdaptionOverride.methods.filter[name == "method8" && synthetic == false].size)
		assertSame(Derived, TypeAdaptionOverride.methods.filter[name == "method8" && synthetic == false].get(0).returnType)
		assertEquals(1, TypeAdaptionOverride.methods.filter[name == "method9" && synthetic == false].size)
		assertSame(Derived, TypeAdaptionOverride.methods.filter[name == "method9" && synthetic == false].get(0).returnType)
		assertEquals(1, TypeAdaptionOverride.declaredConstructors.size)
		assertEquals(0, TypeAdaptionOverride.declaredConstructors.get(0).parameterTypes.size)

	}

}
