package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ImplAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerClassPart
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerTopLevel
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@ApplyRules
class TypeAdaptionMethodParametersSimpleBase {

	def void methodParameterCovariant(
		@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerClassPart)")
		ControllerBase controller
	) {
	}

	@ImplAdaptionRule("apply(return new org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1(null);)")
	def ControllerBase methodParameterContravariant(
		@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase)")
		ControllerClassPart controller
	) {
		return null
	}

	def void methodParameterMultipleCovariant(
		@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerClassPart)")
		ControllerBase controller1,
		@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerTopLevel)")
		ControllerBase controller2
	) {
	}

	@ImplAdaptionRule("apply(return new org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1(null);)")
	static def ControllerBase staticMethodParameterCovariant(
		@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerClassPart)")
		ControllerBase controller
	) {
		return null
	}

	@ImplAdaptionRule("apply(return new org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase(null);)")
	static def ControllerBase staticMethodParameterContravariant(
		@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase)")
		ControllerClassPart controller
	) {
		return null
	}

}

@ApplyRules
class TypeAdaptionMethodParametersSimpleDerived extends TypeAdaptionMethodParametersSimpleBase {
}

@ApplyRules
class TypeAdaptionMethodParametersSimpleDerivedNotImplementedAgain extends TypeAdaptionMethodParametersSimpleDerived {
}

@ApplyRules
class TypeAdaptionMethodParametersFallbackBase {

	public int testValue = 0

	def void myMethod(
		@TypeAdaptionRule("apply(notFound)")
		Integer value
	) {
		testValue = 1
	}

	def void myMethod(
		@TypeAdaptionRule("apply(notFound)")
		Double value
	) {
		testValue = 99
	}

	def void myMethod(
		@TypeAdaptionRule("applyVariable(var.class.simple);replaceAll(TypeAdaptionMethodParametersFallbackDerived,java.lang.Number);replaceAll(Type,NotFound)")
		Object value2
	) {
		testValue = 55
	}

}

@ApplyRules
class TypeAdaptionMethodParametersFallbackDerived extends TypeAdaptionMethodParametersFallbackBase {
}

@ApplyRules
class TypeAdaptionMethodParametersFallbackAnotherDerived extends TypeAdaptionMethodParametersFallbackDerived {
}

class TypeAdaptionMethodParametersTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testParameterCovariance() {

		assertEquals(5, TypeAdaptionMethodParametersSimpleDerived.declaredMethods.size)

		assertSame(ControllerBase, TypeAdaptionMethodParametersSimpleDerived.declaredMethods.filter [
			name == "methodParameterCovariant" && synthetic == false
		].get(0).parameters.get(0).type)

		var boolean exceptionThrown

		val obj = new TypeAdaptionMethodParametersSimpleDerived

