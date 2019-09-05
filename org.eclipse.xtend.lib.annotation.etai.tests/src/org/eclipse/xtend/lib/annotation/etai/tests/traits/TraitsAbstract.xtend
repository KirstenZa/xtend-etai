package org.eclipse.xtend.lib.annotation.etai.tests.traits

import java.lang.reflect.Modifier
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedBy
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassProtectedMethods
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassPublicMethods
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassProtectedMethods {

	@ExclusiveMethod
	protected def void method1() {
		TraitTestsBase::TEST_BUFFER += "E"
	}

	@ProcessedMethod(processor=EPVoidPre)
	protected def void method2() {
		TraitTestsBase::TEST_BUFFER += "P"
	}

	@EnvelopeMethod(required=false, setFinal=false)
	protected def void method3() {
		TraitTestsBase::TEST_BUFFER += "V1"
		method3$extended
		TraitTestsBase::TEST_BUFFER += "V2"
	}

	@PriorityEnvelopeMethod(value=800, required=false)
	protected def void method4() {
		TraitTestsBase::TEST_BUFFER += "F1"
		method4$extended
		TraitTestsBase::TEST_BUFFER += "F2"
	}

}

@ExtendedByAuto
@ApplyRules
abstract class ExtendedProtectedAbstract implements ITraitClassProtectedMethods {

	abstract protected def void method1()

	abstract protected def void method2()

	abstract protected def void method3()

	abstract protected def void method4()

}

@ApplyRules
class ExtendedProtectedAbstractImplemented extends ExtendedProtectedAbstract {

	override protected void method1() {
		super.method1
		TraitTestsBase::TEST_BUFFER += "e"
	}

	override protected void method2() {
		super.method2
		TraitTestsBase::TEST_BUFFER += "p"
	}

	override protected void method3() {
		super.method3
		TraitTestsBase::TEST_BUFFER += "x"
	}

	override protected void method4() {
		TraitTestsBase::TEST_BUFFER += "y"
	}

}

abstract class ExtendedProtectedAbstractBase {

	abstract protected def void method1()

	abstract protected def void method2()

	abstract protected def void method3()

	abstract protected def void method4()

}

@ExtendedBy(TraitClassProtectedMethods)
@ApplyRules
class ExtendedProtectedAbstractBaseDerived extends ExtendedProtectedAbstractBase implements ITraitClassProtectedMethods {
}

@TraitClassAutoUsing
abstract class TraitClassPublicMethods {

	@ExclusiveMethod
	override void method1() {
		TraitTestsBase::TEST_BUFFER += "E"
	}

	@ProcessedMethod(processor=EPVoidPre)
	override void method2() {
		TraitTestsBase::TEST_BUFFER += "P"
	}

	@EnvelopeMethod(required=false, setFinal=false)
	override void method3() {
		TraitTestsBase::TEST_BUFFER += "V1"
		method3$extended
		TraitTestsBase::TEST_BUFFER += "V2"
	}

	@PriorityEnvelopeMethod(value=800, required=false)
	override void method4() {
		TraitTestsBase::TEST_BUFFER += "F1"
		method4$extended
		TraitTestsBase::TEST_BUFFER += "F2"
	}

}

@ExtendedByAuto
@ApplyRules
abstract class ExtendedPublicAbstract implements ITraitClassPublicMethods {

	abstract override void method1()

	abstract override void method2()

	abstract override void method3()

	abstract override void method4()

}

@ApplyRules
class ExtendedPublicAbstractImplemented extends ExtendedPublicAbstract {

	override void method1() {
		super.method1
		TraitTestsBase::TEST_BUFFER += "e"
	}

	override void method2() {
		super.method2
		TraitTestsBase::TEST_BUFFER += "p"
	}

	override void method3() {
		super.method3
		TraitTestsBase::TEST_BUFFER += "x"
	}

	override void method4() {
		TraitTestsBase::TEST_BUFFER += "y"
	}

}

