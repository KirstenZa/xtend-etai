package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.EPFirstNotNullPost
import org.eclipse.xtend.lib.annotation.etai.EPVoidPost
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithInheritanceDerived
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithInheritanceSuperCallTestDerived
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithInheritanceWrapCallTestDerived
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassWithInheritanceBase {

	@ExclusiveMethod
	override void method1() {
		TraitTestsBase.TEST_BUFFER += "1"
	}

	@ExclusiveMethod
	override AdaptionClassBase methodOverridden() {
		null
	}

	@ExclusiveMethod
	override AdaptionClassBase [] methodOverriddenArray() {
		null
	}

}

@TraitClassAutoUsing
abstract class TraitClassWithInheritanceDerived extends TraitClassWithInheritanceBase {

	@ExclusiveMethod
	override void method2() {
		TraitTestsBase.TEST_BUFFER += "2"
	}

	@ExclusiveMethod
	override AdaptionClassDerived methodOverridden() {
		null
	}

	@ExclusiveMethod
	override AdaptionClassDerived [] methodOverriddenArray() {
		null
	}

}

@TraitClassAutoUsing
abstract class TraitClassWithInheritanceDerivedFurther extends TraitClassWithInheritanceDerived {

	@ExclusiveMethod
	override void method2() {
		TraitTestsBase.TEST_BUFFER += "2"
	}

}

@ExtendedByAuto
class ExtendedTraitClassWithInheritanceDerived implements ITraitClassWithInheritanceDerived {
}

@TraitClass
abstract class TraitClassWithInheritanceSuperCallTestBase {

	@ProcessedMethod(processor=EPFirstNotNullPost)
	def protected Integer methodParamProtected(int x, Integer y) {
		TraitTestsBase.TEST_BUFFER += "S" + x + y
		return 1
	}

	@ProcessedMethod(processor=EPFirstNotNullPost)
	override Integer methodParamPublic(int x, Integer y) {
		TraitTestsBase.TEST_BUFFER += "T" + x + y
		return 10
	}

	@ProcessedMethod(processor=EPVoidPost)
	def protected void methodProtected() {
		TraitTestsBase.TEST_BUFFER += "A"
	}

	@ProcessedMethod(processor=EPVoidPost)
	override void methodPublic() {
		TraitTestsBase.TEST_BUFFER += "B"
	}

	@ExclusiveMethod
	def protected void methodProtectedVarArgs(int h, Object ... args) {
		TraitTestsBase.TEST_BUFFER += h + "PRO"
		for (arg : args)
			TraitTestsBase.TEST_BUFFER += arg
	}

}

@TraitClass
abstract class TraitClassWithInheritanceSuperCallTestBetween extends TraitClassWithInheritanceSuperCallTestBase {

	@ProcessedMethod(processor=EPFirstNotNullPost)
	def protected Integer methodParamProtectedBetween(int x) {
		TraitTestsBase.TEST_BUFFER += "M" + x
		return 2
	}

	@ProcessedMethod(processor=EPFirstNotNullPost)
	override Integer methodParamPublicBetween(int x) {
		TraitTestsBase.TEST_BUFFER += "N" + x
		return 12
	}

	@ExclusiveMethod
	override void methodPublicVarArgs(int h, Object ... args) {
		TraitTestsBase.TEST_BUFFER += h + "PUB"
		for (arg : args)
			TraitTestsBase.TEST_BUFFER += arg
	}

}

@TraitClass
abstract class TraitClassWithInheritanceSuperCallTestDerived extends TraitClassWithInheritanceSuperCallTestBetween {

	@ProcessedMethod(processor=EPFirstNotNullPost)
	override protected Integer methodParamProtected(int x, Integer y) {
		return super.methodParamProtected(x + 1, y + 1)
	}

	@ProcessedMethod(processor=EPFirstNotNullPost)
	override Integer methodParamPublic(int x, Integer y) {
		return super.methodParamPublic(x + 1, y + 1)
	}

	@ProcessedMethod(processor=EPVoidPost)
	override protected void methodProtected() {
		super.methodProtected()
		TraitTestsBase.TEST_BUFFER += "X"
	}

	@ProcessedMethod(processor=EPVoidPost)
	override void methodPublic() {
		TraitTestsBase.TEST_BUFFER += "Y"
		super.methodPublic()
	}

	@ProcessedMethod(processor=EPFirstNotNullPost)
	override protected Integer methodParamProtectedBetween(int x) {
		return super.methodParamProtectedBetween(x + 2)
	}

	@ProcessedMethod(processor=EPFirstNotNullPost)
	override Integer methodParamPublicBetween(int x) {
		return super.methodParamPublicBetween(x + 2)
	}

	@ProcessedMethod(processor=EPFirstNotNullPost)
	override void methodVarArgs(int h, Object ... args) {
	}

	@ExclusiveMethod
	override void mixed() {
		super.methodParamPublicBetween(10)
		super.methodProtected()
	}

	@ExclusiveMethod
	override void methodProtectedVarArgs(int h, Object ... args) {
		super.methodProtectedVarArgs(h, args)
	}

	@ExclusiveMethod
	override void methodPublicVarArgs(int h, Object ... args) {
		super.methodPublicVarArgs(h, args)
	}

}