		exceptionThrown = false
		try {
			obj.methodParameterCovariant(new ControllerBase(null))
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.methodParameterCovariant(new ControllerAttributeStringConcrete1(null))
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

		// test if it is possible to use with null
		exceptionThrown = false
		try {
			obj.methodParameterCovariant(null)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

	}

	@Test
	def void testParameterCovarianceOtherFile() {

		assertEquals(5, TypeAdaptionMethodParametersSimpleDerivedOtherFile.declaredMethods.size)

		assertSame(ControllerBase, TypeAdaptionMethodParametersSimpleDerivedOtherFile.declaredMethods.filter [
			name == "methodParameterCovariant" && synthetic == false
		].get(0).parameters.get(0).type)

		var boolean exceptionThrown

		val obj = new TypeAdaptionMethodParametersSimpleDerivedOtherFile

		exceptionThrown = false
		try {
			obj.methodParameterCovariant(new ControllerBase(null))
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.methodParameterCovariant(new ControllerAttributeStringConcrete1(null))
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

	}

	@Test
	def void testParameterContravariance() {

		assertEquals(5, TypeAdaptionMethodParametersSimpleDerived.declaredMethods.size)

		assertSame(ControllerClassPart, TypeAdaptionMethodParametersSimpleDerived.declaredMethods.filter [
			name == "methodParameterContravariant" && synthetic == false
		].get(0).parameters.get(0).type)

		val obj = new TypeAdaptionMethodParametersSimpleDerived

		assertSame(ControllerAttributeStringConcrete1,
			obj.methodParameterContravariant(new ControllerAttributeStringConcrete2(null)).class)

	}

	@Test
	def void testParameterStaticCovariance() {

		assertEquals(1, TypeAdaptionMethodParametersSimpleDerived.declaredMethods.filter [
			name == "staticMethodParameterCovariant" && synthetic == false
		].size)
		assertSame(ControllerClassPart, TypeAdaptionMethodParametersSimpleDerived.declaredMethods.filter [
			name == "staticMethodParameterCovariant" && synthetic == false
		].get(0).parameters.get(0).type)

		assertNull(TypeAdaptionMethodParametersSimpleDerived::staticMethodParameterCovariant(new ControllerBase(null)))
		assertSame(ControllerAttributeStringConcrete1,
			TypeAdaptionMethodParametersSimpleDerived::staticMethodParameterCovariant(
				new ControllerAttributeStringConcrete2(null)).class)

	}

	@Test
	def void testParameterStaticContravariance() {

		assertEquals(1, TypeAdaptionMethodParametersSimpleDerived.declaredMethods.filter [
			name == "staticMethodParameterContravariant" && synthetic == false
		].size)
		assertSame(ControllerBase, TypeAdaptionMethodParametersSimpleDerived.declaredMethods.filter [
			name == "staticMethodParameterContravariant" && synthetic == false
		].get(0).parameters.get(0).type)

		assertNull(
			TypeAdaptionMethodParametersSimpleDerived::staticMethodParameterContravariant(
				new ControllerAttributeStringConcrete2(null)))
		assertSame(ControllerBase,
			TypeAdaptionMethodParametersSimpleDerived::staticMethodParameterContravariant(new ControllerBase(null)).
				class)

	}

	@Test
	def void testParameterMultipleCovariance() {

		var boolean exceptionThrown

		val obj = new TypeAdaptionMethodParametersSimpleDerived

		exceptionThrown = false
		try {
			obj.methodParameterMultipleCovariant(new ControllerBase(null), new ControllerTopLevel())
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		exceptionThrown = false
		try {
			obj.methodParameterMultipleCovariant(new ControllerAttributeStringConcrete2(null), new ControllerBase(null))
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		exceptionThrown = false
		try {
			obj.methodParameterMultipleCovariant(new ControllerAttributeStringConcrete2(null), new ControllerTopLevel())
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

	}

	@Test
	def void testTypeAdaptionMethodParametersFallback() {

		var boolean exceptionThrown

		val obj1 = new TypeAdaptionMethodParametersFallbackDerived()

		obj1.myMethod(new Integer(10))
		assertEquals(1, obj1.testValue)

		obj1.myMethod(new Double(20.0))
		assertEquals(99, obj1.testValue)

		obj1.myMethod(new Float(20.0f))
		assertEquals(55, obj1.testValue)

		exceptionThrown = false
		try {
			obj1.myMethod("Test")
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		val obj2 = new TypeAdaptionMethodParametersFallbackAnotherDerived()

		obj2.myMethod(new Integer(10))
		assertEquals(1, obj2.testValue)

		obj2.myMethod(new Double(20.0))
		assertEquals(99, obj2.testValue)

		obj2.myMethod(new Float(20.0f))
		assertEquals(55, obj2.testValue)

		exceptionThrown = false
		try {
			obj2.myMethod("Test")
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

	}

	@Test
	def void testParameterAdaptionAmbiguityError() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule

@ApplyRules
class TypeAdaptionMethodParametersFallbackBase {

	public int testValue = 0

	def void myMethod(
		@TypeAdaptionRule("apply(notFound)")
		Integer value
	) {
		testValue = 1
	}

	def void myMethod(
		@TypeAdaptionRule("applyVariable(var.class.simple);replaceAll(TypeAdaptionMethodParametersFallbackDerived,java.lang.Number);replaceAll(Type,NotFound)")
		Object value
	) {
		testValue = 55
	}

}

@ApplyRules
class TypeAdaptionMethodParametersFallbackDerived extends TypeAdaptionMethodParametersFallbackBase {
}

@ApplyRules
class TypeAdaptionMethodParametersFallbackAnotherDerived extends TypeAdaptionMethodParametersFallbackDerived {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.TypeAdaptionMethodParametersFallbackAnotherDerived')

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("ambiguity"))

			assertEquals(1, allProblems.size)

		]

	}

	@Test
	def void testTypeAdaptionParameterWithGenericsWarning() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule

@ApplyRules
class TypeAdaptionMethodParametersWithGenericsBase {

	def void methodParameterWithGenericsCovariant(
		@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.ControllerWithGenericsTopLevel);addTypeParam(apply(Character));addTypeParam(apply(Integer))")
		org.eclipse.xtend.lib.annotation.etai.tests.adaption.ControllerWithGenericsBase<Integer> controller
	) {
	}

}

@ApplyRules
class TypeAdaptionMethodParametersWithGenericsDerived extends TypeAdaptionMethodParametersWithGenericsBase {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.TypeAdaptionMethodParametersWithGenericsDerived')

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass.size)
			assertEquals(Severity.WARNING, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("type arguments"))

			assertEquals(1, allProblems.size)

		]

	}

	@Test
	def void testNotImplementedUnnecessarily() {

		assertEquals(3, TypeAdaptionMethodParametersSimpleDerivedNotImplementedAgain.declaredMethods.size)
		assertEquals(3, TypeAdaptionMethodParametersSimpleDerivedNotImplementedAgainOtherFile.declaredMethods.size)

	}

}
