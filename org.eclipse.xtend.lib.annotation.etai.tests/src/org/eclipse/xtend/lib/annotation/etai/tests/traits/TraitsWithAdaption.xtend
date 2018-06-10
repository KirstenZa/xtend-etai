package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.EPDefault
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithAdaptionDerived
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithAdaptionDerivedOneConstructor
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassForAdaptedClass
import java.lang.reflect.Modifier
import org.junit.Test

import static org.junit.Assert.*

class AdaptionClassBase {
}

class AdaptionClassDerived extends AdaptionClassBase {
}

class AdaptionClassDerivedFurther extends AdaptionClassDerived {
}

@TraitClassAutoUsing
@ApplyRules
abstract class TraitClassWithAdaptionBase {

	AdaptionClassBase internalObj
	char character

	@TypeAdaptionRule
	@ConstructorMethod
	protected def void construct(char character) {
		this.character = character

		// use attribute in order to avoid warning
		this.character = this.character
	}

	@ConstructorMethod
	protected def void construct(
		@TypeAdaptionRule("applyVariable(var.class.simple);replace(ExtendedClass,_DO_NOT_ADAPT_);replace(TraitClassWithAdaption,org.eclipse.xtend.lib.annotation.etai.tests.traits.AdaptionClass)")
		AdaptionClassBase internalObj
	) {
		this.internalObj = internalObj
	}

	@TypeAdaptionRule("applyVariable(var.class.simple);replace(ExtendedClass,_DO_NOT_ADAPT_);replace(TraitClassWithAdaption,org.eclipse.xtend.lib.annotation.etai.tests.traits.AdaptionClass)")
	@ExclusiveMethod
	override AdaptionClassBase method1() {
		return internalObj
	}

	@TypeAdaptionRule("applyVariable(var.class.simple);replace(ExtendedClass,_DO_NOT_ADAPT_);replace(TraitClassWithAdaption,org.eclipse.xtend.lib.annotation.etai.tests.traits.AdaptionClass)")
	@ProcessedMethod(processor=EPDefault)
	override AdaptionClassBase method2() {
		return internalObj
	}

	@TypeAdaptionRule("applyVariable(var.class.simple);replace(ExtendedClass,_DO_NOT_ADAPT_);replace(TraitClassWithAdaption,org.eclipse.xtend.lib.annotation.etai.tests.traits.AdaptionClass)")
	@ProcessedMethod(processor=EPDefault)
	override AdaptionClassBase method3() {
		return internalObj
	}

}

@ApplyRules
@TraitClassAutoUsing
abstract class TraitClassWithAdaptionDerived extends TraitClassWithAdaptionBase {
}

@ApplyRules
@TraitClassAutoUsing
abstract class TraitClassWithAdaptionDerivedOneConstructor extends TraitClassWithAdaptionBase {

	@TypeAdaptionRule
	@ConstructorMethod
	protected def void construct2(char character) {
		super.construct(character)
	}

}

@ExtendedByAuto
@ApplyRules
class ExtendedClassWithAdaption implements ITraitClassWithAdaptionDerived {

	new(AdaptionClassDerived internalObjDerived) {
		new$TraitClassWithAdaptionDerived(internalObjDerived)
	}

	new(char character) {
		new$TraitClassWithAdaptionDerived(character)
	}

	override AdaptionClassDerived method2() {
		return null
	}

	override AdaptionClassDerivedFurther method3() {
		return null
	}

}

@ExtendedByAuto
@ApplyRules
class ExtendedClassWithAdaptionOneConstructor implements ITraitClassWithAdaptionDerivedOneConstructor {

	new() {
		new$TraitClassWithAdaptionDerivedOneConstructor('X')
	}

}

@TraitClassAutoUsing
abstract class TraitClassForAdaptedClass {

	@ConstructorMethod
	protected def void construct(int x) {}

}

/**
 * The following must compile without errors:
 * In this class, there is a combination of two constructor extensions
 * (check for auto-adaption and manual construction)
 */
@ApplyRules
@ExtendedByAuto
class ExtendedAndAdaptedClass implements ITraitClassForAdaptedClass {

	new(int x) {
		new$TraitClassForAdaptedClass(10)
	}

}

// Must compile without error
//
// The required base class should is in file ExtensionWithAdaptionOtherFile.xtend (this way a bug concerning the transformation order is possible)
@ApplyRules
class ExtendedClassWithRequiredMethodImplAdaptedNonAbstract extends ExtendedClassWithRequiredMethodImplAdapted {
}

class TraitsWithAdaptionTests extends TraitTestsBase {

	@Test
	def void testExtensionWithAdaption() {

		val internalObj = new AdaptionClassDerived
		val obj = new ExtendedClassWithAdaption(internalObj)
		assertTrue(obj.method1 instanceof AdaptionClassBase)
		assertNull(obj.method2)

		assertEquals(2, ExtendedClassWithAdaption.declaredMethods.filter([
			synthetic == false && name == "new$TraitClassWithAdaptionDerived"
		]).size)
		var foundAdaptionClassDerived = false
		var foundCharacter = false
		for (var i = 0; i < 2; i++) {
			val type = ExtendedClassWithAdaption.declaredMethods.filter([
				synthetic == false && name == "new$TraitClassWithAdaptionDerived"
			]).get(i).parameters.get(0).type
			if (type === AdaptionClassDerived)
				foundAdaptionClassDerived = true
			else if (type == char)
				foundCharacter = true
		}
		assertTrue(foundAdaptionClassDerived)
		assertTrue(foundCharacter)

		assertEquals(1,
			ExtendedClassWithAdaption.declaredMethods.filter([synthetic == false && name == "method1"]).size)
		assertSame(AdaptionClassDerived, ExtendedClassWithAdaption.declaredMethods.filter([
			synthetic == false && name == "method1"
		]).get(0).returnType)
		assertEquals(1,
			ExtendedClassWithAdaption.declaredMethods.filter([synthetic == false && name == "method2"]).size)
		assertSame(AdaptionClassDerived, ExtendedClassWithAdaption.declaredMethods.filter([
			synthetic == false && name == "method2"
		]).get(0).returnType)
		assertEquals(1,
			ExtendedClassWithAdaption.declaredMethods.filter([synthetic == false && name == "method3"]).size)
		assertSame(AdaptionClassDerivedFurther, ExtendedClassWithAdaption.declaredMethods.filter([
			synthetic == false && name == "method3"
		]).get(0).returnType)

	}

	@Test
	def void testExtensionWithAdaptionOneConstructor() {

		assertEquals(1, ExtendedClassWithAdaptionOneConstructor.declaredMethods.filter([
			synthetic == false && name == "new$TraitClassWithAdaptionDerivedOneConstructor"
		]).size)
		assertEquals(char, ExtendedClassWithAdaptionOneConstructor.declaredMethods.filter([
			synthetic == false && name == "new$TraitClassWithAdaptionDerivedOneConstructor"
		]).get(0).parameters.get(0).type)

	}

	@Test
	def void testExtendedAndAdaptedConstructors() {

		// if optimized, the following constructors must exist
		assertEquals(3, ExtendedAndAdaptedClass.declaredConstructors.size)
		assertEquals(2, ExtendedAndAdaptedClass.declaredConstructors.filter[Modifier.isPrivate(it.modifiers)].size)
		assertEquals(1, ExtendedAndAdaptedClass.declaredConstructors.filter[Modifier.isPublic(it.modifiers)].size)

	}

}
