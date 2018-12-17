package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import java.lang.reflect.Modifier
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.CopyConstructorRule
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.SetAdaptionVariable
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IComponentBase
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IComponentFeature
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IControllerAttributeStringConcrete1
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IControllerBase
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IClassWithChangingFactoryInterfaceExtension
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IClassWithFactoryClassReturnTypeAdaption
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IClassWithFactoryClassReturnTypeAdaptionDerived
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IClassWithFactoryClassTypeArgsAndInterface
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITraitClassSpecifyingFactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.tests.traits.TypeA
import org.eclipse.xtend.lib.annotation.etai.tests.traits.TypeB
import org.eclipse.xtend.lib.annotation.etai.tests.traits.TypeC
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.eclipse.xtend.lib.annotation.etai.tests.adaption.ClassWithFactoryClassNonFinal.*
import static org.junit.Assert.*

abstract class ClassWithFactoryClassBase1 {

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
abstract class ClassWithFactoryClassBase2 extends ClassWithFactoryClassBase1 {
}

@ApplyRules
@FactoryMethodRule(factoryMethod="create", factoryInstance="FACTORY")
class ClassWithFactoryClassWithoutConstructorDerived1 extends ClassWithFactoryMethodBase2 {
}

@ApplyRules
abstract class ClassWithFactoryClassWithoutConstructorDerived2 extends ClassWithFactoryClassWithoutConstructorDerived1 {
}

@ApplyRules
class ClassWithFactoryClassWithoutConstructorDerived3 extends ClassWithFactoryClassWithoutConstructorDerived2 {
}

@ApplyRules
@FactoryMethodRule(factoryMethod="create", factoryInstance="FACTORY", factoryClassDerived=true)
class ClassWithFactoryClassCheckDerivation1 {
}

@ApplyRules
abstract class ClassWithFactoryClassCheckDerivation2 extends ClassWithFactoryClassCheckDerivation1 {
}

@ApplyRules
class ClassWithFactoryClassCheckDerivation3 extends ClassWithFactoryClassCheckDerivation2 {
}

@ApplyRules
@FactoryMethodRule(factoryMethod="create%", factoryInstance="FACTORY_INSTANCE")
class ClassWithFactoryClassWithParametersDerived1 extends ClassWithFactoryClassBase1 {

	new(int add, Object dummyObj) {
		value += add
	}

	@CopyConstructorRule
	new(int add) {
		this(add, null)
	}

}

@ApplyRules
class ClassWithFactoryClassWithParametersAdapted extends ClassWithFactoryClassWithParametersDerived1 {
}

@ApplyRules
class ClassWithFactoryClassWithParametersDerived2 extends ClassWithFactoryClassWithParametersDerived1 {

	new(int multiply, int add) {
		super(add)
		value *= multiply
	}

}

@ApplyRules
class ClassWithFactoryClassWithParametersDerived3 extends ClassWithFactoryClassWithParametersDerived2 {

	new(int add, int multiply, String str) {
		super(multiply, add)
		this.str = str
	}

}

@ApplyRules
class ClassWithFactoryClassWithParametersDerived4 extends ClassWithFactoryClassWithParametersDerived3 {

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
@FactoryMethodRule(factoryMethod="construct", factoryInstance="FACTORY")
class ClassWithFactoryClassTypeArgs<T, B extends Double> {

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

	static def callingMustWork(ClassWithFactoryClassTypeArgs<Integer, Double> obj) {
	}

}

interface IFactory {
	def IClassWithFactoryClassImplementingInterface create()
}

interface IClassWithFactoryClassImplementingInterface {
	def int getValue()
}

@ApplyRules
@FactoryMethodRule(factoryMethod="create", factoryInstance="FACTORY", factoryInterface=IFactory, factoryClassDerived=true)
class ClassWithFactoryClassImplementingInterface implements IClassWithFactoryClassImplementingInterface {

	public int value

	new() {
		value = 99
	}

