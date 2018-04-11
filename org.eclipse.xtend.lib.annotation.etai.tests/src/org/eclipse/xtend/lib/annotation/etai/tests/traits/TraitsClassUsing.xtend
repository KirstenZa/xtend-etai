package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ConstructRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.EPDefault
import org.eclipse.xtend.lib.annotation.etai.EPOverride
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.IExtendedClassTypeArgsUsingIndirectTraits
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.IExtendedClassTypeArgsUsingIndirectTraitsFactory
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.IExtendedClassUsingIndirectTraits
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.IExtendedClassUsingIndirectTraitsBase
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.IExtendedClassUsingIndirectTraitsProtectedMethods
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassCheckCovarianceUsed
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassCheckCovarianceUsedDerived
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassCheckCovarianceUsingUsed
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassCheckCovarianceUsingUsedDerived
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassDoubleAspect
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassLongAspect
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassNameAspect
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassProtectedMethods1
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassProtectedMethods2
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassTAspect
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassTypeArgsUsed
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassTypeArgsUsingOtherExtension
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassUsingOtherExtensionTypeArgumentsBase
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassSpecifiedMultipleTimes
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassUsingOtherExtension
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassUsingOtherExtensionBase
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassUsingOtherExtensionProtectedMethods
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassUsingOtherExtensionTypeArguments1
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassUsingOtherExtensionTypeArguments2
import java.lang.reflect.Modifier
import java.math.BigInteger
import java.util.List
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassNameAspect {

	String name = "Nothing"

	@ConstructorMethod
	protected def void create(String name) {
		this.name = name
	}

	@ProcessedMethod(processor=StringCombinatorPost)
	override String getName() {
		name + "Base"
	}

	@ExclusiveMethod
	override int someValue() {
		88
	}

}

@TraitClassAutoUsing
abstract class TraitClassLongAspect {

	@ExclusiveMethod
	override long getMyLong() {
		23
	}

}

@TraitClassAutoUsing
abstract class TraitClassDoubleAspect implements ITraitClassLongAspect, ITraitClassNameAspect, ITraitClassSpecifiedMultipleTimes {

	@ExclusiveMethod
	override double getMyDouble() {
		5.3
	}

}

@TraitClassAutoUsing
abstract class TraitClassTAspect<T> {

	@ExclusiveMethod
	override T getMyT() {
		null
	}

}

@TraitClassAutoUsing
abstract class TraitClassSpecifiedMultipleTimes {

	@ExclusiveMethod
	override int doIt() {
		45
	}

}

@TraitClassAutoUsing(baseClass=true)
abstract class TraitClassUsingOtherExtensionBase implements ITraitClassTAspect<Character>, ITraitClassSpecifiedMultipleTimes {
}

@TraitClassAutoUsing
abstract class TraitClassUsingOtherExtension extends TraitClassUsingOtherExtensionBase implements ITraitClassNameAspect, ITraitClassDoubleAspect {

	int value = 1

	@ConstructorMethod
	protected def void create(int value) {
		this.value = value
	}

	@ProcessedMethod(processor=StringCombinatorPost)
	override String getName() {
		"Using"
	}

	@ExclusiveMethod
	override int getValue() {
		value + someValue()
	}

}

@ApplyRules
@ExtractInterface
class ExtendedClassUsingIndirectTraitsBase {
}

@ApplyRules
@ExtractInterface
@FactoryMethodRule(factoryMethod="create")
@ConstructRule(TraitClassUsingOtherExtension, TraitClassNameAspect)
@ExtendedByAuto
class ExtendedClassUsingIndirectTraits extends ExtendedClassUsingIndirectTraitsBase implements ITraitClassUsingOtherExtension {
}

@TraitClassAutoUsing
abstract class TraitClassTypeArgsUsed<A1, A2> {

	@ExclusiveMethod
	override A1 getA11() {
		null
	}

	@ExclusiveMethod
	override List<A1> getA12() {
		null
	}

	@ExclusiveMethod
	override A2 getA2() {
		null
	}

}

@TraitClassAutoUsing
abstract class TraitClassTypeArgsUsingOtherExtension<T, X> implements ITraitClassTypeArgsUsed<List<T>, Integer> {

