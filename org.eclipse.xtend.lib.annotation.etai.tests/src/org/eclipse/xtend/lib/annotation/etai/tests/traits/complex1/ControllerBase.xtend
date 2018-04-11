package org.eclipse.xtend.lib.annotation.etai.tests.traits.complex1

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.tests.traits.complex1.intf.IControllerManagement

@ExtractInterface
abstract class ControllerBase {

	override IControllerManagement _mgmt() {
		return null
	}
	
}
