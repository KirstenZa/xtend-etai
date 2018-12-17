package org.eclipse.xtend.lib.annotation.etai.tests.extraction

import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@ExtractInterface
class ExtractInterfaceRelativeStandardPrefix {
}

@ExtractInterface(name="#I")
class ExtractInterfaceRelativePrefixNoPackage {
}

@ExtractInterface(name="#pack1.")
class ExtractInterfaceRelativePrefixOneSubPackage {
}

@ExtractInterface(name="#pack1.pack2.X")
class ExtractInterfaceRelativePrefixMultipleSubPackages {
}

class ExtractInterfaceRelativePrefixWithInnerClass {

	@ExtractInterface(name="#nopack.Prefix")
	static class InnerClass {
	}

}

@ExtractInterface(name="@pack1.")
class ExtractInterfaceAbsolutePrefixOneSubPackage {
}

@ExtractInterface(name="@pack1.pack2.X")
class ExtractInterfaceAbsolutePrefixMultipleSubPackages {
}

@ExtractInterface(name="pack1.pack2.TheExtractedInterface2")
class ExtractInterfaceAbsoluteMultipleSubPackages {
}

@TraitClass(name="#pack1.I")
abstract class TraitClassIndividualInterfaceName1 {
}

@TraitClassAutoUsing(name="#pack1.I")
abstract class TraitClassIndividualInterfaceName2 {
}

class ExtractInterfaceIndividualNameTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testRelativePrefix() {

		assertNotNull(
			class.classLoader.loadClass(
				"org.eclipse.xtend.lib.annotation.etai.tests.extraction.intf.IExtractInterfaceRelativeStandardPrefix"))
		assertNotNull(
			class.classLoader.loadClass(
				"org.eclipse.xtend.lib.annotation.etai.tests.extraction.IExtractInterfaceRelativePrefixNoPackage"))
		assertNotNull(
			class.classLoader.loadClass(
				"org.eclipse.xtend.lib.annotation.etai.tests.extraction.pack1.ExtractInterfaceRelativePrefixOneSubPackage"))
		assertNotNull(
			class.classLoader.loadClass(
				"org.eclipse.xtend.lib.annotation.etai.tests.extraction.pack1.pack2.XExtractInterfaceRelativePrefixMultipleSubPackages"))
		assertNotNull(
			class.classLoader.loadClass(
				"org.eclipse.xtend.lib.annotation.etai.tests.extraction.ExtractInterfaceRelativePrefixWithInnerClass$PrefixInnerClass"))

	}

	@Test
	def void testAbsolutePrefix() {

		assertNotNull(class.classLoader.loadClass("pack1.ExtractInterfaceAbsolutePrefixOneSubPackage"))
		assertNotNull(class.classLoader.loadClass("pack1.pack2.XExtractInterfaceAbsolutePrefixMultipleSubPackages"))

	}

	@Test
	def void testTraitClass() {

		assertNotNull(class.classLoader.loadClass("org.eclipse.xtend.lib.annotation.etai.tests.extraction.pack1.ITraitClassIndividualInterfaceName1"))
		assertNotNull(class.classLoader.loadClass("org.eclipse.xtend.lib.annotation.etai.tests.extraction.pack1.ITraitClassIndividualInterfaceName2"))

	}

	@Test
	def void testFullyQualified() {

		assertNotNull(class.classLoader.loadClass("pack1.pack2.TheExtractedInterface2"))

	}

	@Test
	def void testDoNotExtractInDefaultPackage() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface

@ExtractInterface(name="@I")
class ExtractInterfaceAbsolutePrefixNoPackage {
}

@ExtractInterface(name="TheExtractedInterface1")
class ExtractInterfaceAbsoluteNoPackage {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz1 = findClass("virtual.ExtractInterfaceAbsolutePrefixNoPackage")
			val clazz2 = findClass("virtual.ExtractInterfaceAbsoluteNoPackage")

			val problemsClass1 = (clazz1.primarySourceElement as ClassDeclaration).problems
			val problemsClass2 = (clazz2.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass1.size)
			assertEquals(Severity.ERROR, problemsClass1.get(0).severity)
			assertTrue(problemsClass1.get(0).message.contains("default package"))
			assertEquals(1, problemsClass2.size)
			assertEquals(Severity.ERROR, problemsClass2.get(0).severity)
			assertTrue(problemsClass2.get(0).message.contains("default package"))

			assertEquals(2, allProblems.size)

		]

	}

}
