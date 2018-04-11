package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import org.eclipse.xtend.lib.annotation.etai.AdaptedMethod
import org.eclipse.xtend.lib.annotation.etai.ConstructRuleAuto
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.EPFirstNotNullPost
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.ImplAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.SetAdaptionVariable
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribute
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IConstructorTypeAdaptionWithVariableTraitClass
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITraitClassVar2
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITraitClassVar3
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITraitClassVarUsed
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITraitSettingAdaptionVariable
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITypeAdaptionWithVariableTraitClass
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
@ApplyRules
@SetAdaptionVariable("AdaptionType1=org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString")
abstract class TypeAdaptionWithVariableTraitClass {

	@ProcessedMethod(processor=EPFirstNotNullPost)
	@TypeAdaptionRule("applyVariable(AdaptionType1)")
	override ControllerBase a1() {
		return null;
	}

	@ExclusiveMethod
	@TypeAdaptionRule("applyVariable(AdaptionType1)")
	override ControllerBase a2(int x) {
		return null;
	}

	@ExclusiveMethod
	override ControllerBase a2(String x) {
		return null;
	}

	@ExclusiveMethod
	@TypeAdaptionRule("applyVariable(AdaptionType2)")
	override ControllerBase a3() {
		return null;
	}

}

@TraitClassAutoUsing
@SetAdaptionVariable("AdaptionType4=org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString")
abstract class TraitSettingAdaptionVariable {
}

@ApplyRules
@ExtendedByAuto
@ExtractInterface
class TypeAdaptionWithVariableExtendedClass implements ITypeAdaptionWithVariableTraitClass {

	@AdaptedMethod
	override ControllerAttribute a1() {
		return null;
	}

	@TypeAdaptionRule("applyVariable(AdaptionType3)")
	override ControllerBase b1() {
		return null;
	}

	override void b2(
		@TypeAdaptionRule("applyVariable(AdaptionType3)")
		ControllerBase controllerBase
	) {
	}

	@TypeAdaptionRule("applyVariable(AdaptionType4)")
	override ControllerBase b3() {
		return null;
	}

	@TypeAdaptionRule("applyVariable(DoesNotExist)")
	override ControllerBase b4() {
		return null;
	}

}

@ApplyRules
@ExtractInterface
@ExtendedByAuto
@SetAdaptionVariable("AdaptionType1=org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1,   AdaptionType2=org.eclipse.xtend.lib.annotation.etai.tests.adaption.ControllerAttributeStringConcrete2, AdaptionType3=org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1")
class TypeAdaptionWithVariableExtendedClassDerived extends TypeAdaptionWithVariableExtendedClass implements ITraitSettingAdaptionVariable {
}

@TraitClassAutoUsing
@SetAdaptionVariable("v2=C")
abstract class TraitClassVarUsed {
}

@TraitClassAutoUsing
@SetAdaptionVariable("v2=B, v3=2")
abstract class TraitClassVar1 implements ITraitClassVarUsed {
}

@TraitClassAutoUsing
@SetAdaptionVariable("v5=K, v4=Y, v2=A, v3=1")
abstract class TraitClassVar2 extends TraitClassVar1 {
}

@TraitClassAutoUsing
@SetAdaptionVariable("v4=X, v2=E")
abstract class TraitClassVar3 {
}

@SetAdaptionVariable("v1= Test")
@ApplyRules
abstract class ExtendedClassBase {

	@ImplAdaptionRule("apply(return \");appendVariable(v1);appendVariable(v2);appendVariable(v3);appendVariable(v4);appendVariable(v5);appendVariable(v6);append(\";)")
	def String getVariable()

}

@ExtendedByAuto
@SetAdaptionVariable("v5=L")
@ApplyRules
class ExtendedClassVar extends ExtendedClassBase implements ITraitClassVar2, ITraitClassVar3 {
}

class AnotherBase {
}

class AnotherDerived extends AnotherBase {
}

@TraitClassAutoUsing
@ApplyRules
@SetAdaptionVariable("AdaptionType1=org.eclipse.xtend.lib.annotation.etai.tests.adaption.Derived")
abstract class ConstructorTypeAdaptionWithVariableTraitClass {

	@ConstructorMethod
	protected def void construct(
		@TypeAdaptionRule("applyVariable(AdaptionType1)")
		Base x1
	) {}

}

@ApplyRules
@SetAdaptionVariable("AdaptionType2=org.eclipse.xtend.lib.annotation.etai.tests.adaption.AnotherDerived")
abstract class ConstructorTypeAdaptionWithVariableBase {

	new(
		@TypeAdaptionRule("applyVariable(AdaptionType2)")
		AnotherBase x2,
		AnotherBase x3
	) {
	}

}