abstract class ExtendedPublicAbstractBase {

	abstract def void method1()

	abstract def void method2()

	abstract def void method3()

	abstract def void method4()

}

@ExtendedBy(TraitClassPublicMethods)
@ApplyRules
class ExtendedPublicAbstractBaseDerived extends ExtendedPublicAbstractBase implements ITraitClassPublicMethods {
}

class TraitsAbstractTests extends TraitTestsBase {

	@Test
	def void testAbstractProtectedInExtended() {

		val obj = new ExtendedProtectedAbstractImplemented
		obj.method1
		obj.method2
		obj.method3
		obj.method4
		assertEquals("EePpV1V2xF1yF2", TEST_BUFFER)

		assertTrue(Modifier.isProtected(ExtendedProtectedAbstract.declaredMethods.findFirst [
			name == "method1" && synthetic == false
		].modifiers))
		assertTrue(Modifier.isProtected(ExtendedProtectedAbstract.declaredMethods.findFirst [
			name == "method2" && synthetic == false
		].modifiers))
		assertTrue(Modifier.isProtected(ExtendedProtectedAbstract.declaredMethods.findFirst [
			name == "method3" && synthetic == false
		].modifiers))
		assertTrue(Modifier.isProtected(ExtendedProtectedAbstract.declaredMethods.findFirst [
			name == "method4" && synthetic == false
		].modifiers))

	}

	@Test
	def void testAbstractProtectedInBaseClassOfExtended() {

		val obj = new ExtendedProtectedAbstractBaseDerived
		obj.method1
		obj.method2
		obj.method3
		obj.method4
		assertEquals("EPV1V2F1F2", TEST_BUFFER)

		assertTrue(Modifier.isProtected(ExtendedProtectedAbstractBaseDerived.declaredMethods.findFirst [
			name == "method1" && synthetic == false
		].modifiers))
		assertTrue(Modifier.isProtected(ExtendedProtectedAbstractBaseDerived.declaredMethods.findFirst [
			name == "method2" && synthetic == false
		].modifiers))
		assertTrue(Modifier.isProtected(ExtendedProtectedAbstractBaseDerived.declaredMethods.findFirst [
			name == "method3" && synthetic == false
		].modifiers))
		assertTrue(Modifier.isProtected(ExtendedProtectedAbstractBaseDerived.declaredMethods.findFirst [
			name == "method4" && synthetic == false
		].modifiers))

	}

	@Test
	def void testAbstractPublicInExtended() {

		val obj = new ExtendedPublicAbstractImplemented
		obj.method1
		obj.method2
		obj.method3
		obj.method4
		assertEquals("EePpV1V2xF1yF2", TEST_BUFFER)

		assertTrue(Modifier.isPublic(ExtendedPublicAbstract.getMethod("method1").modifiers))
		assertTrue(Modifier.isPublic(ExtendedPublicAbstract.getMethod("method2").modifiers))
		assertTrue(Modifier.isPublic(ExtendedPublicAbstract.getMethod("method3").modifiers))
		assertTrue(Modifier.isPublic(ExtendedPublicAbstract.getMethod("method4").modifiers))

	}

	@Test
	def void testAbstractPublicInBaseClassOfExtended() {

		val obj = new ExtendedPublicAbstractBaseDerived
		obj.method1
		obj.method2
		obj.method3
		obj.method4
		assertEquals("EPV1V2F1F2", TEST_BUFFER)

		assertTrue(Modifier.isPublic(ExtendedPublicAbstractBaseDerived.getMethod("method1").modifiers))
		assertTrue(Modifier.isPublic(ExtendedPublicAbstractBaseDerived.getMethod("method2").modifiers))
		assertTrue(Modifier.isPublic(ExtendedPublicAbstractBaseDerived.getMethod("method3").modifiers))
		assertTrue(Modifier.isPublic(ExtendedPublicAbstractBaseDerived.getMethod("method4").modifiers))

	}

}