	override int getValue() {
		value
	}

}

@ApplyRules
class ClassWithFactoryClassImplementingInterfaceDerived extends ClassWithFactoryClassImplementingInterface {
}

interface IFactoryWithTypeArgs {
	def <T, U extends Double> IClassWithFactoryClassTypeArgsAndInterface<T, U> create()
}

@ApplyRules
@ExtractInterface
@FactoryMethodRule(factoryMethod="create", factoryInstance="FACTORY", factoryInterface=IFactoryWithTypeArgs)
class ClassWithFactoryClassTypeArgsAndInterface<T, U extends Double> {

	new() {
	}

}

interface IFactoryInterface1 {
}

interface IFactoryInterface2 {
}

@TraitClassAutoUsing
@SetAdaptionVariable("factoryInf=org.eclipse.xtend.lib.annotation.etai.tests.adaption.IFactoryInterface2")
abstract class ClassWithChangingFactoryInterfaceExtension {
}

@ApplyRules
@FactoryMethodRule(factoryMethod="create", factoryInstance="FACTORY", factoryInterfaceVariable="factoryInf")
@SetAdaptionVariable("factoryInf=does_not_exist")
class ClassWithChangingFactoryInterfaceBase {
}

@ApplyRules
@SetAdaptionVariable("factoryInf=org.eclipse.xtend.lib.annotation.etai.tests.adaption.IFactoryInterface1")
class ClassWithChangingFactoryInterfaceDerived extends ClassWithChangingFactoryInterfaceBase {
}

@ApplyRules
@ExtendedByAuto
class ClassWithChangingFactoryInterface extends ClassWithChangingFactoryInterfaceDerived implements IClassWithChangingFactoryInterfaceExtension {
}

@TraitClassAutoUsing
@ApplyRules
@FactoryMethodRule(factoryMethod="construct", factoryInstance="FACTORY", initMethod="init")
abstract class TraitClassSpecifyingFactoryMethodRule {

	@RequiredMethod
	protected def void init()

}

@ApplyRules
@ExtendedByAuto
class ExtendedClassNotSpecifyingFactoryMethodRule implements ITraitClassSpecifyingFactoryMethodRule {

	public int value = 0

	def void init() {
		value++
	}

}

@ApplyRules
@FactoryMethodRule(factoryMethod="construct", factoryInstance="FACTORY", factoryClassDerived=false)
abstract class ClassWithFactoryClassAdaptedTwiceBase {

	new(
		IControllerBase x
	) {
	}

	new(
		@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.extending.TypeB)")
		TypeA x
	) {
	}

	@CopyConstructorRule
	new(
		IComponentBase x
	) {
	}

}

@ApplyRules
abstract class ClassWithFactoryClassAdaptedTwiceDerived extends ClassWithFactoryClassAdaptedTwiceBase {

	new(
		@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IControllerAttributeStringConcrete1)")
		IControllerBase x
	) {
		super(x)
	}

	new(
		@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.traits.TypeC)")
		TypeB x
	) {
		super(x)
	}

	new(
		@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.intf.IComponentFeature)")
		IComponentBase x
	) {
		super(x)
	}

}

@ApplyRules
class ClassWithFactoryClassAdaptedTwiceConcrete extends ClassWithFactoryClassAdaptedTwiceDerived {
}

interface IFactoryForClassWithFactoryNonFinal {
	def ClassWithFactoryClassNonFinal construct()
}

@ApplyRules
@FactoryMethodRule(factoryMethod="construct", factoryInstance="FACTORY", factoryInterface=IFactoryForClassWithFactoryNonFinal, factoryInstanceFinal=false, factoryClassDerived=true)
class ClassWithFactoryClassNonFinal {

	def int method1() { 1 }

}

@ApplyRules
class ClassWithFactoryClassNonFinalDerived extends ClassWithFactoryClassNonFinal {

	override int method1() { 9 }

}

@ApplyRules
@ExtractInterface
@FactoryMethodRule(factoryInstance="FACTORY", factoryMethod="create", returnTypeAdaptionRule="applyVariable(var.package);append(.intf.I);appendVariable(var.class.simple);append(<);appendVariable(var.class.typeparameters);append(>)")
class ClassWithFactoryClassReturnTypeAdaption<G, H> {