@ExtendedByAuto
class ExtendedClassWithInheritanceSuperCallTest implements ITraitClassWithInheritanceSuperCallTestDerived {

	def Integer methodParamProtected(int x, Integer y) {
		TraitTestsBase.TEST_BUFFER += "X" + x + y
		return null
	}

	override Integer methodParamPublic(int x, Integer y) {
		TraitTestsBase.TEST_BUFFER += "Y" + x + y
		return null
	}

	def void methodProtected() {
		TraitTestsBase.TEST_BUFFER += "E"
	}

	override void methodPublic() {
		TraitTestsBase.TEST_BUFFER += "F"
	}

}

@TraitClass
abstract class TraitClassWithInheritanceWrapCallTestBase {

	@ProcessedMethod(processor=EPVoidPost)
	def protected void methodOnlyInBaseProtected() {
		TraitTestsBase.TEST_BUFFER += "A"
	}

	@ProcessedMethod(processor=EPVoidPost)
	override void methodOnlyInBasePublic() {
		TraitTestsBase.TEST_BUFFER += "B"
	}

}

@TraitClass
abstract class TraitClassWithInheritanceWrapCallTestDerived extends TraitClassWithInheritanceWrapCallTestBase {

	@ProcessedMethod(processor=EPVoidPost)
	override void methodOnlyInBaseProtectedWrap() {
		methodOnlyInBaseProtected
	}

	@ProcessedMethod(processor=EPVoidPost)
	override void methodOnlyInBasePublicWrap() {
		methodOnlyInBasePublic
	}

}

@ExtendedByAuto
class ExtendedClassWithInheritanceWrapCallTest implements ITraitClassWithInheritanceWrapCallTestDerived {

	def void methodOnlyInBaseProtected() {
		TraitTestsBase.TEST_BUFFER += "C"
	}

	override void methodOnlyInBasePublic() {
		TraitTestsBase.TEST_BUFFER += "D"
	}

}

class TraitsInheritanceTests extends TraitTestsBase {

	@Test
	def void testExtensionMultiple() {

		val obj = new ExtendedTraitClassWithInheritanceDerived()
		obj.method1
		obj.method2
		assertEquals("12", TEST_BUFFER)

	}

	@Test
	def void testExtensionOverriding() {

		assertEquals(1, ExtendedTraitClassWithInheritanceDerived.declaredMethods.filter [
			name == "methodOverridden" && synthetic == false
		].size)
		assertSame(AdaptionClassDerived, ExtendedTraitClassWithInheritanceDerived.declaredMethods.filter [
			name == "methodOverridden" && synthetic == false
		].get(0).returnType)

	}

	@Test
	def void testSuperCallInTraitClassTest() {

		val obj = new ExtendedClassWithInheritanceSuperCallTest

		TraitTestsBase.TEST_BUFFER = ""
		obj.methodPublic()
		assertEquals("FYB", TraitTestsBase.TEST_BUFFER)

		TraitTestsBase.TEST_BUFFER = ""
		obj.methodProtected()
		assertEquals("EAX", TraitTestsBase.TEST_BUFFER)

		TraitTestsBase.TEST_BUFFER = ""
		assertEquals(10, obj.methodParamPublic(9, 10))
		assertEquals("Y910T1011", TraitTestsBase.TEST_BUFFER)

		TraitTestsBase.TEST_BUFFER = ""
		assertEquals(1, obj.methodParamProtected(21, 18))
		assertEquals("X2118S2219", TraitTestsBase.TEST_BUFFER)

		TraitTestsBase.TEST_BUFFER = ""
		assertEquals(12, obj.methodParamPublicBetween(9))
		assertEquals("N11", TraitTestsBase.TEST_BUFFER)

		TraitTestsBase.TEST_BUFFER = ""
		assertEquals(2, obj.methodParamProtectedBetween(21))
		assertEquals("M23", TraitTestsBase.TEST_BUFFER)

		TraitTestsBase.TEST_BUFFER = ""
		obj.methodProtectedVarArgs(1, 2, 3, 4)
		assertEquals("1PRO234", TraitTestsBase.TEST_BUFFER)

		TraitTestsBase.TEST_BUFFER = ""
		obj.methodPublicVarArgs(2, 3, 4, 5)
		assertEquals("2PUB345", TraitTestsBase.TEST_BUFFER)

	}

	@Test
	def void testCallInTraitClassTest() {

		val obj = new ExtendedClassWithInheritanceWrapCallTest

		TraitTestsBase.TEST_BUFFER = ""
		obj.methodOnlyInBasePublic
		assertEquals("DB", TraitTestsBase.TEST_BUFFER)

		TraitTestsBase.TEST_BUFFER = ""
		obj.methodOnlyInBaseProtected
		assertEquals("CA", TraitTestsBase.TEST_BUFFER)

		TraitTestsBase.TEST_BUFFER = ""
		obj.methodOnlyInBasePublicWrap
		assertEquals("DB", TraitTestsBase.TEST_BUFFER)

		TraitTestsBase.TEST_BUFFER = ""
		obj.methodOnlyInBaseProtectedWrap
		assertEquals("CA", TraitTestsBase.TEST_BUFFER)

	}

}
