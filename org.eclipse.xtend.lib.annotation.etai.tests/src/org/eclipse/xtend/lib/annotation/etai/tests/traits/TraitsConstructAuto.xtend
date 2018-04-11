package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ConstructRuleAuto
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassAutoConstructUsed
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassAutoConstructUsedNoConstructor
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassAutoConstructUsing
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassAutoConstructUsingNoConstructor
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassConstructRuleAutoNoConstructor
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassAutoConstructUsed {

	int value1

	@ConstructorMethod
	protected def void doConstruct(int value1) {
		this.value1 = value1
	}

	@ExclusiveMethod
	override int getValue1() {
		value1
	}

}

@TraitClassAutoUsing
abstract class TraitClassAutoConstructUsedNoConstructor {

	@ExclusiveMethod
	override int getValue3() {
		80
	}

}

@TraitClassAutoUsing
abstract class TraitClassAutoConstructUsing implements ITraitClassAutoConstructUsed, ITraitClassAutoConstructUsedNoConstructor {

	int value2

	@ConstructorMethod
	protected def void doConstruct(int value2) {
		this.value2 = value2
	}

	@ExclusiveMethod
	override int getValue2() {
		value2
	}

}

@TraitClassAutoUsing
abstract class TraitClassAutoConstructUsingNoConstructor implements ITraitClassAutoConstructUsed, ITraitClassAutoConstructUsedNoConstructor {

	@ExclusiveMethod
	override int getValue4() {
		90
	}

}

@ExtendedByAuto
@FactoryMethodRule(factoryMethod="create")
@ConstructRuleAuto
@ApplyRules
class ExtendedConstructRuleAuto implements ITraitClassAutoConstructUsing, ITraitClassAutoConstructUsingNoConstructor {
}

@TraitClassAutoUsing
abstract class TraitClassConstructRuleAutoNoConstructor {
}

// Must compile without error, because "ConstructRuleAuto" shall be silently accept, if there is nothing to be constructed automatically 
@ExtendedByAuto
@FactoryMethodRule(factoryMethod="create")
@ConstructRuleAuto
@ApplyRules
abstract class ExtendedClassConstructRuleAutoNoConstructor implements ITraitClassConstructRuleAutoNoConstructor {
}

class TraitsConstructAllTests extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testExtensionConstructRuleAuto() {

		val obj = ExtendedConstructRuleAuto::create(10, 40)

		assertEquals(40, obj.value1);
		assertEquals(10, obj.value2);
		assertEquals(80, obj.value3);
		assertEquals(90, obj.value4);

	}

	@Test
	def void testNotApplicableWithRegularRule() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ConstructRule
import org.eclipse.xtend.lib.annotation.etai.ConstructRuleAuto
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto

import virtual.intf.ITraitClassSimple

@TraitClassAutoUsing
abstract class TraitClassSimple {

	@ConstructorMethod
	protected def void construct(int param) {}

}

@ApplyRules
@ConstructRule(TraitClassSimple)
@ConstructRuleAuto
@FactoryMethodRule(factoryMethod="create")
@ExtendedByAuto
class ExtendedClassSimple implements ITraitClassSimple {
}


		'''.compile [

			val extension ctx = transformationContext

			val clazz1 = findClass("virtual.ExtendedClassSimple")

			val problemsClass1 = (clazz1.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass1.size)
			assertEquals(Severity.ERROR, problemsClass1.get(0).severity)
			assertTrue(problemsClass1.get(0).message.contains("apply both"))

		]

	}

}
