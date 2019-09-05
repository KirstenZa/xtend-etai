package org.eclipse.xtend.lib.annotation.etai.tests.traits

import java.lang.reflect.Modifier
import java.util.List
import org.eclipse.xtend.lib.annotation.etai.EPVoidPost
import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TraitClassProcessor
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.IExtendedClassNonPublic
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassNonPublic
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassNonPublicImplementRequired
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassNonPublicImplementRequiredNonBase
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassNonPublicUsingImplementRequired
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithProtectedMethodAndGenericParameter
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithProtectedMethodAndGenericParameterObjectFromClass
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithProtectedMethodAndGenericParameterStringFromClass
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassNonPublic {

	@ProcessedMethod(processor=EPVoidPre)
	protected def void extendedMethodUsed() {
		TraitTestsBase::TEST_BUFFER += "1"
	}

	@ExclusiveMethod
	protected def void method1() {
		extendedMethodUsed
		TraitTestsBase::TEST_BUFFER += "A"
	}

	@ProcessedMethod(processor=EPVoidPre)
	protected def void method2() {
		extendedMethodUsed
		TraitTestsBase::TEST_BUFFER += "B"
	}

	@ProcessedMethod(processor=EPVoidPre)
	protected def void method3() {
		extendedMethodUsed
		TraitTestsBase::TEST_BUFFER += "C"
	}

	@ProcessedMethod(processor=EPVoidPre)
	override void method4() {
		extendedMethodUsed
		TraitTestsBase::TEST_BUFFER += "D"
	}

	@RequiredMethod
	protected def void methodRequired()

}

@ExtendedByAuto
@ExtractInterface
class ExtendedClassNonPublic implements ITraitClassNonPublic {

	protected def void extendedMethodUsed() {
		TraitTestsBase::TEST_BUFFER += "2"
	}

	protected def void method2() {
		extendedMethodUsed
		TraitTestsBase::TEST_BUFFER += "X"
	}

	override void method3() {
		extendedMethodUsed
		TraitTestsBase::TEST_BUFFER += "Y"
	}

	protected override void method4() {
		extendedMethodUsed
		TraitTestsBase::TEST_BUFFER += "Z"
	}

	override void method1PublicAccess() {
		method1()
	}

	override void method2PublicAccess() {
		method2()
	}

	override void methodRequired() {
	}

}

abstract class ExtendedClassCheckIncreaseVisibilityBase {
	abstract def void method2()

	def void method3() {}

	protected def void method4() {}
}

interface ExtendedClassCheckIncreaseVisibilityInterface {
	def void method1()
}

@ExtendedByAuto
class ExtendedClassCheckIncreaseVisibility extends ExtendedClassCheckIncreaseVisibilityBase implements ExtendedClassCheckIncreaseVisibilityInterface, ITraitClassNonPublic {

	def void methodRequired() {
	}

}

// test (protected) required method that is implemented by derived trait class
@TraitClassAutoUsing(baseClass=true)
abstract class TraitClassNonPublicBase {

	@ExclusiveMethod
	protected def int method1() {
		return 1
	}

	@RequiredMethod
	protected def void methodRequired()

}

@TraitClassAutoUsing(baseClass=true)
abstract class TraitClassNonPublicImplementRequiredBase extends TraitClassNonPublicBase {

	@ExclusiveMethod
	protected override void methodRequired() {

		TraitTestsBase::TEST_BUFFER += "I"

	}

}

@TraitClassAutoUsing
abstract class TraitClassNonPublicImplementRequiredNonBase extends TraitClassNonPublicImplementRequiredBase {
}

@TraitClassAutoUsing
abstract class TraitClassNonPublicImplementRequired extends TraitClassNonPublicBase {

	@ExclusiveMethod
	protected override void methodRequired() {

		TraitTestsBase::TEST_BUFFER += "I"

	}

}

@TraitClassAutoUsing
abstract class TraitClassNonPublicUsingImplementRequired implements ITraitClassNonPublicImplementRequired {
}

@ExtendedByAuto
class ExtendedClassNonPublicImplementRequired implements ITraitClassNonPublicImplementRequired {
}

@ExtendedByAuto
class ExtendedClassNonPublicUsingImplementRequired implements ITraitClassNonPublicUsingImplementRequired {
}

@ExtendedByAuto
class ExtendedClassNonPublicImplementRequiredCheckBaseNonBase implements ITraitClassNonPublicImplementRequiredNonBase {
}

@TraitClass
abstract class TraitClassWithProtectedMethodAndGenericParameter {

	@ProcessedMethod(processor=EPVoidPost)
	protected def void myMethod(List<?> anotherNameForObjs) {
		TraitTestsBase::TEST_BUFFER += anotherNameForObjs.get(1)
	}

	@ExclusiveMethod
	override void start(List<?> objs) {
		myMethod(objs)
	}

	@EnvelopeMethod
	protected def void myMethodEnv(List<?> objs) {
		TraitTestsBase::TEST_BUFFER += "a"
		myMethodEnv$extended(objs)
		TraitTestsBase::TEST_BUFFER += "b"
	}

}

@ExtendedByAuto
class ExtendedByWithProtectedMethodAndGenericParameter implements ITraitClassWithProtectedMethodAndGenericParameter {

	protected def void myMethod(List<?> objs) {
		TraitTestsBase::TEST_BUFFER += objs.get(0)
		TraitTestsBase::TEST_BUFFER += objs.get(2)
	}