@ExtendedByAuto
@ConstructRuleAuto
@FactoryMethodRule(factoryMethod="create")
@ApplyRules
class ConstructorTypeAdaptionWithVariableExtendedClass extends ConstructorTypeAdaptionWithVariableBase implements IConstructorTypeAdaptionWithVariableTraitClass {
}

class TypeAdaptionVariableTests {

	@Test
	def void testTypeAdaptionWithVariable() {

		val declaredMethodsExtendedClass = TypeAdaptionWithVariableExtendedClass.declaredMethods.filter([
			synthetic == false
		])
		val declaredMethodsExtendedClassDerived = TypeAdaptionWithVariableExtendedClassDerived.declaredMethods.filter([
			synthetic == false
		])

		// check case (a1)
		assertEquals(1, declaredMethodsExtendedClass.filter([
			name == "a1"
		]).size)
		assertSame(ControllerAttribute, declaredMethodsExtendedClass.filter([name == "a1"]).get(0).returnType)
		assertEquals(1, declaredMethodsExtendedClassDerived.filter([
			name == "a1"
		]).size)
		assertSame(ControllerAttributeStringConcrete1, declaredMethodsExtendedClassDerived.filter([
			name == "a1"
		]).get(0).returnType)

		// check case (a2)
		assertEquals(2, declaredMethodsExtendedClass.filter([
			name == "a2"
		]).size)
		assertEquals(#{ControllerBase, ControllerAttributeString},
			declaredMethodsExtendedClass.filter([name == "a2"]).map[returnType].toSet)
		assertEquals(1, declaredMethodsExtendedClassDerived.filter([
			name == "a2"
		]).size)
		assertSame(ControllerAttributeStringConcrete1, declaredMethodsExtendedClassDerived.filter([
			name == "a2"
		]).get(0).returnType)

		// check case (a3)
		assertEquals(1, declaredMethodsExtendedClass.filter([
			name == "a3"
		]).size)
		assertSame(ControllerBase, declaredMethodsExtendedClass.filter([name == "a3"]).get(0).returnType)
		assertEquals(1, declaredMethodsExtendedClassDerived.filter([
			name == "a3"
		]).size)
		assertSame(ControllerAttributeStringConcrete2, declaredMethodsExtendedClassDerived.filter([
			name == "a3"
		]).get(0).returnType)

		// check case (b1)
		assertEquals(1, declaredMethodsExtendedClass.filter([
			name == "b1"
		]).size)
		assertSame(ControllerBase, declaredMethodsExtendedClass.filter([name == "b1"]).get(0).returnType)
		assertEquals(1, declaredMethodsExtendedClassDerived.filter([
			name == "b1"
		]).size)
		assertSame(ControllerAttributeStringConcrete1, declaredMethodsExtendedClassDerived.filter([
			name == "b1"
		]).get(0).returnType)

		// check case (b2)
		assertEquals(1, declaredMethodsExtendedClass.filter([
			name == "b2"
		]).size)
		assertSame(ControllerBase, declaredMethodsExtendedClass.filter([name == "b2"]).get(0).parameters.get(0).type)
		assertEquals(1, declaredMethodsExtendedClassDerived.filter([
			name == "b2"
		]).size)
		assertSame(ControllerAttributeStringConcrete1, declaredMethodsExtendedClassDerived.filter([
			name == "b2"
		]).get(0).parameters.get(0).type)

		// check case (b3)
		assertEquals(1, declaredMethodsExtendedClass.filter([
			name == "b3"
		]).size)
		assertSame(ControllerBase, declaredMethodsExtendedClass.filter([name == "b3"]).get(0).returnType)
		assertEquals(1, declaredMethodsExtendedClassDerived.filter([
			name == "b3"
		]).size)
		assertSame(ControllerAttributeString, declaredMethodsExtendedClassDerived.filter([
			name == "b3"
		]).get(0).returnType)

		// check case (b4)
		assertEquals(1, declaredMethodsExtendedClass.filter([
			name == "b4"
		]).size)
		assertSame(ControllerBase, declaredMethodsExtendedClass.filter([name == "b4"]).get(0).returnType)
		assertEquals(0, declaredMethodsExtendedClassDerived.filter([
			name == "b4"
		]).size)

	}

	@Test
	def void testConstructorTypeAdaptionWithVariable() {

		assertEquals(1, ConstructorTypeAdaptionWithVariableExtendedClass.declaredMethods.filter([
			name == "create"
		]).size)

		val createMethod = ConstructorTypeAdaptionWithVariableExtendedClass.declaredMethods.filter([
			name == "create"
		]).get(0)

		assertEquals(3, createMethod.parameterCount)
		assertSame(AnotherDerived, createMethod.parameters.get(0).type)
		assertSame(AnotherBase, createMethod.parameters.get(1).type)
		assertSame(Derived, createMethod.parameters.get(2).type)

	}

	@Test
	def void testAdaptionWithOverriding() {

		assertEquals(" TestC1XL", new ExtendedClassVar().variable)

	}

}
