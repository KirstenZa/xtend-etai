package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ConstructRuleAuto
import org.eclipse.xtend.lib.annotation.etai.ConstructRuleDisable
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithConstructorSimple1
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithConstructorSimple2
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithConstructorSimple3
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithConstructorUsingSimple1
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassWithConstructorSimple1 {

	int w

	@ConstructorMethod
	protected def void construct(int w) {
		this.w = w
	}

	@ConstructorMethod
	protected def void construct(int w, String doubleW) {
		construct(w * 2)
	}

	@ExclusiveMethod
	override int getW() {
		w
	}

}

@TraitClassAutoUsing
abstract class TraitClassWithConstructorSimple2 {

	int x

	@ConstructorMethod
	protected def void construct(int x) {
		this.x = x
	}

	@ExclusiveMethod
	override int getX() {
		x
	}

}

@TraitClassAutoUsing
abstract class TraitClassWithConstructorSimple3 {

	int y

	@ConstructorMethod
	protected def void construct(int y) {
		this.y = y
	}

	@ConstructorMethod
	protected def void construct(int y, String tripleY) {
		construct(y * 3)
	}

	@ExclusiveMethod
	override int getY() {
		y
	}

}

@ApplyRules
@ExtendedByAuto
@ConstructRuleAuto
@FactoryMethodRule
class ExtendedClassConstructEnable implements ITraitClassWithConstructorSimple1, ITraitClassWithConstructorSimple2, ITraitClassWithConstructorSimple3 {

	int z

	new(int z) {
		this.z = z
	}

	def int getZ() {
		z
	}

}

@ApplyRules
@ConstructRuleDisable(TraitClassWithConstructorSimple1, TraitClassWithConstructorSimple2)
class ExtendedClassConstructDisable extends ExtendedClassConstructEnable {

	new(int z) {
		super(z)
		this.auto$new$TraitClassWithConstructorSimple1(88, "do double")
		this.auto$new$TraitClassWithConstructorSimple2(99)
	}

	new() {
		super(10)
		this.auto$new$TraitClassWithConstructorSimple1(1)
		this.auto$new$TraitClassWithConstructorSimple2(16)
	}

}

@ApplyRules
class ExtendedClassConstructDisableDerived extends ExtendedClassConstructDisable {

	new() {
		super(77)
	}

}

@ApplyRules
@ConstructRuleDisable(TraitClassWithConstructorSimple2)
class ExtendedClassConstructDisableWithoutManualConstruction extends ExtendedClassConstructEnable {

	new(int z) {
		super(z)
	}

}

@TraitClassAutoUsing
abstract class TraitClassWithConstructorUsingSimple1 implements ITraitClassWithConstructorSimple1 {

	String str1

	@ConstructorMethod
	protected def void construct(String str1) {
		this.str1 = str1
	}

	@ExclusiveMethod
	override String getStr1() {
		return str1
	}

}

@ApplyRules
@ExtendedByAuto
@ConstructRuleAuto
@FactoryMethodRule
class ExtendedClassWithConstructorUsingSimple1 implements ITraitClassWithConstructorUsingSimple1 {
}

@ApplyRules
@ConstructRuleDisable(TraitClassWithConstructorSimple1)
class ExtendedClassWithConstructorUsingSimple1Derived extends ExtendedClassWithConstructorUsingSimple1 {

	new() {
		auto$new$TraitClassWithConstructorSimple1(1)
	}

}

class TraitsConstructDisableTests extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testTraitClassAutoConstructDisable() {

		assertEquals(4, ExtendedClassConstructDisable.declaredMethods.filter[name.startsWith("create")].size)
		assertEquals(2, ExtendedClassConstructDisableDerived.declaredMethods.filter[name.startsWith("create")].size)
		assertEquals(4, ExtendedClassConstructDisableWithoutManualConstruction.declaredMethods.filter [
			name.startsWith("create")
		].size)

		val obj1 = ExtendedClassConstructDisable.createExtendedClassConstructDisable(111)
		assertEquals(1, obj1.w)
		assertEquals(16, obj1.x)
		assertEquals(111, obj1.y)
		assertEquals(10, obj1.z)

		val obj2 = ExtendedClassConstructDisable.createExtendedClassConstructDisable(111, "")
		assertEquals(1, obj2.w)
		assertEquals(16, obj2.x)
		assertEquals(333, obj2.y)
		assertEquals(10, obj2.z)

		val obj3 = ExtendedClassConstructDisable.createExtendedClassConstructDisable(111, 198)
		assertEquals(176, obj3.w)
		assertEquals(99, obj3.x)
		assertEquals(198, obj3.y)
		assertEquals(111, obj3.z)

		val obj4 = ExtendedClassConstructDisable.createExtendedClassConstructDisable(111, 198, "")
		assertEquals(176, obj4.w)
		assertEquals(99, obj4.x)
		assertEquals(594, obj4.y)
		assertEquals(111, obj4.z)

		val obj5 = ExtendedClassConstructDisableDerived.createExtendedClassConstructDisableDerived(111)
		assertEquals(176, obj5.w)
		assertEquals(99, obj5.x)
		assertEquals(111, obj5.y)
		assertEquals(77, obj5.z)

		val obj6 = ExtendedClassConstructDisableDerived.createExtendedClassConstructDisableDerived(111, "")
		assertEquals(176, obj6.w)
		assertEquals(99, obj6.x)
		assertEquals(333, obj6.y)
		assertEquals(77, obj6.z)

	}

	@Test
	def void testTraitClassAutoConstructDisableUsingContext() {

		assertEquals(1, ExtendedClassWithConstructorUsingSimple1Derived.declaredMethods.filter [
			name.startsWith("create")
		].size)

		val obj = ExtendedClassWithConstructorUsingSimple1Derived.
			createExtendedClassWithConstructorUsingSimple1Derived("mystr")
		assertEquals("mystr", obj.str1)
		assertEquals(1, obj.w)

	}

	@Test(expected=AssertionError)
	def void testTraitClassAutoConstructDisableCreationCheck() {

		ExtendedClassConstructDisableWithoutManualConstruction.
			createExtendedClassConstructDisableWithoutManualConstruction(1, 2, 3)

	}

	@Test
	def void testAutoConstructContext() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ConstructRuleDisable
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

@TraitClassAutoUsing
abstract class TraitClassNoAutoConstruct {	
}

@ConstructRuleDisable(TraitClassNoAutoConstruct)
class ExtendedClassNoExtension {

	new() {
	}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedClassNoExtension")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(2, allProblems.size)

			assertEquals(2, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.map[message].exists[it.contains("@ApplyRules")])
			assertEquals(Severity.ERROR, problemsClass.get(1).severity)
			assertTrue(problemsClass.map[message].exists[it.contains("cannot be disabled")])

		]

	}

}
