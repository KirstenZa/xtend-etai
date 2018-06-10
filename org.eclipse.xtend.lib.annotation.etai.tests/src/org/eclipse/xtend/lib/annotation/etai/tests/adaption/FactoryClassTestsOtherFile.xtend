package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString

@ApplyRules
class ClassWithFactoryClassAdaptedTwiceConcreteOtherFile extends ClassWithFactoryClassAdaptedTwiceDerived {
}

@ExtractInterface
@ApplyRules
class ControllerAttributeStringConcrete2 extends ControllerAttributeString {
}
