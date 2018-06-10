package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedBy
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassCheck
import org.junit.Test

import static org.junit.Assert.*
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassExtendedHasThisMethod

@TraitClassAutoUsing
abstract class TraitClassCheck {

	@ExclusiveMethod
	override boolean check() {
		val ITraitClassCheck myThis = $extendedThis
		return myThis instanceof ExtendedCheck
	}

}

@ExtendedByAuto
class ExtendedCheck implements ITraitClassCheck {
}

@TraitClass
abstract class TraitClassBaseHasExtendedThis<T> {
}

@TraitClass
abstract class TraitClassExtendedHasThisMethod<T> extends TraitClassBaseHasExtendedThis<T> {

	int x = 0;

	@ExclusiveMethod
	override void incX() { x++ }
	
	@ExclusiveMethod
	override int getX() { x }

	@ExclusiveMethod
	override void method() {
		TraitClassExtendedHasThisMethod::method($extendedThis)
	}

	static def <H> void method(ITraitClassExtendedHasThisMethod<H> x) { x.incX }

}

@ExtendedBy(TraitClassExtendedHasThisMethod)
class ExtendedClassTestExtendedThisMethod implements ITraitClassExtendedHasThisMethod<Integer> {
}

class TraitsExtendedThisTests extends TraitTestsBase {

	@Test
	def void testInstanceOfCheck() {

		val obj = new ExtendedCheck
		assertEquals(true, obj.check)

	}
	
	@Test
	def void testExtendedThisMethod() {

		val obj = new ExtendedClassTestExtendedThisMethod
		obj.method
		assertEquals(1, obj.getX)

	}

}