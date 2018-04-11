package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import org.eclipse.xtend.lib.annotation.etai.ConstructRuleAuto
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITypeAdaptionConstructTraitClass2
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITypeAdaptionConstructFactoryTraitClass2
import org.eclipse.xtend.lib.annotation.etai.tests.traits.TypeA
import org.eclipse.xtend.lib.annotation.etai.tests.traits.TypeB
import org.junit.Test

import static org.junit.Assert.*

@ApplyRules
@TraitClassAutoUsing
abstract class TypeAdaptionConstructTraitClass1 {

	@ConstructorMethod
	protected def void construct(
		@TypeAdaptionRule("applyVariable(var.class.simple);replace(TypeAdaption,);replace(ConstructExtendedClass1,org.eclipse.xtend.lib.annotation.etai.tests.traits.TypeB)")
		TypeA value1,
		@TypeAdaptionRule("applyVariable(var.class.simple);replace(TypeAdaption,);replace(ConstructTraitClass2,org.eclipse.xtend.lib.annotation.etai.tests.traits.TypeB)")
		TypeA value2
	) {
	}

}

@ApplyRules
@TraitClassAutoUsing
abstract class TypeAdaptionConstructTraitClass2 extends TypeAdaptionConstructTraitClass1 {
}

@ApplyRules
@ExtendedByAuto
@FactoryMethodRule(factoryMethod="create")
@ConstructRuleAuto
class TypeAdaptionConstructExtendedClass1 implements ITypeAdaptionConstructTraitClass2 {
}

@ApplyRules
class TypeAdaptionConstructExtendedClass2 extends TypeAdaptionConstructExtendedClass1 {
}

@ApplyRules
@TraitClassAutoUsing
abstract class TypeAdaptionConstructFactoryTraitClass1 {

	@ConstructorMethod
	protected def void construct(
		@TypeAdaptionRule("applyVariable(var.class.simple);replace(TypeAdaption,);replace(ConstructFactoryExtendedClass1,org.eclipse.xtend.lib.annotation.etai.tests.traits.TypeB)")
		TypeA value1,
		@TypeAdaptionRule("applyVariable(var.class.simple);replace(TypeAdaption,);replace(ConstructFactoryTraitClass2,org.eclipse.xtend.lib.annotation.etai.tests.traits.TypeB)")
		TypeA value2
	) {
	}

}

@ApplyRules
@TraitClassAutoUsing
abstract class TypeAdaptionConstructFactoryTraitClass2 extends TypeAdaptionConstructFactoryTraitClass1 {
}

@ApplyRules
@ExtendedByAuto
@FactoryMethodRule(factoryMethod="create", factoryInstance="FACTORY")
@ConstructRuleAuto
class TypeAdaptionConstructFactoryExtendedClass1 implements ITypeAdaptionConstructFactoryTraitClass2 {
}

@ApplyRules
class TypeAdaptionConstructFactoryExtendedClass2 extends TypeAdaptionConstructFactoryExtendedClass1 {
}

class TypeAdaptionConstruct {

	@Test
	def void testTypeAdaptionConstructType() {
		assertNotNull(TypeAdaptionConstructExtendedClass2.getMethod("create", TypeB, TypeB))
		assertNotNull(TypeAdaptionConstructFactoryExtendedClass2::FACTORY.class.getMethod("create", TypeB, TypeB))
	}

}
