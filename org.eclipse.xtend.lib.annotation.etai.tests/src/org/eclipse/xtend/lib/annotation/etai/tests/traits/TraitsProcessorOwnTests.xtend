package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.LazyEvaluation
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TraitMethodProcessor
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassOwnProcessorTest
import org.junit.Test

import static org.junit.Assert.*

class ReturnZeroIfNotInExtendedProcessor implements TraitMethodProcessor {

	override call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {
		if (expressionExtendedClass === null)
			return 0
		else
			expressionTraitClass.eval()
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

class TraitsProcessorOwnProcessorTests extends TraitTestsBase {

	@Test
	def void testReturnZeroIfNotInExtendedProcessor() {

		val obj = new ExtendedClassOwnProcessorTest();
		assertEquals(0, obj.methodReturn100)

	}

}
