package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import java.lang.reflect.Modifier
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ComponentFeature
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ComponentTopLevel
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttribute
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerEnhanced_CAN_BE_REMOVED
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerFeature
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerTopLevel
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IComponentBase
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IComponentEnhanced
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IComponentFeature
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IComponentTopLevel
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IControllerBase
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IControllerFeature
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IControllerTopLevel
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@ApplyRules
class AdaptedClass1 {

	public int value

	new(
		@TypeAdaptionRule
		int value
	) {
		this.value = value
	}

}

@ApplyRules
class AdaptedClass2 extends AdaptedClass1 {
}

class TypeAdaptionTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testConstructorAdaptionWithoutTypeChange() {

		val obj = new AdaptedClass2(3)

		assertEquals(3, obj.value)

	}

	@Test
	def void testTypeAdaptionApplyAppendPrepend() {

		assertEquals(1, ControllerTopLevel.declaredMethods.filter [
			name == "getControllerApplyAppendPrepend" && synthetic == false
		].size)
		assertSame(IControllerTopLevel, ControllerTopLevel.declaredMethods.filter [
			name == "getControllerApplyAppendPrepend" && synthetic == false
		].get(0).returnType)

		assertEquals(1, ControllerTopLevel.declaredMethods.filter [
			name == "getControllerApplyAppendPrependVariable" && synthetic == false
		].size)
		assertSame(
			ControllerTopLevel,
			ControllerTopLevel.declaredMethods.filter [
				name == "getControllerApplyAppendPrependVariable" && synthetic == false
			].get(0).returnType
		)

	}

	@Test
	def void testContollerComponentAdaptionsMethods() {

		assertEquals(3, ControllerTopLevel.declaredMethods.filter[synthetic == false].size)
		assertEquals(1, ControllerTopLevel.declaredMethods.filter[synthetic == false && name == "_comp"].size)
		assertSame(IComponentTopLevel,
			ControllerTopLevel.declaredMethods.filter[synthetic == false && name == "_comp"].get(0).returnType)

		assertEquals(1, ControllerFeature.declaredMethods.filter[synthetic == false].size)
		assertEquals("_comp", ControllerFeature.declaredMethods.filter[synthetic == false].get(0).name)
		assertSame(IComponentFeature, ControllerFeature.declaredMethods.filter[synthetic == false].get(0).returnType)

		assertEquals(0, ControllerAttribute.declaredMethods.filter[synthetic == false].size)

		assertEquals(1, ControllerAttributeStringConcrete1.declaredMethods.filter[synthetic == false].size)

		assertEquals(1, ComponentTopLevel.declaredMethods.filter[synthetic == false].size)
		assertEquals("_ctrl", ComponentTopLevel.declaredMethods.filter[synthetic == false].get(0).name)
		assertSame(IControllerTopLevel, ComponentTopLevel.declaredMethods.filter[synthetic == false].get(0).returnType)

		assertEquals(1, ControllerEnhanced_CAN_BE_REMOVED.declaredMethods.filter[synthetic == false].size)
		assertEquals("_comp", ControllerEnhanced_CAN_BE_REMOVED.declaredMethods.filter[synthetic == false].get(0).name)
		assertSame(IComponentEnhanced,
			ControllerEnhanced_CAN_BE_REMOVED.declaredMethods.filter[synthetic == false].get(0).returnType)

	}

	@Test
	def void testContollerComponentAdaptionsConstructors() {

		assertEquals(1, ControllerAttribute.declaredConstructors.filter [
			Modifier.isPublic(it.modifiers)
		].size)
		assertEquals(1, ControllerAttribute.declaredConstructors.filter [
			Modifier.isPublic(it.modifiers)
		].get(0).parameterTypes.size)
		assertSame(IControllerBase, ControllerAttribute.declaredConstructors.filter [
			Modifier.isPublic(it.modifiers)
		].get(0).parameterTypes.get(0))

		assertEquals(1, ControllerTopLevel.declaredConstructors.filter [
			Modifier.isPublic(it.modifiers)
		].size)
		assertEquals(0, ControllerTopLevel.declaredConstructors.filter [
			Modifier.isPublic(it.modifiers)
		].get(0).parameterTypes.size)

		assertEquals(2, ComponentFeature.declaredConstructors.filter [
			Modifier.isPublic(it.modifiers)
		].size)
		var foundConstructor1 = false
		var foundConstructor2 = false
		for (var i = 0; i < 2; i++) {
			val parameterTypes = ComponentFeature.declaredConstructors.filter [
				Modifier.isPublic(it.modifiers)
			].get(i).parameterTypes
			if (parameterTypes.size == 2) {
				if (parameterTypes.get(0) === IControllerFeature && parameterTypes.get(1) === IComponentBase)
					foundConstructor1 = true
				else if(parameterTypes.get(0) === IControllerBase &&
					parameterTypes.get(1) == int) foundConstructor2 = true
			}
		}
		assertTrue(foundConstructor1)
		assertTrue(foundConstructor2)

	}

	@Test
	def void testContollerComponentAdaptionsExtractedInterfaces() {

		assertEquals(1, IComponentTopLevel.declaredMethods.filter[synthetic == false].size)
		assertSame(IControllerTopLevel, IComponentTopLevel.declaredMethods.filter[synthetic == false].get(0).returnType)

	}

	@Test
	def void testContollerComponentAdaptionsUsage() {

		val controllerTopLevel = new ControllerTopLevel();
		val controllerAttributeString = new ControllerAttributeStringConcrete1(controllerTopLevel);
		val componentFeature = new ComponentFeature(controllerAttributeString, null)

		assertSame(controllerTopLevel, controllerAttributeString.controllerParent)
		assertSame(controllerAttributeString, componentFeature._ctrl())

		// use alternative constructor
		val componentFeatureAlternative = new ComponentFeature(controllerAttributeString, 5)
		assertSame(controllerAttributeString, componentFeatureAlternative._ctrl())

	}

	@Test
	def void testRequiredMethodMustBeAbstract() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule

import static org.junit.Assert.*

@ApplyRules
class TypeAdaptionFunctionTest {

	@TypeAdaptionRule("se t(XXX)")
	def Object get() {
		null
	}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.TypeAdaptionFunctionTest")

			val problemsMethod = (clazz.findDeclaredMethod("get").primarySourceElement as MethodDeclaration).problems

			// do assertions
			assertEquals(1, problemsMethod.size)
			assertEquals(Severity.ERROR, problemsMethod.get(0).severity)
			assertTrue(problemsMethod.get(0).message.contains("not found"))

			assertEquals(1, allProblems.size)

		]

	}

	@Test
	def void testTypeAdaptionNotOnFields() {
		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule

import static org.junit.Assert.*

@ApplyRules
class ClassWithField {

	@TypeAdaptionRule("apply(Something)")
	Object controller

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ClassWithField")

			val problemsFieldController = (clazz.findDeclaredField("controller").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(1, problemsFieldController.size)
			assertEquals(Severity.ERROR, problemsFieldController.get(0).severity)
			assertTrue(problemsFieldController.get(0).message.contains("cannot be applied to a field"))

			assertEquals(1, allProblems.size)

		]

	}

}
