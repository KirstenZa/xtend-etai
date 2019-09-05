package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TraitMethodProcessor
import org.eclipse.xtend.lib.annotation.etai.LazyEvaluation
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassMultipleBase1
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassMultipleBase2
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassMultipleBase3
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassSecondBranch
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassThirdBranch
import org.junit.Test

import static org.junit.Assert.*

class IntegerCombinatorAddPre implements TraitMethodProcessor {

	override call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {
		if (expressionExtendedClass === null)
			return expressionTraitClass.eval()
		else
			expressionTraitClass.eval() as Integer + expressionExtendedClass.eval() as Integer
	}

}

@TraitClassAutoUsing
abstract class TraitClassSecondBranch {

	@ExclusiveMethod
	override void methodBase5() {
		TraitTestsBase::TEST_BUFFER += "3"
	}

}

@TraitClassAutoUsing
abstract class TraitClassThirdBranch {

	@ExclusiveMethod
	override void methodBase6() {
		TraitTestsBase::TEST_BUFFER += "4"
	}

}

@TraitClassAutoUsing
abstract class TraitClassMultipleBase1 implements ITraitClassSecondBranch {

	@ExclusiveMethod
	override void methodBase3() {
		TraitTestsBase::TEST_BUFFER += "1"
	}

}

@TraitClassAutoUsing
abstract class TraitClassMultipleBase2 extends TraitClassMultipleBase1 {

	@ExclusiveMethod
	override void methodBase1() {
		TraitTestsBase::TEST_BUFFER += "1"
		methodBase5
	}

}

@TraitClassAutoUsing
abstract class TraitClassMultipleBase3 implements ITraitClassThirdBranch, ITraitClassMultipleBase1 {

	@ProcessedMethod(processor=IntegerCombinatorAddPre)
	override int methodBase2() {
		TraitTestsBase::TEST_BUFFER += "2"
		return 8
	}

	@ExclusiveMethod
	override void methodBase4() {
		methodBase5
		methodBase6
	}

}

@ExtendedByAuto
class ExtendedMultipleBase implements ITraitClassSecondBranch, ITraitClassThirdBranch {
}

@ExtendedByAuto
class ExtendedMultiple extends ExtendedMultipleBase implements ITraitClassMultipleBase2, ITraitClassMultipleBase3 {

	override int methodBase2() {
		return 7
	}

}

class TraitsMultipleTests extends TraitTestsBase {

	@Test
	def void testTraitClassMultiple() {

		val obj = new ExtendedMultiple()
		obj.methodBase1
		assertEquals(15, obj.methodBase2)
		assertEquals("132", TEST_BUFFER)

		TEST_BUFFER = ""
		obj.methodBase1
		assertEquals("13", TEST_BUFFER)

		TEST_BUFFER = ""
		obj.methodBase4
		assertEquals("34", TEST_BUFFER)

	}

}
