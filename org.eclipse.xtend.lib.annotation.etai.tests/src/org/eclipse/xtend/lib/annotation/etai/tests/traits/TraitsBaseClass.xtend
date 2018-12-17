package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedBy
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassExtendingBaseClass
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassUsingBase
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassUsingBaseDerived
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassUsingExtended
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitBaseClass

interface TraitBaseInterface {

	/**
	 * This is the description of the method in ExtensionBaseInterface
	 */
	def void method3()

	def int method5()

}

@TraitClassAutoUsing(baseClass=true)
abstract class TraitBaseClass implements TraitBaseInterface {

	@RequiredMethod
	abstract protected def void method4()

	@ExclusiveMethod
	override void method1() {
		TraitTestsBase.TEST_BUFFER += "1"
		method4
	}

	@ExclusiveMethod
	override int method5() {
		TraitTestsBase.TEST_BUFFER += "5"
		return 5
	}

}

@TraitClassAutoUsing
abstract class TraitClassExtendingBaseClass extends TraitBaseClass {

	@ExclusiveMethod
	override void method2() {
		TraitTestsBase.TEST_BUFFER += "2"
	}

	@ExclusiveMethod
	protected override void method4() {
		TraitTestsBase.TEST_BUFFER += "4"
	}

}

@ExtendedByAuto
class ExtendedClassExtendingWithBaseClassUsage implements ITraitClassExtendingBaseClass {
	
	override method3() {
		TraitTestsBase.TEST_BUFFER += "3"
	}

}

// test the "usage" of base classes
@TraitClass(using=TraitBaseClass)
abstract class TraitClassUsingBase implements ITraitBaseClass {

	@ExclusiveMethod
	override void method3() {
		TraitTestsBase.TEST_BUFFER += "Z"
	}

	@ExclusiveMethod
	override void methodX() {
		TraitTestsBase.TEST_BUFFER += "X"
	}

}

@TraitClass(using=TraitClassExtendingBaseClass)
abstract class TraitClassUsingBaseDerived extends TraitClassUsingBase implements ITraitClassExtendingBaseClass {

	@ExclusiveMethod
	override void methodY() {
		TraitTestsBase.TEST_BUFFER += "Y"
	}

}

@TraitClass(using=TraitClassExtendingBaseClass)
abstract class TraitClassUsingExtended implements ITraitClassExtendingBaseClass {

	@ExclusiveMethod
	override void methodY() {
		TraitTestsBase.TEST_BUFFER += "Y"
	}

}

@ExtendedBy(TraitClassUsingBaseDerived)
class ExtendedClassUsingBaseAndDerivedByDerivation implements ITraitClassUsingBaseDerived {
}

@ExtendedBy(TraitClassUsingBase, TraitClassUsingExtended)
class ExtendedClassUsingBaseAndDerivedLR implements ITraitClassUsingBase, ITraitClassUsingExtended {
}

@ExtendedBy(TraitClassUsingExtended, TraitClassUsingBase)
class ExtendedClassUsingBaseAndDerivedRL implements ITraitClassUsingExtended, ITraitClassUsingBase {
}

@ExtendedBy(TraitClassUsingBase, TraitClassExtendingBaseClass)
class ExtendedClassUsingBaseAndDerivedDirectLR implements ITraitClassUsingBase, ITraitClassExtendingBaseClass {
}

@ExtendedBy(TraitClassExtendingBaseClass, TraitClassUsingBase)
class ExtendedClassUsingBaseAndDerivedDirectRL implements ITraitClassExtendingBaseClass, ITraitClassUsingBase {
}

class ExtendedBaseClassTests extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testTraitBaseClass() {

		val obj = new ExtendedClassExtendingWithBaseClassUsage
		obj.method1
		obj.method2
		obj.method3
		obj.method5
		assertEquals("14235", TEST_BUFFER);

	}

	@Test
	def void testUsageOfTraitBaseClass() {

		{
			TraitTestsBase.TEST_BUFFER = ""
			val obj = new ExtendedClassUsingBaseAndDerivedByDerivation
			obj.method1
			obj.method2
			obj.method3
			obj.method5
			obj.methodX
			obj.methodY
			assertEquals("142Z5XY", TEST_BUFFER)
		}

		{
			TraitTestsBase.TEST_BUFFER = ""
			val obj = new ExtendedClassUsingBaseAndDerivedLR
			obj.method1
			obj.method2
			obj.method3
			obj.method5
			obj.methodX
			obj.methodY
			assertEquals("142Z5XY", TEST_BUFFER)
		}

		{
			TraitTestsBase.TEST_BUFFER = ""
			val obj = new ExtendedClassUsingBaseAndDerivedRL
			obj.method1
			obj.method2
			obj.method3
			obj.method5
			obj.methodX
			obj.methodY
			assertEquals("142Z5XY", TEST_BUFFER)
		}

		{
			TraitTestsBase.TEST_BUFFER = ""
			val obj = new ExtendedClassUsingBaseAndDerivedDirectLR
			obj.method1
			obj.method2
			obj.method3
			obj.method5
			obj.methodX
			assertEquals("142Z5X", TEST_BUFFER)
		}

		{
			TraitTestsBase.TEST_BUFFER = ""
			val obj = new ExtendedClassUsingBaseAndDerivedDirectRL
			obj.method1
			obj.method2
			obj.method3
			obj.method5
			obj.methodX
			assertEquals("142Z5X", TEST_BUFFER)
		}

	}

	@Test
	def void testInvalidApplicationOfTraitBaseClass() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExtendedBy
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto

import virtual.intf.IMyTraitBaseClass
import virtual.intf.IMyTraitBaseClassWithAutoUsing
import virtual.intf.IMyTraitClassAutoUsing
import virtual.intf.IMyTraitClassAutoUsingTwice
import virtual.intf.IMyTraitClassNoUsing

@TraitClass(baseClass=true)
abstract class MyTraitBaseClass {
}

@TraitClassAutoUsing(baseClass=true)
abstract class MyTraitBaseClassWithAutoUsing {
}

@TraitClassAutoUsing
abstract class MyTraitClassAutoUsing implements IMyTraitBaseClass {
}

@TraitClassAutoUsing
abstract class MyTraitClassAutoUsingTwice implements IMyTraitBaseClassWithAutoUsing {
}

// will not cause error, because (base) trait class not specified explicitly
@TraitClass
abstract class MyTraitClassNoUsing implements IMyTraitClassAutoUsingTwice {
}

@ExtendedByAuto
class MyExtendedClassExtendingBaseClass1 implements IMyTraitBaseClass {
}

@ExtendedByAuto
class MyExtendedClassExtendingBaseClass2 implements IMyTraitBaseClassWithAutoUsing {
}

@ExtendedByAuto
class MyExtendedClassExtendingBaseClass3 implements IMyTraitClassAutoUsing {
}

@ExtendedBy(MyTraitClassAutoUsing)
class MyExtendedClassExtendingBaseClass4 implements IMyTraitClassAutoUsing {
}

@ExtendedByAuto
class MyExtendedClassExtendingBaseClass5 implements IMyTraitClassAutoUsingTwice {
}

@ExtendedBy(MyTraitClassNoUsing)
class MyExtendedClassExtendingBaseClass6 implements IMyTraitClassNoUsing, IMyTraitBaseClass {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazzB1 = findClass("virtual.MyTraitBaseClass")
			val clazzB2 = findClass("virtual.MyTraitBaseClassWithAutoUsing")
			val clazzB3 = findClass("virtual.MyTraitClassAutoUsing")
			val clazzB4 = findClass("virtual.MyTraitClassAutoUsingTwice")
			val clazzB5 = findClass("virtual.MyTraitClassNoUsing")

			val clazz1 = findClass("virtual.MyExtendedClassExtendingBaseClass1")
			val clazz2 = findClass("virtual.MyExtendedClassExtendingBaseClass2")
			val clazz3 = findClass("virtual.MyExtendedClassExtendingBaseClass3")
			val clazz4 = findClass("virtual.MyExtendedClassExtendingBaseClass4")
			val clazz5 = findClass("virtual.MyExtendedClassExtendingBaseClass5")
			val clazz6 = findClass("virtual.MyExtendedClassExtendingBaseClass6")

			val clazzProblemsB1 = (clazzB1.primarySourceElement as ClassDeclaration).problems
			val clazzProblemsB2 = (clazzB2.primarySourceElement as ClassDeclaration).problems
			val clazzProblemsB3 = (clazzB3.primarySourceElement as ClassDeclaration).problems
			val clazzProblemsB4 = (clazzB4.primarySourceElement as ClassDeclaration).problems
			val clazzProblemsB5 = (clazzB5.primarySourceElement as ClassDeclaration).problems

			val clazzProblems1 = (clazz1.primarySourceElement as ClassDeclaration).problems
			val clazzProblems2 = (clazz2.primarySourceElement as ClassDeclaration).problems
			val clazzProblems3 = (clazz3.primarySourceElement as ClassDeclaration).problems
			val clazzProblems4 = (clazz4.primarySourceElement as ClassDeclaration).problems
			val clazzProblems5 = (clazz5.primarySourceElement as ClassDeclaration).problems
			val clazzProblems6 = (clazz6.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(0, clazzProblemsB1.size)
			assertEquals(0, clazzProblemsB2.size)
			assertEquals(0, clazzProblemsB3.size)
			assertEquals(0, clazzProblemsB4.size)
			assertEquals(0, clazzProblemsB5.size)

			assertEquals(1, clazzProblems1.size)
			assertEquals(Severity.ERROR, clazzProblems1.get(0).severity)
			assertTrue(clazzProblems1.get(0).message.contains("is a trait base class"))

			assertEquals(1, clazzProblems2.size)
			assertEquals(Severity.ERROR, clazzProblems2.get(0).severity)
			assertTrue(clazzProblems2.get(0).message.contains("is a trait base class"))

			assertEquals(1, clazzProblems3.size)
			assertEquals(Severity.ERROR, clazzProblems3.get(0).severity)
			assertTrue(clazzProblems3.get(0).message.contains("is a trait base class"))

			assertEquals(1, clazzProblems4.size)
			assertEquals(Severity.ERROR, clazzProblems4.get(0).severity)
			assertTrue(clazzProblems4.get(0).message.contains("is a trait base class"))

			assertEquals(1, clazzProblems5.size)
			assertEquals(Severity.ERROR, clazzProblems5.get(0).severity)
			assertTrue(clazzProblems5.get(0).message.contains("is a trait base class"))

			assertEquals(0, clazzProblems6.size)

			assertEquals(5, allProblems.size)

		]

	}

}