	new(Integer g) {
	}

}

@ApplyRules
@ExtractInterface
class ClassWithFactoryClassReturnTypeAdaptionDerived extends ClassWithFactoryClassReturnTypeAdaption<Integer, Double> {

	new(Integer h) {
		super(h)
	}

}

class FactoryClassTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testFactoryClass() {

		val newDerived1 = ClassWithFactoryClassWithoutConstructorDerived1::FACTORY.create
		val newDerived3 = ClassWithFactoryClassWithoutConstructorDerived3::FACTORY.create

		assertTrue(newDerived1 instanceof ClassWithFactoryClassWithoutConstructorDerived1)
		assertFalse(newDerived1 instanceof ClassWithFactoryClassWithoutConstructorDerived3)
		assertTrue(newDerived3 instanceof ClassWithFactoryClassWithoutConstructorDerived3)

		assertFalse(ClassWithFactoryClassWithoutConstructorDerived2.declaredFields.exists[name == "FACTORY"])

		assertEquals(0, ClassWithFactoryClassWithoutConstructorDerived1.constructors.size())
		assertEquals(0, ClassWithFactoryClassWithoutConstructorDerived3.constructors.size())

	}

	@Test
	def void testFactoryClassWithAdaption() {

		val newAdapted = ClassWithFactoryClassWithParametersAdapted::FACTORY_INSTANCE.
			createClassWithFactoryClassWithParametersAdapted(10)

		assertEquals(11, newAdapted.value)

		assertEquals(0, ClassWithFactoryClassWithParametersAdapted.constructors.size())

	}

	@Test
	def void testFactoryClassWithParametersAndNameAdaption() {

		val newDerived11 = ClassWithFactoryClassWithParametersDerived1::FACTORY_INSTANCE.
			createClassWithFactoryClassWithParametersDerived1(10)
		val newDerived12 = ClassWithFactoryClassWithParametersDerived1::FACTORY_INSTANCE.
			createClassWithFactoryClassWithParametersDerived1(13, "asStringCastedToObject")
		val newDerived2 = ClassWithFactoryClassWithParametersDerived2::FACTORY_INSTANCE.
			createClassWithFactoryClassWithParametersDerived2(30, 4)
		val newDerived3 = ClassWithFactoryClassWithParametersDerived3::FACTORY_INSTANCE.
			createClassWithFactoryClassWithParametersDerived3(2, 3, "anStr")
		val newDerived41 = ClassWithFactoryClassWithParametersDerived4::FACTORY_INSTANCE.
			createClassWithFactoryClassWithParametersDerived4
		val newDerived42 = ClassWithFactoryClassWithParametersDerived4::FACTORY_INSTANCE.
			createClassWithFactoryClassWithParametersDerived4(20)

		assertTrue(newDerived11 instanceof ClassWithFactoryClassWithParametersDerived1)
		assertTrue(newDerived12 instanceof ClassWithFactoryClassWithParametersDerived1)
		assertTrue(newDerived2 instanceof ClassWithFactoryClassWithParametersDerived2)
		assertTrue(newDerived3 instanceof ClassWithFactoryClassWithParametersDerived3)
		assertTrue(newDerived41 instanceof ClassWithFactoryClassWithParametersDerived4)
		assertTrue(newDerived42 instanceof ClassWithFactoryClassWithParametersDerived4)

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

		assertEquals(2, ClassWithFactoryClassWithParametersDerived1.Factory.declaredMethods.filter[
			name.startsWith("create") && synthetic == false
		].size())
		assertEquals(1, ClassWithFactoryClassWithParametersDerived2.Factory.declaredMethods.filter[
			name.startsWith("create") && synthetic == false
		].size())
		assertEquals(1, ClassWithFactoryClassWithParametersDerived3.Factory.declaredMethods.filter[
			name.startsWith("create") && synthetic == false
		].size())
		assertEquals(2, ClassWithFactoryClassWithParametersDerived4.Factory.declaredMethods.filter[
			name.startsWith("create") && synthetic == false
		].size())

		assertEquals(0, ClassWithFactoryClassWithParametersDerived1.constructors.size())
		assertEquals(0, ClassWithFactoryClassWithParametersDerived2.constructors.size())
		assertEquals(0, ClassWithFactoryClassWithParametersDerived3.constructors.size())
		assertEquals(0, ClassWithFactoryClassWithParametersDerived4.constructors.size())

		assertEquals(2, ClassWithFactoryClassWithParametersDerived1.declaredConstructors.filter[
			Modifier.isProtected(it.modifiers)
		].size())
		assertEquals(1, ClassWithFactoryClassWithParametersDerived2.declaredConstructors.filter[
			Modifier.isProtected(it.modifiers)
		].size())
		assertEquals(1, ClassWithFactoryClassWithParametersDerived3.declaredConstructors.filter[
			Modifier.isProtected(it.modifiers)
		].size())
		assertEquals(3, ClassWithFactoryClassWithParametersDerived4.declaredConstructors.filter[
			Modifier.isProtected(it.modifiers)
		].size())

	}

	@Test
	def void testFactoryClassTypeArgs() {

		val obj1 = ClassWithFactoryClassTypeArgs::FACTORY.construct(10)
		val Integer value1 = obj1.arg1
		assertEquals(10, value1)
		ClassWithFactoryClassTypeArgs::callingMustWork(obj1)

		val obj2 = ClassWithFactoryClassTypeArgs.FACTORY.construct(10, 50.0)
		val Integer value2 = obj2.arg1
		val Double fValue2 = obj2.arg3
		assertEquals(10, value2)
		assertEquals(50.0, fValue2, 0.001)
		ClassWithFactoryClassTypeArgs::callingMustWork(obj2)

		val obj3 = ClassWithFactoryClassTypeArgs::FACTORY.construct(10, new ArrayList<Double>(), 50.0)
		val Integer value3 = obj3.arg1
		val Double fValue3 = obj3.arg3
		assertEquals(10, value3)
		assertEquals(50.0, fValue3, 0.001)
		ClassWithFactoryClassTypeArgs::callingMustWork(obj3)

	}

	@Test
	def void testFactoryInterface() {

		val IFactory factory = ClassWithFactoryClassImplementingInterface::FACTORY
		val IClassWithFactoryClassImplementingInterface newObj = factory.create
		assertEquals(99, newObj.value)

	}

	@Test
	def void testFactoryInterfaceAndTypeArgument() {

		val IFactoryWithTypeArgs factory = ClassWithFactoryClassTypeArgsAndInterface::FACTORY
		val IClassWithFactoryClassTypeArgsAndInterface<Integer, Double> newObj = factory.create()
		assertNotNull(newObj)

	}

	@Test
	def void testFactoryInterfaceHierarchy() {

		assertEquals(ClassWithFactoryClassImplementingInterface::FACTORY.class,
			ClassWithFactoryClassImplementingInterfaceDerived::FACTORY.class.superclass)
		assertEquals(0, ClassWithFactoryClassImplementingInterfaceDerived::FACTORY.class.interfaces.size)

	}

	@Test
	def void testFactoryClassNoInstance() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule

