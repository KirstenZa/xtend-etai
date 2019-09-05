/**
 * Test passes if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.implement

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.EPDefault
import org.eclipse.xtend.lib.annotation.etai.EPOverride
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ImplementDefault
import org.eclipse.xtend.lib.annotation.etai.LazyEvaluation
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TraitMethodProcessor
import org.eclipse.xtend.lib.annotation.etai.tests.implement.intf.IAnotherTraitClassWithRequired
import org.eclipse.xtend.lib.annotation.etai.tests.implement.intf.ITraitClassWithRequired
import org.eclipse.xtend.lib.annotation.etai.tests.traits.IntegerCombinatorAddPre
import org.junit.Test

import static org.junit.Assert.*
import org.eclipse.xtend.lib.annotation.etai.tests.traits.SimpleDefaultValueProvider20
import org.eclipse.xtend.lib.annotation.etai.tests.implement.intf.ITraitClassPriorityEnvelopeMethodRequired
import org.eclipse.xtend.lib.annotation.etai.tests.implement.intf.ITraitClassPriorityEnvelopeMethodNotRequired

class IntegerCombinatorSpecial implements TraitMethodProcessor {

	override call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {
		expressionTraitClass.eval() as Integer * (if(expressionExtendedClass.eval() as Integer == 0) 2 else 5)
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

	@PriorityEnvelopeMethod(required=true, value=5)
	override int methodPriorityEnvelope() {
		return 55 + this.methodPriorityEnvelope$extended
	}

}

@TraitClassAutoUsing
abstract class AnotherTraitClassWithRequired {

	@ProcessedMethod(required=true, processor=IntegerCombinatorAddPre)
	override int methodRequiredProtectedWillBeInAnotherTraitClass() { 150 }

}

@ExtendedByAuto
@ImplementDefault
@ApplyRules
class ExtendedClassWithRequiredImplement implements ITraitClassWithRequired, IAnotherTraitClassWithRequired {
}

@ExtendedByAuto
@ApplyRules
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

	override int methodPriorityEnvelope() {
		return 9
	}

	override int methodRequiredProtectedWillBeInAnotherTraitClass() {
		return 3
	}

}

@ImplementDefault
@ApplyRules
class ExtendedClassWithRequiredImplementDerived extends ExtendedClassWithRequiredNoImplementBase {
}

@TraitClass
abstract class TraitClassPriorityEnvelopeMethodRequired {

	@PriorityEnvelopeMethod(required=true, value=5)
	override int methodPriorityEnvelope() {
		return 55 + this.methodPriorityEnvelope$extended
	}

}

@TraitClass
abstract class TraitClassPriorityEnvelopeMethodNotRequired {

	@PriorityEnvelopeMethod(required=false, value=2, defaultValueProvider=SimpleDefaultValueProvider20)
	override int methodPriorityEnvelope() {
		return 3 + this.methodPriorityEnvelope$extended
	}

}

@ExtendedByAuto
@ApplyRules
@ImplementDefault
class NoAutoImplementationForPriorityEnvelopeMethod implements ITraitClassPriorityEnvelopeMethodRequired, ITraitClassPriorityEnvelopeMethodNotRequired {
}

@ExtendedByAuto
@ApplyRules
abstract class ExtendedPriorityEnvelopeMethodRequiredAbstract implements ITraitClassPriorityEnvelopeMethodRequired {
}

@ImplementDefault
@ApplyRules
class ExtendedPriorityEnvelopeMethodRequiredNonAbstract extends ExtendedPriorityEnvelopeMethodRequiredAbstract {
}

@ApplyRules
class ExtendedPriorityEnvelopeMethodRequiredDerived extends ExtendedPriorityEnvelopeMethodRequiredNonAbstract {
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
		assertEquals(64, obj.methodPriorityEnvelope)

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
		assertEquals(55, obj.methodPriorityEnvelope)

	}

	@Test
	def void testNoAutoImplementationForPriorityEnvelopeMethod() {

		val obj = new NoAutoImplementationForPriorityEnvelopeMethod
		assertEquals(78, obj.methodPriorityEnvelope)
		assertEquals(0, NoAutoImplementationForPriorityEnvelopeMethod.declaredMethods.filter [
			name == "methodPriorityEnvelope$impl"
		].size)

	}

	@Test
	def void testPriorityEnvelopeMethodDerived() {

		{

			val obj = new ExtendedPriorityEnvelopeMethodRequiredNonAbstract
			assertEquals(55, obj.methodPriorityEnvelope)

		}

		{

			val obj = new ExtendedPriorityEnvelopeMethodRequiredDerived
			assertEquals(55, obj.methodPriorityEnvelope)

		}

	}

}
