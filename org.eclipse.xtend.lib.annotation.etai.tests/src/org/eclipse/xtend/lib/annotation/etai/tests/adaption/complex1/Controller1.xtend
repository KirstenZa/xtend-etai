package org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.ControllerAttributeStringConcrete2

@ExtractInterface
@ApplyRules
public abstract class ControllerAttributeString extends ControllerAttribute {
}

@ExtractInterface
@ApplyRules
public class ControllerAttributeStringConcrete1 extends ControllerAttributeString {
}

@ApplyRules
public class ControllerAttributeStringConcreteSubSub extends ControllerAttributeStringConcrete2 {	
}


@ExtractInterface
@ApplyRules
public class ControllerEnhanced_CAN_BE_REMOVED extends ControllerClassPart {
}