interface IFactory {}

@ApplyRules
@FactoryMethodRule(factoryInterface=IFactory)
class UsingFactoryClassInterface {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.UsingFactoryClassInterface')

			val problemsClass1 = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass1.size)
			assertEquals(Severity.ERROR, problemsClass1.get(0).severity)
			assertTrue(problemsClass1.get(0).message.contains("must be specified"))

			assertEquals(1, allProblems.size)

		]

	}

	@Test
	def void testEmptyFactoryMethodNameError() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule

abstract class IFactory {}

@ApplyRules
@FactoryMethodRule(factoryInstance="FACTORY", factoryInterface=IFactory)
class UsingFactoryClassInterface {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.UsingFactoryClassInterface")

			val problemsClass1 = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass1.size)
			assertEquals(Severity.ERROR, problemsClass1.get(0).severity)
			assertTrue(problemsClass1.get(0).message.contains("must be an interface"))

			assertEquals(1, allProblems.size)

		]

	}

	@Test
	def void testFactoryInterfaceSpecificationError() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule

interface IFactory {}

@ApplyRules
@FactoryMethodRule(factoryMethod="create", factoryInstance="FACTORY", factoryInterface=IFactory, factoryInterfaceVariable="var")
class UsingFactoryClassInterface {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.UsingFactoryClassInterface")

