package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TraitMethodRedirection
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitMethodRedirectionDisableRedirection
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitMethodRedirectionDisableRedirectionChecker
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitMethodRedirectionDisableRedirection {

	@EnvelopeMethod(setFinal=true, disableRedirection=true)
	override void envelope() {
		TraitTestsBase.TEST_BUFFER += "E1"
		envelope$extended
		TraitTestsBase.TEST_BUFFER += "E2"
	}

}

@TraitClassAutoUsing
abstract class TraitMethodRedirectionDisableRedirectionChecker {

	@ProcessedMethod(processor=EPVoidPre)
	override void envelope() {
		TraitTestsBase.TEST_BUFFER += "e"
	}

}

@ExtendedByAuto
class ExtendedRedirectionDisableRedirection implements ITraitMethodRedirectionDisableRedirection, ITraitMethodRedirectionDisableRedirectionChecker {

	@TraitMethodRedirection("envelopeInternal")
	override void envelope() { envelopeInternal }

	def void envelopeInternal() {}

}

class TraitsMethodRedirectionDisableTests extends TraitTestsBase {

	@Test
	def void testDisableRedirection() {

		val obj = new ExtendedRedirectionDisableRedirection
		obj.envelope
		assertEquals("E1eE2", TEST_BUFFER)

	}

}
