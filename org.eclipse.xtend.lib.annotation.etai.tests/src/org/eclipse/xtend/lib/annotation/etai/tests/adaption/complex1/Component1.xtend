package org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface

@ExtractInterface
@ApplyRules
class ComponentClassPart extends ComponentBase {
}

@ExtractInterface
@ApplyRules
class ComponentFeature extends ComponentClassPart {
}

@ExtractInterface
@ApplyRules	
class ComponentEnhanced extends ComponentClassPart {
}