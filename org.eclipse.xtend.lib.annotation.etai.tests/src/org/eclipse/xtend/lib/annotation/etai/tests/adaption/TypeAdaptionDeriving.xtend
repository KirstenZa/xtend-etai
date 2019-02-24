package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import org.eclipse.xtend.lib.annotation.etai.AdaptedMethod
import org.eclipse.xtend.lib.annotation.etai.ConstructRuleAuto
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.EPOverride
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribute
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITraitClassTypeAdaptionDerivedA1
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITraitClassTypeAdaptionDerivedA2
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
@ApplyRules
abstract class TraitClassTypeAdaptionBase {

	ControllerBase controller

	@ConstructorMethod
	@TypeAdaptionRule
	protected def void create() {
		this.controller = null
	}

	@ConstructorMethod
	protected def void create(
		@TypeAdaptionRule("applyVariable(var.class.simple);replaceFirst(Trait(?!ClassTypeAdaptionDerivedA),NOTEXIST);replaceAll(_[^_]*_,);replaceFirst(TraitClassTypeAdaptionDerivedA1,org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribute);replaceFirst(ExtendedClassAttribute,org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribute)")
		ControllerBase controller
	) {
		this.controller = controller
	}

	@TypeAdaptionRule("applyVariable(var.class.simple);replaceFirst(Trait(?!ClassTypeAdaptionDerivedA),NOTEXIST);replaceAll(_[^_]*_,);replaceFirst(TraitClassTypeAdaptionDerivedA1,org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribute);replaceFirst(ExtendedClassAttribute,org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribute)")
	@ExclusiveMethod
	override ControllerBase method1() {
		return controller
	}

	@TypeAdaptionRule("applyVariable(var.class.simple);replaceFirst(Trait(?!ClassTypeAdaptionDerivedA),NOTEXIST);replaceAll(_[^_]*_,);replaceFirst(TraitClassTypeAdaptionDerivedA1,org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribute);replaceFirst(ExtendedClassAttribute,org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribute)")
	@RequiredMethod
	abstract override ControllerBase method2()

	@TypeAdaptionRule("applyVariable(var.class.simple);replaceFirst(Trait(?!ClassTypeAdaptionDerivedA),NOTEXIST);replaceAll(_[^_]*_,);replaceFirst(TraitClassTypeAdaptionDerivedA1,org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribute);replaceFirst(ExtendedClassAttribute,org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribute)")
	@RequiredMethod
	abstract override ControllerBase method3()

	@TypeAdaptionRule("applyVariable(var.class.simple);replaceFirst(Trait.*Class,NOTEXIST);replaceAll(_[^_]*_,);replaceFirst(ExtendedClassAttribute,org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribute)")
	@ExclusiveMethod
	override ControllerBase method4() {
		return controller
	}

	@TypeAdaptionRule("applyVariable(var.class.simple);replaceFirst(Trait.*Class,NOTEXIST);replaceFirst(AttributeString(?!Concrete),NOTEXIST);replaceAll(_[^_]*_,);replaceFirst(ExtendedClassAttribute,org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribute)")
	@ExclusiveMethod
	override ControllerBase method5() {
		return controller
	}

}

@TraitClassAutoUsing
@ApplyRules
abstract class TraitClassTypeAdaptionDerived extends TraitClassTypeAdaptionBase {
}

@TraitClassAutoUsing
@ApplyRules
abstract class TraitClassTypeAdaptionDerivedA1 extends TraitClassTypeAdaptionDerived {
}

@TraitClassAutoUsing
@ApplyRules
abstract class TraitClassTypeAdaptionDerivedA2 extends TraitClassTypeAdaptionDerived {

	@ConstructorMethod
	protected def void create(
		ControllerAttribute controller
	) {
		super.create(controller);
	}

	@ExclusiveMethod
	override ControllerAttribute method1() {
		return super.method1 as ControllerAttribute
	}

	@AdaptedMethod
	@ExclusiveMethod
	override ControllerBase method2() {
		return super.method1
	}