	@ExclusiveMethod
	override X getX() {
		null
	}

}

@ApplyRules
@ExtractInterface
@ExtendedByAuto
class ExtendedClassTypeArgsUsingIndirectTraits<T> implements ITraitClassTypeArgsUsingOtherExtension<T, BigInteger> {
}

@ApplyRules
@FactoryMethodRule(factoryMethod="create")
@ExtractInterface
@ExtendedByAuto
class ExtendedClassTypeArgsUsingIndirectTraitsFactory<T> implements ITraitClassTypeArgsUsingOtherExtension<T, BigInteger> {
}

@TraitClassAutoUsing
abstract class TraitClassProtectedMethods1 {

	@ExclusiveMethod
	protected def void protectedMethodA() {
		TraitTestsBase.TEST_BUFFER += "A"
	}

	@ProcessedMethod(processor=EPOverride)
	protected def void protectedMethodDefault() {
		TraitTestsBase.TEST_BUFFER += "X"
	}

}

@TraitClassAutoUsing
abstract class TraitClassProtectedMethods2 {

	@RequiredMethod
	protected def void protectedMethodRequired()

	@ProcessedMethod(processor=EPOverride)
	protected def void protectedMethodDefault() {
		TraitTestsBase.TEST_BUFFER += "Y"
	}

}

@TraitClassAutoUsing
abstract class TraitClassUsingOtherExtensionProtectedMethods implements ITraitClassProtectedMethods1, ITraitClassProtectedMethods2 {

	@ExclusiveMethod
	protected def void protectedMethodB() {
		protectedMethodRequired
		protectedMethodDefault$impl
		protectedMethodDefault
		protectedMethodA
		TraitTestsBase.TEST_BUFFER += "B"
	}

	@ProcessedMethod(processor=EPDefault)
	protected def void protectedMethodDefault() {
		TraitTestsBase.TEST_BUFFER += "Z"
	}

}

@ExtendedByAuto
@ExtractInterface
class ExtendedClassUsingIndirectTraitsProtectedMethods implements ITraitClassUsingOtherExtensionProtectedMethods {

	protected def void protectedMethodRequired() {
		TraitTestsBase.TEST_BUFFER += "R"
	}

	override void publicMethodC() {
		protectedMethodB
		TraitTestsBase.TEST_BUFFER += "C"
	}

}

@TraitClassAutoUsing
abstract class TraitClassCheckCovarianceUsed {

	int value = 0

	@ExclusiveMethod
	override int getAndIncValue() {
		value += 1
		return value
	}

}

@TraitClassAutoUsing
abstract class TraitClassCheckCovarianceUsedDerived extends TraitClassCheckCovarianceUsed {

	int value = 0

	@ExclusiveMethod
	override int getAndIncValue() {
		value += 2
		return value
	}

}

@TraitClassAutoUsing
abstract class TraitClassCheckCovarianceUsingUsed implements ITraitClassCheckCovarianceUsed {
}

@TraitClassAutoUsing
abstract class TraitClassCheckCovarianceUsingUsedDerived implements ITraitClassCheckCovarianceUsedDerived {
}

@ExtendedByAuto
class ExtendedClassCheckVariance1 implements ITraitClassCheckCovarianceUsingUsed, ITraitClassCheckCovarianceUsingUsedDerived {
}

@ExtendedByAuto
class ExtendedClassCheckVariance2 implements ITraitClassCheckCovarianceUsingUsedDerived, ITraitClassCheckCovarianceUsingUsed {
}

@ExtendedByAuto
class ExtendedClassCheckVariance3 implements ITraitClassCheckCovarianceUsedDerived, ITraitClassCheckCovarianceUsingUsedDerived, ITraitClassCheckCovarianceUsingUsed {
}

@ExtendedByAuto
class ExtendedClassCheckVariance4 implements ITraitClassCheckCovarianceUsingUsedDerived, ITraitClassCheckCovarianceUsedDerived, ITraitClassCheckCovarianceUsingUsed {
}

@TraitClassAutoUsing
abstract class TraitClassUsingOtherExtensionTypeArgumentsBase<T, U> {

	T value

	@ExclusiveMethod
	override T getValue() {
		return value
	}

