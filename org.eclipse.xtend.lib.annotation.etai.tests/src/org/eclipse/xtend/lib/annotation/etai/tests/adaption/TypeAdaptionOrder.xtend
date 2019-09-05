/**
 * Test passes if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules

@ApplyRules
class CommandContainerFeature {

	new(
		@TypeAdaptionRule
		Object controllerBase
	) {
	}

}

@ApplyRules
class CommandContainerFeatureAttribute extends CommandContainerFeatureUnsettable {	
}

@ApplyRules
class CommandContainerFeatureSingle extends CommandContainerFeature {
}

@ApplyRules
class CommandContainerFeatureUnsettable extends CommandContainerFeatureSingle {
}
