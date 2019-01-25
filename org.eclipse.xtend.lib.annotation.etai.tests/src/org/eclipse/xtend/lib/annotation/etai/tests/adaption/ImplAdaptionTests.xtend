package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import org.eclipse.xtend.lib.annotation.etai.AdaptedMethod
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.CopyConstructorRule
import org.eclipse.xtend.lib.annotation.etai.EPDefault
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ImplAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IReturnAdaptionTrait
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IReturnAdaptionTraitExtended
import org.junit.Test

import static org.junit.Assert.*

class ReturnAdaptionType1Return {
}

class ReturnAdaptionType2Return extends ReturnAdaptionType1Return {
}

class ReturnAdaptionType3Return extends ReturnAdaptionType2Return {
}

class ReturnAdaptionType4Return extends ReturnAdaptionType3Return {
}

class ReturnAdaptionType5Return extends ReturnAdaptionType4Return {
}

class ReturnAdaptionType6Return extends ReturnAdaptionType5Return {
}

class ReturnAdaptionType7Return extends ReturnAdaptionType6Return {
}

class ReturnAdaptionType8Return extends ReturnAdaptionType7Return {
}

@TraitClassAutoUsing
@ApplyRules
abstract class ReturnAdaptionTrait {

	@RequiredMethod
	@ImplAdaptionRule("apply(return \");appendVariable(var.class.qualified);append(\";)")
	override String getQualifiedTypeName()

	@ProcessedMethod(processor=EPDefault)
	@ImplAdaptionRule("apply(return \");appendVariable(var.class.qualified);append(\";)")
	override String getQualifiedTypeNameAlternative() {
		return ""
	}

}

@TraitClassAutoUsing
@ApplyRules
abstract class ReturnAdaptionTraitExtended extends ReturnAdaptionTrait {
}

@ApplyRules
abstract class ReturnAdaptionType1 {

	public int value

	@CopyConstructorRule
	@ImplAdaptionRule(value="apply(super(\"\");\nvalue += 1;)", typeExistenceCheck="applyVariable(var.class.simple);replace(ReturnAdaptionType4,);appendVariable(var.class.qualified)")
	new(String x) {
	}

	@TypeAdaptionRule("applyVariable(var.class.qualified);append(Return)")
	@ImplAdaptionRule(value="applyVariable(var.class.qualified);prepend(return new );append(Return();)")
	def ReturnAdaptionType1Return method()

	@ImplAdaptionRule("applyVariable(var.class.qualified);replaceAll(.*([0-9]),$1);prepend(return \");append(\";)")
	def String getClassNumber() {
		"Nothing"
	}

	@ImplAdaptionRule(value="apply(return 1 + super.countNonAbstract();)", typeExistenceCheck="applyVariable(var.class.abstract);replace(false,);appendVariable(var.class.qualified)")
	def int countNonAbstract() {
		10
	}

	@ImplAdaptionRule(value="applyVariable(var.class.qualified);replaceAll(.*([0-9]),$1);prepend(x + );prependVariable(const.bracket.round.open);prepend(return new Double);appendVariable(const.bracket.round.close);append(.toString();)")
	static def String returnAsString(
		@TypeAdaptionRule("apply(Double)")
		Integer x
	) {
		return x.toString
	}

	@ImplAdaptionRule("")
	abstract def void methodToBeImplemented()

}

@ApplyRules
class ReturnAdaptionType2 extends ReturnAdaptionType1 {
}

@ApplyRules
@ExtendedByAuto
abstract class ReturnAdaptionType3 extends ReturnAdaptionType2 implements IReturnAdaptionTrait {
}

@ApplyRules
class ReturnAdaptionType4 extends ReturnAdaptionType3 {
}

@ApplyRules
class ReturnAdaptionType5 extends ReturnAdaptionType4 {

	@AdaptedMethod
	override ReturnAdaptionType4Return method() {
		return new ReturnAdaptionType4Return()
	}

}

@ApplyRules
class ReturnAdaptionType6 extends ReturnAdaptionType5 {
}

@ApplyRules
@ExtendedByAuto
class ReturnAdaptionType7 extends ReturnAdaptionType2 implements IReturnAdaptionTraitExtended {
}

@ApplyRules
class ReturnAdaptionType8 extends ReturnAdaptionType7 {
}

class ImplAdaptionTests {

	@Test
	def void testImplAdaptionConstructors() {

		val obj2 = new ReturnAdaptionType2("")
		val obj4 = new ReturnAdaptionType4("")
		val obj5 = new ReturnAdaptionType5("")
		val obj6 = new ReturnAdaptionType6("")

		assertEquals(0, obj2.value)
		assertEquals(1, obj4.value)
		assertEquals(1, obj5.value)
		assertEquals(1, obj6.value)

	}

