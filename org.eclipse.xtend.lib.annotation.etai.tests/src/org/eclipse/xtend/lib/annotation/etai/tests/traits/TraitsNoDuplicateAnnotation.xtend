/**
 * Test passes, if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.IBaseClassNoDuplicate

interface IPrioritizedObject {
	def int getPriority()
}

@ExtractInterface
class BaseClassNoDuplicate {

	override int getPriority() {
		5
	}

}

@TraitClassAutoUsing
abstract class TraitClassNoDuplicate implements IBaseClassNoDuplicate, IPrioritizedObject {
}

@ExtractInterface
class ConcreteExtendedClassNoDuplicate extends BaseClassNoDuplicate {
}
