/**
 * Test passes, if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import java.lang.reflect.InvocationTargetException
import org.eclipse.xtend.lib.annotation.etai.AdaptedMethod
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.EPTraitClassResultPre
import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitClassProcessor
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITraitClassWithTypeAdaptionBase
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITraitClassWithTypeAdaptionDerived
import org.junit.Test

import static org.junit.Assert.*

@ApplyRules
@TraitClass
abstract class TraitClassWithTypeAdaptionBase {

	@ProcessedMethod(processor=EPVoidPre)
	override void paramAdapted1(
		@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1)")
		ControllerBase controller
	) {
	}

	@ProcessedMethod(processor=EPVoidPre)
	override void paramAdapted2(
		@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1)")
		ControllerBase controller
	) {
	}

	@ProcessedMethod(processor=EPVoidPre)
	override void paramAdapted3(
		@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1)")
		ControllerBase controller
	) {
	}

	@ProcessedMethod(processor=EPVoidPre)
	override void paramAdapted4(
		@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1)")
		ControllerBase controller
	) {
	}

	@ProcessedMethod(processor=EPVoidPre)
	override void paramAdapted5(
		@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1)")
		ControllerBase controller
	) {
	}

	@ProcessedMethod(processor=EPTraitClassResultPre)
	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1)")
	override ControllerBase returnAdapted1() {
		return null
	}

	@ProcessedMethod(processor=EPTraitClassResultPre)
	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1)")
	override ControllerBase returnAdapted2() {
		return null
	}

	@ProcessedMethod(processor=EPTraitClassResultPre)
	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1)")
	override ControllerBase returnAdapted3() {
		return null
	}

	@ProcessedMethod(processor=EPTraitClassResultPre)
	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1)")
	override ControllerBase returnAdapted4() {
		return null
	}

	@ProcessedMethod(processor=EPTraitClassResultPre)
	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1)")
	override ControllerBase returnAdapted5() {
		return null
	}

}

@ApplyRules
@TraitClass
abstract class TraitClassWithTypeAdaptionDerived extends TraitClassWithTypeAdaptionBase {

	@AdaptedMethod
	@ProcessedMethod(processor=EPTraitClassResultPre)
	override void paramAdapted3(
		ControllerBase controller
	) {
	}

	@ProcessedMethod(processor=EPTraitClassResultPre)
	override void paramAdapted4(
		@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.ControllerAttributeStringConcrete2)")
		ControllerBase controller
	) {
	}

	@ProcessedMethod(processor=EPTraitClassResultPre)
	override void paramAdapted5(
		ControllerBase controller
	) {
	}

	@AdaptedMethod
	@ProcessedMethod(processor=EPTraitClassResultPre)
	override ControllerBase returnAdapted3() {
		return null
	}

	@ProcessedMethod(processor=EPTraitClassResultPre)
	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.ControllerAttributeStringConcrete2)")
	override ControllerBase returnAdapted4() {
		return null
	}

	@ProcessedMethod(processor=EPTraitClassResultPre)
	override ControllerBase returnAdapted5() {
		return null
	}

}

@ApplyRules
@ExtendedByAuto
class ExtendedFromBaseIsBase implements ITraitClassWithTypeAdaptionBase {

	@AdaptedMethod
	override void paramAdapted2(
		ControllerBase controller
	) {
	}

	override void paramAdapted5(
		ControllerBase controller
	) {
	}

	@AdaptedMethod
	override ControllerBase returnAdapted2() {
		return null
	}

	override ControllerBase returnAdapted5() {
		return null
	}

}

@ApplyRules
class ExtendedFromBaseIsDerived extends ExtendedFromBaseIsBase {
}

@ApplyRules
@ExtendedByAuto
class ExtendedFromDerivedIsBase implements ITraitClassWithTypeAdaptionDerived {

	@AdaptedMethod
	override void paramAdapted2(
		ControllerBase controller
	) {
	}

	@AdaptedMethod
	override ControllerAttributeStringConcrete1 returnAdapted2() {
		return null
	}

}

@ApplyRules
class ExtendedFromDerivedIsDerived extends ExtendedFromDerivedIsBase {
}

class TypeAdaptionTraitsTests {

	@Test
	def void testAdaptionViaTraits() {

		assertEquals(20, TraitClassWithTypeAdaptionDerived.declaredMethods.filter [
			(name.startsWith("param") || name.startsWith("return")) && synthetic == false
		].size)
		assertEquals(14, ExtendedFromBaseIsBase.declaredMethods.filter [
			(name.startsWith("param") || name.startsWith("return")) && synthetic == false
		].size)
		assertEquals(2, ExtendedFromBaseIsDerived.declaredMethods.filter [
			(name.startsWith("param") || name.startsWith("return")) && synthetic == false
		].size)
		assertEquals(12, ExtendedFromDerivedIsBase.declaredMethods.filter [
			(name.startsWith("param") || name.startsWith("return")) && synthetic == false
		].size)
		assertEquals(1, ExtendedFromDerivedIsDerived.declaredMethods.filter [
			(name.startsWith("param") || name.startsWith("return")) && synthetic == false
		].size)

		var Class<?> expectedReturnType

		for (i : 1 .. 5) {

			// TraitClassWithTypeAdaptionDerived
			assertEquals(1, TraitClassWithTypeAdaptionDerived.declaredMethods.filter [
				name == "paramAdapted" + i && synthetic == false
			].size)
			assertSame(ControllerBase, TraitClassWithTypeAdaptionDerived.declaredMethods.filter [
				name == "paramAdapted" + i && synthetic == false
			].get(0).parameters.get(0).type)

			assertEquals(1, TraitClassWithTypeAdaptionDerived.declaredMethods.filter [
				name == "paramAdapted" + i + TraitClassProcessor.TRAIT_METHOD_IMPL_NAME_SUFFIX && synthetic == false
			].size)
			assertSame(ControllerBase, TraitClassWithTypeAdaptionDerived.declaredMethods.filter [
				name == "paramAdapted" + i + TraitClassProcessor.TRAIT_METHOD_IMPL_NAME_SUFFIX && synthetic == false
			].get(0).parameters.get(0).type)

			expectedReturnType = if (i >= 1 && i <= 2)
				ControllerAttributeStringConcrete1
			else
				ControllerBase

			assertEquals(1, TraitClassWithTypeAdaptionDerived.declaredMethods.filter [
				name == "returnAdapted" + i && synthetic == false
			].size)
			assertSame(expectedReturnType, TraitClassWithTypeAdaptionDerived.declaredMethods.filter [
				name == "returnAdapted" + i && synthetic == false
			].get(0).returnType)

			assertEquals(1, TraitClassWithTypeAdaptionDerived.declaredMethods.filter [
				name == "returnAdapted" + i + TraitClassProcessor.TRAIT_METHOD_IMPL_NAME_SUFFIX && synthetic == false
			].size)
			assertSame(expectedReturnType, TraitClassWithTypeAdaptionDerived.declaredMethods.filter [
				name == "returnAdapted" + i + TraitClassProcessor.TRAIT_METHOD_IMPL_NAME_SUFFIX && synthetic == false
			].get(0).returnType)

			// ExtendedFromBaseIsBase 
			assertEquals(1, ExtendedFromBaseIsBase.declaredMethods.filter [
				name == "paramAdapted" + i && synthetic == false
			].size)
			assertSame(ControllerBase, ExtendedFromBaseIsBase.declaredMethods.filter [
				name == "paramAdapted" + i && synthetic == false
			].get(0).parameters.get(0).type)

			expectedReturnType = if (i == 2 || i == 5)
				ControllerBase
			else
				ControllerAttributeStringConcrete1

			assertEquals(1, ExtendedFromBaseIsBase.declaredMethods.filter [
				name == "returnAdapted" + i && synthetic == false
			].size)
			assertSame(expectedReturnType, ExtendedFromBaseIsBase.declaredMethods.filter [
				name == "returnAdapted" + i && synthetic == false
			].get(0).returnType)

			// ExtendedFromDerivedIsBase
			assertEquals(1, ExtendedFromDerivedIsBase.declaredMethods.filter [
				name == "paramAdapted" + i && synthetic == false
			].size)
			assertSame(ControllerBase, ExtendedFromDerivedIsBase.declaredMethods.filter [
				name == "paramAdapted" + i && synthetic == false
			].get(0).parameters.get(0).type)

			expectedReturnType = if (i == 4)
				ControllerAttributeStringConcrete2
			else if (i == 5)
				ControllerBase
			else
				ControllerAttributeStringConcrete1

			assertEquals(1, ExtendedFromDerivedIsBase.declaredMethods.filter [
				name == "returnAdapted" + i && synthetic == false
			].size)
			assertSame(expectedReturnType, ExtendedFromDerivedIsBase.declaredMethods.filter [
				name == "returnAdapted" + i && synthetic == false
			].get(0).returnType)

		}

		// additional checks
		assertEquals(1, ExtendedFromBaseIsBase.declaredMethods.filter [
			name.startsWith("paramAdapted2__$") && synthetic == false
		].size)
		assertSame(ControllerBase, ExtendedFromBaseIsBase.declaredMethods.filter [
			name.startsWith("paramAdapted2__$") && synthetic == false
		].get(0).parameters.get(0).type)

		assertEquals(1, ExtendedFromBaseIsBase.declaredMethods.filter [
			name.startsWith("paramAdapted5__$") && synthetic == false
		].size)
		assertSame(ControllerBase, ExtendedFromBaseIsBase.declaredMethods.filter [
			name.startsWith("paramAdapted5__$") && synthetic == false
		].get(0).parameters.get(0).type)

		assertEquals(1, ExtendedFromBaseIsBase.declaredMethods.filter [
			name.startsWith("returnAdapted2__$") && synthetic == false
		].size)
		assertSame(ControllerBase, ExtendedFromBaseIsBase.declaredMethods.filter [
			name.startsWith("returnAdapted2__$") && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedFromBaseIsBase.declaredMethods.filter [
			name.startsWith("returnAdapted5__$") && synthetic == false
		].size)
		assertSame(ControllerBase, ExtendedFromBaseIsBase.declaredMethods.filter [
			name.startsWith("returnAdapted5__$") && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedFromDerivedIsBase.declaredMethods.filter [
			name.startsWith("paramAdapted2__$") && synthetic == false
		].size)
		assertSame(ControllerBase, ExtendedFromDerivedIsBase.declaredMethods.filter [
			name.startsWith("paramAdapted2__$") && synthetic == false
		].get(0).parameters.get(0).type)

		assertEquals(1, ExtendedFromDerivedIsBase.declaredMethods.filter [
			name.startsWith("returnAdapted2__$") && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1, ExtendedFromDerivedIsBase.declaredMethods.filter [
			name.startsWith("returnAdapted2__$") && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedFromBaseIsDerived.declaredMethods.filter [
			name == "paramAdapted2" && synthetic == false
		].size)
		assertSame(ControllerBase, ExtendedFromBaseIsDerived.declaredMethods.filter [
			name == "paramAdapted2" && synthetic == false
		].get(0).parameters.get(0).type)

		assertEquals(1, ExtendedFromBaseIsDerived.declaredMethods.filter [
			name == "returnAdapted2" && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1, ExtendedFromBaseIsDerived.declaredMethods.filter [
			name == "returnAdapted2" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedFromDerivedIsDerived.declaredMethods.filter [
			name == "paramAdapted2" && synthetic == false
		].size)
		assertSame(ControllerBase, ExtendedFromDerivedIsDerived.declaredMethods.filter [
			name == "paramAdapted2" && synthetic == false
		].get(0).parameters.get(0).type)

	}

	@Test
	def void testTraitParamAdaption() {

		var boolean exceptionExpected
		var boolean exceptionThrown

		for (i : 1 .. 5) {

			// ExtendedFromBaseIsBase
			val objFromBaseIsBase = new ExtendedFromBaseIsBase

			exceptionExpected = if (i == 2 || i == 5)
				false
			else
				true

			assertEquals(1,
				objFromBaseIsBase.class.methods.filter[name == "paramAdapted" + i && synthetic == false].size)
			exceptionThrown = false
			try {
				objFromBaseIsBase.class.methods.filter[name == "paramAdapted" + i && synthetic == false].get(0).invoke(
					objFromBaseIsBase, new ControllerBase(null))
			} catch (InvocationTargetException invocationTargetException) {
				if (invocationTargetException.cause instanceof AssertionError)
					exceptionThrown = true
			}
			assertEquals(exceptionExpected, exceptionThrown)

			// ExtendedFromBaseIsDerived
			val objFromBaseIsDerived = new ExtendedFromBaseIsDerived

			exceptionExpected = if (i == 5)
				false
			else
				true

			assertEquals(1,
				objFromBaseIsDerived.class.methods.filter[name == "paramAdapted" + i && synthetic == false].size)
			exceptionThrown = false
			try {
				objFromBaseIsDerived.class.methods.filter[name == "paramAdapted" + i && synthetic == false].get(0).
					invoke(objFromBaseIsDerived, new ControllerBase(null))
			} catch (InvocationTargetException invocationTargetException) {
				if (invocationTargetException.cause instanceof AssertionError)
					exceptionThrown = true
			}
			assertEquals(exceptionExpected, exceptionThrown)

			// ExtendedFromDerivedIsBase
			val objFromDerivedIsBase = new ExtendedFromDerivedIsBase

			exceptionExpected = if (i == 5 || i == 2)
				false
			else
				true

			assertEquals(1,
				objFromDerivedIsBase.class.methods.filter[name == "paramAdapted" + i && synthetic == false].size)
			exceptionThrown = false
			try {
				objFromDerivedIsBase.class.methods.filter[name == "paramAdapted" + i && synthetic == false].get(0).
					invoke(objFromDerivedIsBase, new ControllerBase(null))
			} catch (InvocationTargetException invocationTargetException) {
				if (invocationTargetException.cause instanceof AssertionError)
					exceptionThrown = true
			}
			assertEquals(exceptionExpected, exceptionThrown)

			// ExtendedFromDerivedIsDerived
			val objFromDerivedIsDerived = new ExtendedFromDerivedIsDerived

			exceptionExpected = if (i == 5)
				false
			else
				true

			assertEquals(1, objFromDerivedIsDerived.class.methods.filter [
				name == "paramAdapted" + i && synthetic == false
			].size)
			exceptionThrown = false
			try {
				objFromDerivedIsDerived.class.methods.filter[name == "paramAdapted" + i && synthetic == false].get(0).
					invoke(objFromDerivedIsDerived, new ControllerBase(null))
			} catch (InvocationTargetException invocationTargetException) {
				if (invocationTargetException.cause instanceof AssertionError)
					exceptionThrown = true
			}
			assertEquals(exceptionExpected, exceptionThrown)

		}

	}

}