	@AdaptedMethod
	@ExclusiveMethod
	override ControllerBase method3() {
		return super.method1
	}

	@ProcessedMethod(processor=EPOverride)
	override ControllerBase method6() {
		return super.method1
	}

	@AdaptedMethod
	@ProcessedMethod(processor=EPOverride)
	override ControllerBase method7() {
		return super.method1
	}

}

@ApplyRules
class ExtendedClassAttributeStringBase {

	@TypeAdaptionRule("applyVariable(var.class.simple);replaceAll(_[^_]*_,);replaceFirst(ExtendedClassAttribute,org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribute)")
	def ControllerAttribute method6() {
		return null
	}

	@TypeAdaptionRule("applyVariable(var.class.simple);replaceAll(_[^_]*_,);replaceFirst(ExtendedClassAttribute,org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribute)")
	def ControllerAttribute method7() {
		return null
	}

}

@ExtendedByAuto
@ExtractInterface
@ConstructRuleAuto
@FactoryMethodRule(factoryMethod="create")
@ApplyRules
class ExtendedClass_A1_AttributeString implements ITraitClassTypeAdaptionDerivedA1 {

	// this way, adaption is not applied (would have return type: ControllerAttributeString);
	// this is a current design decision, because adaption could not be stopped otherwise
	@AdaptedMethod
	override ControllerAttribute method2() {
		return method1
	}

	// this way, adaption is not applied (would have return type: ControllerAttributeString);
	// this is a current design decision, because adaption could not be stopped otherwise
	override ControllerAttribute method3() {
		return method1
	}

}

@ApplyRules
@ExtractInterface
class ExtendedClass_A1_AttributeStringConcrete1 extends ExtendedClass_A1_AttributeString {
}

@ExtendedByAuto
@ConstructRuleAuto
@ExtractInterface
@FactoryMethodRule(factoryMethod="create")
@ApplyRules
class ExtendedClass_A2_AttributeString extends ExtendedClassAttributeStringBase implements ITraitClassTypeAdaptionDerivedA2 {
}

@ApplyRules
@ExtractInterface
class ExtendedClass_A2_AttributeStringConcrete1 extends ExtendedClass_A2_AttributeString {
}

class TypeAdaptionDerivingTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testExtendedClassTypeAdaptions() {

		// check constructors
		assertEquals(2, ExtendedClass_A1_AttributeString.declaredMethods.filter[
			name == "create" && synthetic == false
		].size)
		assertEquals(1, ExtendedClass_A1_AttributeString.declaredMethods.filter[
			parameterCount == 0 && synthetic == false
		].filter[name == "create"].size)
		assertSame(ControllerAttributeString, ExtendedClass_A1_AttributeString.declaredMethods.filter[
			parameterCount == 1 && name == "create" && synthetic == false
		].get(0).parameters.get(0).type)

		assertEquals(2, ExtendedClass_A1_AttributeStringConcrete1.declaredMethods.filter[
			name == "create" && synthetic == false
		].size)
		assertEquals(1, ExtendedClass_A1_AttributeStringConcrete1.declaredMethods.filter[
			parameterCount == 0 && synthetic == false
		].filter[name == "create"].size)
		assertSame(ControllerAttributeStringConcrete1,
			ExtendedClass_A1_AttributeStringConcrete1.declaredMethods.filter[
				parameterCount == 1 && synthetic == false
			].filter[name == "create"].get(0).parameters.get(0).type)

		assertEquals(1, ExtendedClass_A2_AttributeString.declaredMethods.filter[
			name == "create" && synthetic == false
		].size)
		assertSame(ControllerAttribute, ExtendedClass_A2_AttributeString.declaredMethods.filter[
			name == "create" && synthetic == false
		].get(0).parameters.get(0).type)

		assertEquals(1, ExtendedClass_A2_AttributeStringConcrete1.declaredMethods.filter[
			name == "create" && synthetic == false
		].size)
		assertSame(ControllerAttribute, ExtendedClass_A2_AttributeStringConcrete1.declaredMethods.filter[
			name == "create" && synthetic == false
		].get(0).parameters.get(0).type)

