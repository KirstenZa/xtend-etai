/**
 * Covariance and contravariance rules in Java
 * 
 * The overriding method is covariant in the return type and invariant in the argument types.
 * That means that the return type of the overriding method can be a subclass of the return type
 * of the overridden method, but the argument types must match exactly.
 * 
 * If the argument types aren’t identical in the subclass then the method will be overloaded
 * instead of overridden.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.traits

import java.util.Arrays
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.EPOverride
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.LazyEvaluation
import org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TraitMethodProcessor
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.IExtendedClassTypeABNotDerivedHaveCAAbstract
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.IExtendedClassTypeAGenericHaveB
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.IExtendedClassTypeBBNotDerivedHaveCAAbstract
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.IExtendedClassTypeBGenericHaveA
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.IExtendedClassTypeBNotDerivedAHaveCAAbstract
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.IExtendedClassTypeBNotDerivedBHaveCAAbstract
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassTypeA
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassTypeB
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassTypeBNotDerived
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassTypeGeneric
import org.junit.Test

import static org.junit.Assert.*
import org.eclipse.xtend.lib.annotation.etai.DefaultValueProviderNull

class TypeA {

	public int counter = 0;

	def calc(int i) { counter += i * 1000000 }

}

class TypeB extends TypeA {

	override calc(int i) { counter += i }

}

class TypeC extends TypeB {

	override calc(int i) { counter = i + 13 }

	def void calc2(int i) { counter = i + 14 }

}

class TypeCombinator implements TraitMethodProcessor {

	override call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {
		if (expressionExtendedClass === null) {
			return expressionTraitClass.eval()
		} else {
			expressionTraitClass.eval()
			return expressionExtendedClass.eval()
		}
	}

}

@TraitClassAutoUsing
abstract class TraitClassTypeA {

	TypeA objA = new TypeA

	@ProcessedMethod(processor=EPOverride)
	override TypeA getObjA() {
		objA
	}

	@ExclusiveMethod
	override void setObjA(TypeA objA) {
		this.objA = objA
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeA methodProcessed1() {
		objA.calc(1)
		return objA
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeA[] methodProcessed2() {
		objA.calc(1)
		return #[objA]
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeA methodProcessed3() {
		null
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeA[] methodProcessed4() {
		null
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeA methodProcessed5() {
		objA.calc(1)
		return objA
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeA[] methodProcessed6() {
		objA.calc(1)
		return #[objA]
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeA methodProcessed7() {
		null
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeA[] methodProcessed8() {
		null
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeA methodProcessed9() {
		return null
	}

	@EnvelopeMethod(required=false, defaultValueProvider=DefaultValueProviderNull)
	override TypeA methodEnvelope() {
		val obj = methodEnvelope$extended
		obj.counter++
		return obj
	}

	@PriorityEnvelopeMethod(value=50, required=false, defaultValueProvider=DefaultValueProviderNull)
	override TypeA methodPriorityEnvelope1() {
		val obj = methodPriorityEnvelope1$extended
		obj.counter = obj.counter + 1
		return obj
	}

	@PriorityEnvelopeMethod(value=50, required=false, defaultValueProvider=DefaultValueProviderNull)
	override TypeA [] methodPriorityEnvelope2() {
		return methodPriorityEnvelope2$extended
	}

}

@TraitClassAutoUsing
abstract class TraitClassTypeB extends TraitClassTypeA {

	@ProcessedMethod(processor=TypeCombinator)
	override TypeB methodProcessed1() {
		objA.calc(100)
		return super.methodProcessed1 as TypeB
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeB[] methodProcessed2() {
		objA.calc(100)
		val baseArray = super.methodProcessed2
		return Arrays.copyOf(baseArray, baseArray.length, typeof(TypeB[]))
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeB methodProcessed3() {
		return super.methodProcessed3 as TypeB
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeB[] methodProcessed4() {
		val baseArray = super.methodProcessed2
		return Arrays.copyOf(baseArray, baseArray.length, typeof(TypeB[]))
	}

	@EnvelopeMethod(required=false, defaultValueProvider=DefaultValueProviderNull)
	override TypeB methodEnvelope() {
		val obj = super.methodEnvelope
		obj.counter = obj.counter + 10
		return obj as TypeB
	}

	@PriorityEnvelopeMethod(value=50, required=false, defaultValueProvider=DefaultValueProviderNull)
	override TypeB methodPriorityEnvelope1() {
		val obj = super.methodPriorityEnvelope1
		obj.counter = obj.counter + 10
		return obj as TypeB
	}

	@PriorityEnvelopeMethod(value=50, required=false, defaultValueProvider=DefaultValueProviderNull)
	override TypeB [] methodPriorityEnvelope2() {
		return #[super.methodPriorityEnvelope2.get(0) as TypeB]
	}

}

@TraitClassAutoUsing
abstract class TraitClassTypeBNotDerived {

	@RequiredMethod
	override TypeA getObjA()

	@ProcessedMethod(processor=TypeCombinator)
	override TypeB methodProcessed5() {
		objA.calc(100)
		return objA as TypeB
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeB[] methodProcessed6() {
		objA.calc(100)
		val baseArray = #[objA]
		return Arrays.copyOf(baseArray, baseArray.length, typeof(TypeB[]))
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeB methodProcessed7() {
		return null
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeB[] methodProcessed8() {
		return null
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeB methodProcessed9() {
		return null
	}

	@PriorityEnvelopeMethod(value=10, required=false, defaultValueProvider=DefaultValueProviderNull)
	override TypeB methodPriorityEnvelope1() {
		val obj = methodPriorityEnvelope1$extended
		obj.counter = obj.counter + 700
		return obj
	}

	@PriorityEnvelopeMethod(value=10, required=false, defaultValueProvider=DefaultValueProviderNull)
	override TypeB [] methodPriorityEnvelope2() {
		return methodPriorityEnvelope2$extended
	}

}

@ExtendedByAuto
@ApplyRules
class ExtendedClassTypeBBNotDerivedHaveNone implements ITraitClassTypeB, ITraitClassTypeBNotDerived {
}

@ExtendedByAuto
@ApplyRules
class ExtendedClassTypeAHaveB implements ITraitClassTypeA {

	override TypeB methodProcessed1() {
		objA.calc(10000)
		return objA as TypeB
	}

	override TypeB [] methodProcessed2() {
		objA.calc(10000)
		return #[objA as TypeB]
	}

	override TypeB methodEnvelope() {
		return new TypeB
	}

	override TypeB methodPriorityEnvelope1() {
		return new TypeB
	}

	override TypeA [] methodPriorityEnvelope2() {
		return #[new TypeB]
	}

}

@ExtendedByAuto
@ApplyRules
class ExtendedClassTypeBHaveA implements ITraitClassTypeB {

	override TypeA methodProcessed1() {
		objA.calc(10000)
		return objA as TypeB
	}

	override TypeA [] methodProcessed2() {
		objA.calc(10000)
		return #[objA as TypeB] as TypeB []
	}

	override TypeA methodEnvelope() {
		return new TypeB
	}

	override TypeA methodPriorityEnvelope1() {
		return new TypeB
	}

	override TypeA [] methodPriorityEnvelope2() {
		return #[new TypeB]
	}

}

@ExtendedByAuto
@ApplyRules
class ExtendedClassTypeBHaveB implements ITraitClassTypeB {

	override TypeB methodProcessed1() {
		objA.calc(10000)
		return objA as TypeB
	}

	override TypeB [] methodProcessed2() {
		objA.calc(10000)
		return #[objA as TypeB]
	}

	override TypeB methodEnvelope() {
		return new TypeB
	}

	override TypeB methodPriorityEnvelope1() {
		return new TypeB
	}

	override TypeB [] methodPriorityEnvelope2() {
		return #[new TypeB]
	}

}

@ApplyRules
@ExtendedByAuto
class ExtendedClassTypeABNotDerivedHaveA implements ITraitClassTypeA, ITraitClassTypeBNotDerived {

	override TypeA methodProcessed1() {
		objA.calc(10000)
		return objA
	}

	override TypeA [] methodProcessed2() {
		objA.calc(10000)
		return #[objA]
	}

	override TypeA methodProcessed5() {
		objA.calc(10000)
		return objA
	}

	override TypeA [] methodProcessed6() {
		objA.calc(10000)
		return #[objA]
	}

	override TypeA methodProcessed9() {
		return new TypeA
	}

	override TypeA methodEnvelope() {
		return new TypeB
	}

	override TypeA methodPriorityEnvelope1() {
		return new TypeB
	}

	override TypeA [] methodPriorityEnvelope2() {
		return #[new TypeB]
	}

}

@ApplyRules
@ExtendedByAuto
@ExtractInterface
class ExtendedClassTypeBNotDerivedAHaveA implements ITraitClassTypeBNotDerived, ITraitClassTypeA {

	override TypeA methodProcessed1() {
		objA.calc(10000)
		return objA
	}

	override TypeA [] methodProcessed2() {
		objA.calc(10000)
		return #[objA]
	}

	override TypeA methodProcessed5() {
		objA.calc(10000)
		return objA
	}

	override TypeA [] methodProcessed6() {
		objA.calc(10000)
		return #[objA]
	}

	override TypeA methodEnvelope() {
		return new TypeB
	}

	override TypeA methodPriorityEnvelope1() {
		return new TypeB
	}

	override TypeA [] methodPriorityEnvelope2() {
		return #[new TypeB]
	}

}

@ApplyRules
@ExtendedByAuto
@ExtractInterface
abstract class ExtendedClassTypeABNotDerivedHaveCAAbstract implements ITraitClassTypeA, ITraitClassTypeBNotDerived {

	abstract override TypeC methodProcessed1()

	abstract override TypeC [] methodProcessed2()

	abstract override TypeA methodProcessed3()

	abstract override TypeA [] methodProcessed4()

	abstract override TypeC methodProcessed5()

	abstract override TypeC [] methodProcessed6()

	abstract override TypeA methodProcessed7()

	abstract override TypeA [] methodProcessed8()

}

@ApplyRules
class ExtendedClassTypeABNotDerivedHaveCA extends ExtendedClassTypeABNotDerivedHaveCAAbstract {
}

@ApplyRules
@ExtendedByAuto
@ExtractInterface
abstract class ExtendedClassTypeBBNotDerivedHaveCAAbstract implements ITraitClassTypeB, ITraitClassTypeBNotDerived {

	abstract override TypeC methodProcessed1()

	abstract override TypeC [] methodProcessed2()

	abstract override TypeA methodProcessed3()

	abstract override TypeA [] methodProcessed4()

	abstract override TypeC methodProcessed5()

	abstract override TypeC [] methodProcessed6()

	abstract override TypeA methodProcessed7()

	abstract override TypeA [] methodProcessed8()

}

@ApplyRules
class ExtendedClassTypeBBNotDerivedHaveCA extends ExtendedClassTypeBBNotDerivedHaveCAAbstract {
}

@ApplyRules
@ExtendedByAuto
@ExtractInterface
abstract class ExtendedClassTypeBNotDerivedAHaveCAAbstract implements ITraitClassTypeBNotDerived, ITraitClassTypeA {

	abstract override TypeC methodProcessed1()

	abstract override TypeC [] methodProcessed2()

	abstract override TypeA methodProcessed3()

	abstract override TypeA [] methodProcessed4()

	abstract override TypeC methodProcessed5()

	abstract override TypeC [] methodProcessed6()

	abstract override TypeA methodProcessed7()

	abstract override TypeA [] methodProcessed8()

}

@ApplyRules
class ExtendedClassTypeBNotDerivedAHaveCA extends ExtendedClassTypeBNotDerivedAHaveCAAbstract {
}

@ApplyRules
@ExtendedByAuto
@ExtractInterface
abstract class ExtendedClassTypeBNotDerivedBHaveCAAbstract implements ITraitClassTypeBNotDerived, ITraitClassTypeB {

	abstract override TypeC methodProcessed1()

	abstract override TypeC [] methodProcessed2()

	abstract override TypeA methodProcessed3()

	abstract override TypeA [] methodProcessed4()

	abstract override TypeC methodProcessed5()

	abstract override TypeC [] methodProcessed6()

	abstract override TypeA methodProcessed7()

	abstract override TypeA [] methodProcessed8()

}

@ApplyRules
class ExtendedClassTypeBNotDerivedBHaveCA extends ExtendedClassTypeBNotDerivedBHaveCAAbstract {
}

abstract class BaseClassHaveCA {

	abstract def TypeA methodProcessed1()

	abstract def TypeA [] methodProcessed2()

	abstract def TypeC methodProcessed3()

	abstract def TypeC [] methodProcessed4()

	abstract def TypeA methodProcessed5()

	abstract def TypeA [] methodProcessed6()

	abstract def TypeC methodProcessed7()

	abstract def TypeC [] methodProcessed8()

}

@ApplyRules
@ExtendedByAuto
class ExtendedClassTypeABNotDerivedHaveCADerived extends BaseClassHaveCA implements ITraitClassTypeA, ITraitClassTypeBNotDerived {
}

@ApplyRules
@ExtendedByAuto
class ExtendedClassTypeBBNotDerivedHaveCADerived extends BaseClassHaveCA implements ITraitClassTypeB, ITraitClassTypeBNotDerived {
}

@ApplyRules
@ExtendedByAuto
class ExtendedClassTypeBNotDerivedAHaveCADerived extends BaseClassHaveCA implements ITraitClassTypeBNotDerived, ITraitClassTypeA {
}

@ApplyRules
@ExtendedByAuto
class ExtendedClassTypeBNotDerivedBHaveCADerived extends BaseClassHaveCA implements ITraitClassTypeBNotDerived, ITraitClassTypeB {
}

@TraitClass
abstract class TraitClassTypeGeneric<T> {

	@ProcessedMethod(processor=TypeCombinator)
	override T methodGeneric() {
		null
	}

}

@ExtendedByAuto
@ExtractInterface
class ExtendedClassTypeAGenericHaveB implements ITraitClassTypeGeneric<TypeA> {

	override TypeB methodGeneric() {
		null
	}

}

@ExtendedByAuto
@ExtractInterface
class ExtendedClassTypeBGenericHaveA implements ITraitClassTypeGeneric<TypeB> {

	override TypeA methodGeneric() {
		null
	}

}

class TraitsCovarianceTests extends TraitTestsBase {

	@Test
	def void testCovarianceOverridingInTraitClass() {

		val obj = new ExtendedClassTypeBBNotDerivedHaveNone()
		val objB = new TypeB()
		obj.setObjA(objB)
		assertEquals(101, obj.methodProcessed1.counter)
		assertSame(objB, obj.methodProcessed1)
		assertArrayEquals(#[objB], obj.methodProcessed2)

		// explicit check that return types are correct
		assertSame(TypeB, obj.class.getDeclaredMethod("methodProcessed1").returnType)
		assertSame(typeof(TypeB[]), obj.class.getDeclaredMethod("methodProcessed2").returnType)

	}

	@Test
	def void testCovarianceTraitClassHasMoreConcreteclass() {

		{

			val obj = new ExtendedClassTypeBHaveA()
			val objB = new TypeB()
			obj.setObjA(objB)
			assertEquals(10101, obj.methodProcessed1.counter)
			assertSame(objB, obj.methodProcessed1)
			assertArrayEquals(#[objB], obj.methodProcessed2)

			assertEquals(11, obj.methodEnvelope.counter)

			// explicit check that return types are correct (compilation error if there is no explicit cast)
			assertSame(TypeB, obj.class.getDeclaredMethod("methodProcessed1").returnType)
			assertSame(TypeA,
				obj.class.getDeclaredMethod("methodProcessed1__$beforeExtended$__TraitClassTypeB").returnType)
			assertSame(typeof(TypeB[]), obj.class.getDeclaredMethod("methodProcessed2").returnType)
			assertSame(typeof(TypeA[]),
				obj.class.getDeclaredMethod("methodProcessed2__$beforeExtended$__TraitClassTypeB").returnType)

			assertSame(TypeB, obj.class.getDeclaredMethod("methodEnvelope").returnType)
			assertSame(TypeA,
				obj.class.getDeclaredMethod("methodEnvelope__$beforeExtended$__TraitClassTypeB").returnType)

		}

		{

			val obj = new ExtendedClassTypeABNotDerivedHaveA()

			assertEquals(701, obj.methodPriorityEnvelope1.counter)

			// explicit check that return types are correct (compilation error if there is no explicit cast)
			assertSame(TypeB, obj.class.getDeclaredMethod("methodPriorityEnvelope1").returnType)
			assertSame(TypeA, obj.class.getDeclaredMethod("methodPriorityEnvelope1$impl").returnType)

		}

	}

	@Test
	def void testCovarianceOverridingInExtendedClass() {

		val obj = new ExtendedClassTypeAHaveB()
		val objB = new TypeB()
		obj.setObjA(objB)
		assertEquals(10001, obj.methodProcessed1.counter)
		assertSame(objB, obj.methodProcessed1)
		assertArrayEquals(#[objB], obj.methodProcessed2)

		assertEquals(1, obj.methodEnvelope.counter)

		// explicit check that return types are correct (compilation error if there is no explicit cast)
		assertSame(TypeB, obj.class.getDeclaredMethod("methodProcessed1").returnType)
		assertSame(TypeB, obj.class.getDeclaredMethod("methodProcessed1__$beforeExtended$__TraitClassTypeA").returnType)
		assertSame(typeof(TypeB[]), obj.class.getDeclaredMethod("methodProcessed2").returnType)
		assertSame(typeof(TypeB[]),
			obj.class.getDeclaredMethod("methodProcessed2__$beforeExtended$__TraitClassTypeA").returnType)

		assertSame(TypeB, obj.class.getDeclaredMethod("methodEnvelope").returnType)
		assertSame(TypeB, obj.class.getDeclaredMethod("methodEnvelope__$beforeExtended$__TraitClassTypeA").returnType)

	}

	@Test
	def void testCovarianceOverridingInTraitClassAndExtendedClass() {

		val obj = new ExtendedClassTypeBHaveB()
		val objB = new TypeB()
		obj.setObjA(objB)
		assertEquals(10101, obj.methodProcessed1.counter)
		assertSame(objB, obj.methodProcessed1)
		assertArrayEquals(#[objB], obj.methodProcessed2)

		assertEquals(11, obj.methodEnvelope.counter)

		// explicit check that return types are correct (compilation error if there is no explicit cast)
		assertSame(TypeB, obj.class.getDeclaredMethod("methodProcessed1").returnType)
		assertSame(TypeB, obj.class.getDeclaredMethod("methodProcessed1__$beforeExtended$__TraitClassTypeB").returnType)
		assertSame(typeof(TypeB[]), obj.class.getDeclaredMethod("methodProcessed2").returnType)
		assertSame(typeof(TypeB[]),
			obj.class.getDeclaredMethod("methodProcessed2__$beforeExtended$__TraitClassTypeB").returnType)

		assertSame(TypeB, obj.class.getDeclaredMethod("methodEnvelope").returnType)
		assertSame(TypeB, obj.class.getDeclaredMethod("methodEnvelope__$beforeExtended$__TraitClassTypeB").returnType)

	}

	@Test
	def void testCovarianceMultipleTraitClassesDifferentReturnTypes() {

		{

			val obj = new ExtendedClassTypeABNotDerivedHaveA()
			val objB = new TypeB()
			obj.setObjA(objB)
			assertSame(objB, obj.methodProcessed1)
			assertEquals(10001, objB.counter)
			assertSame(objB, obj.methodProcessed5)
			assertEquals(20102, objB.counter)

			// explicit check that return types are correct (compilation error if there is no explicit cast)
			assertSame(TypeA, obj.class.getDeclaredMethod("methodProcessed1").returnType)
			assertSame(TypeA,
				obj.class.getDeclaredMethod("methodProcessed1__$beforeExtended$__TraitClassTypeA").returnType)
			assertSame(typeof(TypeA[]), obj.class.getDeclaredMethod("methodProcessed2").returnType)
			assertSame(typeof(TypeA[]),
				obj.class.getDeclaredMethod("methodProcessed2__$beforeExtended$__TraitClassTypeA").returnType)
			assertSame(TypeB, obj.class.getDeclaredMethod("methodProcessed5").returnType)
			assertSame(TypeA,
				obj.class.getDeclaredMethod("methodProcessed5__$beforeExtended$__TraitClassTypeA").returnType)
			assertSame(TypeA,
				obj.class.getDeclaredMethod("methodProcessed5__$beforeExtended$__TraitClassTypeBNotDerived").returnType)
			assertSame(typeof(TypeB[]), obj.class.getDeclaredMethod("methodProcessed6").returnType)
			assertSame(typeof(TypeA[]),
				obj.class.getDeclaredMethod("methodProcessed6__$beforeExtended$__TraitClassTypeA").returnType)
			assertSame(typeof(TypeA[]),
				obj.class.getDeclaredMethod("methodProcessed6__$beforeExtended$__TraitClassTypeBNotDerived").returnType)

		}

		{
			val obj = new ExtendedClassTypeBNotDerivedAHaveA()
			val objB = new TypeB()
			obj.setObjA(objB)
			assertSame(objB, obj.methodProcessed1)
			assertEquals(10001, objB.counter)
			assertSame(objB, obj.methodProcessed5)
			assertEquals(20102, objB.counter)

			// explicit check that return types are correct (compilation error if there is no explicit cast)
			assertSame(TypeA, obj.class.getDeclaredMethod("methodProcessed1").returnType)
			assertSame(TypeA,
				obj.class.getDeclaredMethod("methodProcessed1__$beforeExtended$__TraitClassTypeA").returnType)
			assertSame(typeof(TypeA[]), obj.class.getDeclaredMethod("methodProcessed2").returnType)
			assertSame(typeof(TypeA[]),
				obj.class.getDeclaredMethod("methodProcessed2__$beforeExtended$__TraitClassTypeA").returnType)
			assertSame(TypeB, obj.class.getDeclaredMethod("methodProcessed5").returnType)
			assertSame(TypeB,
				obj.class.getDeclaredMethod("methodProcessed5__$beforeExtended$__TraitClassTypeA").returnType)
			assertSame(TypeA,
				obj.class.getDeclaredMethod("methodProcessed5__$beforeExtended$__TraitClassTypeBNotDerived").returnType)
			assertSame(typeof(TypeB[]), obj.class.getDeclaredMethod("methodProcessed6").returnType)
			assertSame(typeof(TypeB[]),
				obj.class.getDeclaredMethod("methodProcessed6__$beforeExtended$__TraitClassTypeA").returnType)
			assertSame(typeof(TypeA[]),
				obj.class.getDeclaredMethod("methodProcessed6__$beforeExtended$__TraitClassTypeBNotDerived").returnType)

		}

	}

	@Test
	def void testCovarianceExtendAbstract() {

		val obj = new ExtendedClassTypeBBNotDerivedHaveCA()
		val objC = new TypeC()
		obj.setObjA(objC)
		val returnedObj = obj.methodProcessed1
		assertSame(objC, returnedObj)
		returnedObj.calc2(1)
		assertEquals(15, returnedObj.counter)

	}

	@Test
	def void testCovarianceGeneric() {

		assertSame(typeof(TypeB), ExtendedClassTypeAGenericHaveB.getMethod("methodGeneric").returnType)
		assertEquals(2, IExtendedClassTypeAGenericHaveB.methods.filter[name == "methodGeneric"].size)
		assertSame(typeof(TypeB), IExtendedClassTypeAGenericHaveB.getMethod("methodGeneric").returnType)

		assertSame(typeof(TypeB), ExtendedClassTypeBGenericHaveA.getMethod("methodGeneric").returnType)
		assertEquals(1, IExtendedClassTypeBGenericHaveA.methods.filter[name == "methodGeneric"].size)
		assertSame(typeof(Object), IExtendedClassTypeBGenericHaveA.getMethod("methodGeneric").returnType)

	}

	@Test
	def void testCovarianceWrongCast() {

		var boolean exceptionThrown

		val obj = new ExtendedClassTypeABNotDerivedHaveA()

		TEST_BUFFER = "";
		exceptionThrown = false
		try {
			obj.methodProcessed9
		} catch (ClassCastException classCastException) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

	}

	@Test
	def void testCovarianceInterfaces() {

		assertSame(typeof(TypeC),
			IExtendedClassTypeABNotDerivedHaveCAAbstract.getDeclaredMethod("methodProcessed1").returnType)
		assertSame(typeof(TypeC[]),
			IExtendedClassTypeABNotDerivedHaveCAAbstract.getDeclaredMethod("methodProcessed2").returnType)
		assertSame(typeof(TypeA), IExtendedClassTypeABNotDerivedHaveCAAbstract.getMethod("methodProcessed3").returnType)
		assertSame(typeof(TypeA[]),
			IExtendedClassTypeABNotDerivedHaveCAAbstract.getMethod("methodProcessed4").returnType)
		assertSame(typeof(TypeC),
			IExtendedClassTypeABNotDerivedHaveCAAbstract.getDeclaredMethod("methodProcessed5").returnType)
		assertSame(typeof(TypeC[]),
			IExtendedClassTypeABNotDerivedHaveCAAbstract.getDeclaredMethod("methodProcessed6").returnType)
		assertTrue(IExtendedClassTypeABNotDerivedHaveCAAbstract.methods.exists [
			name == "methodProcessed7" && it.returnType == typeof(TypeB)
		])
		assertTrue(IExtendedClassTypeABNotDerivedHaveCAAbstract.methods.exists [
			name == "methodProcessed8" && it.returnType == typeof(TypeB[])
		])

		assertSame(typeof(TypeC),
			IExtendedClassTypeBBNotDerivedHaveCAAbstract.getDeclaredMethod("methodProcessed1").returnType)
		assertSame(typeof(TypeC[]),
			IExtendedClassTypeBBNotDerivedHaveCAAbstract.getDeclaredMethod("methodProcessed2").returnType)
		assertSame(typeof(TypeB), IExtendedClassTypeBBNotDerivedHaveCAAbstract.getMethod("methodProcessed3").returnType)
		assertSame(typeof(TypeB[]),
			IExtendedClassTypeBBNotDerivedHaveCAAbstract.getMethod("methodProcessed4").returnType)
		assertSame(typeof(TypeC),
			IExtendedClassTypeBBNotDerivedHaveCAAbstract.getDeclaredMethod("methodProcessed5").returnType)
		assertSame(typeof(TypeC[]),
			IExtendedClassTypeBBNotDerivedHaveCAAbstract.getDeclaredMethod("methodProcessed6").returnType)
		assertTrue(IExtendedClassTypeBBNotDerivedHaveCAAbstract.methods.exists [
			name == "methodProcessed7" && it.returnType == typeof(TypeB)
		])
		assertTrue(IExtendedClassTypeBBNotDerivedHaveCAAbstract.methods.exists [
			name == "methodProcessed8" && it.returnType == typeof(TypeB[])
		])

		assertSame(typeof(TypeC),
			IExtendedClassTypeBNotDerivedAHaveCAAbstract.getDeclaredMethod("methodProcessed1").returnType)
		assertSame(typeof(TypeC[]),
			IExtendedClassTypeBNotDerivedAHaveCAAbstract.getDeclaredMethod("methodProcessed2").returnType)
		assertSame(typeof(TypeA), IExtendedClassTypeBNotDerivedAHaveCAAbstract.getMethod("methodProcessed3").returnType)
		assertSame(typeof(TypeA[]),
			IExtendedClassTypeBNotDerivedAHaveCAAbstract.getMethod("methodProcessed4").returnType)
		assertSame(typeof(TypeC),
			IExtendedClassTypeBNotDerivedAHaveCAAbstract.getDeclaredMethod("methodProcessed5").returnType)
		assertSame(typeof(TypeC[]),
			IExtendedClassTypeBNotDerivedAHaveCAAbstract.getDeclaredMethod("methodProcessed6").returnType)
		assertTrue(IExtendedClassTypeBNotDerivedAHaveCAAbstract.methods.exists [
			name == "methodProcessed7" && it.returnType == typeof(TypeB)
		])
		assertTrue(IExtendedClassTypeBNotDerivedAHaveCAAbstract.methods.exists [
			name == "methodProcessed8" && it.returnType == typeof(TypeB[])
		])

		assertSame(typeof(TypeC),
			IExtendedClassTypeBNotDerivedBHaveCAAbstract.getDeclaredMethod("methodProcessed1").returnType)
		assertSame(typeof(TypeC[]),
			IExtendedClassTypeBNotDerivedBHaveCAAbstract.getDeclaredMethod("methodProcessed2").returnType)
		assertSame(typeof(TypeB), IExtendedClassTypeBNotDerivedBHaveCAAbstract.getMethod("methodProcessed3").returnType)
		assertSame(typeof(TypeB[]),
			IExtendedClassTypeBNotDerivedBHaveCAAbstract.getMethod("methodProcessed4").returnType)
		assertSame(typeof(TypeC),
			IExtendedClassTypeBNotDerivedBHaveCAAbstract.getDeclaredMethod("methodProcessed5").returnType)
		assertSame(typeof(TypeC[]),
			IExtendedClassTypeBNotDerivedBHaveCAAbstract.getDeclaredMethod("methodProcessed6").returnType)
		assertTrue(IExtendedClassTypeBNotDerivedBHaveCAAbstract.methods.exists [
			name == "methodProcessed7" && it.returnType == typeof(TypeB)
		])
		assertTrue(IExtendedClassTypeBNotDerivedBHaveCAAbstract.methods.exists [
			name == "methodProcessed8" && it.returnType == typeof(TypeB[])
		])

	}

	@Test
	def void testCovarianceSignatureInAbstractBaseClass() {

		assertSame(typeof(TypeA),
			ExtendedClassTypeABNotDerivedHaveCADerived.getDeclaredMethod("methodProcessed1").returnType)
		assertSame(typeof(TypeA[]),
			ExtendedClassTypeABNotDerivedHaveCADerived.getDeclaredMethod("methodProcessed2").returnType)
		assertSame(typeof(TypeC),
			ExtendedClassTypeABNotDerivedHaveCADerived.getDeclaredMethod("methodProcessed3").returnType)
		assertSame(typeof(TypeC[]),
			ExtendedClassTypeABNotDerivedHaveCADerived.getDeclaredMethod("methodProcessed4").returnType)
		assertSame(typeof(TypeB),
			ExtendedClassTypeABNotDerivedHaveCADerived.getDeclaredMethod("methodProcessed5").returnType)
		assertSame(typeof(TypeB[]),
			ExtendedClassTypeABNotDerivedHaveCADerived.getDeclaredMethod("methodProcessed6").returnType)
		assertTrue(ExtendedClassTypeABNotDerivedHaveCADerived.methods.exists [
			name == "methodProcessed7" && it.returnType == typeof(TypeC)
		])
		assertTrue(ExtendedClassTypeABNotDerivedHaveCADerived.methods.exists [
			name == "methodProcessed8" && it.returnType == typeof(TypeC[])
		])

		assertSame(typeof(TypeB),
			ExtendedClassTypeBBNotDerivedHaveCADerived.getDeclaredMethod("methodProcessed1").returnType)
		assertSame(typeof(TypeB[]),
			ExtendedClassTypeBBNotDerivedHaveCADerived.getDeclaredMethod("methodProcessed2").returnType)
		assertSame(typeof(TypeC),
			ExtendedClassTypeBBNotDerivedHaveCADerived.getDeclaredMethod("methodProcessed3").returnType)
		assertSame(typeof(TypeC[]),
			ExtendedClassTypeBBNotDerivedHaveCADerived.getDeclaredMethod("methodProcessed4").returnType)
		assertSame(typeof(TypeB),
			ExtendedClassTypeBBNotDerivedHaveCADerived.getDeclaredMethod("methodProcessed5").returnType)
		assertSame(typeof(TypeB[]),
			ExtendedClassTypeBBNotDerivedHaveCADerived.getDeclaredMethod("methodProcessed6").returnType)
		assertTrue(ExtendedClassTypeBBNotDerivedHaveCADerived.methods.exists [
			name == "methodProcessed7" && it.returnType == typeof(TypeC)
		])
		assertTrue(ExtendedClassTypeBBNotDerivedHaveCADerived.methods.exists [
			name == "methodProcessed8" && it.returnType == typeof(TypeC[])
		])

		assertSame(typeof(TypeA),
			ExtendedClassTypeBNotDerivedAHaveCADerived.getDeclaredMethod("methodProcessed1").returnType)
		assertSame(typeof(TypeA[]),
			ExtendedClassTypeBNotDerivedAHaveCADerived.getDeclaredMethod("methodProcessed2").returnType)
		assertSame(typeof(TypeC),
			ExtendedClassTypeBNotDerivedAHaveCADerived.getDeclaredMethod("methodProcessed3").returnType)
		assertSame(typeof(TypeC[]),
			ExtendedClassTypeBNotDerivedAHaveCADerived.getDeclaredMethod("methodProcessed4").returnType)
		assertSame(typeof(TypeB),
			ExtendedClassTypeBNotDerivedAHaveCADerived.getDeclaredMethod("methodProcessed5").returnType)
		assertSame(typeof(TypeB[]),
			ExtendedClassTypeBNotDerivedAHaveCADerived.getDeclaredMethod("methodProcessed6").returnType)
		assertTrue(ExtendedClassTypeBNotDerivedAHaveCADerived.methods.exists [
			name == "methodProcessed7" && it.returnType == typeof(TypeC)
		])
		assertTrue(ExtendedClassTypeBNotDerivedAHaveCADerived.methods.exists [
			name == "methodProcessed8" && it.returnType == typeof(TypeC[])
		])

		assertSame(typeof(TypeB),
			ExtendedClassTypeBNotDerivedBHaveCADerived.getDeclaredMethod("methodProcessed1").returnType)
		assertSame(typeof(TypeB[]),
			ExtendedClassTypeBNotDerivedBHaveCADerived.getDeclaredMethod("methodProcessed2").returnType)
		assertSame(typeof(TypeC),
			ExtendedClassTypeBNotDerivedBHaveCADerived.getDeclaredMethod("methodProcessed3").returnType)
		assertSame(typeof(TypeC[]),
			ExtendedClassTypeBNotDerivedBHaveCADerived.getDeclaredMethod("methodProcessed4").returnType)
		assertSame(typeof(TypeB),
			ExtendedClassTypeBNotDerivedBHaveCADerived.getDeclaredMethod("methodProcessed5").returnType)
		assertSame(typeof(TypeB[]),
			ExtendedClassTypeBNotDerivedBHaveCADerived.getDeclaredMethod("methodProcessed6").returnType)
		assertTrue(ExtendedClassTypeBNotDerivedBHaveCADerived.methods.exists [
			name == "methodProcessed7" && it.returnType == typeof(TypeC)
		])
		assertTrue(ExtendedClassTypeBNotDerivedBHaveCADerived.methods.exists [
			name == "methodProcessed8" && it.returnType == typeof(TypeC[])
		])

	}

}
