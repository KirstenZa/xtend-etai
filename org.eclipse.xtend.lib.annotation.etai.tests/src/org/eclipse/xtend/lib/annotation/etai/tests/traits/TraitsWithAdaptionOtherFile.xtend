package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ImplAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassWithRequiredMethodImplAdapted

// The following classes belong to ExtensionWithAdaption.xtend (this way a bug concerning the transformation order is possible)
@ApplyRules
@TraitClassAutoUsing
abstract class TraitClassWithRequiredMethodImplAdaptedBase {
	
	@RequiredMethod
	@ImplAdaptionRule(value="apply(return null;)", typeExistenceCheck="applyVariable(var.class.abstract);replace(false,);appendVariable(var.class.qualified)")
	override TraitClassWithRequiredMethodImplAdapted req1()
	 
}

@ApplyRules
@TraitClassAutoUsing
abstract class TraitClassWithRequiredMethodImplAdapted extends TraitClassWithRequiredMethodImplAdaptedBase {
	
	@RequiredMethod
	@ImplAdaptionRule(value="apply(return null;)", typeExistenceCheck="applyVariable(var.class.abstract);replace(false,);appendVariable(var.class.qualified)")
	override TraitClassWithRequiredMethodImplAdapted req2()
	 
}

@ApplyRules
@ExtendedByAuto
abstract class ExtendedClassWithRequiredMethodImplAdapted implements ITraitClassWithRequiredMethodImplAdapted {
}