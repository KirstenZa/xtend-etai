package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import java.lang.reflect.Modifier
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.CopyConstructorRule
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IClassWithFactoryMethodReturnInterfaceDerived
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IClassWithFactoryMethodReturnInterface

abstract class ClassWithFactoryMethodBase1 {

	protected int value = 1
	protected String str = ""

	def getValue() {
		value
	}

	def getStr() {
		str
	}

}

@ApplyRules
abstract class ClassWithFactoryMethodBase2 extends ClassWithFactoryMethodBase1 {
}

@ApplyRules
@FactoryMethodRule(factoryMethod="create")
class ClassWithFactoryMethodWithoutConstructorDerived1 extends ClassWithFactoryMethodBase2 {
}

@ApplyRules
abstract class ClassWithFactoryMethodWithoutConstructorDerived2 extends ClassWithFactoryMethodWithoutConstructorDerived1 {
}

@ApplyRules
class ClassWithFactoryMethodWithoutConstructorDerived3 extends ClassWithFactoryMethodWithoutConstructorDerived2 {
}

@ApplyRules
@FactoryMethodRule(factoryMethod="create%")
class ClassWithFactoryMethodWithParametersDerived1 extends ClassWithFactoryMethodBase1 {

	new(int add, Object dummyObj) {
		value += add
	}

	@CopyConstructorRule
	new(int add) {
		this(add, null)
	}

}

@ApplyRules
class ClassWithFactoryMethodWithParametersAdapted extends ClassWithFactoryMethodWithParametersDerived1 {
}

@ApplyRules
class ClassWithFactoryMethodWithParametersDerived2 extends ClassWithFactoryMethodWithParametersDerived1 {

	new(int multiply, int add) {
		super(add)
		value *= multiply
	}

}

@ApplyRules
class ClassWithFactoryMethodWithParametersDerived3 extends ClassWithFactoryMethodWithParametersDerived2 {

	new(int add, int multiply, String str) {
		super(multiply, add)
		this.str = str
	}

}

@ApplyRules
class ClassWithFactoryMethodWithParametersDerived4 extends ClassWithFactoryMethodWithParametersDerived3 {

	new() {
		super(10, 60, "myStr")
	}

	new(int add) {
		super(add, 60, "myStr")
	}

	protected new(int add, String str) {
		super(add, 60, str)
	}

}

@ApplyRules
@FactoryMethodRule(factoryMethod="create", initMethod="init")
abstract class ClassWithInitMethodAbstract extends ClassWithFactoryMethodBase1 {

	protected def void init()

}

@ApplyRules
class ClassWithInitMethodConcrete1 extends ClassWithInitMethodAbstract {

	protected override void init() {
		value *= 5
	}

}

@ApplyRules
class ClassWithInitMethodConcrete2 extends ClassWithInitMethodConcrete1 {

	new(int add) {
		value += add
	}

	new(int add, int multiply) {
		this(add)
		value *= multiply
	}

	protected override void init() {
		value *= 2
	}

}

@ApplyRules
@FactoryMethodRule(factoryMethod="construct")
class ClassWithFactoryMethodVarArgs {

	double sum

	new(int firstValue, double ... args) {
		sum = firstValue
		for (arg : args)
			sum += arg
	}

	def double getSum() {
		sum
	}

}

@ApplyRules
@FactoryMethodRule(factoryMethod="construct")
class ClassWithFactoryMethodTypeArgs<T, B extends Double> {

	T arg1
	List<B> arg2
	B arg3

	/**
	 * @bug Type arguments for constructors are not supported by xtend.
	 */
	new(T arg1) {
		this.arg1 = arg1
	}

	new(T arg1, B arg3) {
		this.arg1 = arg1
		this.arg3 = arg3
	}

	new(T arg1, List<B> arg2, B arg3) {
		this.arg1 = arg1
		this.arg2 = arg2
		this.arg3 = arg3
	}

	def T getArg1() {
		arg1
	}

	def List<B> getArg2() {
		arg2
	}

	def B getArg3() {
		arg3
	}

	static def callingMustWork(ClassWithFactoryMethodTypeArgs<Integer, Double> obj) {
	}

}

@ApplyRules
@ExtractInterface
@FactoryMethodRule(factoryMethod="construct", returnTypeAdaptionRule="applyVariable(var.class.qualified);replaceAll(ClassWith,intf.IClassWith)")
class ClassWithFactoryMethodReturnInterface {
}

@ApplyRules
@ExtractInterface
class ClassWithFactoryMethodReturnInterfaceDerived extends ClassWithFactoryMethodReturnInterface {
}

@ApplyRules
class ClassWithFactoryMethodReturnInterfaceDerivedNoInterface extends ClassWithFactoryMethodReturnInterface {
}