		assertEquals(1, ExtendedClass_A3_AttributeString.declaredMethods.filter[
			name == "create" && synthetic == false
		].size)
		assertSame(ControllerAttribute, ExtendedClass_A3_AttributeString.declaredMethods.filter[
			name == "create" && synthetic == false
		].get(0).parameters.get(0).type)

		assertEquals(1, ExtendedClass_A3_AttributeStringConcrete1.declaredMethods.filter[
			name == "create" && synthetic == false
		].size)
		assertSame(ControllerAttribute, ExtendedClass_A3_AttributeStringConcrete1.declaredMethods.filter[
			name == "create" && synthetic == false
		].get(0).parameters.get(0).type)

		// check regular method (1)
		assertEquals(1, ExtendedClass_A1_AttributeString.declaredMethods.filter[
			name == "method1" && synthetic == false
		].size)
		assertSame(ControllerAttributeString, ExtendedClass_A1_AttributeString.declaredMethods.filter[
			name == "method1" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedClass_A1_AttributeStringConcrete1.declaredMethods.filter[
			name == "method1" && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1,
			ExtendedClass_A1_AttributeStringConcrete1.declaredMethods.filter[
				name == "method1" && synthetic == false
			].get(0).returnType)

		assertEquals(1, ExtendedClass_A2_AttributeString.declaredMethods.filter[
			name == "method1" && synthetic == false
		].size)
		assertSame(ControllerAttribute, ExtendedClass_A2_AttributeString.declaredMethods.filter[
			name == "method1" && synthetic == false
		].get(0).returnType)

		assertEquals(0, ExtendedClass_A2_AttributeStringConcrete1.declaredMethods.filter[
			name == "method1" && synthetic == false
		].size)

		assertEquals(1, ExtendedClass_A3_AttributeString.declaredMethods.filter[
			name == "method1" && synthetic == false
		].size)
		assertSame(ControllerAttribute, ExtendedClass_A3_AttributeString.declaredMethods.filter[
			name == "method1" && synthetic == false
		].get(0).returnType)

		assertEquals(0, ExtendedClass_A3_AttributeStringConcrete1.declaredMethods.filter[
			name == "method1" && synthetic == false
		].size)

		// check regular method (2)
		assertEquals(1, ExtendedClass_A1_AttributeString.declaredMethods.filter[
			name == "method2" && synthetic == false
		].size)
		assertSame(ControllerAttribute, ExtendedClass_A1_AttributeString.declaredMethods.filter[
			name == "method2" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedClass_A1_AttributeStringConcrete1.declaredMethods.filter[
			name == "method2" && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1,
			ExtendedClass_A1_AttributeStringConcrete1.declaredMethods.filter[
				name == "method2" && synthetic == false
			].get(0).returnType)

		assertEquals(1, ExtendedClass_A2_AttributeString.declaredMethods.filter[
			name == "method2" && synthetic == false
		].size)
		assertSame(ControllerAttributeString, ExtendedClass_A2_AttributeString.declaredMethods.filter[
			name == "method2" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedClass_A2_AttributeStringConcrete1.declaredMethods.filter[
			name == "method2" && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1,
			ExtendedClass_A2_AttributeStringConcrete1.declaredMethods.filter[
				name == "method2" && synthetic == false
			].get(0).returnType)

		assertEquals(1, ExtendedClass_A3_AttributeString.declaredMethods.filter[
			name == "method2" && synthetic == false
		].size)
		assertSame(ControllerAttributeString, ExtendedClass_A3_AttributeString.declaredMethods.filter[
			name == "method2" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedClass_A3_AttributeStringConcrete1.declaredMethods.filter[
			name == "method2" && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1,
			ExtendedClass_A3_AttributeStringConcrete1.declaredMethods.filter[
				name == "method2" && synthetic == false
			].get(0).returnType)

		// check regular method (3)
		assertEquals(1, ExtendedClass_A1_AttributeString.declaredMethods.filter[
			name == "method3" && synthetic == false
		].size)
		assertSame(ControllerAttribute, ExtendedClass_A1_AttributeString.declaredMethods.filter[
			name == "method3" && synthetic == false
		].get(0).returnType)

		assertEquals(0, ExtendedClass_A1_AttributeStringConcrete1.declaredMethods.filter[
			name == "method3" && synthetic == false
		].size)

		assertEquals(1, ExtendedClass_A2_AttributeString.declaredMethods.filter[
			name == "method3" && synthetic == false
		].size)
		assertSame(ControllerAttributeString, ExtendedClass_A2_AttributeString.declaredMethods.filter[
			name == "method3" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedClass_A2_AttributeStringConcrete1.declaredMethods.filter[
			name == "method3" && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1,
			ExtendedClass_A2_AttributeStringConcrete1.declaredMethods.filter[
				name == "method3" && synthetic == false
			].get(0).returnType)

		assertEquals(1, ExtendedClass_A3_AttributeString.declaredMethods.filter[
			name == "method3" && synthetic == false
		].size)
		assertSame(ControllerAttributeString, ExtendedClass_A3_AttributeString.declaredMethods.filter[
			name == "method3" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedClass_A3_AttributeStringConcrete1.declaredMethods.filter[
			name == "method3" && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1,
			ExtendedClass_A3_AttributeStringConcrete1.declaredMethods.filter[
				name == "method3" && synthetic == false
			].get(0).returnType)

		// check regular method (4)
		assertEquals(1, ExtendedClass_A1_AttributeString.declaredMethods.filter[
			name == "method4" && synthetic == false
		].size)
		assertSame(ControllerAttributeString, ExtendedClass_A1_AttributeString.declaredMethods.filter[
			name == "method4" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedClass_A1_AttributeStringConcrete1.declaredMethods.filter[
			name == "method4" && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1,
			ExtendedClass_A1_AttributeStringConcrete1.declaredMethods.filter[
				name == "method4" && synthetic == false
			].get(0).returnType)

		assertEquals(1, ExtendedClass_A2_AttributeString.declaredMethods.filter[
			name == "method4" && synthetic == false
		].size)
		assertSame(ControllerAttributeString, ExtendedClass_A2_AttributeString.declaredMethods.filter[
			name == "method4" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedClass_A2_AttributeStringConcrete1.declaredMethods.filter[
			name == "method4" && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1,
			ExtendedClass_A2_AttributeStringConcrete1.declaredMethods.filter[
				name == "method4" && synthetic == false
			].get(0).returnType)

		assertEquals(1, ExtendedClass_A3_AttributeString.declaredMethods.filter[
			name == "method4" && synthetic == false
		].size)
		assertSame(ControllerAttributeString, ExtendedClass_A3_AttributeString.declaredMethods.filter[
			name == "method4" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedClass_A3_AttributeStringConcrete1.declaredMethods.filter[
			name == "method4" && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1,
			ExtendedClass_A3_AttributeStringConcrete1.declaredMethods.filter[
				name == "method4" && synthetic == false
			].get(0).returnType)

		// check regular method (5)
		assertEquals(1, ExtendedClass_A1_AttributeString.declaredMethods.filter[
			name == "method5" && synthetic == false
		].size)
		assertSame(ControllerBase, ExtendedClass_A1_AttributeString.declaredMethods.filter[
			name == "method5" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedClass_A1_AttributeStringConcrete1.declaredMethods.filter[
			name == "method5" && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1,
			ExtendedClass_A1_AttributeStringConcrete1.declaredMethods.filter[
				name == "method5" && synthetic == false
			].get(0).returnType)

		assertEquals(1, ExtendedClass_A2_AttributeString.declaredMethods.filter[
			name == "method5" && synthetic == false
		].size)
		assertSame(ControllerBase, ExtendedClass_A2_AttributeString.declaredMethods.filter[
			name == "method5" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedClass_A2_AttributeStringConcrete1.declaredMethods.filter[
			name == "method5" && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1,
			ExtendedClass_A2_AttributeStringConcrete1.declaredMethods.filter[
				name == "method5" && synthetic == false
			].get(0).returnType)

		assertEquals(1, ExtendedClass_A3_AttributeString.declaredMethods.filter[
			name == "method5" && synthetic == false
		].size)
		assertSame(ControllerBase, ExtendedClass_A3_AttributeString.declaredMethods.filter[
			name == "method5" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedClass_A3_AttributeStringConcrete1.declaredMethods.filter[
			name == "method5" && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1,
			ExtendedClass_A3_AttributeStringConcrete1.declaredMethods.filter[
				name == "method5" && synthetic == false
			].get(0).returnType)

		// check regular method (6)
		assertEquals(1, ExtendedClass_A2_AttributeString.declaredMethods.filter[
			name == "method6" && synthetic == false
		].size)
		assertSame(ControllerAttributeString, ExtendedClass_A2_AttributeString.declaredMethods.filter[
			name == "method6" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedClass_A2_AttributeStringConcrete1.declaredMethods.filter[
			name == "method6" && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1,
			ExtendedClass_A2_AttributeStringConcrete1.declaredMethods.filter[
				name == "method6" && synthetic == false
			].get(0).returnType)

		assertEquals(1, ExtendedClass_A3_AttributeString.declaredMethods.filter[
			name == "method6" && synthetic == false
		].size)
		assertSame(ControllerAttributeString, ExtendedClass_A3_AttributeString.declaredMethods.filter[
			name == "method6" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedClass_A3_AttributeStringConcrete1.declaredMethods.filter[
			name == "method6" && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1,
			ExtendedClass_A3_AttributeStringConcrete1.declaredMethods.filter[
				name == "method6" && synthetic == false
			].get(0).returnType)

		// check regular method (7)
		assertEquals(1, ExtendedClass_A2_AttributeString.declaredMethods.filter[
			name == "method7" && synthetic == false
		].size)
		assertSame(ControllerAttributeString, ExtendedClass_A2_AttributeString.declaredMethods.filter[
			name == "method7" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedClass_A2_AttributeStringConcrete1.declaredMethods.filter[
			name == "method7" && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1,
			ExtendedClass_A2_AttributeStringConcrete1.declaredMethods.filter[
				name == "method7" && synthetic == false
			].get(0).returnType)

		assertEquals(1, ExtendedClass_A3_AttributeString.declaredMethods.filter[
			name == "method7" && synthetic == false
		].size)
		assertSame(ControllerAttributeString, ExtendedClass_A3_AttributeString.declaredMethods.filter[
			name == "method7" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ExtendedClass_A3_AttributeStringConcrete1.declaredMethods.filter[
			name == "method7" && synthetic == false
		].size)
		assertSame(ControllerAttributeStringConcrete1,
			ExtendedClass_A3_AttributeStringConcrete1.declaredMethods.filter[
				name == "method7" && synthetic == false
			].get(0).returnType)

		// use code
		val controllerAttributeStringConcrete1 = new ControllerAttributeStringConcrete1(null)

		val objA111 = ExtendedClass_A1_AttributeString::create()
		assertNull(objA111.method1)
		assertNull(objA111.method2)
		assertNull(objA111.method3)
		assertNull(objA111.method4)
		assertNull(objA111.method5)

		val objA112 = ExtendedClass_A1_AttributeString::create(controllerAttributeStringConcrete1)
		assertSame(controllerAttributeStringConcrete1, objA112.method1)
		assertSame(controllerAttributeStringConcrete1, objA112.method2)
		assertSame(controllerAttributeStringConcrete1, objA112.method3)
		assertSame(controllerAttributeStringConcrete1, objA112.method4)
		assertSame(controllerAttributeStringConcrete1, objA112.method5)

		val objA121 = ExtendedClass_A1_AttributeStringConcrete1::create()
		assertNull(objA121.method1)
		assertNull(objA121.method2)
		assertNull(objA121.method3)
		assertNull(objA121.method4)
		assertNull(objA121.method5)

		val objA122 = ExtendedClass_A1_AttributeStringConcrete1::create(controllerAttributeStringConcrete1)
		assertSame(controllerAttributeStringConcrete1, objA122.method1)
		assertSame(controllerAttributeStringConcrete1, objA122.method2)
		assertSame(controllerAttributeStringConcrete1, objA122.method3)
		assertSame(controllerAttributeStringConcrete1, objA122.method4)
		assertSame(controllerAttributeStringConcrete1, objA122.method5)

		val objA211 = ExtendedClass_A2_AttributeString::create(controllerAttributeStringConcrete1)
		assertSame(controllerAttributeStringConcrete1, objA211.method1)
		assertSame(controllerAttributeStringConcrete1, objA211.method2)
		assertSame(controllerAttributeStringConcrete1, objA211.method3)
		assertSame(controllerAttributeStringConcrete1, objA211.method4)
		assertSame(controllerAttributeStringConcrete1, objA211.method5)
		assertSame(controllerAttributeStringConcrete1, objA211.method6)
		assertSame(controllerAttributeStringConcrete1, objA211.method7)

		val objA221 = ExtendedClass_A2_AttributeStringConcrete1::create(controllerAttributeStringConcrete1)
		assertSame(controllerAttributeStringConcrete1, objA221.method1)
		assertSame(controllerAttributeStringConcrete1, objA221.method2)
		assertSame(controllerAttributeStringConcrete1, objA221.method3)
		assertSame(controllerAttributeStringConcrete1, objA221.method4)
		assertSame(controllerAttributeStringConcrete1, objA221.method5)
		assertSame(controllerAttributeStringConcrete1, objA221.method6)
		assertSame(controllerAttributeStringConcrete1, objA221.method7)

		val objA311 = ExtendedClass_A3_AttributeString::create(controllerAttributeStringConcrete1)
		assertSame(controllerAttributeStringConcrete1, objA311.method1)
		assertSame(controllerAttributeStringConcrete1, objA311.method2)
		assertSame(controllerAttributeStringConcrete1, objA311.method3)
		assertSame(controllerAttributeStringConcrete1, objA311.method4)
		assertSame(controllerAttributeStringConcrete1, objA311.method5)
		assertSame(controllerAttributeStringConcrete1, objA311.method6)
		assertSame(controllerAttributeStringConcrete1, objA311.method7)

		val objA321 = ExtendedClass_A3_AttributeStringConcrete1::create(controllerAttributeStringConcrete1)
		assertSame(controllerAttributeStringConcrete1, objA321.method1)
		assertSame(controllerAttributeStringConcrete1, objA321.method2)
		assertSame(controllerAttributeStringConcrete1, objA321.method3)
		assertSame(controllerAttributeStringConcrete1, objA321.method4)
		assertSame(controllerAttributeStringConcrete1, objA321.method5)
		assertSame(controllerAttributeStringConcrete1, objA321.method6)
		assertSame(controllerAttributeStringConcrete1, objA321.method7)

	}

	@Test
	def void testRuleUsageWithoutAutoAdaptionAnnotationErrors() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

import virtual.intf.ITraitClassWithApplyRules

@TraitClassAutoUsing
@ApplyRules
abstract class TraitClassWithApplyRules {
}

@ExtendedByAuto
class ExtendedClassWithoutApplyRules implements ITraitClassWithApplyRules

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ExtendedClassWithoutApplyRules')

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("@ApplyRules"))

			assertEquals(1, allProblems.size)

		]

	}

	@Test
	def void testAmbiguousTypeAdaptionErrors() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

import virtual.intf.ITraitClassWithApplyRules

@TraitClassAutoUsing
@ApplyRules
abstract class TraitClassWithApplyRules {
}

@ExtendedByAuto
class ExtendedClassWithoutApplyRules implements ITraitClassWithApplyRules

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ExtendedClassWithoutApplyRules')

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("@ApplyRules"))

			assertEquals(1, allProblems.size)

		]

	}

	@Test
	def void testAmbiguousTypeAdaptionRules() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.EPBooleanPostAnd
import org.eclipse.xtend.lib.annotation.etai.EPBooleanPreAnd
import org.eclipse.xtend.lib.annotation.etai.EPVoidPost
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule

import virtual.intf.ITraitClassWithTypeAdaptionRule

@TraitClassAutoUsing
@ApplyRules
abstract class TraitClassWithTypeAdaptionRule {

	@TypeAdaptionRule
	@ProcessedMethod(processor=EPBooleanPreAnd)
	override Boolean method11() {
		return true
	}

	@TypeAdaptionRule
	@ProcessedMethod(processor=EPBooleanPreAnd)
	override Boolean method12() {
		return true
	}

	@ProcessedMethod(processor=EPVoidPost)
	override void method21(@TypeAdaptionRule Boolean test) {
	}

	@ProcessedMethod(processor=EPVoidPost)
	override void method22(@TypeAdaptionRule Boolean test) {
	}

	@TypeAdaptionRule
	@ProcessedMethod(processor=EPBooleanPreAnd)
	override Boolean method41(Boolean test) {
		return true
	}

	@TypeAdaptionRule
	@ProcessedMethod(processor=EPBooleanPreAnd)
	override Boolean method42(Boolean test) {
		return true
	}

	@ProcessedMethod(processor=EPBooleanPostAnd)
	override Boolean method51(@TypeAdaptionRule Boolean test) {
		return true
	}

	@ProcessedMethod(processor=EPBooleanPostAnd)
	override Boolean method52(@TypeAdaptionRule Boolean test) {
		return true
	}

}

@ApplyRules
class ExtendedClassWithTypeAdaptionRuleBase {

	@TypeAdaptionRule
	def Boolean method12() {
		return true
	}

	def void method22(@TypeAdaptionRule Boolean test) {
	}

	def Boolean method42(Boolean test) {
		return true
	}

	@TypeAdaptionRule
	def Boolean method52(Boolean test) {
		return true
	}

}

@ApplyRules
@ExtendedByAuto
class ExtendedClassWithTypeAdaptionRule extends ExtendedClassWithTypeAdaptionRuleBase implements ITraitClassWithTypeAdaptionRule {

	@TypeAdaptionRule
	override Boolean method11() {
		return true
	}

	override void method21(@TypeAdaptionRule Boolean test) {
	}

	override Boolean method41(Boolean test) {
		return true
	}

	override Boolean method51(@TypeAdaptionRule Boolean test) {
		return true
	}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ExtendedClassWithTypeAdaptionRule')

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(3, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("specifies another type adaption rule"))
			assertEquals(Severity.ERROR, problemsClass.get(1).severity)
			assertTrue(problemsClass.get(1).message.contains("specifies another type adaption rule"))
			assertEquals(Severity.ERROR, problemsClass.get(2).severity)
			assertTrue(problemsClass.get(2).message.contains("specifies another type adaption rule"))

			assertEquals(3, allProblems.size)

		]

	}

	@Test
	def void testTypeAdaptionRuleNotNecessaryInEachTraitClass() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.EPFirstNotNullPost
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule

import virtual.intf.ITraitClass_X1
import virtual.intf.ITraitClass_X2

@TraitClassAutoUsing
@ApplyRules
abstract class TraitClass_X1 {
	@TypeAdaptionRule("applyVariable(var.class.qualified)")
	@ProcessedMethod(processor=EPFirstNotNullPost)
	override Object method() {
		return null
	}
}

@TraitClassAutoUsing
@ApplyRules
abstract class TraitClass_X2 {
}

@ApplyRules
@ExtendedByAuto
class ExtendedClass_X_Base implements ITraitClass_X1, ITraitClass_X2 {
}

@ApplyRules
class ExtendedClass_X extends ExtendedClass_X_Base {	
}

		'''.compile [

			// do assertions
			assertEquals(0, allProblems.size)

		]

	}

}
