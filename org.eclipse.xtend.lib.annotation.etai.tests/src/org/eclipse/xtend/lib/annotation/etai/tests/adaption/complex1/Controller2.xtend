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
public class ControllerBase {

	public IComponentBase comp;
	public IControllerBase controllerParent;

	@CopyConstructorRule
	new(IControllerBase controllerParent) {
		this.controllerParent = controllerParent;
	}

	@TypeAdaptionRule("applyVariable(var.class.qualified);replace(Controller,intf.IComponent);replace(_CAN_BE_REMOVED,)")
	public override IComponentBase _comp() {
		return comp;
	}
	
	@TypeAdaptionRule("apply(IControllerTopLevel);replace(Level,);append(Level);prepend(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.)")
	public override IControllerBase getControllerApplyAppendPrepend() {
		return null;
	}
	
	@TypeAdaptionRule("applyVariable(var.class.simple);replace(Level,);appendVariable(%varLevel%);prepend(.);prependVariable(var.package)")
	public override ControllerBase getControllerApplyAppendPrependVariable() {
		return null;
	}
	
}

@ExtractInterface
@ApplyRules
public class ControllerTopLevel extends ControllerBase {

	new() {
		super(null)
	}

}

@ExtractInterface
@ApplyRules
public abstract class ControllerClassPart extends ControllerBase {
}

@ExtractInterface
@ApplyRules
public abstract class ControllerFeature extends ControllerClassPart {
}

@ExtractInterface
@ApplyRules
public abstract class ControllerAttribute extends ControllerFeature {
}
