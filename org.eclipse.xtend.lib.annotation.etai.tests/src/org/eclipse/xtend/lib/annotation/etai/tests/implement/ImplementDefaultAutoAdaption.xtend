/**
 * Test passes if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.implement

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.ImplAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.ImplementDefault
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.implement.intf.IExtensionWithAdaption
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
@ApplyRules
abstract class ExtensionWithAdaption {

	@RequiredMethod
	@ImplAdaptionRule(value="apply(return \");appendVariable(var.class.qualified);append(\";)", typeExistenceCheck="applyVariable(var.class.qualified);append(DoesNotExist)")
	override String exmethod11()

	@RequiredMethod
	@ImplAdaptionRule(value="apply(return \");appendVariable(var.class.qualified);append(\";)", typeExistenceCheck="applyVariable(var.class.qualified);append(ForExistence)")
	override String exmethod12()

	@RequiredMethod
	@TypeAdaptionRule(value="apply(org.eclipse.xtend.lib.annotation.etai.tests.implement.TypeDerived)")
	override TypeBase exmethod13()

}

@ApplyRules
abstract class BaseWithAdaption {

	public int value

	@ImplAdaptionRule(value="apply(return \");appendVariable(var.class.qualified);append(\";)", typeExistenceCheck="applyVariable(var.class.qualified);append(DoesNotExist)")
	def String method11()

	@ImplAdaptionRule(value="apply(return \");appendVariable(var.class.qualified);append(\";)", typeExistenceCheck="applyVariable(var.class.qualified);append(ForExistence)")
	def String method12()

	@TypeAdaptionRule(value="apply(org.eclipse.xtend.lib.annotation.etai.tests.implement.TypeDerived)")
	def TypeBase method13()

}

class DerivedWithAdaptionForExistence {
}

class ConcreteWithAdaptionNoExistingForExistence {
}

@ApplyRules
@ExtendedByAuto
abstract class DerivedWithAdaption extends BaseWithAdaption implements IExtensionWithAdaption {
}

@ApplyRules
@ImplementDefault
class ConcreteWithAdaption extends DerivedWithAdaption {
}

@ApplyRules
@ExtendedByAuto
@ImplementDefault
class DerivedWithAdaptionNoExisting extends BaseWithAdaption implements IExtensionWithAdaption {
}

@ApplyRules
class ConcreteWithAdaptionNoExisting extends DerivedWithAdaptionNoExisting {
}

class ImplementDefaultAutoAdaptionTests {

	@Test
	def void testImplementDefaultWithImplAdaption() {

		val obj1 = new ConcreteWithAdaption;
		assertNull(obj1.exmethod11)
		assertEquals("org.eclipse.xtend.lib.annotation.etai.tests.implement.DerivedWithAdaption", obj1.exmethod12)
		assertNull(obj1.method11)
		assertEquals("org.eclipse.xtend.lib.annotation.etai.tests.implement.DerivedWithAdaption", obj1.method12)

		val obj2 = new ConcreteWithAdaptionNoExisting;
		assertNull(obj2.exmethod11)
		assertEquals("org.eclipse.xtend.lib.annotation.etai.tests.implement.ConcreteWithAdaptionNoExisting", obj2.exmethod12)
		assertNull(obj2.method11)
		assertEquals("org.eclipse.xtend.lib.annotation.etai.tests.implement.ConcreteWithAdaptionNoExisting", obj2.method12)

	}

	@Test
	def void testImplementDefaultWithTypeAdaption() {

		assertSame(TypeDerived, DerivedWithAdaption.getMethod("method13").returnType)
		assertSame(TypeDerived, ConcreteWithAdaption.getMethod("method13").returnType)
		assertSame(TypeDerived, DerivedWithAdaptionNoExisting.getMethod("method13").returnType)
		assertSame(TypeDerived, ConcreteWithAdaptionNoExisting.getMethod("method13").returnType)

		assertSame(TypeDerived, DerivedWithAdaption.getMethod("exmethod13").returnType)
		assertSame(TypeDerived, ConcreteWithAdaption.getMethod("exmethod13").returnType)
		assertSame(TypeDerived, DerivedWithAdaptionNoExisting.getMethod("exmethod13").returnType)
		assertSame(TypeDerived, ConcreteWithAdaptionNoExisting.getMethod("exmethod13").returnType)

	}

}
