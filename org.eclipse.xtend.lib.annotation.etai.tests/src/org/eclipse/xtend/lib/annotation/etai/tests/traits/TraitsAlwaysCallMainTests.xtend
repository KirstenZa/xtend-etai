package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.EPVoidPost
import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.junit.Test

import static org.junit.Assert.*
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassAlwaysMain

@TraitClassAutoUsing
abstract class TraitClassAlwaysMain {

	@ExclusiveMethod
	override void method1() {
		method2
		method3
		method3$impl
	}

	@ProcessedMethod(processor=EPVoidPre)
	override void method2() {
		TraitTestsBase.TEST_BUFFER += "A"
	}

	@ProcessedMethod(processor=EPVoidPost)
	override void method3() {
		TraitTestsBase.TEST_BUFFER += "B"
	}

}

@ExtractInterface
@ExtendedByAuto
class ExtendedMainClass implements ITraitClassAlwaysMain {

	override void method2() {
		TraitTestsBase.TEST_BUFFER += "C"
	}

	override void method3() {
		TraitTestsBase.TEST_BUFFER += "D"
	}

}

class TraitsAwaysCallMainTests extends TraitTestsBase {

	@Test
	def void testExtensionAwaysCallMain() {

		val obj = new ExtendedMainClass()
		obj.method1
		assertEquals("ACDBB", TEST_BUFFER)

	}

}
