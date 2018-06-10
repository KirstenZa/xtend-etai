package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TraitMethodProcessor
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.LazyEvaluation
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClass1

@ExtractInterface
abstract class BaseClass1 {

	override void _implementedBase() {
		System.out.println("BaseClass1::_implementedBase()");
	}

	override abstract void _abstractBase()

}

@ExtractInterface
abstract class DerivedClass1 extends BaseClass1 {

	override void _implementedDerived() {
		System.out.println("DerivedClass1::_implementedDerived()");
	}

	override abstract void _abstractDerived()

}

@TraitClassAutoUsing
abstract class BaseTraitClass1 {

	static def void allowedStaticMethod() {
	}

	@ExclusiveMethod
	protected def void allowedProtectedMethod() {
		allowedPrivateMethod()
	}

	private def void allowedPrivateMethod() {
	}

	@ProcessedMethod(processor=EPVoidPre)
	override void _implementedBaseExtension() {
		System.out.println("BaseTraitClass1::_implementedBaseExtension()")
	}

	@ProcessedMethod(processor=EPVoidPre)
	override void _abstractDerived() {
		System.out.println("TraitClass1::_abstractDerived()")
	}

}

@TraitClassAutoUsing
abstract class TraitClass1 extends BaseTraitClass1 {

	@ProcessedMethod(processor=EPVoidPre)
	override void _implementedExtension() {
		System.out.println("TraitClass1::_implementedExtension()")
	}

	@ProcessedMethod(processor=EPVoidPre)
	override void _abstractBaseExtension() {
		System.out.println("TraitClass1::_abstractBaseExtension()")
	}

	@ProcessedMethod(processor=EPVoidPre)
	override void _implementedDerived() {
		System.out.println("TraitClass1::_implementedDerived()")
	}

	@ProcessedMethod(processor=EPVoidPre)
	override void _implementedBase() {
		System.out.println("TraitClass1::_implementedBase()")
	}

	@ProcessedMethod(processor=EPVoidPre)
	override void _abstractBase() {
		System.out.println("TraitClass1::_abstractBase()")
	}

	@ProcessedMethod(processor=SomeProcessor)
	override boolean equals(Object arg0) {
		return false
	}

}

class SomeProcessor implements TraitMethodProcessor {

	override call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {
		throw new UnsupportedOperationException("Exception!")
	}

}

@ExtractInterface
@ExtendedByAuto
class ContreteClass1 extends DerivedClass1 implements ITraitClass1 {
	override void _abstractBase() {
		System.out.println("ContreteClass1::_abstractBase()")
	}
}
