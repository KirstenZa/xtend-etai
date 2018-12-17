package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity

import org.junit.Test

import static org.junit.Assert.*

class TraitsInvalidMethodsTests extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testInvalidTraitMethods() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod

@TraitClassAutoUsing
abstract class TraitClassInvalid {

	override void method1() {}

	protected def void method2() {}

	@ExclusiveMethod
	private def void method3() {}

	@ExclusiveMethod
    static def void method4() {}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.TraitClassInvalid")

			val problemsMethod1 = (clazz.findDeclaredMethod("method1").primarySourceElement as MethodDeclaration).
				problems
			val problemsMethod2 = (clazz.findDeclaredMethod("method2").primarySourceElement as MethodDeclaration).
				problems
			val problemsMethod3 = (clazz.findDeclaredMethod("method3").primarySourceElement as MethodDeclaration).
				problems
			val problemsMethod4 = (clazz.findDeclaredMethod("method4").primarySourceElement as MethodDeclaration).
				problems

			// do assertions
			assertEquals(1, problemsMethod1.size)
			assertEquals(Severity.ERROR, problemsMethod1.get(0).severity)
			assertTrue(problemsMethod1.get(0).message.contains("must be a trait method"))

			assertEquals(1, problemsMethod2.size)
			assertEquals(Severity.ERROR, problemsMethod2.get(0).severity)
			assertTrue(problemsMethod2.get(0).message.contains("must be a trait method"))

			assertEquals(1, problemsMethod3.size)
			assertEquals(Severity.ERROR, problemsMethod3.get(0).severity)
			assertTrue(problemsMethod3.get(0).message.contains("must not be declared private"))

			assertEquals(1, problemsMethod4.size)
			assertEquals(Severity.ERROR, problemsMethod4.get(0).severity)
			assertTrue(problemsMethod4.get(0).message.contains("must not be declared static"))

			assertEquals(4, allProblems.size)
			
		]

	}

}
