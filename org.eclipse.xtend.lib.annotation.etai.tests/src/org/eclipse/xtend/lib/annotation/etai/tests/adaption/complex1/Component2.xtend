package org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.CopyConstructorRule
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IControllerBase
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IComponentBase

@ExtractInterface
@ApplyRules
public class ComponentBase {

	public IComponentBase componentParent;
	public IControllerBase controller;

	new(
		@TypeAdaptionRule("applyVariable(var.class.simple);replace(Component,org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IController)")
		IControllerBase controller,
		IComponentBase componentParent
	) {
		this.controller = controller;
		this.componentParent = componentParent;
	}

	@CopyConstructorRule
	new(
		IControllerBase controller,
		int param
	) {
		this.controller = controller;
	}

	@TypeAdaptionRule("applyVariable(var.class.simple);replace(Component,org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IController)")
	public override IControllerBase _ctrl() {
		return controller;
	}

}

@ApplyRules
@ExtractInterface
public class ComponentIntermediate extends ComponentBase {
}


@ApplyRules
@ExtractInterface
public class ComponentTopLevel extends ComponentIntermediate {
}