			val problemsClass1 = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass1.size)
			assertEquals(Severity.ERROR, problemsClass1.get(0).severity)
			assertTrue(problemsClass1.get(0).message.contains("both"))

			assertEquals(1, allProblems.size)

		]

	}

	@Test
	def void testFactoryVariableInterface() {

		// must compile
		val ClassWithChangingFactoryInterfaceBase.Factory obj1 = ClassWithChangingFactoryInterfaceBase.FACTORY
		val IFactoryInterface1 obj2 = ClassWithChangingFactoryInterfaceDerived.FACTORY
		val IFactoryInterface2 obj3 = ClassWithChangingFactoryInterface.FACTORY

		assertNotNull(obj1)
		assertNotNull(obj2)
		assertNotNull(obj3)

		assertEquals(0, ClassWithChangingFactoryInterfaceBase.Factory.interfaces.size)
		assertEquals(1, ClassWithChangingFactoryInterfaceDerived.Factory.interfaces.size)
		assertArrayEquals(#[IFactoryInterface1], ClassWithChangingFactoryInterfaceDerived.Factory.interfaces)
		assertEquals(1, ClassWithChangingFactoryInterface.Factory.interfaces.size)
		assertArrayEquals(#[IFactoryInterface2], ClassWithChangingFactoryInterface.Factory.interfaces)

	}

	@Test
	def void testFactoryRuleSpecificationByTraitClass() {

		val obj = ExtendedClassNotSpecifyingFactoryMethodRule.FACTORY.construct
		assertEquals(1, obj.value)

	}

	@Test
	def void testFactoryAdaptedTwice() {

		// check factory and its methods
		assertEquals(3, ClassWithFactoryClassAdaptedTwiceConcrete.FACTORY.class.declaredMethods.size)
		assertEquals(1, ClassWithFactoryClassAdaptedTwiceConcrete.FACTORY.class.declaredMethods.filter[
			it.parameters.get(0).type === IControllerAttributeStringConcrete1 && synthetic == false
		].size)
		assertEquals(1, ClassWithFactoryClassAdaptedTwiceConcrete.FACTORY.class.declaredMethods.filter[
			it.parameters.get(0).type === TypeC && synthetic == false
		].size)
		assertEquals(1, ClassWithFactoryClassAdaptedTwiceConcrete.FACTORY.class.declaredMethods.filter[
			it.parameters.get(0).type === IComponentFeature && synthetic == false
		].size)

		// check also if declared in another file		
		assertEquals(3, ClassWithFactoryClassAdaptedTwiceConcreteOtherFile.FACTORY.class.declaredMethods.size)
		assertEquals(1, ClassWithFactoryClassAdaptedTwiceConcrete.FACTORY.class.declaredMethods.filter[
			it.parameters.get(0).type === IControllerAttributeStringConcrete1 && synthetic == false
		].size)
		assertEquals(1, ClassWithFactoryClassAdaptedTwiceConcrete.FACTORY.class.declaredMethods.filter[
			it.parameters.get(0).type === TypeC && synthetic == false
		].size)
		assertEquals(1, ClassWithFactoryClassAdaptedTwiceConcrete.FACTORY.class.declaredMethods.filter[
			it.parameters.get(0).type === IComponentFeature && synthetic == false
		].size)

	}

	@Test
	def void testFactoryClassNoDerivation() {

		assertTrue(Modifier.isPrivate(ClassWithFactoryClassWithoutConstructorDerived2.declaredClasses.findFirst[
			simpleName == "Factory"
		].modifiers))

		assertEquals(ClassWithFactoryClassWithoutConstructorDerived1,
			ClassWithFactoryClassWithoutConstructorDerived2.superclass)
		assertEquals(ClassWithFactoryClassWithoutConstructorDerived2,
			ClassWithFactoryClassWithoutConstructorDerived3.superclass)
		assertEquals(Object, ClassWithFactoryClassWithoutConstructorDerived3.Factory.superclass)

	}

	@Test
	def void testFactoryClassDerivation() {

		assertEquals(ClassWithFactoryClassNonFinal, ClassWithFactoryClassNonFinalDerived.superclass)
		assertFalse(Modifier.isAbstract(ClassWithFactoryClassNonFinal.Factory.modifiers))
		assertEquals(ClassWithFactoryClassNonFinal.Factory, ClassWithFactoryClassNonFinalDerived.Factory.superclass)

		assertFalse(Modifier.isAbstract(ClassWithFactoryClassCheckDerivation1.Factory.modifiers))
		assertTrue(Modifier.isAbstract(ClassWithFactoryClassCheckDerivation2.Factory.modifiers))
		assertFalse(Modifier.isAbstract(ClassWithFactoryClassCheckDerivation3.Factory.modifiers))

		assertEquals(Object, ClassWithFactoryClassCheckDerivation1.Factory.superclass)

		assertEquals(ClassWithFactoryClassCheckDerivation1, ClassWithFactoryClassCheckDerivation2.superclass)
		assertEquals(ClassWithFactoryClassCheckDerivation1.Factory,
			ClassWithFactoryClassCheckDerivation2.Factory.superclass)

		assertEquals(ClassWithFactoryClassCheckDerivation2, ClassWithFactoryClassCheckDerivation3.superclass)
		assertEquals(ClassWithFactoryClassCheckDerivation2.Factory,
			ClassWithFactoryClassCheckDerivation3.Factory.superclass)

	}

	@Test
	def void testFactoryClassNonFinal() {

		ClassWithFactoryClassNonFinal::FACTORY = ClassWithFactoryClassNonFinalDerived::FACTORY

		val classWithFactory = ClassWithFactoryClassNonFinal::FACTORY.construct

		assertEquals(9, classWithFactory.method1)

	}

	@Test
	def void testFactoryClassReturnTypeAdaption() {

		assertEquals(IClassWithFactoryClassReturnTypeAdaption,
			ClassWithFactoryClassReturnTypeAdaption::FACTORY.class.getMethod("create", Integer).returnType)
		assertEquals(2,
			ClassWithFactoryClassReturnTypeAdaption::FACTORY.class.getMethod("create", Integer).typeParameters.length)
		assertEquals(2,
			ClassWithFactoryClassReturnTypeAdaption::FACTORY.class.getMethod("create", Integer).returnType.
				typeParameters.length)
		assertEquals(
			ClassWithFactoryClassReturnTypeAdaption::FACTORY.class.getMethod("create", Integer).typeParameters.get(0).
				name,
			ClassWithFactoryClassReturnTypeAdaption::FACTORY.class.getMethod("create", Integer).returnType.
				typeParameters.get(0).name)
		assertEquals(
			ClassWithFactoryClassReturnTypeAdaption::FACTORY.class.getMethod("create", Integer).typeParameters.get(1).
				name,
			ClassWithFactoryClassReturnTypeAdaption::FACTORY.class.getMethod("create", Integer).returnType.
				typeParameters.get(1).name)

		assertEquals(IClassWithFactoryClassReturnTypeAdaptionDerived,
			ClassWithFactoryClassReturnTypeAdaptionDerived::FACTORY.class.getMethod("create", Integer).returnType)
		assertEquals(0,
			ClassWithFactoryClassReturnTypeAdaptionDerived::FACTORY.class.getMethod("create", Integer).typeParameters.
				length)
		assertEquals(0,
			ClassWithFactoryClassReturnTypeAdaptionDerived::FACTORY.class.getMethod("create", Integer).returnType.
				typeParameters.length)

	}

}
