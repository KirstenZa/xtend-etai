package org.eclipse.xtend.lib.annotation.etai.tests.extraction

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

class ExtractInterfaceDefaultPackageErrorTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testDefaultPackageErrors() {

		'''

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface

@ExtractInterface
public class MyComponent {}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("MyComponent")

			val problemsClass1 = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass1.size)
			assertEquals(Severity.ERROR, problemsClass1.get(0).severity)
			assertTrue(problemsClass1.get(0).message.contains("default package"))

		]

	}

}
