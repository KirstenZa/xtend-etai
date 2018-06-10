/**
 * Test passes, if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.implement

import org.eclipse.xtend.lib.annotation.etai.ImplementDefault
import org.junit.Test

import static org.junit.Assert.*

interface InterfaceGeneric<T> {

	def void ifmethod11(T x)

	def T ifmethod12()

	def <U> T ifmethod13(U x)

	def void ifmethod21(T x)

	def T ifmethod22()

	def <U> T ifmethod23(U x)

	def void ifmethod31(T x)

	def T ifmethod32()

	def <U> T ifmethod33(U x)

}

abstract class AbstractBaseGeneric<T extends TypeBase> implements InterfaceGeneric<T> {

	def void method11()

	def T method12()

	def <U> T method13(U x)

	override void ifmethod21(T x) {}

	override T ifmethod22() { new TypeBase as T }

	override <U> T ifmethod23(U x) { new TypeBase as T }

}

@ImplementDefault
class NonAbstractGeneric1<T extends TypeBase> extends AbstractBaseGeneric<T> {

	override void ifmethod31(T x) {}

	override T ifmethod32() { new TypeBase as T }

	override <U> T ifmethod33(U x) { new TypeBase as T }

}

@ImplementDefault
class NonAbstractGeneric2 extends AbstractBaseGeneric<TypeBase> {

	override void ifmethod31(TypeBase x) {}

	override TypeBase ifmethod32() { new TypeBase }

	override <U> TypeBase ifmethod33(U x) { new TypeBase }

}

class ImplementDefaultWithGenericsTests {

	@Test
	def void testDefaultImplementationGeneric() {

		val obj1 = new NonAbstractGeneric1
		obj1.method11
		assertNull(obj1.method12)
		assertNull(obj1.method13(null))
		obj1.ifmethod21(null)
		assertNotNull(obj1.ifmethod22)
		assertNotNull(obj1.ifmethod23(null))
		obj1.ifmethod31(null)
		assertNotNull(obj1.ifmethod32)
		assertNotNull(obj1.ifmethod33(null))

		val obj2 = new NonAbstractGeneric1
		obj2.method11
		assertNull(obj2.method12)
		assertNull(obj2.method13(null))
		obj2.ifmethod21(null)
		assertNotNull(obj2.ifmethod22)
		assertNotNull(obj2.ifmethod23(null))
		obj2.ifmethod31(null)
		assertNotNull(obj2.ifmethod32)
		assertNotNull(obj2.ifmethod33(null))

	}

}
