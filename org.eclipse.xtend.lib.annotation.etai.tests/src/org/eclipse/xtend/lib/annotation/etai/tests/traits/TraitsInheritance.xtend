package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithInheritanceDerived
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassWithInheritanceBase {

	@ExclusiveMethod
	override void method1() {
		TraitTestsBase.TEST_BUFFER += "1"
	}

	@ExclusiveMethod
	override AdaptionClassBase methodOverridden() {
		null
	}

	@ExclusiveMethod
	override AdaptionClassBase [] methodOverriddenArray() {
		null
	}

}

@TraitClassAutoUsing
abstract class TraitClassWithInheritanceDerived extends TraitClassWithInheritanceBase {

	@ExclusiveMethod
	override void method2() {
		TraitTestsBase.TEST_BUFFER += "2"
	}

	@ExclusiveMethod
	override AdaptionClassDerived methodOverridden() {
		null
	}

	@ExclusiveMethod
	override AdaptionClassDerived [] methodOverriddenArray() {
		null
	}

}

@TraitClassAutoUsing
abstract class TraitClassWithInheritanceDerivedFurther extends TraitClassWithInheritanceDerived {

	@ExclusiveMethod
	override void method2() {
		TraitTestsBase.TEST_BUFFER += "2"
	}

}

@ExtendedByAuto
class ExtendedTraitClassWithInheritanceDerived implements ITraitClassWithInheritanceDerived {
}

class TraitsInheritanceTests extends TraitTestsBase {

	@Test
	def void testExtensionMultiple() {

		val obj = new ExtendedTraitClassWithInheritanceDerived()
		obj.method1
		obj.method2
		assertEquals("12", TEST_BUFFER)

	}

	@Test
	def void testExtensionOverriding() {

		assertEquals(1, ExtendedTraitClassWithInheritanceDerived.declaredMethods.filter[
			name == "methodOverridden" && synthetic == false
		].size)
		assertSame(AdaptionClassDerived, ExtendedTraitClassWithInheritanceDerived.declaredMethods.filter[
			name == "methodOverridden" && synthetic == false
		].get(0).returnType)

	}

}
