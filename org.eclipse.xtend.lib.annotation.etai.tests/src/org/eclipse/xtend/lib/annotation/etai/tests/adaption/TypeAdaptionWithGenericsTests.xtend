package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.CopyConstructorRule
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IComponentWithGenericsBase
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IControllerWithGenericsBase
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IControllerWithGenericsClassPart
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IControllerWithGenericsTopLevel
import java.lang.reflect.Modifier
import org.junit.Test

import static org.junit.Assert.*
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IComponentWithGenericsTopLevel

@ExtractInterface
@ApplyRules
public class ControllerWithGenericsBase<T> {

	public IComponentWithGenericsBase<T> comp;
	public IControllerWithGenericsBase<T> controllerParent;

	@CopyConstructorRule
	new(
		IControllerWithGenericsBase<T> controllerParent) {
		this.controllerParent = controllerParent;
	}

	@TypeAdaptionRule("applyVariable(var.class.qualified);replace(Controller,intf.IComponent);replace(_CAN_BE_REMOVED,)")
	public override IComponentWithGenericsBase<T> _comp() {
		return comp;
	}

	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IComponentWithGenericsTopLevel);addTypeParamWildcardSuper(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.ControllerWithGenericsTopLevel);addTypeParam(apply(?));addTypeParam(apply(?)));addTypeParamWildcardExtends(apply(Integer))")
	public override IComponentWithGenericsBase<? extends Number> _compComplexAdaption() {
		return null;
	}

	override T getSomething() {
		return null
	}

}

@ExtractInterface
@ApplyRules
public class ControllerWithGenericsTopLevel<B, C> extends ControllerWithGenericsBase<C> {

	new() {
		super(
			null)
	}

}

@ExtractInterface
@ApplyRules
public class ControllerWithGenericsClassPart extends ControllerWithGenericsBase<Integer> {
}

@ExtractInterface
@ApplyRules
public class ComponentWithGenericsBase<T> {

	public IComponentWithGenericsBase<T> componentParent;
	public IControllerWithGenericsBase<T> controller;

	new(
		@TypeAdaptionRule("applyVariable(var.class.simple);replace(Component,org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IController);addTypeParams()")
		IControllerWithGenericsBase<T> controller,
		IComponentWithGenericsBase<T> componentParent
	) {
		this.controller = controller;
		this.componentParent = componentParent;
	}

	@TypeAdaptionRule("applyVariable(var.class.simple);replace(Component,org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IController);addTypeParam(applyVariable(var.class.typeparameter.1));addTypeParam(applyVariable(var.class.typeparameter.2));addTypeParam(applyVariable(var.class.typeparameter.3))")
	public override IControllerWithGenericsBase<T> _ctrl() {
		return controller;
	}

	@TypeAdaptionRule("applyVariable(var.class.simple);replace(Component,org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IController);addTypeParam(applyVariable(var.class.typeparameter.1));addTypeParam(applyVariable(var.class.typeparameter.2))")
	public override <K extends T> IControllerWithGenericsBase<T> _ctrlExtended(K someValue) {
		return controller;
	}

}

@ApplyRules
@ExtractInterface
public class ComponentWithGenericsTopLevel<B, C> extends ComponentWithGenericsBase<C> {

	new(IControllerWithGenericsTopLevel<B, C> controller) {
		super(controller, null)
	}

}

@ExtractInterface
@ApplyRules
public class ComponentWithGenericsClassPart extends ComponentWithGenericsBase<Integer> {
}

class TypeAdaptionWithGenericsTests {

	@Test
	def void testAdaptionWithGenericsConstructors() {

		assertEquals(1, ComponentWithGenericsTopLevel.declaredConstructors.filter [
			Modifier.isPublic(it.modifiers)
		].size)
		assertEquals(1, ComponentWithGenericsClassPart.declaredConstructors.filter [
			Modifier.isPublic(it.modifiers)
		].size)

	}

	@Test
	def void testAdaptionWithGenericsComplex() {

		// must compile, if type is adapted correctly
		val obj = new ControllerWithGenericsTopLevel<Float, Float>()
		val IComponentWithGenericsTopLevel<? super ControllerWithGenericsTopLevel<?, ?>, ? extends Integer> myVar = obj.
			_compComplexAdaption
		assertNull(myVar)

	}

	@Test
	def void testAdaptionWithGenerics() {

		val controllerTopLevel = new ControllerWithGenericsTopLevel<Character, Integer>()
		val componentTopLevel = new ComponentWithGenericsTopLevel<Character, Integer>(controllerTopLevel)

		val controllerClassPart = new ControllerWithGenericsClassPart(controllerTopLevel)
		val componentClassPart = new ComponentWithGenericsClassPart(controllerClassPart, componentTopLevel)

		var Integer myInt1 = controllerTopLevel.something
		var Integer myInt2 = controllerClassPart.something

		assertNull(myInt1)
		assertNull(myInt2)

		var IControllerWithGenericsClassPart controllerWithGenericsClassPart = componentClassPart._ctrl()
		var IControllerWithGenericsTopLevel<Character, Integer> controllerWithGenericsTopLevel = componentTopLevel.
			_ctrl()
		var IControllerWithGenericsBase<Integer> controllerWithGenericsClassPartBase = componentClassPart._ctrl()
		var IControllerWithGenericsBase<Integer> controllerWithGenericsTopLevelBase = componentTopLevel._ctrl()

		assertNotNull(controllerWithGenericsClassPart)
		assertNotNull(controllerWithGenericsTopLevel)
		assertNotNull(controllerWithGenericsClassPartBase)
		assertNotNull(controllerWithGenericsTopLevelBase)

	}

}
