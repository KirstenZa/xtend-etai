package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ConstructRuleAuto
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITypeAdaptionConstructFactoryTraitClass2
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITypeAdaptionConstructTraitClass2
import org.eclipse.xtend.lib.annotation.etai.tests.traits.TypeA
import org.eclipse.xtend.lib.annotation.etai.tests.traits.TypeB
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@ApplyRules
@TraitClassAutoUsing
abstract class TypeAdaptionConstructTraitClass1 {

	@ConstructorMethod
	protected def void construct(
		@TypeAdaptionRule("applyVariable(var.class.simple);replace(TypeAdaption,);replace(ConstructExtendedClass1,org.eclipse.xtend.lib.annotation.etai.tests.traits.TypeB)")
		TypeA value1,
		@TypeAdaptionRule("applyVariable(var.class.simple);replace(TypeAdaption,);replace(ConstructTraitClass2,org.eclipse.xtend.lib.annotation.etai.tests.traits.TypeB)")
		TypeA value2
	) {
	}

}

@ApplyRules
@TraitClassAutoUsing
abstract class TypeAdaptionConstructTraitClass2 extends TypeAdaptionConstructTraitClass1 {
}

@ApplyRules
@ExtendedByAuto
@FactoryMethodRule(factoryMethod="create")
@ConstructRuleAuto
class TypeAdaptionConstructExtendedClass1 implements ITypeAdaptionConstructTraitClass2 {
}

@ApplyRules
class TypeAdaptionConstructExtendedClass2 extends TypeAdaptionConstructExtendedClass1 {
}

@ApplyRules
@TraitClassAutoUsing
abstract class TypeAdaptionConstructFactoryTraitClass1 {

	@ConstructorMethod
	protected def void construct(
		@TypeAdaptionRule("applyVariable(var.class.simple);replace(TypeAdaption,);replace(ConstructFactoryExtendedClass1,org.eclipse.xtend.lib.annotation.etai.tests.traits.TypeB)")
		TypeA value1,
		@TypeAdaptionRule("applyVariable(var.class.simple);replace(TypeAdaption,);replace(ConstructFactoryTraitClass2,org.eclipse.xtend.lib.annotation.etai.tests.traits.TypeB)")
		TypeA value2
	) {
	}

}

@ApplyRules
@TraitClassAutoUsing
abstract class TypeAdaptionConstructFactoryTraitClass2 extends TypeAdaptionConstructFactoryTraitClass1 {
}

@ApplyRules
@ExtendedByAuto
@FactoryMethodRule(factoryMethod="create", factoryInstance="FACTORY")
@ConstructRuleAuto
class TypeAdaptionConstructFactoryExtendedClass1 implements ITypeAdaptionConstructFactoryTraitClass2 {
}

@ApplyRules
class TypeAdaptionConstructFactoryExtendedClass2 extends TypeAdaptionConstructFactoryExtendedClass1 {
}

@ApplyRules
class TypeAdaptionConstructFallbackBase {

	public int testValue = 0

	new(
		@TypeAdaptionRule("apply(notFound)")
		Integer value
	) {
		testValue = 1
	}

	new(
		@TypeAdaptionRule("apply(notFound)")
		Double value
	) {
		testValue = 99
	}

	new(
		@TypeAdaptionRule("applyVariable(var.class.simple);replaceAll(TypeAdaptionConstructFallbackDerived,java.lang.Number);replaceAll(Type,NotFound)")
		Object value2
	) {
		testValue = 55
	}

}

@ApplyRules
class TypeAdaptionConstructFallbackDerived extends TypeAdaptionConstructFallbackBase {
}

@ApplyRules
class TypeAdaptionConstructFallbackAnotherDerived extends TypeAdaptionConstructFallbackDerived {
}

class TypeAdaptionConstruct {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testTypeAdaptionConstructType() {
		assertNotNull(TypeAdaptionConstructExtendedClass2.getMethod("create", TypeB, TypeB))
		assertNotNull(TypeAdaptionConstructFactoryExtendedClass2::FACTORY.class.getMethod("create", TypeB, TypeB))
	}

	@Test
	def void testTypeAdaptionConstructFallback() {

		val obj1 = new TypeAdaptionConstructFallbackDerived(new Integer(10))
		assertEquals(1, obj1.testValue)

		val obj2 = new TypeAdaptionConstructFallbackDerived(new Double(20.0))
		assertEquals(99, obj2.testValue)

		val obj3 = new TypeAdaptionConstructFallbackDerived(new Float(20.0f))
		assertEquals(55, obj3.testValue)

		val obj4 = new TypeAdaptionConstructFallbackDerived(new Integer(10))
		assertEquals(1, obj4.testValue)

		val obj5 = new TypeAdaptionConstructFallbackDerived(new Double(20.0))
		assertEquals(99, obj5.testValue)

		val obj6 = new TypeAdaptionConstructFallbackDerived(new Float(20.0f))
		assertEquals(55, obj6.testValue)

	}
	
	@Test
	def void testParameterAdaptionAmbiguityError() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.CopyConstructorRule

@ApplyRules
class TypeAdaptionConstructFallbackBase {

	@CopyConstructorRule
	new(Double value) {}

	new(
		@TypeAdaptionRule("applyVariable(var.class.simple);replaceAll(TypeAdaptionConstructFallbackDerived,java.lang.Number);replaceAll(Type,NotFound)")
		Object value
	) {
	}

}

@ApplyRules
class TypeAdaptionConstructFallbackDerived extends TypeAdaptionConstructFallbackBase {
}

@ApplyRules
class TypeAdaptionConstructFallbackAnotherDerived extends TypeAdaptionConstructFallbackDerived {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.TypeAdaptionConstructFallbackAnotherDerived')
			
			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("ambiguity"))

			assertEquals(1, allProblems.size)

		]

	}

}