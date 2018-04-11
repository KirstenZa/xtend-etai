package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

class TraitsConstructErrorTests extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testAmbiguousTypeCombination() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.InjectConstructorParameterType
import org.eclipse.xtend.lib.annotation.etai.ConstructRule
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule

import virtual.intf.ITraitClass1
import virtual.intf.ITraitClass2

@TraitClassAutoUsing
abstract class TraitClass1 {

	@ConstructorMethod
	protected def void construct1(int a, int b) {}

	@ConstructorMethod
	protected def void construct1(int a) {}

}

@TraitClassAutoUsing
abstract class TraitClass2 {

	@ConstructorMethod
	protected def void construct2(int c) {}
	
	@ConstructorMethod
	protected def void construct2(int c, int d) {}

}

@FactoryMethodRule(factoryMethod="create%")
@ConstructRule(TraitClass1, TraitClass2)
@ExtendedByAuto
@ApplyRules
class ExtendedClassTwice implements ITraitClass1, ITraitClass2 {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedClassTwice")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, allProblems.size)
			
			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("type combination is ambiguous"))

		]

	}

	@Test
	def void testTraitClassWithoutValidConstructorMethod() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ConstructRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule

import virtual.intf.ITraitClassNoConstructor
import virtual.intf.ITraitClassNoParameterConstructor

@TraitClassAutoUsing
abstract class TraitClassNoConstructor {
}

@TraitClassAutoUsing
abstract class TraitClassNoParameterConstructor {
	
	@ConstructorMethod
	protected def void construct() {}
	
}

@FactoryMethodRule
@ConstructRule(TraitClassNoConstructor)
@ApplyRules
@ExtendedByAuto
class ExtendedClassNoConstructor implements ITraitClassNoConstructor {
}

@FactoryMethodRule
@ConstructRule(TraitClassNoParameterConstructor)
@ApplyRules
@ExtendedByAuto
class ExtendedClassNoParameterConstructor implements ITraitClassNoParameterConstructor {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz1 = findClass("virtual.ExtendedClassNoConstructor")
			val clazz2 = findClass("virtual.ExtendedClassNoParameterConstructor")

			val problemsClass1 = (clazz1.primarySourceElement as ClassDeclaration).problems
			val problemsClass2 = (clazz2.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(2, allProblems.size)

			assertEquals(1, problemsClass1.size)
			assertEquals(Severity.ERROR, problemsClass1.get(0).severity)
			assertTrue(problemsClass1.get(0).message.contains("not contain constructor methods"))

			assertEquals(1, problemsClass2.size)
			assertEquals(Severity.ERROR, problemsClass2.get(0).severity)
			assertTrue(problemsClass2.get(0).message.contains("not contain constructor methods"))

		]

	}

	@Test
	def void testParameterTypeMismatch() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ConstructRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule

import virtual.intf.ITraitClass1

@TraitClassAutoUsing
abstract class TraitClass1 {

	@ConstructorMethod
	protected def void construct1(int a) {}

}

@FactoryMethodRule(factoryMethod="create%")
@ConstructRule(TraitClass1)
@ApplyRules
@ExtendedByAuto
class ExtendedClassParameterTypeMismatch implements ITraitClass1 {
	new (double a) {}
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedClassParameterTypeMismatch")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, allProblems.size
				
			)
			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("type mismatch of parameter"))

		]

	}

	@Test
	def void testRuleWithInvalidTraitClasses() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ConstructRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule

import virtual.intf.ITraitClass1
import virtual.intf.ITraitClass2

@TraitClassAutoUsing
abstract class TraitClass1 {
	
	@ConstructorMethod
	protected def void construct(int param) {}
	
}

@TraitClassAutoUsing
abstract class TraitClass2 {
	
	@ConstructorMethod
	protected def void construct(int param) {}
	
}

@FactoryMethodRule
@ApplyRules
@ExtendedByAuto
class ExtendedClassBase implements ITraitClass1 {
	new() {
		new$TraitClass1(0)
	}
}

@ConstructRule(TraitClass1, TraitClass2)
@ApplyRules
@ExtendedByAuto
class ExtendedClassDerived extends ExtendedClassBase implements ITraitClass2 {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ExtendedClassDerived")

			val problemsClass1 = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, allProblems.size)

			assertEquals(1, problemsClass1.size)
			assertEquals(Severity.ERROR, problemsClass1.get(0).severity)
			assertTrue(problemsClass1.get(0).message.contains("is not extending"))
		]

	}
	
	@Test
	def void testWithoutFactoryMethod() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ConstructRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

import virtual.intf.ITraitClass1

@TraitClassAutoUsing
abstract class TraitClass1 {
	
	@ConstructorMethod
	protected def void construct(int param) {}
	
}

@ConstructRule(TraitClass1)
@ApplyRules
@ExtendedByAuto
class ExtendedClass1 implements ITraitClass1 {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ExtendedClass1')

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, allProblems.size)

			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("without specifying a factory method"))
		]

	}
	
	@Test
	def void testNoConstuctorMethod() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ConstructRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

import virtual.intf.ITraitClassNoConstructorMethod
import virtual.intf.ITraitClassNoConstructorMethodWithParameters

@TraitClassAutoUsing
abstract class TraitClassNoConstructorMethod {
}

@TraitClassAutoUsing
abstract class TraitClassNoConstructorMethodWithParameters {

	@ConstructorMethod
	protected def void construct() {}

}

@FactoryMethodRule(factoryMethod="create%")
@ConstructRule(TraitClassNoConstructorMethod)
@ApplyRules
@ExtendedByAuto
class ExtendedClassNoConstructorMethod implements ITraitClassNoConstructorMethod {
}

@FactoryMethodRule(factoryMethod="create%")
@ConstructRule(TraitClassNoConstructorMethodWithParameters)
@ApplyRules
@ExtendedByAuto
class ExtendedClassNoConstructorMethodWithParameters implements ITraitClassNoConstructorMethodWithParameters {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz1 = findClass('virtual.ExtendedClassNoConstructorMethod')
			val clazz2 = findClass('virtual.ExtendedClassNoConstructorMethodWithParameters')

			val problemsClass1 = (clazz1.primarySourceElement as ClassDeclaration).problems
			val problemsClass2 = (clazz2.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(2, allProblems.size)

			assertEquals(1, problemsClass1.size)
			assertEquals(Severity.ERROR, problemsClass1.get(0).severity)
			assertTrue(problemsClass1.get(0).message.contains("does not contain constructor methods"))
			assertEquals(1, problemsClass2.size)
			assertEquals(Severity.ERROR, problemsClass2.get(0).severity)
			assertTrue(problemsClass2.get(0).message.contains("does not contain constructor methods"))

		]

	}
	
	@Test
	def void testVarArgsUnsupported() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ConstructRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

import virtual.intf.ITraitClass1

@TraitClassAutoUsing
abstract class TraitClass1 {
	
	@ConstructorMethod
	protected def void construct(int param, Object ... objs) {}
	
}

@FactoryMethodRule(factoryMethod="create%")
@ConstructRule(TraitClass1)
@ApplyRules
@ExtendedByAuto
class ExtendedClass1 implements ITraitClass1 {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ExtendedClass1')

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, allProblems.size)

			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("variable argument lists"))
		]

	}

}
