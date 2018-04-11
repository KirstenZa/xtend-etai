package org.eclipse.xtend.lib.annotation.etai.tests.traits.complex1

import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.tests.traits.complex1.intf.IControllerBase
import org.eclipse.xtend.lib.annotation.etai.tests.traits.complex1.intf.IControllerApp

@TraitClassAutoUsing
abstract class XControllerChild<TPARENT> implements IControllerBase {

	@ExclusiveMethod
	override IControllerApp _app() {

		return null

	}

}

@TraitClassAutoUsing
abstract class XControllerParent<TCHILD> implements IControllerBase {
}
