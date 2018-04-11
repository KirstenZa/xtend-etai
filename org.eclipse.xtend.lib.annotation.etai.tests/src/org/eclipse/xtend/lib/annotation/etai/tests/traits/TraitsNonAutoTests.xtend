package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.EPOverride
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedBy
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassSimpleMethod0
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassSimpleMethod1
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassSimpleMethod23
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassSimpleMethod4
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassSimpleMethod0 {

	@ExclusiveMethod
	override int method0() {
		0
	}

}

@TraitClassAutoUsing
abstract class TraitClassSimpleMethod1 {

	@ExclusiveMethod
	override int method1() {
		1
	}

}

@TraitClassAutoUsing
abstract class TraitClassSimpleMethod23 {

	@ExclusiveMethod
	override int method2() {
		2
	}

	@ProcessedMethod(processor=EPOverride)
	override int method3() {
		3
	}

}

@TraitClass(using=#[TraitClassSimpleMethod0, TraitClassSimpleMethod1])
abstract class TraitClassSimpleMethod4 implements ITraitClassSimpleMethod0, ITraitClassSimpleMethod23, ITraitClassSimpleMethod1 {

	@ExclusiveMethod
	override int method4() {
		4
	}

}

@ExtendedBy(TraitClassSimpleMethod0, TraitClassSimpleMethod1)
class ExtendedNonAuto implements ITraitClassSimpleMethod0, ITraitClassSimpleMethod1, ITraitClassSimpleMethod23 {

	override int method2() {
		12
	}

	override int method3() {
		13
	}

}

@ExtendedByAuto
class ExtendedCheckNonAutoUsing implements ITraitClassSimpleMethod4 {

	override int method2() {
		12
	}

	override int method3() {
		13
	}

}

class TraitsNonAutoTests extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testExtendedNonAuto() {

		val obj = new ExtendedNonAuto

		assertEquals(0, obj.method0)
		assertEquals(1, obj.method1)
		assertEquals(12, obj.method2)
		assertEquals(13, obj.method3)

	}
	
	@Test
	def void testExtendedNonAutoUsing() {

		val obj = new ExtendedCheckNonAutoUsing

		assertEquals(0, obj.method0)
		assertEquals(1, obj.method1)
		assertEquals(12, obj.method2)
		assertEquals(13, obj.method3)
		assertEquals(4, obj.method4)

	}

	@Test
	def void testExtendedByNoTraitClass() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.ExtendedBy

import virtual.intf.INotAnTraitClass

@ExtractInterface
abstract class NotAnTraitClass {
}

@ExtendedBy(NotAnTraitClass)
abstract class AnExtendedClass implements INotAnTraitClass {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.AnExtendedClass")

			val localProblems = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, allProblems.size)

			assertEquals(1, localProblems.size)
			assertEquals(Severity.ERROR, localProblems.get(0).severity)
			assertTrue(localProblems.get(0).message.contains("not a trait class"))

		]

	}
	

	@Test
	def void testExtendedByCannotMixAutoWithNonAuto() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ExtendedBy
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

import virtual.intf.IExtensionNonAuto

@TraitClassAutoUsing
abstract class ExtensionNonAuto {
}

@ExtendedBy(ExtensionNonAuto)
@ExtendedByAuto
abstract class ExtendedNonAuto implements IExtensionNonAuto {
}


		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedNonAuto")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, allProblems.size)

			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("apply both"))

		]

	}

	@Test
	def void testExtendedByNeedsInterface() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtendedBy
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

@TraitClassAutoUsing
abstract class ExtensionNonAuto {
}

@ExtendedBy(ExtensionNonAuto)
abstract class ExtendedNonAuto {
}


		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedNonAuto")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, allProblems.size)

			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("interface"))

		]

	}

	@Test
	def void testTraitClassCannotMixUsingAutoWithNonAuto() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

import virtual.intf.IExtensionUsed

@TraitClass
abstract class ExtensionUsed {
}

@TraitClass(using=ExtensionUsed)
@TraitClassAutoUsing
abstract class ExtensionNonAuto implements IExtensionUsed {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtensionNonAuto")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("apply both"))

		]

	}

	@Test
	def void testTraitClassNeedsInterface() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.ExtendedBy

import virtual.intf.IExtensionNonAuto

@TraitClass
abstract class ExtensionUsed {
}

@TraitClass(using=ExtensionUsed)
abstract class ExtensionNonAuto {
}

@ExtendedBy(ExtensionNonAuto)
abstract class ExtendedNonAuto implements IExtensionNonAuto {
}


		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtensionNonAuto")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, allProblems.size)
			
			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("interface"))

		]

	}
	
	@Test
	def void testExtensionAtLeastOne() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.ExtendedBy
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto

import virtual.intf.IExtensionNonAuto

@TraitClass
abstract class ExtensionNonAuto {
}

@ExtendedBy
abstract class ExtendedNone1 implements IExtensionNonAuto {
}

@ExtendedByAuto
abstract class ExtendedNone2 {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz1 = findClass("virtual.ExtendedNone1")
			val clazz2 = findClass("virtual.ExtendedNone2")

			val problemsClass1 = (clazz1.primarySourceElement as ClassDeclaration).problems
			val problemsClass2 = (clazz2.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(2, allProblems.size)
			
			assertEquals(1, problemsClass1.size)
			assertEquals(Severity.ERROR, problemsClass1.get(0).severity)
			assertTrue(problemsClass1.get(0).message.contains("at least one"))

			assertEquals(1, problemsClass2.size)
			assertEquals(Severity.ERROR, problemsClass2.get(0).severity)
			assertTrue(problemsClass2.get(0).message.contains("at least one"))

		]

	}
	
	@Test
	def void testTraitClassWrongSpecificationOrder() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.ExtendedBy

import virtual.intf.IExtensionNonAuto1
import virtual.intf.IExtensionNonAuto2
import virtual.intf.IExtensionNonAuto3
import virtual.intf.IExtensionUsed1
import virtual.intf.IExtensionUsed2

@TraitClass
abstract class ExtensionUsed1 {
}

@TraitClass
abstract class ExtensionUsed2 {
}

@TraitClass(using=#[ExtensionUsed1, ExtensionUsed2])
abstract class ExtensionNonAuto1 implements IExtensionUsed2, IExtensionUsed1 {
}

@TraitClass
abstract class ExtensionNonAuto2 {
}

@TraitClass
abstract class ExtensionNonAuto3 {
}

@ExtendedBy(ExtensionNonAuto1, ExtensionNonAuto2)
abstract class ExtendedNonAuto implements IExtensionNonAuto2, IExtensionNonAuto1 {
}

@ExtendedBy(ExtensionNonAuto3)
abstract class ExtendedNonAutoDerived extends ExtendedNonAuto implements IExtensionNonAuto3 {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz1 = findClass("virtual.ExtensionNonAuto1")
			val clazz2 = findClass("virtual.ExtendedNonAuto")

			val problemsClass1 = (clazz1.primarySourceElement as ClassDeclaration).problems
			val problemsClass2 = (clazz2.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(2, allProblems.size)
			
			assertEquals(1, problemsClass1.size)
			assertEquals(Severity.ERROR, problemsClass1.get(0).severity)
			assertTrue(problemsClass1.get(0).message.contains("order"))

			assertEquals(1, problemsClass2.size)
			assertEquals(Severity.ERROR, problemsClass2.get(0).severity)
			assertTrue(problemsClass2.get(0).message.contains("order"))

		]

	}

}