	@Test
	def void testImplAdaptionMethods() {

		val obj2 = new ReturnAdaptionType2("")
		val obj4 = new ReturnAdaptionType4("")
		val obj5 = new ReturnAdaptionType5("")
		val obj6 = new ReturnAdaptionType6("")

		assertEquals(1, ReturnAdaptionType2.declaredMethods.filter[name == "method" && synthetic == false].size)
		assertSame(ReturnAdaptionType2Return, ReturnAdaptionType2.declaredMethods.filter[
			name == "method" && synthetic == false
		].get(0).returnType)
		assertEquals(1, ReturnAdaptionType3.declaredMethods.filter[name == "method" && synthetic == false].size)
		assertSame(ReturnAdaptionType3Return, ReturnAdaptionType3.declaredMethods.filter[
			name == "method" && synthetic == false
		].get(0).returnType)
		assertEquals(1, ReturnAdaptionType4.declaredMethods.filter[name == "method" && synthetic == false].size)
		assertSame(ReturnAdaptionType4Return, ReturnAdaptionType4.declaredMethods.filter[
			name == "method" && synthetic == false
		].get(0).returnType)
		assertEquals(1, ReturnAdaptionType5.declaredMethods.filter[name == "method" && synthetic == false].size)
		assertSame(ReturnAdaptionType4Return, ReturnAdaptionType5.declaredMethods.filter[
			name == "method" && synthetic == false
		].get(0).returnType)
		assertEquals(1, ReturnAdaptionType6.declaredMethods.filter[name == "method" && synthetic == false].size)
		assertSame(ReturnAdaptionType6Return, ReturnAdaptionType6.declaredMethods.filter[
			name == "method" && synthetic == false
		].get(0).returnType)

		assertSame(ReturnAdaptionType2Return, obj2.method.class)
		assertSame(ReturnAdaptionType4Return, obj4.method.class)
		assertSame(ReturnAdaptionType4Return, obj5.method.class)
		assertSame(ReturnAdaptionType6Return, obj6.method.class)

		assertEquals("2", obj2.getClassNumber)
		assertEquals("4", obj4.getClassNumber)
		assertEquals("5", obj5.getClassNumber)
		assertEquals("6", obj6.getClassNumber)

		assertEquals(11, obj2.countNonAbstract)
		assertEquals(12, obj4.countNonAbstract)
		assertEquals(13, obj5.countNonAbstract)
		assertEquals(14, obj6.countNonAbstract)

	}

	@Test
	def void testImplAdaptionMethodsStatic() {

		assertEquals("10", ReturnAdaptionType1.returnAsString(Integer::valueOf(10)))
		assertEquals("10", ReturnAdaptionType2.returnAsString(Integer::valueOf(10)))
		assertEquals("10", ReturnAdaptionType3.returnAsString(Integer::valueOf(10)))
		assertEquals("10", ReturnAdaptionType4.returnAsString(Integer::valueOf(10)))
		assertEquals("10", ReturnAdaptionType5.returnAsString(Integer::valueOf(10)))
		assertEquals("10", ReturnAdaptionType6.returnAsString(Integer::valueOf(10)))

		assertEquals(1, ReturnAdaptionType1.methods.filter[name == "returnAsString"].size)
		assertEquals("12.0", ReturnAdaptionType2.returnAsString(Double::valueOf(10)))
		assertEquals("13.0", ReturnAdaptionType3.returnAsString(Double::valueOf(10)))
		assertEquals("14.0", ReturnAdaptionType4.returnAsString(Double::valueOf(10)))
		assertEquals("15.0", ReturnAdaptionType5.returnAsString(Double::valueOf(10)))
		assertEquals("16.0", ReturnAdaptionType6.returnAsString(Double::valueOf(10)))

	}

	@Test
	def void testImplAdaptionFromExtension() {

		val obj4 = new ReturnAdaptionType4("")
		val obj7 = new ReturnAdaptionType7("")
		val obj8 = new ReturnAdaptionType8("")

		assertEquals("org.eclipse.xtend.lib.annotation.etai.tests.adaption.ReturnAdaptionType4", obj4.qualifiedTypeName)
		assertEquals("org.eclipse.xtend.lib.annotation.etai.tests.adaption.ReturnAdaptionType7", obj7.qualifiedTypeName)
		assertEquals("org.eclipse.xtend.lib.annotation.etai.tests.adaption.ReturnAdaptionType8", obj8.qualifiedTypeName)

		assertEquals("org.eclipse.xtend.lib.annotation.etai.tests.adaption.ReturnAdaptionType4",
			obj4.qualifiedTypeNameAlternative)
		assertEquals("org.eclipse.xtend.lib.annotation.etai.tests.adaption.ReturnAdaptionType7",
			obj7.qualifiedTypeNameAlternative)
		assertEquals("org.eclipse.xtend.lib.annotation.etai.tests.adaption.ReturnAdaptionType8",
			obj8.qualifiedTypeNameAlternative)

	}

}
