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

import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TraitMethodProcessor
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.LazyEvaluation
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.IExtendedClassTypeCCombiningAbstract
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassTypeA
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassTypeB
import java.util.Arrays
import org.junit.Test

import static org.junit.Assert.*

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

	TypeA objA

	@ExclusiveMethod
	override TypeA getObjA() {
		objA
	}

	@ExclusiveMethod
	override void setObjA(TypeA objA) {
		this.objA = objA
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeA method1() {
		objA.calc(1)
		return objA
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeA[] method2() {
		objA.calc(1)
		return #[objA]
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeA method3() {
		null
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeA[] method4() {
		null
	}

}

@TraitClassAutoUsing
abstract class TraitClassTypeB extends TraitClassTypeA {

	@ProcessedMethod(processor=TypeCombinator)
	override TypeB method1() {
		objA.calc(100)
		return super.method1$impl() as TypeB
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeB[] method2() {
		objA.calc(100)
		val baseArray = super.method2$impl()
		return Arrays.copyOf(baseArray, baseArray.length, typeof(TypeB[]))
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeB method3() {
		return super.method3$impl() as TypeB
	}

	@ProcessedMethod(processor=TypeCombinator)
	override TypeB[] method4() {
		val baseArray = super.method2$impl()
		return Arrays.copyOf(baseArray, baseArray.length, typeof(TypeB[]))
	}

}

@ExtendedByAuto
class ExtendedClassTypeACombining implements ITraitClassTypeA {

	override TypeB method1() {
		objA.calc(10000)
		return objA as TypeB
	}

	override TypeB [] method2() {
		objA.calc(10000)
		return #[objA as TypeB]
	}

}

@ExtendedByAuto
class ExtendedClassTypeB implements ITraitClassTypeB {
}

@ExtendedByAuto
class ExtendedClassTypeBCombining implements ITraitClassTypeB {

	override TypeB method1() {
		objA.calc(10000)
		return objA as TypeB
	}

	override TypeB [] method2() {
		objA.calc(10000)
		return #[objA as TypeB]
	}

}

@ExtendedByAuto
@ExtractInterface
abstract class ExtendedClassTypeCCombiningAbstract implements ITraitClassTypeB {

	abstract override TypeC method1()

	abstract override TypeC [] method2()

	abstract override TypeA method3()

	abstract override TypeA [] method4()

}

class ExtendedClassTypeCCombining extends ExtendedClassTypeCCombiningAbstract {
}

abstract class ExtendedClassTypeCCombiningAbstractBase {

	abstract def TypeA method1()

	abstract def TypeA [] method2()

	abstract def TypeC method3()

	abstract def TypeC [] method4()

}

@ExtendedByAuto
class ExtendedClassTypeCCombiningDervied extends ExtendedClassTypeCCombiningAbstractBase implements ITraitClassTypeB {
}

class TraitsCovarianceTests extends TraitTestsBase {

	@Test
	def void testCovarianceOverridingInTraitClass() {

		val obj = new ExtendedClassTypeB()
		val objB = new TypeB()
		obj.setObjA(objB)
		assertEquals(101, obj.method1.counter);
		assertSame(objB, obj.method1);
		assertArrayEquals(#[objB], obj.method2);

		// explicit check that return types are correct
		assertSame(TypeB, obj.class.getDeclaredMethod("method1").returnType);
		assertSame(typeof(TypeB[]), obj.class.getDeclaredMethod("method2").returnType);

	}

	@Test
	def void testCovarianceOverridingInExtendedClass() {

		val obj = new ExtendedClassTypeACombining()
		val objB = new TypeB()
		obj.setObjA(objB)
		assertEquals(10001, obj.method1.counter);
		assertSame(objB, obj.method1);
		assertArrayEquals(#[objB], obj.method2);

		// explicit check that return types are correct (compilation error, if there is no explicit cast)
		assertSame(TypeB, obj.class.getDeclaredMethod("method1").returnType);
		assertSame(TypeB, obj.class.getDeclaredMethod("method1__$beforeExtended$__TraitClassTypeA").returnType);
		assertSame(typeof(TypeB[]), obj.class.getDeclaredMethod("method2").returnType);
		assertSame(typeof(TypeB[]),
			obj.class.getDeclaredMethod("method2__$beforeExtended$__TraitClassTypeA").returnType);

	}

	@Test
	def void testCovarianceOverridingInTraitClassAndExtendedClass() {

		val obj = new ExtendedClassTypeBCombining()
		val objB = new TypeB()
		obj.setObjA(objB)
		assertEquals(10101, obj.method1.counter);
		assertSame(objB, obj.method1);
		assertArrayEquals(#[objB], obj.method2);

		// explicit check that return types are correct (compilation error, if there is no explicit cast)
		assertSame(TypeB, obj.class.getDeclaredMethod("method1").returnType);
		assertSame(TypeB, obj.class.getDeclaredMethod("method1__$beforeExtended$__TraitClassTypeB").returnType);
		assertSame(typeof(TypeB[]), obj.class.getDeclaredMethod("method2").returnType);
		assertSame(typeof(TypeB[]),
			obj.class.getDeclaredMethod("method2__$beforeExtended$__TraitClassTypeB").returnType);

	}

	@Test
	def void testCovarianceExtendAbstract() {

		val obj = new ExtendedClassTypeCCombining()
		val objC = new TypeC()
		obj.setObjA(objC)
		val returnedObj = obj.method1
		assertSame(objC, returnedObj);
		returnedObj.calc2(1)
		assertEquals(15, returnedObj.counter);

	}

	@Test
	def void testCovarianceInterfaces() {

		assertSame(typeof(TypeC), IExtendedClassTypeCCombiningAbstract.getDeclaredMethod("method1").returnType);
		assertSame(typeof(TypeC[]), IExtendedClassTypeCCombiningAbstract.getDeclaredMethod("method2").returnType);
		assertSame(typeof(TypeB), IExtendedClassTypeCCombiningAbstract.getMethod("method3").returnType);
		assertSame(typeof(TypeB[]), IExtendedClassTypeCCombiningAbstract.getMethod("method4").returnType);

	}

}
