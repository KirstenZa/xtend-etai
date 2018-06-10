package org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.CopyConstructorRule
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.SetAdaptionVariable
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IComponentBase
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IControllerBase

@ExtractInterface
@ApplyRules
@SetAdaptionVariable("%varLevel%=Level")
class ControllerBase {

	public IComponentBase comp;
	public IControllerBase controllerParent;

	@CopyConstructorRule
	new(IControllerBase controllerParent) {
		this.controllerParent = controllerParent;
	}

	@TypeAdaptionRule("applyVariable(var.class.qualified);replace(Controller,intf.IComponent);replace(_CAN_BE_REMOVED,)")
	override IComponentBase _comp() {
		return comp;
	}
	
	@TypeAdaptionRule("apply(IControllerTopLevel);replace(Level,);append(Level);prepend(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.)")
	override IControllerBase getControllerApplyAppendPrepend() {
		return null;
	}
	
	@TypeAdaptionRule("applyVariable(var.class.simple);replace(Level,);appendVariable(%varLevel%);prepend(.);prependVariable(var.package)")
	override ControllerBase getControllerApplyAppendPrependVariable() {
		return null;
	}
	
}

@ExtractInterface
@ApplyRules
class ControllerTopLevel extends ControllerBase {

	new() {
		super(null)
	}

}

@ExtractInterface
@ApplyRules
abstract class ControllerClassPart extends ControllerBase {
}

@ExtractInterface
@ApplyRules
abstract class ControllerFeature extends ControllerClassPart {
}

@ExtractInterface
@ApplyRules
abstract class ControllerAttribute extends ControllerFeature {
}