	@ExclusiveMethod
	override void setValue(T value) {
		this.value = value
	}

}

@TraitClassAutoUsing
abstract class TraitClassUsingOtherExtensionTypeArguments1<T> implements ITraitClassUsingOtherExtensionTypeArgumentsBase<T, String> {
}

@TraitClassAutoUsing
abstract class TraitClassUsingOtherExtensionTypeArguments2<T> implements ITraitClassUsingOtherExtensionTypeArgumentsBase<T, String> {
}

@ExtendedByAuto
class ExtendedClassUsingIndirectTraitsTypeArguments implements ITraitClassUsingOtherExtensionTypeArguments1<Integer>, ITraitClassUsingOtherExtensionTypeArguments2<Integer> {
}

class TraitsClassUsingOtherTraitsTests extends TraitTestsBase {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testTraitClassUsingOtherExtension() {

		val obj1 = ExtendedClassUsingIndirectTraits::create(10, "MyName")
		assertEquals(98, obj1.value)
		assertEquals("UsingMyNameBase", obj1.name)
		assertEquals(5.3, obj1.myDouble, 0.001)
		assertEquals(23, obj1.myLong)
		assertEquals(45, obj1.doIt)
		val Character myChar1 = obj1.myT
		assertNull(myChar1)

		val IExtendedClassUsingIndirectTraits obj1Interface = obj1
		assertEquals(98, obj1Interface.value)
		assertEquals("UsingMyNameBase", obj1Interface.name)
		assertEquals(5.3, obj1Interface.myDouble, 0.001)
		assertEquals(23, obj1Interface.myLong)
		assertEquals(45, obj1Interface.doIt)
		val Character myChar2 = obj1Interface.myT
		assertNull(myChar2)

		val ITraitClassUsingOtherExtensionBase obj1SubInterface = obj1
		assertEquals(45, obj1SubInterface.doIt)
		val Character myChar3 = obj1SubInterface.myT
		assertNull(myChar3)

	}

	@Test
	def void testTraitClassUsingOtherExtensionInterfaces() {

		assertTrue(IExtendedClassUsingIndirectTraits.interfaces.contains(ITraitClassUsingOtherExtension))
		assertTrue(IExtendedClassUsingIndirectTraits.interfaces.contains(IExtendedClassUsingIndirectTraitsBase))
		assertTrue(ITraitClassUsingOtherExtension.interfaces.contains(ITraitClassNameAspect))
		assertTrue(ITraitClassUsingOtherExtension.interfaces.contains(ITraitClassDoubleAspect))
		assertTrue(ITraitClassUsingOtherExtension.interfaces.contains(ITraitClassUsingOtherExtensionBase))
		assertTrue(ITraitClassDoubleAspect.interfaces.contains(ITraitClassLongAspect))
		assertTrue(ITraitClassDoubleAspect.interfaces.contains(ITraitClassNameAspect))
		assertTrue(ITraitClassDoubleAspect.interfaces.contains(ITraitClassSpecifiedMultipleTimes))

	}

	@Test
	def void testTraitClassTypeArgsUsingOtherExtension() {

		val obj = new ExtendedClassTypeArgsUsingIndirectTraits<String>

		val List<String> a11 = obj.a11
		val List<List<String>> a12 = obj.a12
		val Integer a2 = obj.a2
		val BigInteger x = obj.x

		assertNull(a11)
		assertNull(a12)
		assertNull(a2)
		assertNull(x)

		val IExtendedClassTypeArgsUsingIndirectTraits<String> objInterface = obj

		val List<String> ia11 = objInterface.a11
		val List<List<String>> ia12 = objInterface.a12
		val Integer ia2 = objInterface.a2
		val BigInteger ix = objInterface.x

		assertNull(ia11)
		assertNull(ia12)
		assertNull(ia2)
		assertNull(ix)

	}

