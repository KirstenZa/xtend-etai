package org.eclipse.xtend.lib.annotation.etai.tests.extraction

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.tests.extraction.intf.IExtractInterfaceExoticMethods

import org.junit.Test

import static org.junit.Assert.*

@ExtractInterface
class ExtractInterfaceExoticMethods {
	
	// this method is using inferred types that must only be used if not extracted
	protected def methodWithInferredType() {
		return 1
	} 

	override Object [] method1() {
		return #{null}
	}
	
	override Object [][] method2() {
		return #{null}
	}

}

class ExtractInterfaceExoticMethodsTests {

	@Test
	def void testReturnTypeArray() {

		assertEquals(true, IExtractInterfaceExoticMethods.getMethod("method1").returnType.array)
		assertEquals(false, IExtractInterfaceExoticMethods.getMethod("method1").returnType.getComponentType().array)
		assertEquals(true, IExtractInterfaceExoticMethods.getMethod("method2").returnType.array)
		assertEquals(true, IExtractInterfaceExoticMethods.getMethod("method2").returnType.getComponentType().array)
		assertEquals(false, IExtractInterfaceExoticMethods.getMethod("method2").returnType.getComponentType().getComponentType().array)

	}
	
}