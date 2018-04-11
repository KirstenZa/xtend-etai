package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

class TraitsClassTests extends TraitTestsBase {
	
	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)
	
	@Test
	def void testNoExtensionOfTraitClass() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

import virtual.intf.ITraitClassSimple

@TraitClassAutoUsing
abstract class TraitClassSimple {
}

@ExtendedByAuto
@TraitClassAutoUsing
abstract class TraitClassExtended implements ITraitClassSimple {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.TraitClassExtended")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, allProblems.size)

			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("extended"))

		]

	}

}