	protected def void myMethodEnv(List<?> objs) {
		TraitTestsBase::TEST_BUFFER += objs.get(3)
	}

}

@TraitClassAutoUsing
abstract class TraitClassWithProtectedMethodAndGenericParameterObjectFromClass<T> {

	@ExclusiveMethod
	protected def T transform(T value) {
		return value
	}

}

@ExtendedByAuto
class ExtendedByProtectedMethodAndGenericParameterObjectFromClass<T> implements ITraitClassWithProtectedMethodAndGenericParameterObjectFromClass<T> {
}

@TraitClassAutoUsing
abstract class TraitClassWithProtectedMethodAndGenericParameterStringFromClass<T extends String> {

	@ExclusiveMethod
	protected def T transform(T value) {
		return (value + "transformed") as T
	}

}

@ExtendedByAuto
class ExtendedByProtectedMethodAndGenericParameterStringFromClass<T extends String> implements ITraitClassWithProtectedMethodAndGenericParameterStringFromClass<T> {
}

class TraitsNonPublicTests extends TraitTestsBase {

	@Test
	def void testVisibilityTraitClassConstructor() {

		assertEquals(1, TraitClassNonPublic.declaredConstructors.size)
		assertTrue(Modifier.isPublic(TraitClassNonPublic.declaredConstructors.get(0).modifiers))

	}

	@Test
	def void testVisibilityTraitClassMethod() {

		assertTrue(
			Modifier.isPublic(
				TraitClassNonPublic.getDeclaredMethod("method1" + TraitClassProcessor.TRAIT_METHOD_IMPL_NAME_SUFFIX).
					modifiers))

	}

	@Test
	def void testExtensionNonPublicCalls() {

		val obj = new ExtendedClassNonPublic
		obj.method1PublicAccess
		obj.method2PublicAccess
		obj.method3
		obj.method4
		assertEquals("12A12B12X12C12Y12D12Z", TEST_BUFFER)

	}

	@Test
	def void testExtensionNonPublicIncreaseVisibility() {

		assertTrue(Modifier.isProtected(ExtendedClassNonPublic.getDeclaredMethod("method1").modifiers))
		assertTrue(Modifier.isProtected(ExtendedClassNonPublic.getDeclaredMethod("method2").modifiers))
		assertTrue(Modifier.isPublic(ExtendedClassNonPublic.getDeclaredMethod("method3").modifiers))
		assertTrue(Modifier.isPublic(ExtendedClassNonPublic.getDeclaredMethod("method4").modifiers))

		assertTrue(Modifier.isPublic(ExtendedClassCheckIncreaseVisibility.getDeclaredMethod("method1").modifiers))
		assertTrue(Modifier.isPublic(ExtendedClassCheckIncreaseVisibility.getDeclaredMethod("method2").modifiers))
		assertTrue(Modifier.isPublic(ExtendedClassCheckIncreaseVisibility.getDeclaredMethod("method3").modifiers))
		assertTrue(Modifier.isPublic(ExtendedClassCheckIncreaseVisibility.getDeclaredMethod("method4").modifiers))

	}

	@Test
	def void testExtensionNonPublicImplementRequiredMethod() {

		{
			TraitTestsBase::TEST_BUFFER = ""
			val obj = new ExtendedClassNonPublicImplementRequired
			obj.methodRequired
			assertEquals(1, obj.method1)
			assertEquals("I", TEST_BUFFER)
		}

		{
			TraitTestsBase::TEST_BUFFER = ""
			val obj = new ExtendedClassNonPublicUsingImplementRequired
			obj.methodRequired
			assertEquals(1, obj.method1)
			assertEquals("I", TEST_BUFFER)
		}

		{
			TraitTestsBase::TEST_BUFFER = ""
			val obj = new ExtendedClassNonPublicImplementRequiredCheckBaseNonBase
			obj.methodRequired
			assertEquals(1, obj.method1)
			assertEquals("I", TEST_BUFFER)
		}

	}

	@Test
	def void testExtensionNonPublicInterfaces() {

		var boolean exceptionThrown

		exceptionThrown = false
		try {
			IExtendedClassNonPublic.getDeclaredMethod("method1")
		} catch (NoSuchMethodException exception) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			IExtendedClassNonPublic.getDeclaredMethod("method2")
		} catch (NoSuchMethodException exception) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			IExtendedClassNonPublic.getDeclaredMethod("method3")
		} catch (NoSuchMethodException exception) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

	}

	@Test
	def void testProtectedMethodAndGenericParameter() {

		val obj = new ExtendedByWithProtectedMethodAndGenericParameter

		TraitTestsBase::TEST_BUFFER = ""
		obj.start(#[5, 6, 7])
		assertEquals("576", TraitTestsBase::TEST_BUFFER)

		TraitTestsBase::TEST_BUFFER = ""
		obj.myMethodEnv(#[11, 12, 13, 14])
		assertEquals("a14b", TraitTestsBase::TEST_BUFFER)

	}

	@Test
	def void testProtectedMethodAndGenericParameterFromClass() {

		{
			val obj = new ExtendedByProtectedMethodAndGenericParameterObjectFromClass
			assertEquals(6, obj.transform(Long.valueOf(6)))
		}

		{
			val obj = new ExtendedByProtectedMethodAndGenericParameterStringFromClass
			assertEquals("Xtransformed", obj.transform("X"))
		}

	}

}
