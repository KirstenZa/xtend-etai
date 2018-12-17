/**
 * Classes in this file should be separated, because this way potential problems can be detected.
 */

package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import org.eclipse.xtend.lib.annotation.etai.ApplyRules

@ApplyRules
class TypeAdaptionMethodParametersSimpleDerivedOtherFile extends TypeAdaptionMethodParametersSimpleBase {
}

@ApplyRules
class TypeAdaptionMethodParametersSimpleDerivedNotImplementedAgainOtherFile extends TypeAdaptionMethodParametersSimpleDerived {
}
