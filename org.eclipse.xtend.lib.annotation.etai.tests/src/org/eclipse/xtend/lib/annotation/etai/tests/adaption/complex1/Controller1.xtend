package org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.ControllerAttributeStringConcrete2

@ExtractInterface
@ApplyRules
abstract class ControllerAttributeString extends ControllerAttribute {

	abstract override String getAString()

}

@ExtractInterface
@ApplyRules
class ControllerAttributeStringConcrete1 extends ControllerAttributeString {

	override String getAString() { return "ControllerAttributeStringConcrete1" }

}

@ApplyRules
class ControllerAttributeStringConcreteSubSub extends ControllerAttributeStringConcrete2 {

	override String getAString() { return "ControllerAttributeStringConcreteSubSub" }

}

@ExtractInterface
@ApplyRules
class ControllerEnhanced_CAN_BE_REMOVED extends ControllerClassPart {
}
