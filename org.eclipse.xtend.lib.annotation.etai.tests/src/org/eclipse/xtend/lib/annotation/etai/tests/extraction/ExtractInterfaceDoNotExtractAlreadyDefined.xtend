package org.eclipse.xtend.lib.annotation.etai.tests.extraction

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.tests.extraction.intf.IExtractInterfacePartly
import java.util.HashSet
import org.junit.Test

import static org.junit.Assert.*

class BaseClassPartlyExtractionTest {
}

class DerivedClassPartlyExtractionTest extends BaseClassPartlyExtractionTest {
}

// Doc1
interface PartInterface1 {

	def void method1()

}

/**
 * Doc2
 */
interface PartInterface2 extends PartInterface1 {

	def void method2()

}

interface PartInterface3 {

	// this is a first comment
	def void method3()

	def BaseClassPartlyExtractionTest method4()

}

@ExtractInterface
class ExtractInterfacePartly implements PartInterface2, PartInterface3 {

	override void method1() {}

	override void method2() {}

	// this is another comment
	override void method3() {}

	// must be contained within extracted interface (covariance)
	override DerivedClassPartlyExtractionTest method4() {}

	override void method5() {}

}

class ExtractInterfaceDoNotExtractAlreadyDefinedTests {

	@Test
	def void testMethodsInExtractedInterfaceWithoutAlreadyDefined() {

		assertEquals(2, IExtractInterfacePartly.interfaces.size)
		assertEquals(#{PartInterface2, PartInterface3}, new HashSet(IExtractInterfacePartly.interfaces))
		
		val declaredMethodInterface = IExtractInterfacePartly.declaredMethods.filter[synthetic == false]	
		assertEquals(2, declaredMethodInterface.size)
		assertEquals(#{"method4", "method5"},
			#{declaredMethodInterface.get(0).name, declaredMethodInterface.get(1).name})

	}

}
