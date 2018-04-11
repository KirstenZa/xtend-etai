/**
 * Test passes, if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.extraction

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.tests.extraction.intf.IExtractInterfaceTestNoMethod
import org.eclipse.xtend.lib.annotation.etai.tests.extraction.intf.IExtractInterfaceTestRegular

// Regular comments won't be generated in Java
@ExtractInterface
class ExtractInterfaceTestNoMethod {
}

class ExtractInterfaceTestRegularBase {

	def void methodBase() {}

}

/**
 * This is a JavaDoc comment.
 * 
 * And this is another test line.
 */
@ExtractInterface
class ExtractInterfaceTestRegular extends ExtractInterfaceTestRegularBase {

	override void method() {}

	override int method2(int i) { 3 }

}

class ExtractInterfaceTestInnerClass {

	@ExtractInterface
	static public class Inner {

		override void method() {}

		override int method2(int i) { 3 }

	}

}

class ExtractInterfaceTestCode {

	def method1() {
		var IExtractInterfaceTestNoMethod obj = null
		return obj
	}

	def method2() {
		var IExtractInterfaceTestRegular obj = null
		obj.methodBase
		obj.method
		obj.method2(5)
		return obj
	}

	def method3() {
		var ExtractInterfaceTestInnerClass.IInner obj = null
		obj.method
		obj.method2(5)
		return obj
	}

}
