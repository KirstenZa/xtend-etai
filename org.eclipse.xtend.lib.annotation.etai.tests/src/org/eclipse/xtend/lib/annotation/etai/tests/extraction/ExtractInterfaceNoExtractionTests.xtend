package org.eclipse.xtend.lib.annotation.etai.tests.extraction

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.NoInterfaceExtract
import org.eclipse.xtend.lib.annotation.etai.tests.extraction.intf.IExtractInterfaceTestNoExtraction
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

/**
 * This is a JavaDoc comment.
 */
@ExtractInterface
class ExtractInterfaceTestNoExtraction {

	override void method1() {}

	@NoInterfaceExtract
	def void method2() {}

	static def void method3() {}

}

class ExtractInterfaceTestNoExtractionTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testExtractInterfaceTestNoExtraction() {

		assertEquals(1, IExtractInterfaceTestNoExtraction.declaredMethods.size)
		assertEquals("method1", IExtractInterfaceTestNoExtraction.declaredMethods.get(0).name)

	}

	@Test
	def void testNoExtractionNotAllowedForTraitClasses() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.NoInterfaceExtract

@TraitClassAutoUsing
abstract class AnTraitClass {

	@ExclusiveMethod
	@NoInterfaceExtract
	def void method() {}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.AnTraitClass")

			val problemsMethod = (clazz.findDeclaredMethod("method").primarySourceElement as MethodDeclaration).problems

			// do assertions
			assertEquals(1, problemsMethod.size)
			assertEquals(Severity.ERROR, problemsMethod.get(0).severity)
			assertTrue(problemsMethod.get(0).message.contains("must not be used within trait classes"))

			assertEquals(1, allProblems.size)

		]

	}

	@Test
	def void testNoInterfaceExtractionWrongUsageOnFields() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.NoInterfaceExtract
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface

@ExtractInterface
class ClassWithExtractInterface {

	@NoInterfaceExtract
	int field = 40

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ClassWithExtractInterface')

			val problemsField = (clazz.findDeclaredField("field").primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(1, problemsField.size)
			assertEquals(Severity.ERROR, problemsField.get(0).severity)
			assertTrue(problemsField.get(0).message.contains("only be applied to methods"))

			assertEquals(1, allProblems.size)

		]

	}

}
