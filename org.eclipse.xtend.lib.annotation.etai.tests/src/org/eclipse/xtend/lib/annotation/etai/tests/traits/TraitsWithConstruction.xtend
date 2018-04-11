package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithConstructionBase
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithConstructionDerived
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithConstructionEmptyNonEmptyConstruction
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithConstructionNoConstruction
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithConstructionOnlyEmptyConstruction
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassWithConstructionBase {

	int param = 30
	protected int value = 0

	/**
	 * Construct with Integer parameter.
	 */
	@ConstructorMethod
	protected def void construct(int param) {
		this.param = param
	}

	@ExclusiveMethod
	override int getValue() {
		return value
	}

	@ExclusiveMethod
	override void method1() {
		value += 1
		value += param
	}

}

@TraitClassAutoUsing
abstract class TraitClassWithConstructionDerived extends TraitClassWithConstructionBase {

	int param2 = 40

	@ConstructorMethod
	protected def void construct(int param1, int param2) {
		super.construct(param1)
		this.param2 = param2
	}

	@ExclusiveMethod
	override void method2() {
		value += 2
		value += param2 * 2
	}

}

@TraitClassAutoUsing
abstract class TraitClassWithConstructionEmptyNonEmptyConstruction extends TraitClassWithConstructionBase {

	@ConstructorMethod
	protected def void constructAlternative(String notUsed) {
		super.construct(70)
	}

	@ConstructorMethod
	protected def void construct(double notUsed) {
		super.construct(60)
	}

	@ConstructorMethod
	protected override void construct(int param1) {
		super.construct(param1)
	}

	@ConstructorMethod
	protected def void construct() {
	}

}

@TraitClassAutoUsing
abstract class TraitClassWithConstructionOnlyEmptyConstruction extends TraitClassWithConstructionBase {

	@ConstructorMethod
	protected def void construct() {
		super.construct(50)
	}

}

@TraitClassAutoUsing
abstract class TraitClassWithConstructionNoConstruction extends TraitClassWithConstructionBase {
}

@ExtendedByAuto
class ExtendedClassWithConstruction implements ITraitClassWithConstructionBase {

	new() {
		new$TraitClassWithConstructionBase(10000)
	}

}

@ExtendedByAuto
class ExtendedClassWithConstructionDerived implements ITraitClassWithConstructionDerived {

	new(double x, int y) {
		new$TraitClassWithConstructionDerived(10000, 20000)
	}

}

@ExtendedByAuto
class ExtendedClassWithConstructionEmptyNonEmptyConstruction implements ITraitClassWithConstructionEmptyNonEmptyConstruction {

	new() {
		new$TraitClassWithConstructionEmptyNonEmptyConstruction()
	}

	new(int param1) {
		new$TraitClassWithConstructionEmptyNonEmptyConstruction(param1)
	}

	new(double notUsed) {
		new$TraitClassWithConstructionEmptyNonEmptyConstruction(notUsed)
	}

	new(String notUsed) {
		new$TraitClassWithConstructionEmptyNonEmptyConstruction(notUsed)
	}

	new(Object obj) {
	}

}

@ExtendedByAuto
class ExtendedClassWithConstructionOnlyEmptyConstruction implements ITraitClassWithConstructionOnlyEmptyConstruction {
}

@ExtendedByAuto
class ExtendedClassWithConstructionNoConstruction implements ITraitClassWithConstructionNoConstruction {
}

@ExtendedByAuto
class ExtendedClassWithConstructionNotConstructedCorrectly implements ITraitClassWithConstructionBase {

	new() {
		// do nothing
	}

}

@ExtendedByAuto
class ExtendedClassWithConstructionDoubleConstructed implements ITraitClassWithConstructionBase {

	new() {
		new$TraitClassWithConstructionBase(1)
		new$TraitClassWithConstructionBase(1)
	}

}

class TraitsWithConstructionTests extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testExtensionWithConstruction() {

		val obj = new ExtendedClassWithConstruction()
		obj.method1
		assertEquals(10001, obj.value)

	}

	@Test
	def void testExtensionWithConstructionDerived() {

		val obj = new ExtendedClassWithConstructionDerived(20, 30)
		obj.method1
		assertEquals(10001, obj.value)
		obj.method2
		assertEquals(50003, obj.value)

	}

	@Test
	def void testExtensionWithConstructionNoConstruction() {

		val obj1 = new ExtendedClassWithConstructionNoConstruction()
		obj1.method1
		assertEquals(31, obj1.value)

	}

	@Test
	def void testExtensionWithConstructionEmptyNonEmptyConstruction() {

		val obj1 = new ExtendedClassWithConstructionEmptyNonEmptyConstruction()
		obj1.method1
		assertEquals(31, obj1.value)

		val obj2 = new ExtendedClassWithConstructionEmptyNonEmptyConstruction(40)
		obj2.method1
		assertEquals(41, obj2.value)

		val obj3 = new ExtendedClassWithConstructionEmptyNonEmptyConstruction(40.0)
		obj3.method1
		assertEquals(61, obj3.value)

		val obj4 = new ExtendedClassWithConstructionEmptyNonEmptyConstruction("")
		obj4.method1
		assertEquals(71, obj4.value)

	}

	@Test
	def void testExtensionWithConstructionOnlyEmptyConstruction() {

		val obj1 = new ExtendedClassWithConstructionOnlyEmptyConstruction()
		obj1.method1
		assertEquals(51, obj1.value)

	}

	@Test(expected=AssertionError)
	def void testTraitClassNotConstructedAlternativeExpectError() {

		new ExtendedClassWithConstructionEmptyNonEmptyConstruction(null as Object)

	}

	@Test(expected=AssertionError)
	def void testTraitClassNotConstructedExpectError() {

		new ExtendedClassWithConstructionNotConstructedCorrectly()

	}

	@Test(expected=AssertionError)
	def void testTraitClassDoubleConstructedExpectError() {

		new ExtendedClassWithConstructionDoubleConstructed()

	}

	@Test
	def void testConstructorMethodErrors() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod

@TraitClassAutoUsing
abstract class TraitClassWithConstruction {

	@ConstructorMethod
	final protected def Object construct1() {
	}

	@ConstructorMethod
	final override void construct2() {
	}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.TraitClassWithConstruction")

			val problemsMethod1 = (clazz.findDeclaredMethod("construct1").
				primarySourceElement as MethodDeclaration).problems
			val problemsMethod2 = (clazz.findDeclaredMethod("construct2").
				primarySourceElement as MethodDeclaration).problems

			// do assertions
			assertEquals(1, problemsMethod1.size)
			assertEquals(Severity.ERROR, problemsMethod1.get(0).severity)
			assertTrue(problemsMethod1.get(0).message.contains("void"))

			assertEquals(1, problemsMethod2.size)
			assertEquals(Severity.ERROR, problemsMethod2.get(0).severity)
			assertTrue(problemsMethod2.get(0).message.contains("protected"))

		]

	}

}
