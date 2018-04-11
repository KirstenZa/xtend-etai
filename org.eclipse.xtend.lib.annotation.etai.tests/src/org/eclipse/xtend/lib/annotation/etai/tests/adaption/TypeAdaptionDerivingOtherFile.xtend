package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import org.eclipse.xtend.lib.annotation.etai.ConstructRuleAuto
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITraitClassTypeAdaptionDerivedA2

@ExtendedByAuto
@ConstructRuleAuto
@ExtractInterface
@FactoryMethodRule(factoryMethod="create")
@ApplyRules
class ExtendedClass_A3_AttributeString extends ExtendedClassAttributeStringBase implements ITraitClassTypeAdaptionDerivedA2 {
}

@ApplyRules
@ExtractInterface
class ExtendedClass_A3_AttributeStringConcrete1 extends ExtendedClass_A3_AttributeString {
}
