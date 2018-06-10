package org.eclipse.xtend.lib.annotation.etai.tests.extraction

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.tests.extraction.intf.IExtractInterfaceWithGenerics1
import org.eclipse.xtend.lib.annotation.etai.tests.extraction.intf.IExtractInterfaceWithGenerics3
import java.math.BigInteger
import java.util.ArrayList
import java.util.List
import org.junit.Test

import static org.junit.Assert.*

@ExtractInterface
// note: xtend seems to have a bug if "B extends C" is used before "C extends A"
class ExtractInterfaceWithGenericsUpperBounded<A, C extends A, B extends C> {

	// note: xtend seems to have a bug if "E extends F" is used before "F extends D"
	override <D, F extends D, E extends F, A> A methodX(D var1) { null }

}

@ExtractInterface
class ExtractInterfaceWithGenericsBase<T, B> {

	override T method1(T var1) { var1 }

	override B method2(T var1, B var2) { var2 }

	override B method3(B var2) { var2 }

	override B method4(T var1, B var2) { var2 }

}

@ExtractInterface
class ExtractInterfaceWithGenerics1<T, B, C> extends ExtractInterfaceWithGenericsBase<Integer, T> {

	override T method3(T var2) { var2 }

	override T method4(Integer var1, T var2) { var2 }

	override C method6(T var1, B var2,
		C var3) { var3 }

	override List<? super C> method7() { null }

	override List<? extends C> method8() { null }

}

@ExtractInterface
class ExtractInterfaceWithGenerics2<B extends List<? extends Number>> extends ExtractInterfaceWithGenericsBase<B, B> {
}

@ExtractInterface
class ExtractInterfaceWithGenerics3<T extends List<? extends BigInteger>> extends ExtractInterfaceWithGenerics2<T> {
}

interface ExtractInterfaceWithGenericsInnerTypeBase<Y> {
	def Y method()
}

@ExtractInterface
class ExtractInterfaceWithGenericsInnerType<T> implements ExtractInterfaceWithGenericsInnerTypeBase<List<T>> {

	override List<T> method() {
		return null
	}

}

class ExtractInterfaceWithGenericsTests {

	@Test
	def void testMethodsInExtractedInterfaceWithGenerics() {

		var IExtractInterfaceWithGenerics1<String, Exception, Double> obj = new ExtractInterfaceWithGenerics1<String, Exception, Double>();
		assertEquals(20, obj.method1(20));
		assertEquals("test", obj.method2(30, "test"));
		assertEquals("test2", obj.method3("test2"));
		assertEquals("test", obj.method4(30, "test"));
		assertEquals(4.5, obj.method6("test1", new Exception, 4.5),
			0.001);

	}

	@Test
	def void testMethodsInExtractedInterfaceCheckBounds() {

		val list = new ArrayList<BigInteger>
		var IExtractInterfaceWithGenerics3<ArrayList<BigInteger>> obj = new ExtractInterfaceWithGenerics3<ArrayList<BigInteger>>()
		assertSame(list, obj.method1(list))
		assertSame(list, obj.method2(list, list))

	}

	@Test
	def void testMethodsInExtractedInterfaceInnerType() {

		val obj = new ExtractInterfaceWithGenericsInnerType<String>
		var List<String> stringList = obj.method
		assertNull(stringList);

	}

	@Test
	def void testMethodsInExtractedInterfaceAvoidRespecification() {

		assertEquals(3, IExtractInterfaceWithGenerics1.declaredMethods.size)
		assertEquals(#{"method6", "method7", "method8"},
			#{IExtractInterfaceWithGenerics1.declaredMethods.get(0).name,
				IExtractInterfaceWithGenerics1.declaredMethods.get(1).name,
				IExtractInterfaceWithGenerics1.declaredMethods.get(2).name})

	}

}
