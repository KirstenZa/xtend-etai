package org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface

@ExtractInterface
@ApplyRules
public class ComponentClassPart extends ComponentBase {
}

@ExtractInterface
@ApplyRules
public class ComponentFeature extends ComponentClassPart {
}

@ExtractInterface
@ApplyRules	
public class ComponentEnhanced extends ComponentClassPart {
}