/**
 * Test passes, if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassRequiredFlag
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassRequiredFlag {

	@ProcessedMethod(processor=EPVoidPre)
	override void method1() {}

	@ProcessedMethod(processor=EPVoidPre, required=true)
	override void method2() {}

	@EnvelopeMethod(required=false)
	override void method3() {}

	@EnvelopeMethod
	override void method4() {}

}

@ExtendedByAuto
class ExtendedClassRequiredFlag implements ITraitClassRequiredFlag {

	override void method2() {}

	override void method4() {}

}

class ExtendedClassRequiredFlagBase {

	def void method2() {}

	def void method4() {}

}

@ExtendedByAuto
class ExtendedClassRequiredFlagFromBase extends ExtendedClassRequiredFlagBase implements ITraitClassRequiredFlag {
}

class RequiredFlagTests extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testMissingRequired() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod

import virtual.intf.ITraitClassRequiredFlag

@TraitClassAutoUsing
abstract class TraitClassRequiredFlag {

	@ProcessedMethod(processor=EPVoidPre)
	override void method1() {}

	@ProcessedMethod(processor=EPVoidPre, required=true)
	override void method2() {}

	@EnvelopeMethod(required=false)
	override void method3() {}

	@EnvelopeMethod
	override void method4() {}

}

@ExtendedByAuto
class ExtendedClassRequiredFlagMissing implements ITraitClassRequiredFlag {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedClassRequiredFlagMissing")

			val clazzProblems = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(2, allProblems.size)
			assertEquals(2, clazzProblems.size)
			assertEquals(Severity.ERROR, clazzProblems.get(0).severity)
			var List<String> errorList = new ArrayList<String>
			errorList.add(clazzProblems.get(0).message)
			errorList.add(clazzProblems.get(1).message)
			errorList = errorList.sort
			assertTrue(errorList.get(0).contains("method2"))
			assertTrue(errorList.get(1).contains("method4"))

		]

	}

}