	@Test
	def void testTraitClassTypeArgsAndFactoryUsing() {

		val obj = ExtendedClassTypeArgsUsingIndirectTraitsFactory::create

		val List<String> a11 = obj.a11
		val List<List<String>> a12 = obj.a12
		val Integer a2 = obj.a2
		val BigInteger x = obj.x

		assertNull(a11)
		assertNull(a12)
		assertNull(a2)
		assertNull(x)

		val IExtendedClassTypeArgsUsingIndirectTraitsFactory<String> objInterface = obj

		val List<String> ia11 = objInterface.a11
		val List<List<String>> ia12 = objInterface.a12
		val Integer ia2 = objInterface.a2
		val BigInteger ix = objInterface.x

		assertNull(ia11)
		assertNull(ia12)
		assertNull(ia2)
		assertNull(ix)

	}

	@Test
	def void testTraitClassUsingOtherExtensionExclusivityCheck() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod

import virtual.intf.IXBase
import virtual.intf.IXUsingBase
import virtual.intf.IXExtendsUsing

@TraitClassAutoUsing
abstract class XBase {
	@ExclusiveMethod
	override void test() {}
}

@TraitClassAutoUsing
abstract class XUsingBase implements IXBase {
}

@TraitClassAutoUsing
abstract class XExtendsUsing extends XBase implements IXUsingBase {
}

@ExtendedByAuto
class MyExtendedClass implements IXExtendsUsing {
}

		'''.compile [

			// do assertions
			assertEquals(0, allProblems.size)

		]

	}

	@Test
	def void testTraitClassUsingOtherExtensionInklusionOrder() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod

import virtual.intf.IXLifecycleManaged
import virtual.intf.IXTraitClassDisposable1
import virtual.intf.IXTraitClassDisposable2

@TraitClassAutoUsing
abstract public class XLifecycleManaged {
	@EnvelopeMethod(setFinal=true, disableRedirection=true, required=false)
	override void dispose() {}
}

@TraitClassAutoUsing
abstract class XTraitClassDisposable1 implements IXLifecycleManaged {
	@ProcessedMethod(processor=EPVoidPre)
	override void dispose() {}
}

@TraitClassAutoUsing
abstract class XTraitClassDisposable2 implements IXTraitClassDisposable1, IXLifecycleManaged {
	@ProcessedMethod(processor=EPVoidPre)
	override void dispose() {}
}

@ExtendedByAuto
class MyExtendedClass implements IXTraitClassDisposable2 {
	override void dispose() {}
}

		'''.compile [

			// do assertions
			assertEquals(0, allProblems.size)

		]

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.EPVoidPre
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod

import virtual.intf.IXLifecycleManaged
import virtual.intf.IXTraitClassLevel2Up
import virtual.intf.IXTraitClassLevel1
import virtual.intf.IXTraitClassLevel2
import virtual.intf.IXTraitClassMain

@TraitClassAutoUsing
abstract public class XLifecycleManaged {
	@EnvelopeMethod(setFinal=true, disableRedirection=true, required=false)
	override void dispose() {}
}

@TraitClassAutoUsing
abstract class XTraitClassLevel1 implements IXLifecycleManaged {
}

@TraitClassAutoUsing
abstract class XTraitClassLevel2Up implements IXLifecycleManaged {
	@ProcessedMethod(processor=EPVoidPre)
	override void dispose() {}
}

@TraitClassAutoUsing
abstract class XTraitClassLevel2 implements IXTraitClassLevel2Up {
}

@TraitClassAutoUsing
abstract class XTraitClassMain implements IXTraitClassLevel1, IXTraitClassLevel2 {
}

@ExtendedByAuto
class MyExtendedClass implements IXTraitClassMain {
	override void dispose() {}
}

