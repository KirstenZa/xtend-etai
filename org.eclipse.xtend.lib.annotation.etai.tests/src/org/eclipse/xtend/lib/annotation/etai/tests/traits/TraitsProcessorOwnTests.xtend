package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.LazyEvaluation
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TraitMethodProcessor
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassOwnProcessorTest
import org.junit.Test

import static org.junit.Assert.*
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassAnalyzingProcessor
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassAnalyzingProcessorDark
import org.eclipse.xtend.lib.annotation.etai.TraitMethodRedirection

class ReturnZeroIfNotInExtendedProcessor implements TraitMethodProcessor {

	override call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {
		if (expressionExtendedClass === null)
			return 0
		else
			expressionTraitClass.eval()
	}

}

class CountMethodsProcessor implements TraitMethodProcessor {

	override call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {
		
		var int counter = 0
		if (expressionTraitClass.method.name == "redirected")
			counter++
		if (expressionExtendedClass.method.name == "redirected")
			counter++
		counter += expressionTraitClass.eval() as Integer
		counter += expressionExtendedClass.eval() as Integer
		
		return counter
		
	}

}

@TraitClassAutoUsing
abstract class TraitClassOwnProcessorTest {

	/**
	 * This is the method description in TraitClassBooleanProcessorTest.
	 */
	@ProcessedMethod(processor=ReturnZeroIfNotInExtendedProcessor)
	override int methodReturn100() {
		100
	}

}

@ExtendedByAuto
class ExtendedClassOwnProcessorTest implements ITraitClassOwnProcessorTest {
}

class AddX2AndX3AndUseExtendedOnX1IsOver1000Processor implements TraitMethodProcessor {

	override Object call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {

		if (!(
			expressionTraitClass.numberOfArguments == 3 && expressionExtendedClass.numberOfArguments == 3 &&
			expressionTraitClass.method.name == "methodWithAnalyzedProcessor" &&
			expressionExtendedClass.method.name == "methodWithAnalyzedProcessor" &&
			expressionTraitClass.executingObject.class == TraitClassAnalyzingProcessor &&
			expressionExtendedClass.executingObject.class == ExtendedClassAnalyzingProcessor))
			return expressionExtendedClass.eval

		expressionTraitClass.setArgument(1, (expressionTraitClass.getArgument(1) as Integer) + 1);
		expressionTraitClass.setArgument(2, (expressionTraitClass.getArgument(2) as Integer) + 2);

		expressionExtendedClass.setArgument(1, (expressionExtendedClass.getArgument(1) as Integer) + 3);
		expressionExtendedClass.setArgument(2, (expressionExtendedClass.getArgument(2) as Integer) + 4);

		if ((expressionExtendedClass.getArgument(0) as IntegerWrapper).get() >= 1000)
			return expressionTraitClass.eval
		else
			return expressionExtendedClass.eval

	}

}

class IntegerWrapper {

	int value

	new(int value) {
		this.value = value
	}

	def int get() {
		return value;
	}

}

@TraitClassAutoUsing
abstract class TraitClassAnalyzingProcessor {

	@ProcessedMethod(processor=AddX2AndX3AndUseExtendedOnX1IsOver1000Processor)
	override int methodWithAnalyzedProcessor(IntegerWrapper x1, Integer x2, int x3) {
		return 2000 + x2
	}

	@ProcessedMethod(processor=AddX2AndX3AndUseExtendedOnX1IsOver1000Processor)
	override int methodWithAnalyzedProcessorDark(IntegerWrapper x1, Integer x2, int x3) {
		return 2000 + x2
	}
	
	@ProcessedMethod(processor=CountMethodsProcessor)
	override int notRedirected() {
		return 10
	}

}

@ExtendedByAuto
class ExtendedClassAnalyzingProcessor implements ITraitClassAnalyzingProcessor {

	override int methodWithAnalyzedProcessor(IntegerWrapper x1, Integer x2, int x3) {
		return x1.get() + x2 + x3
	}

	override int methodWithAnalyzedProcessorDark(IntegerWrapper x1, Integer x2, int x3) {
		return x1.get() + x2 + x3
	}
	
	@TraitMethodRedirection("redirected")
	override int notRedirected() {
		return 100 + redirected()
	}
	
	def int redirected() {
		return 1000
	}

}

@TraitClassAutoUsing
abstract class TraitClassAnalyzingProcessorDark {

	@ProcessedMethod(processor=AddX2AndX3AndUseExtendedOnX1IsOver1000Processor)
	override int methodWithAnalyzedProcessor(IntegerWrapper x1, Integer x2, int x3) {
		return 2000 + x2
	}

	@ProcessedMethod(processor=AddX2AndX3AndUseExtendedOnX1IsOver1000Processor)
	override int methodWithAnalyzedProcessorDark(IntegerWrapper x1, Integer x2, int x3) {
		return 2000 + x2
	}

}

@ExtendedByAuto
class ExtendedClassAnalyzingProcessorDark implements ITraitClassAnalyzingProcessorDark {

	override int methodWithAnalyzedProcessor(IntegerWrapper x1, Integer x2, int x3) {
		return x1.get() + x2 + x3
	}

	override int methodWithAnalyzedProcessorDark(IntegerWrapper x1, Integer x2, int x3) {
		return x1.get() + x2 + x3
	}

}

class TraitsProcessorOwnProcessorTests extends TraitTestsBase {

	@Test
	def void testReturnZeroIfNotInExtendedProcessor() {

		val obj = new ExtendedClassOwnProcessorTest();
		assertEquals(0, obj.methodReturn100)

	}

	@Test
	def void testAnalyzingProcessor() {

		val obj = new ExtendedClassAnalyzingProcessor();
		val objDark = new ExtendedClassAnalyzingProcessorDark();

		assertEquals(405, obj.methodWithAnalyzedProcessor(new IntegerWrapper(99), 199, 100))
		assertEquals(2034, obj.methodWithAnalyzedProcessor(new IntegerWrapper(1001), 33, 100))

		assertEquals(398, obj.methodWithAnalyzedProcessorDark(new IntegerWrapper(99), 199, 100))
		assertEquals(1134, obj.methodWithAnalyzedProcessorDark(new IntegerWrapper(1001), 33, 100))

		assertEquals(398, objDark.methodWithAnalyzedProcessor(new IntegerWrapper(99), 199, 100))
		assertEquals(1134, objDark.methodWithAnalyzedProcessor(new IntegerWrapper(1001), 33, 100))

		assertEquals(398, objDark.methodWithAnalyzedProcessorDark(new IntegerWrapper(99), 199, 100))
		assertEquals(1134, objDark.methodWithAnalyzedProcessorDark(new IntegerWrapper(1001), 33, 100))

	}
	
	@Test
	def void testAnalyzingProcessorWithRedirection() {
		
		val obj = new ExtendedClassAnalyzingProcessor();
		assertEquals(1112, obj.notRedirected())
		
	}

}
