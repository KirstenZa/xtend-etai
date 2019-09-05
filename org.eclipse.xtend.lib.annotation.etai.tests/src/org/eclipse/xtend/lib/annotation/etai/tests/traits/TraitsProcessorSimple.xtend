package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.EPOverride
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassProcessorCheckParamName
import org.junit.Test

import static org.junit.Assert.*

@TraitClass
abstract class TraitClassProcessorCheckParamName {

	String savedValue = ""

	@ProcessedMethod(processor=StringCombinatorPre)
	override String myMethod1(String newValue) {

		this.savedValue = newValue + "X"
		return savedValue

	}

	@ProcessedMethod(processor=EPOverride)
	override String myMethod2(String anotherParameterName) {

		this.savedValue = anotherParameterName + "X"
		return savedValue

	}

}

@ExtendedByAuto
class ExtendedClassProcessorSimple implements ITraitClassProcessorCheckParamName {

	override String myMethod1(String newValue2) {
		return "Something"
	}

	override String myMethod2(String newValue2) {
		return "Something"
	}

}

class ExtendedClassProcessorPrivateBase {

	private def String myMethod1(String newValue2) {
		TraitTestsBase::TEST_BUFFER += "NOT_USE"
		return ""
	}

	def void useMethods() {
		myMethod1("nothing")
	}

}

@ExtendedByAuto
class ExtendedClassProcessorPrivateDerived extends ExtendedClassProcessorPrivateBase implements ITraitClassProcessorCheckParamName {
}

class TraitsProcessorSimpleTests extends TraitTestsBase {

	@Test
	def void testProcessorSimpleDifferentParameterName() {

		val obj = new ExtendedClassProcessorSimple();
		assertEquals("testXSomething", obj.myMethod1("test"))
		assertEquals("testX", obj.myMethod2("test"))

	}

	def void testProcessorDoesNotApplyPrivateInBase() {

		val obj = new ExtendedClassProcessorPrivateDerived

		TEST_BUFFER = "";
		assertEquals("XX", obj.myMethod1("X"))
		assertEquals("", TEST_BUFFER)

	}

}