		'''.compile [

			// do assertions
			assertEquals(0, allProblems.size)

		]

	}

	@Test
	def void testTraitClassUsingNoTraitClass() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.TraitClass

import virtual.intf.INotAnTraitClass

@ExtractInterface
abstract class NotAnTraitClass {
}

@TraitClass(using=NotAnTraitClass)
abstract class AnTraitClass implements INotAnTraitClass {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.AnTraitClass")

			val localProblems = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, allProblems.size)

			assertEquals(1, localProblems.size)
			assertEquals(Severity.ERROR, localProblems.get(0).severity)
			assertTrue(localProblems.get(0).message.contains("not a trait class"))

		]

	}

	@Test
	def void testTraitClassUsingOtherExtensionTypeHierarchyError() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

import virtual.intf.ITraitClass21
import virtual.intf.ITraitClass1
import virtual.intf.ITraitClass3
import virtual.intf.ITraitClass4

@TraitClassAutoUsing
abstract class TraitClass1 {
}

@TraitClassAutoUsing
abstract class TraitClass21 extends TraitClass1 implements ITraitClass1 {
}

@TraitClassAutoUsing
abstract class TraitClass22 extends TraitClass1 implements ITraitClass3 {
}

@TraitClassAutoUsing
abstract class TraitClass23 extends TraitClass1 implements ITraitClass4 {
}

@TraitClassAutoUsing
abstract class TraitClass3 extends TraitClass22 {
}

@TraitClassAutoUsing
abstract class TraitClass4 extends TraitClass1 {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz21 = findClass("virtual.TraitClass21")
			val clazz22 = findClass("virtual.TraitClass22")
			val clazz23 = findClass("virtual.TraitClass23")

			val localProblems21 = (clazz21.primarySourceElement as ClassDeclaration).problems
			val localProblems22 = (clazz22.primarySourceElement as ClassDeclaration).problems
			val localProblems23 = (clazz23.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(3, allProblems.size)

			assertEquals(1, localProblems21.size)
			assertEquals(Severity.ERROR, localProblems21.get(0).severity)
			assertTrue(localProblems21.get(0).message.contains("type hierarchy"))

			assertEquals(1, localProblems22.size)
			assertEquals(Severity.ERROR, localProblems22.get(0).severity)
			assertTrue(localProblems22.get(0).message.contains("derived class"))

			assertEquals(1, localProblems23.size)
			assertEquals(Severity.ERROR, localProblems23.get(0).severity)
			assertTrue(localProblems23.get(0).message.contains("common base"))

		]

	}

	@Test
	def void testTraitClassUsingOtherExtensionProtectedMethods() {

		val obj = new ExtendedClassUsingIndirectTraitsProtectedMethods
		obj.publicMethodC
		assertEquals("RZYABC", TEST_BUFFER)

		assertTrue(
			Modifier.isProtected(ExtendedClassUsingIndirectTraitsProtectedMethods.declaredMethods.findFirst [
				name == "protectedMethodRequired"
			].modifiers)
		)
		assertTrue(
			Modifier.isProtected(ExtendedClassUsingIndirectTraitsProtectedMethods.declaredMethods.findFirst [
				name == "protectedMethodA"
			].modifiers)
		)
		assertTrue(
			Modifier.isProtected(TraitClassUsingOtherExtensionProtectedMethods.declaredMethods.findFirst [
				name == "protectedMethodRequired"
			].modifiers)
		)
		assertTrue(
			Modifier.isProtected(TraitClassUsingOtherExtensionProtectedMethods.declaredMethods.findFirst [
				name == "protectedMethodA"
			].modifiers)
		)
		assertNull(
			IExtendedClassUsingIndirectTraitsProtectedMethods.declaredMethods.findFirst [
				name == "protectedMethodRequired"
			]
		)
		assertNull(
			IExtendedClassUsingIndirectTraitsProtectedMethods.declaredMethods.findFirst[name == "protectedMethodA"]
		)
		assertNull(
			ITraitClassUsingOtherExtensionProtectedMethods.declaredMethods.findFirst[name == "protectedMethodRequired"]
		)
		assertNull(
			ITraitClassUsingOtherExtensionProtectedMethods.declaredMethods.findFirst[name == "protectedMethodA"]
		)

	}

	@Test
	def void testTraitClassUsingOtherExtensionCheckVariance() {

		val obj1 = new ExtendedClassCheckVariance1
		assertEquals(2, obj1.getAndIncValue)
		assertEquals(4, obj1.getAndIncValue)

		assertEquals(3, ExtendedClassCheckVariance1.declaredFields.length)

		val obj2 = new ExtendedClassCheckVariance2
		assertEquals(2, obj2.getAndIncValue)
		assertEquals(4, obj2.getAndIncValue)

		assertEquals(3, ExtendedClassCheckVariance2.declaredFields.length)

		val obj3 = new ExtendedClassCheckVariance3
		assertEquals(2, obj3.getAndIncValue)
		assertEquals(4, obj3.getAndIncValue)

		assertEquals(3, ExtendedClassCheckVariance3.declaredFields.length)

		val obj4 = new ExtendedClassCheckVariance4
		assertEquals(2, obj4.getAndIncValue)
		assertEquals(4, obj4.getAndIncValue)

		assertEquals(3, ExtendedClassCheckVariance4.declaredFields.length)

	}

	@Test
	def void testTraitClassUsingOtherExtensionTypeArguments() {

		val obj = new ExtendedClassUsingIndirectTraitsTypeArguments()
		obj.setValue(10);
		assertEquals(10, obj.getValue())

	}

	@Test
	def void testTraitClassUsingOtherExtensionCheckInconsistentVariance() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing

import virtual.intf.ITraitClassCheckInconsistentVarianceUsed
import virtual.intf.ITraitClassCheckInconsistentVarianceUsedDerived1
import virtual.intf.ITraitClassCheckInconsistentVarianceUsedDerived2
import virtual.intf.ITraitClassCheckInconsistentVarianceUsingUsed
import virtual.intf.ITraitClassCheckInconsistentVarianceUsingUsedDerived1
import virtual.intf.ITraitClassCheckInconsistentVarianceUsingUsedDerived2

@TraitClassAutoUsing
abstract class TraitClassCheckInconsistentVarianceUsed {
}

@TraitClassAutoUsing
abstract class TraitClassCheckInconsistentVarianceUsedDerived1 extends TraitClassCheckInconsistentVarianceUsed {}

@TraitClassAutoUsing
abstract class TraitClassCheckInconsistentVarianceUsedDerived2 extends TraitClassCheckInconsistentVarianceUsed {}

@TraitClassAutoUsing
abstract class TraitClassCheckInconsistentVarianceUsingUsed implements ITraitClassCheckInconsistentVarianceUsed {}

@TraitClassAutoUsing
abstract class TraitClassCheckInconsistentVarianceUsingUsedDerived1 implements ITraitClassCheckInconsistentVarianceUsedDerived1 {}

@TraitClassAutoUsing
abstract class TraitClassCheckInconsistentVarianceUsingUsedDerived2 implements ITraitClassCheckInconsistentVarianceUsedDerived2 {}

@ExtendedByAuto
class ExtendedClassCheckInconsistentVariance1 implements ITraitClassCheckInconsistentVarianceUsingUsedDerived1, ITraitClassCheckInconsistentVarianceUsingUsedDerived2 {}

@ExtendedByAuto
class ExtendedClassCheckInconsistentVariance2 implements ITraitClassCheckInconsistentVarianceUsingUsedDerived1, ITraitClassCheckInconsistentVarianceUsed, ITraitClassCheckInconsistentVarianceUsingUsed {}

@ExtendedByAuto
class ExtendedClassCheckInconsistentVariance3 implements ITraitClassCheckInconsistentVarianceUsingUsedDerived1, ITraitClassCheckInconsistentVarianceUsedDerived2 {}

		'''.compile [

			val extension ctx = transformationContext

			val clazz1 = findClass("virtual.ExtendedClassCheckInconsistentVariance1")
			val clazz2 = findClass("virtual.ExtendedClassCheckInconsistentVariance2")
			val clazz3 = findClass("virtual.ExtendedClassCheckInconsistentVariance3")

			val localProblems1 = (clazz1.primarySourceElement as ClassDeclaration).problems
			val localProblems2 = (clazz2.primarySourceElement as ClassDeclaration).problems
			val localProblems3 = (clazz3.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(3, allProblems.size)

			assertEquals(1, localProblems1.size)
			assertEquals(Severity.ERROR, localProblems1.get(0).severity)
			assertTrue(localProblems1.get(0).message.contains("has already been applied"))

			assertEquals(1, localProblems2.size)
			assertEquals(Severity.ERROR, localProblems2.get(0).severity)
			assertTrue(localProblems2.get(0).message.contains("has already been applied"))

			assertEquals(1, localProblems3.size)
			assertEquals(Severity.ERROR, localProblems3.get(0).severity)
			assertTrue(localProblems3.get(0).message.contains("has already been applied"))

		]

	}

}