@ApplyRules
@FactoryMethodRule(factoryMethod="construct")
class ClassWithFactoryMethodConstructorCallingConstructor {

	new(int h) {

		if (h == 0)
			new ClassWithFactoryMethodConstructorCallingConstructor(1)

	}

}

class FactoryMethodTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	// using this method avoids warnings concerning unnecessary instanceof tests
	static def boolean instanceOf(Object obj, Class<?> clazz) {
		return clazz.isAssignableFrom(obj.class)
	}

	@Test
	def void testFactoryMethods() {

		val newDerived1 = ClassWithFactoryMethodWithoutConstructorDerived1.create
		val newDerived2 = ClassWithFactoryMethodWithoutConstructorDerived2.create
		val newDerived3 = ClassWithFactoryMethodWithoutConstructorDerived3.create

		assertTrue(newDerived1.instanceOf(ClassWithFactoryMethodWithoutConstructorDerived1))
		assertFalse(newDerived1.instanceOf(ClassWithFactoryMethodWithoutConstructorDerived2))
		assertFalse(newDerived1.instanceOf(ClassWithFactoryMethodWithoutConstructorDerived3))

		// objects for abstract classes cannot be constructed
		assertTrue(newDerived2.instanceOf(ClassWithFactoryMethodWithoutConstructorDerived1))
		assertFalse(newDerived2.instanceOf(ClassWithFactoryMethodWithoutConstructorDerived2))
		assertFalse(newDerived2.instanceOf(ClassWithFactoryMethodWithoutConstructorDerived3))

		assertTrue(newDerived3.instanceOf(ClassWithFactoryMethodWithoutConstructorDerived3))

		assertFalse(ClassWithFactoryMethodWithoutConstructorDerived2.declaredMethods.exists[name == "create"])

		assertEquals(0, ClassWithFactoryMethodWithoutConstructorDerived1.constructors.size())
		assertEquals(0, ClassWithFactoryMethodWithoutConstructorDerived3.constructors.size())

	}

	@Test
	def void testFactoryMethodsWithAdaption() {

		val newAdapted = ClassWithFactoryMethodWithParametersAdapted.
			createClassWithFactoryMethodWithParametersAdapted(10)

		assertEquals(11, newAdapted.value)

		assertEquals(0, ClassWithFactoryMethodWithParametersAdapted.constructors.size())

	}

	@Test
	def void testFactoryMethodsWithParametersAndNameAdaption() {

		val newDerived11 = ClassWithFactoryMethodWithParametersDerived1.
			createClassWithFactoryMethodWithParametersDerived1(10)
		val newDerived12 = ClassWithFactoryMethodWithParametersDerived1.
			createClassWithFactoryMethodWithParametersDerived1(13, "asStringCastedToObject")
		val newDerived2 = ClassWithFactoryMethodWithParametersDerived2.
			createClassWithFactoryMethodWithParametersDerived2(30, 4)
		val newDerived3 = ClassWithFactoryMethodWithParametersDerived3.
			createClassWithFactoryMethodWithParametersDerived3(2, 3, "anStr")
		val newDerived41 = ClassWithFactoryMethodWithParametersDerived4.
			createClassWithFactoryMethodWithParametersDerived4
		val newDerived42 = ClassWithFactoryMethodWithParametersDerived4.
			createClassWithFactoryMethodWithParametersDerived4(20)

		assertTrue(newDerived11.instanceOf(ClassWithFactoryMethodWithParametersDerived1))
		assertTrue(newDerived12.instanceOf(ClassWithFactoryMethodWithParametersDerived1))
		assertTrue(newDerived2.instanceOf(ClassWithFactoryMethodWithParametersDerived2))
		assertTrue(newDerived3.instanceOf(ClassWithFactoryMethodWithParametersDerived3))
		assertTrue(newDerived41.instanceOf(ClassWithFactoryMethodWithParametersDerived4))
		assertTrue(newDerived42.instanceOf(ClassWithFactoryMethodWithParametersDerived4))

		assertEquals(11, newDerived11.value)
		assertEquals(14, newDerived12.value)
		assertEquals(150, newDerived2.value)
		assertEquals(9, newDerived3.value)
		assertEquals(660, newDerived41.value)
		assertEquals(1260, newDerived42.value)

		assertEquals("", newDerived11.str)
		assertEquals("", newDerived12.str)
		assertEquals("", newDerived2.str)
		assertEquals("anStr", newDerived3.str)
		assertEquals("myStr", newDerived41.str)
		assertEquals("myStr", newDerived42.str)

		assertEquals(2, ClassWithFactoryMethodWithParametersDerived1.declaredMethods.filter [
			name.startsWith("create") && synthetic == false
		].size())
		assertEquals(1, ClassWithFactoryMethodWithParametersDerived2.declaredMethods.filter [
			name.startsWith("create") && synthetic == false
		].size())
		assertEquals(1, ClassWithFactoryMethodWithParametersDerived3.declaredMethods.filter [
			name.startsWith("create") && synthetic == false
		].size())
		assertEquals(2, ClassWithFactoryMethodWithParametersDerived4.declaredMethods.filter [
			name.startsWith("create") && synthetic == false
		].size())

		assertEquals(0, ClassWithFactoryMethodWithParametersDerived1.constructors.size())
		assertEquals(0, ClassWithFactoryMethodWithParametersDerived2.constructors.size())
		assertEquals(0, ClassWithFactoryMethodWithParametersDerived3.constructors.size())
		assertEquals(0, ClassWithFactoryMethodWithParametersDerived4.constructors.size())

		assertEquals(2, ClassWithFactoryMethodWithParametersDerived1.declaredConstructors.filter [
			Modifier.isProtected(it.modifiers)
		].size())
		assertEquals(1, ClassWithFactoryMethodWithParametersDerived2.declaredConstructors.filter [
			Modifier.isProtected(it.modifiers)
		].size())
		assertEquals(1, ClassWithFactoryMethodWithParametersDerived3.declaredConstructors.filter [
			Modifier.isProtected(it.modifiers)
		].size())
		assertEquals(3, ClassWithFactoryMethodWithParametersDerived4.declaredConstructors.filter [
			Modifier.isProtected(it.modifiers)
		].size())

	}

	@Test
	def void testFactoryMethodProtection() {

		var boolean exceptionThrown

		// ensure that creation without factory method does not work
		assertEquals(1, ClassWithFactoryMethodWithoutConstructorDerived1.declaredConstructors.filter [
			Modifier.isProtected(it.modifiers)
		].size())

		exceptionThrown = false
		try {
			new ClassWithFactoryMethodWithoutConstructorDerived1
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		// check trick (calling constructor within constructor)
		exceptionThrown = false
		try {
			ClassWithFactoryMethodConstructorCallingConstructor::construct(0)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

	}

	@Test
	def void testFactoryMethodVarArgs() {

		val obj = ClassWithFactoryMethodVarArgs.construct(1, 5.0, 6.0, 7.0)

		assertEquals(19.0, obj.sum, 0.001)

		assertEquals(0, ClassWithFactoryMethodVarArgs.constructors.size())

	}

	@Test
	def void testFactoryMethodTypeArgs() {

		val obj1 = ClassWithFactoryMethodTypeArgs::construct(10)
		val Integer value1 = obj1.arg1
		assertEquals(10, value1)
		ClassWithFactoryMethodTypeArgs::callingMustWork(obj1)

		val obj2 = ClassWithFactoryMethodTypeArgs.construct(10, 50.0)
		val Integer value2 = obj2.arg1
		val Double fValue2 = obj2.arg3
		assertEquals(10, value2)
		assertEquals(50.0, fValue2, 0.001)
		ClassWithFactoryMethodTypeArgs::callingMustWork(obj2)

		val obj3 = ClassWithFactoryMethodTypeArgs::construct(10, new ArrayList<Double>(), 50.0)
		val Integer value3 = obj3.arg1
		val Double fValue3 = obj3.arg3
		assertEquals(10, value3)
		assertEquals(50.0, fValue3, 0.001)
		ClassWithFactoryMethodTypeArgs::callingMustWork(obj3)

	}

	@Test
	def void testFactoryMethodReturnTypeAdaption() {

		assertEquals(IClassWithFactoryMethodReturnInterface,
			ClassWithFactoryMethodReturnInterface.getMethod("construct").returnType)
		assertEquals(IClassWithFactoryMethodReturnInterfaceDerived,
			ClassWithFactoryMethodReturnInterfaceDerived.getMethod("construct").returnType)
	}

	@Test
	def void testInitMethods() {

		val newConcrete1 = ClassWithInitMethodConcrete1.create
		val newConcrete21 = ClassWithInitMethodConcrete2::create(6)
		val newConcrete22 = ClassWithInitMethodConcrete2.create(3, 19)

		assertEquals(5, newConcrete1.value)
		assertEquals(14, newConcrete21.value)
		assertEquals(152, newConcrete22.value)

	}

	@Test
	def void testFactoryMethodRuleAllowedOnceError() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule

import virtual.intf.ITraitClassWithFactoryMethod

@FactoryMethodRule(factoryMethod="create", initMethod="init")
@ApplyRules
class ClassWithFactoryMethodDerived1 {
	def void init() {}
}

@ApplyRules
abstract class ClassWithFactoryMethodDerived2 extends ClassWithFactoryMethodDerived1 {
}

@FactoryMethodRule(factoryMethod="create")
@ApplyRules
class ClassWithFactoryMethodDerived3 extends ClassWithFactoryMethodDerived2 {
}

@FactoryMethodRule(factoryMethod="create")
@ApplyRules
@TraitClassAutoUsing
abstract class TraitClassWithFactoryMethod {
}

@FactoryMethodRule(factoryMethod="create")
@ApplyRules
@ExtendedByAuto
class ExtendedClassWithFactoryMethod implements ITraitClassWithFactoryMethod {
}



		'''.compile [

			val extension ctx = transformationContext

			val clazz1 = findClass('virtual.ClassWithFactoryMethodDerived3')
			val clazz2 = findClass('virtual.ExtendedClassWithFactoryMethod')

			val problemsClass1 = (clazz1.primarySourceElement as ClassDeclaration).problems
			val problemsClass2 = (clazz2.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass1.size)
			assertEquals(Severity.ERROR, problemsClass1.get(0).severity)
			assertTrue(problemsClass1.get(0).message.contains("Ambiguous"))

			assertEquals(1, problemsClass2.size)
			assertEquals(Severity.ERROR, problemsClass2.get(0).severity)
			assertTrue(problemsClass2.get(0).message.contains("Ambiguous"))

			assertEquals(2, allProblems.size)

		]

	}

	@Test
	def void testInitMethodDeclaration() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod

import virtual.intf.IClassInitMethodExtension

@ApplyRules
abstract class ClassInitMethodBase {
	protected def void init() {}
}

@TraitClassAutoUsing
abstract class ClassInitMethodExtension {
	@ExclusiveMethod
	override void init() {}
}

abstract class ClassInitMethodPrivate {
	def private void init() {}
}

interface InterfaceInitMethod {
	def void init()
}

@ApplyRules
@FactoryMethodRule(factoryMethod="create", initMethod="init")
abstract class ClassWithoutInitMethod1 extends ClassInitMethodBase {
}

@ApplyRules
@ExtendedByAuto
@FactoryMethodRule(factoryMethod="create", initMethod="init")
abstract class ClassWithoutInitMethod2 implements IClassInitMethodExtension {
}

@ApplyRules
@FactoryMethodRule(factoryMethod="create", initMethod="init")
abstract class ClassWithoutInitMethod3 implements InterfaceInitMethod {
}

@ApplyRules
@FactoryMethodRule(factoryMethod="create", initMethod="init")
abstract class ClassWithoutInitMethod4 extends ClassInitMethodPrivate {
}

@ApplyRules
@FactoryMethodRule(factoryMethod="create", initMethod="init")
abstract class ClassWithoutInitMethod5 {
}

@ApplyRules
@TraitClassAutoUsing
@FactoryMethodRule(factoryMethod="create", initMethod="init")
abstract class TraitClassWithoutInitMethod {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz1 = findClass("virtual.ClassWithoutInitMethod1")
			val clazz2 = findClass("virtual.ClassWithoutInitMethod2")
			val clazz3 = findClass("virtual.ClassWithoutInitMethod3")
			val clazz4 = findClass("virtual.ClassWithoutInitMethod4")
			val clazz5 = findClass("virtual.ClassWithoutInitMethod5")
			val clazz6 = findClass("virtual.TraitClassWithoutInitMethod")

			val problemsClass1 = (clazz1.primarySourceElement as ClassDeclaration).problems
			val problemsClass2 = (clazz2.primarySourceElement as ClassDeclaration).problems
			val problemsClass3 = (clazz3.primarySourceElement as ClassDeclaration).problems
			val problemsClass4 = (clazz4.primarySourceElement as ClassDeclaration).problems
			val problemsClass5 = (clazz5.primarySourceElement as ClassDeclaration).problems
			val problemsClass6 = (clazz6.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(0, problemsClass1.size)
			assertEquals(0, problemsClass2.size)
			assertEquals(0, problemsClass3.size)

			assertEquals(1, problemsClass4.size)
			assertEquals(Severity.ERROR, problemsClass4.get(0).severity)
			assertTrue(problemsClass4.get(0).message.contains("must be declared and visible"))

			assertEquals(1, problemsClass5.size)
			assertEquals(Severity.ERROR, problemsClass5.get(0).severity)
			assertTrue(problemsClass5.get(0).message.contains("must be declared and visible"))

			assertEquals(1, problemsClass6.size)
			assertEquals(Severity.ERROR, problemsClass6.get(0).severity)
			assertTrue(problemsClass6.get(0).message.contains("must be declared and visible"))

			assertEquals(3, allProblems.size)

		]

	}

	@Test
	def void testEmptyFactoryMethodNameError() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule

@FactoryMethodRule(factoryMethod="", initMethod="init")
@ApplyRules
class ClassWithFactoryMethod {
	def void init() {}
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ClassWithFactoryMethod")

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("empty factory method name"))

			assertEquals(1, allProblems.size)

		]

	}

}
