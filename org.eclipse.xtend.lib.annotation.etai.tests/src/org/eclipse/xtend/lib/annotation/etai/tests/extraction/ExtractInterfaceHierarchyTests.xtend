/**
 * Test passes, if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.extraction

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.tests.extraction.intf.IExtractInterfaceDerived
import org.junit.Test

import static org.junit.Assert.*

interface I1 {}
interface I2 { def void method3() }
interface I3 {}

@ExtractInterface
class ExtractInterfaceBaseClassWithAnnotation implements I1 {
	override void method1() {}
}

abstract class ExtractInterfaceBaseClassWithoutAnnotation extends ExtractInterfaceBaseClassWithAnnotation implements I2 {
	def void method2() {}
}

@ExtractInterface
class ExtractInterfaceDerived extends ExtractInterfaceBaseClassWithoutAnnotation implements I3 {
	override void method3() {}
	override void method4() {}
}

class ExtractInterfaceHierarchyTests {

	@Test
	public def void testInterfaceContent() {

		assertEquals(0, IExtractInterfaceDerived.declaredMethods.filter[name == "method1"].length)
		assertEquals(1, IExtractInterfaceDerived.declaredMethods.filter[name == "method2"].length)
		assertEquals(0, IExtractInterfaceDerived.declaredMethods.filter[name == "method3"].length)
		assertEquals(1, IExtractInterfaceDerived.declaredMethods.filter[name == "method4"].length)
		
		// interface check in code
		val obj = new ExtractInterfaceDerived
		val IExtractInterfaceDerived iObj1 = obj
		val I2 iObj2 = iObj1
	    iObj2.method3

	}
	
}