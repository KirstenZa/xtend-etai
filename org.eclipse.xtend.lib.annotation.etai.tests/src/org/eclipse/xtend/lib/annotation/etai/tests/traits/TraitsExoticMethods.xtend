package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassExoticMethods
import java.util.List
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
abstract class TraitClassExoticMethods {

	@ExclusiveMethod
	override Object [] method1() {
		return #{null}
	}

	@ExclusiveMethod
	override Object [][] method2() {
		return #{null}
	}

	@ExclusiveMethod
	override List<? extends String> method3() {
		return null
	}

	@ExclusiveMethod
	override List<? extends String> [][] method4() {
		return #{null}
	}

	@ExclusiveMethod
	override List<? super String> method5() {
		return null
	}

	@ExclusiveMethod
	override List<? super String> [][] method6() {
		return #{null}
	}

}

@ExtendedByAuto
class ExtendedClassExoticMethods implements ITraitClassExoticMethods {
}

class ExtendedClassExoticMethodTests extends TraitTestsBase {

	@Test
	def void testExoticMethods() {

		assertEquals(true, ExtendedClassExoticMethods.getMethod("method1").returnType.array)
		assertSame(Object, ExtendedClassExoticMethods.getMethod("method1").returnType.getComponentType())

		assertEquals(true, ExtendedClassExoticMethods.getMethod("method2").returnType.array)
		assertEquals(true, ExtendedClassExoticMethods.getMethod("method2").returnType.getComponentType().array)
		assertSame(Object, ExtendedClassExoticMethods.getMethod("method2").returnType.getComponentType().getComponentType())

		assertSame(List, ExtendedClassExoticMethods.getMethod("method3").returnType)

		assertEquals(true, ExtendedClassExoticMethods.getMethod("method4").returnType.array)
		assertEquals(true, ExtendedClassExoticMethods.getMethod("method4").returnType.getComponentType().array)
		assertSame(List, ExtendedClassExoticMethods.getMethod("method4").returnType.getComponentType().getComponentType())

		assertSame(List, ExtendedClassExoticMethods.getMethod("method5").returnType)

		assertEquals(true, ExtendedClassExoticMethods.getMethod("method6").returnType.array)
		assertEquals(true, ExtendedClassExoticMethods.getMethod("method6").returnType.getComponentType().array)
		assertSame(List, ExtendedClassExoticMethods.getMethod("method6").returnType.getComponentType().getComponentType())

	}

}