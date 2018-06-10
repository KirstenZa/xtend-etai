/**
 * Test passes, if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.implement

import org.eclipse.xtend.lib.annotation.etai.EPDefault
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ImplementDefault
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.IntegerCombinatorAddPre
import org.eclipse.xtend.lib.annotation.etai.tests.implement.intf.IAnotherTraitClassWithRequired
import org.eclipse.xtend.lib.annotation.etai.tests.implement.intf.ITraitClassWithRequired
import org.junit.Test

import static org.junit.Assert.*
import org.eclipse.xtend.lib.annotation.etai.EPOverride
import org.eclipse.xtend.lib.annotation.etai.TraitMethodProcessor
import org.eclipse.xtend.lib.annotation.etai.LazyEvaluation

class IntegerCombinatorSpecial implements TraitMethodProcessor {

	override call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {
		expressionTraitClass.eval() as Integer * (if (expressionExtendedClass.eval() as Integer == 0) 2 else 5)
	}

}

@TraitClassAutoUsing
abstract class TraitClassWithRequired {

	@RequiredMethod
	override int methodRequired()

	@ExclusiveMethod
	override int methodExclusive() { 10 }

	@RequiredMethod
	protected abstract def int methodRequiredProtected()

	@RequiredMethod
	protected abstract def int methodRequiredProtectedWillBeInAnotherTraitClass()

	@ProcessedMethod(required=true, processor=EPDefault)
	override int methodProcessedDefault() { 20 }

	@ProcessedMethod(required=true, processor=EPOverride)
	override int methodProcessedOverride() { 21 }
	
	@ProcessedMethod(required=true, processor=IntegerCombinatorSpecial)
	override int methodProcessedSpecial() { 22 }

	@EnvelopeMethod(required=true)
	override int methodEnvelope() {
		return 33 + this.methodEnvelope$extended
	}

}

@TraitClassAutoUsing
abstract class AnotherTraitClassWithRequired {

	@ProcessedMethod(required=true, processor=IntegerCombinatorAddPre)
	override int methodRequiredProtectedWillBeInAnotherTraitClass() { 150 }

}

@ExtendedByAuto
@ImplementDefault
class ExtendedClassWithRequiredImplement implements ITraitClassWithRequired, IAnotherTraitClassWithRequired {
}

@ExtendedByAuto
abstract class ExtendedClassWithRequiredNoImplementBase implements ITraitClassWithRequired, IAnotherTraitClassWithRequired {

	override int methodProcessedDefault() {
		return 1
	}

	override int methodProcessedOverride() {
		return 11
	}

	override int methodProcessedSpecial() {
		return 111
	}

	override int methodEnvelope() {
		return 2
	}

	override int methodRequiredProtectedWillBeInAnotherTraitClass() {
		return 3
	}

}

@ImplementDefault
class ExtendedClassWithRequiredImplementDerived extends ExtendedClassWithRequiredNoImplementBase {
}

class ImplementDefaultExtendedTests {

	@Test
	def void testDefaultImplementationExtended() {

		val obj = new ExtendedClassWithRequiredImplementDerived
		assertEquals(0, obj.methodRequired)
		assertEquals(10, obj.methodExclusive)
		assertEquals(0, obj.methodRequiredProtected)
		assertEquals(153, obj.methodRequiredProtectedWillBeInAnotherTraitClass)
		assertEquals(1, obj.methodProcessedDefault)
		assertEquals(21, obj.methodProcessedOverride)
		assertEquals(110, obj.methodProcessedSpecial)
		assertEquals(35, obj.methodEnvelope)

	}

	@Test
	def void testDefaultImplementationExtendedProtectedRequired() {

		val obj = new ExtendedClassWithRequiredImplement
		assertEquals(0, obj.methodRequired)
		assertEquals(10, obj.methodExclusive)
		assertEquals(0, obj.methodRequiredProtected)
		assertEquals(150, obj.methodRequiredProtectedWillBeInAnotherTraitClass)
		assertEquals(0, obj.methodProcessedDefault)
		assertEquals(21, obj.methodProcessedOverride)
		assertEquals(44, obj.methodProcessedSpecial)
		assertEquals(33, obj.methodEnvelope)

	}
	
}