package org.eclipse.xtend.lib.annotation.etai.tests.traits.complex1

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.tests.traits.complex1.intf.IXControllerChild
import org.eclipse.xtend.lib.annotation.etai.tests.traits.complex1.intf.IXControllerParent

@ExtendedByAuto
@ExtractInterface
abstract class ControllerApp extends ControllerBase implements IXControllerParent<IXControllerChild<?>> {
}
