package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassProtectedMethods
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassProtectedMethods {

	@ExclusiveMethod
	protected def void method1() {
		TraitTestsBase.TEST_BUFFER += "E"
	}

	@ProcessedMethod(processor=EPVoidPre)
	protected def void method2() {
		TraitTestsBase.TEST_BUFFER += "P"
	}

	@EnvelopeMethod(required=false)
	protected def void method3() {
		TraitTestsBase.TEST_BUFFER += "V1"
		method3$extended
		TraitTestsBase.TEST_BUFFER += "V2"
	}

}

@ExtendedByAuto
abstract class ExtendedAbstract implements ITraitClassProtectedMethods {

	abstract def void method1()

	abstract def void method2()

	abstract def void method3()

}

class ExtendedAbstractImplemented extends ExtendedAbstract {

	override void method1() {
		super.method1
		TraitTestsBase.TEST_BUFFER += "e"
	}

	override void method2() {
		super.method2
		TraitTestsBase.TEST_BUFFER += "p"
	}

}

class TraitsAbstractTests extends TraitTestsBase {

	@Test
	def void testExtensionAwaysCallMain() {

		val obj = new ExtendedAbstractImplemented
		obj.method1
		obj.method2
		obj.method3
		assertEquals("EePpV1V2", TEST_BUFFER)

	}

}
