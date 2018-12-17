package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribute
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@ApplyRules
abstract class TypeAdaptionAlternative {

	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribut);alternative(append(e))")
	def ControllerBase a1() {
		return null;
	}

	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribu);alternative(append(t);append(e))")
	def ControllerBase a2() {
		return null;
	}

	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribu);alternative(append(t));alternative(append(e))")
	def ControllerBase a3() {
		return null;
	}

	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribute);alternative(append(X))")
	def ControllerBase a4() {
		return null;
	}

	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribut);alternative(append(X))")
	def ControllerBase a5() {
		return null;
	}

}

@ApplyRules
class TypeAdaptionAlternativeDerived extends TypeAdaptionAlternative {
}

class TypeAdaptionAlternativeTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testTypeAdaptionAlternative() {

		val declaredMethods = TypeAdaptionAlternativeDerived.declaredMethods.filter[synthetic == false]

		assertEquals(1, declaredMethods.filter[
			name == "a1"
		].size)
		assertSame(ControllerAttribute, declaredMethods.filter[name == "a1"].get(0).returnType)
		assertEquals(1, declaredMethods.filter[
			name == "a2"
		].size)
		assertSame(ControllerAttribute, declaredMethods.filter[name == "a2"].get(0).returnType)
		assertEquals(1, declaredMethods.filter[
			name == "a3"
		].size)
		assertSame(ControllerAttribute, declaredMethods.filter[name == "a3"].get(0).returnType)
		assertEquals(1, declaredMethods.filter[
			name == "a4"
		].size)
		assertSame(ControllerAttribute, declaredMethods.filter[name == "a4"].get(0).returnType)
		assertEquals(0, declaredMethods.filter[
			name == "a5"
		].size)

	}

	@Test
	def void testTypeAdaptionAlternativeErrors() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule

@ApplyRules
abstract class TypeAdaptionAlternative {

	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.ControllerAttribu);alternative(append(t));append(e)")
	def ControllerBase a1() {
		return null;
	}

	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.ControllerAttribu);alternative(append(t);alternative(append(e)))")
	def ControllerBase a2() {
		return null;
	}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.TypeAdaptionAlternative")

			val problemsMethod1 = (clazz.findDeclaredMethod("a1").primarySourceElement as MethodDeclaration).problems
			val problemsMethod2 = (clazz.findDeclaredMethod("a2").primarySourceElement as MethodDeclaration).problems

			// do assertions
			assertEquals(Severity.ERROR, problemsMethod1.get(0).severity)
			assertTrue(problemsMethod1.get(0).message.contains("end"))
			assertEquals(Severity.ERROR, problemsMethod2.get(0).severity)
			assertTrue(problemsMethod2.get(0).message.contains("inside"))

			assertEquals(2, allProblems.size)

		]

	}

}
