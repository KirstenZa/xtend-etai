package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitExclusiveMethodInteractingWithPriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitPriorityEnvelopeSummPrio200
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitProcessedMethodInteractingWithPriorityEnvelopeMethod1

@TraitClass
abstract class TraitPriorityEnvelopePrio700 {

	@PriorityEnvelopeMethod(value=700, required=false, defaultValueProvider=SimpleDefaultValueProvider20)
	override int methodInt() {

		TraitTestsBase::TEST_BUFFER += "P700A"
		try {
			return methodInt$extended + 700
		} finally {
			TraitTestsBase::TEST_BUFFER += "P700B"
		}

	}

	@PriorityEnvelopeMethod(value=700, required=false)
	override void methodVoid(Character anotherParameterName) {

		TraitTestsBase::TEST_BUFFER += "P70_" + anotherParameterName + "_A"
		try {
			var char newChar = anotherParameterName
			newChar++
			methodVoid$extended(newChar)
		} finally {
			TraitTestsBase::TEST_BUFFER += "P700B"
		}

	}

}

@ApplyRules
@ExtendedByAuto
class ExtendedByPrio100300500700900Override5 extends ExtendedByPrio100300500700900Override4 implements ITraitPriorityEnvelopeSummPrio200 {
}

@ExtendedByAuto
@ApplyRules
class ExtendedClassPriorityEnvelopeMethodInteractionWithProcessed5 extends ExtendedClassPriorityEnvelopeMethodInteractionWithPre2 implements ITraitProcessedMethodInteractingWithPriorityEnvelopeMethod1 {
}

@ExtendedByAuto
@ApplyRules
class ExtendedClassPriorityEnvelopeMethodInteractionWithProcessed7 extends ExtendedClassPriorityEnvelopeMethodInteractionWithBetween2 implements ITraitProcessedMethodInteractingWithPriorityEnvelopeMethod1 {
}

@ExtendedByAuto
@ApplyRules
class ExtendedClassPriorityEnvelopeMethodInteractionWithExclusive extends ExtendedClassPriorityEnvelopeMethodInteractionWithPre1 implements ITraitExclusiveMethodInteractingWithPriorityEnvelopeMethod {
}
