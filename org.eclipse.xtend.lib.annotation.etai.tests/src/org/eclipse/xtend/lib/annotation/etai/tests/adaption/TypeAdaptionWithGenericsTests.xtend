package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import java.lang.reflect.Modifier
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.CopyConstructorRule
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IComponentWithGenericsBase
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IComponentWithGenericsTopLevel
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IControllerWithGenericsBase
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IControllerWithGenericsClassPart
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IControllerWithGenericsTopLevel
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@ExtractInterface
@ApplyRules
class ControllerWithGenericsBase<T> {

	public IComponentWithGenericsBase<T> comp;
	public IControllerWithGenericsBase<T> controllerParent;

	@CopyConstructorRule
	new(IControllerWithGenericsBase<T> controllerParent) {
		this.controllerParent = controllerParent;
	}

	@TypeAdaptionRule("applyVariable(var.class.qualified);replace(Controller,intf.IComponent);replace(_CAN_BE_REMOVED,)")
	override IComponentWithGenericsBase<T> _comp() {
		return comp;
	}

	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IComponentWithGenericsTopLevel);addTypeParamWildcardSuper(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.ControllerWithGenericsTopLevel);addTypeParam(apply(?));addTypeParam(apply(?)));addTypeParamWildcardExtends(apply(Integer))")
	override IComponentWithGenericsBase<? extends Number> _compComplexAdaption() {
		return null;
	}

	override T getSomething() {
		return null
	}

}

@ExtractInterface
@ApplyRules
class ControllerWithGenericsTopLevel<B, C> extends ControllerWithGenericsBase<C> {

	new() {
		super(null)
	}

}

@ExtractInterface
@ApplyRules
class ControllerWithGenericsClassPart extends ControllerWithGenericsBase<Integer> {
}

@ExtractInterface
@ApplyRules
class ComponentWithGenericsBase<T> {

	public IComponentWithGenericsBase<T> componentParent;
	public IControllerWithGenericsBase<T> controller;

	new(
		@TypeAdaptionRule("applyVariable(var.class.simple);replace(Component,org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IController);addTypeParam(applyVariable(var.class.typeparameter.1));addTypeParam(applyVariable(var.class.typeparameter.2))")
		IControllerWithGenericsBase<T> controller,
		IComponentWithGenericsBase<T> componentParent
	) {
		this.controller = controller;
		this.componentParent = componentParent;
	}

	@TypeAdaptionRule("applyVariable(var.class.simple);replace(Component,org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IController);addTypeParam(applyVariable(var.class.typeparameter.1));addTypeParam(applyVariable(var.class.typeparameter.2));addTypeParam(applyVariable(var.class.typeparameter.3))")
	override IControllerWithGenericsBase<T> _ctrl() {
		return controller;
	}

	@TypeAdaptionRule("applyVariable(var.class.simple);replace(Component,org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IController);addTypeParam(applyVariable(var.class.typeparameter.1));addTypeParam(applyVariable(var.class.typeparameter.2))")
	override <K extends T> IControllerWithGenericsBase<T> _ctrlExtended(K someValue) {
		return controller;
	}

}

@ApplyRules
@ExtractInterface
class ComponentWithGenericsTopLevel<B, C> extends ComponentWithGenericsBase<C> {

	new(IControllerWithGenericsTopLevel<B, C> controller) {
		super(controller, null)
	}

}

@ExtractInterface
@ApplyRules
class ComponentWithGenericsClassPart extends ComponentWithGenericsBase<Integer> {
}

@ApplyRules
class TypeAdaptionWithGenericsMainTypeBase<T extends Number> {

	T x

	def void setTU(
		@TypeAdaptionRule("apply(U)")
		T newX
	) {
		x = newX
	}

	@TypeAdaptionRule("apply(U)")
	def T getTU() {
		return x
	}

}

@ApplyRules
class TypeAdaptionWithGenericsMainTypeDerived<U extends Integer, V extends Integer> extends TypeAdaptionWithGenericsMainTypeBase<U> {
}

class TypeAdaptionWithGenericsTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

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

	@Test
	def void testAdaptionWithGenericsMainType() {

		// must compile, if type is adapted correctly
		val obj = new TypeAdaptionWithGenericsMainTypeDerived<Integer, Integer>()
		obj.setTU(Integer::valueOf(10))
		assertEquals(10, obj.getTU().intValue)

	}

	@Test
	def void testAdaptionWithGenericsMainTypeMismatch() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule

@ApplyRules
class TypeAdaptionWithGenericsMainTypeBase<T extends java.lang.Number> {

	T x

	def void setTV(
		@TypeAdaptionRule("apply(V)")
		T newX
	) {
		x = newX
	}

	@TypeAdaptionRule("apply(V)")
	def T getTV() {
		return x
	}

}

@ApplyRules
class TypeAdaptionWithGenericsMainTypeDerived<U extends java.lang.Integer, V extends java.lang.Integer> extends TypeAdaptionWithGenericsMainTypeBase<U> {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.TypeAdaptionWithGenericsMainTypeDerived')

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("type parameter"))

			assertEquals(1, allProblems.size)

		]

	}

}
