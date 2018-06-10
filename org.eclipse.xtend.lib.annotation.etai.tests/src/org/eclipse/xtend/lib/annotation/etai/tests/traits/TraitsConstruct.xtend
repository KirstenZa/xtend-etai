package org.eclipse.xtend.lib.annotation.etai.tests.traits

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ConstructRule
import org.eclipse.xtend.lib.annotation.etai.ConstructorMethod
import org.eclipse.xtend.lib.annotation.etai.CopyConstructorRule
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.TraitClassAutoUsing
import org.eclipse.xtend.lib.annotation.etai.FactoryMethodRule
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassConstruct2
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassConstruct3
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassConstruct4
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassConstructBase
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassConstructConcrete
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassConstructDerivedOneConstructor
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassConstructDuplicateParameters
import org.eclipse.xtend.lib.annotation.etai.tests.traits.intf.ITraitClassConstructNonArgAndArg
import java.lang.reflect.Modifier
import java.math.BigDecimal
import java.math.BigInteger
import org.junit.Test

import static org.junit.Assert.*

@TraitClassAutoUsing
@ApplyRules
abstract class TraitClassConstructBase {

	AdaptionClassBase internalObj
	double param
	String str
	char character

	@ConstructorMethod
	protected def void construct(@TypeAdaptionRule("applyVariable(var.class.simple);
			replaceAll(TraitClassConstruct,org.eclipse.xtend.lib.annotation.etai.tests.traits.AdaptionClass);
			replaceAll(ExtendedClassConstructAdapted$,org.eclipse.xtend.lib.annotation.etai.tests.traits.AdaptionClassDerived);
			replaceAll(ExtendedClassConstructAdaptedLocalInherited$,org.eclipse.xtend.lib.annotation.etai.tests.traits.AdaptionClassDerived);
			replaceAll(ExtendedClassConstructNoConstructor$,org.eclipse.xtend.lib.annotation.etai.tests.traits.AdaptionClassDerived);
			replaceAll(ExtendedClassConstructOwnConstructor$,org.eclipse.xtend.lib.annotation.etai.tests.traits.AdaptionClassDerived);
			replaceAll(ExtendedClassConstructNoConstructorFourExtensions$,org.eclipse.xtend.lib.annotation.etai.tests.traits.AdaptionClassDerived);
			replaceAll(ExtendedClassConstructOwnConstructorsFourExtensions$,org.eclipse.xtend.lib.annotation.etai.tests.traits.AdaptionClassDerived);
			replaceAll(ExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll$,DoesNotExist);
			replaceAll(ExtendedClassConstructCopiedAdaptionRuleBase$,org.eclipse.xtend.lib.annotation.etai.tests.traits.AdaptionClassDerived);
			replaceAll(ExtendedClassConstructCopiedAdaptionRuleDerived$,org.eclipse.xtend.lib.annotation.etai.tests.traits.AdaptionClassDerived);
			replaceAll(ExtendedClassConstructDuplicateParameters$,org.eclipse.xtend.lib.annotation.etai.tests.traits.AdaptionClassDerived);
			replaceAll(ExtendedClassConstructUsingThis,org.eclipse.xtend.lib.annotation.etai.tests.traits.AdaptionClassDerived)")
	AdaptionClassBase internalObj) {
		this.internalObj = internalObj
	}

	@TypeAdaptionRule
	@ConstructorMethod
	protected def void construct(String str, char character) {
		this.character = character
		this.str = str
	}

	@ConstructorMethod
	protected def void construct(double param) {
		this.param = param
	}

	@ExclusiveMethod
	override AdaptionClassBase getInternalObj() {
		return internalObj
	}

	@ExclusiveMethod
	override String getString() {
		return str
	}

	@ExclusiveMethod
	override char getCharacter() {
		return character
	}

	@ExclusiveMethod
	override double getDoubleParam() {
		return param
	}

}

@ApplyRules
@TraitClassAutoUsing
abstract class TraitClassConstructConcrete extends TraitClassConstructBase {
}

@ApplyRules
@TraitClassAutoUsing
abstract class TraitClassConstructDerivedOneConstructor extends TraitClassConstructBase {

	@ConstructorMethod
	protected def void construct(String str) {
		super.construct(str, 'X')
	}

}

@FactoryMethodRule(factoryMethod="create%")
@ApplyRules
abstract class ExtendedClassConstructBase {

	int value
	BigDecimal bigDecimal
	BigInteger bigInteger

	new(int value, Object dummyObj) {
		this.value = value
	}

	@CopyConstructorRule
	new(int value) {
		this(value, null)
	}

	@CopyConstructorRule
	new(BigInteger bigInteger) {
		this.bigInteger = bigInteger
	}

	new(BigDecimal bigDecimal) {
		this.bigDecimal = bigDecimal
		
		// use attribute in order to avoid warning
		this.bigDecimal = this.bigDecimal
	}

	def int getValue() {
		return value
	}

	def BigInteger getBigInteger() {
		return bigInteger
	}

}

@ApplyRules
@ConstructRule(TraitClassConstructConcrete)
@ExtendedByAuto
class ExtendedClassConstructAdapted extends ExtendedClassConstructBase implements ITraitClassConstructConcrete {
}

@ConstructRule(value=#[TraitClassConstructConcrete])
@ApplyRules
@ExtendedByAuto
class ExtendedClassConstructAdaptedLocalInherited extends ExtendedClassConstructBase implements ITraitClassConstructConcrete {
}

@ConstructRule(TraitClassConstructConcrete)
@FactoryMethodRule(factoryMethod="create%")
@ApplyRules
@ExtendedByAuto
class ExtendedClassConstructNoConstructor implements ITraitClassConstructConcrete {
}

@ApplyRules
@FactoryMethodRule(factoryMethod="create%")
@ConstructRule(TraitClassConstructConcrete)
@ExtendedByAuto
class ExtendedClassConstructOwnConstructor implements ITraitClassConstructConcrete {

	int value
	long longValue

	protected new(Long longValue) {
		this.longValue = longValue
		
		// use attribute in order to avoid warning
		this.longValue = this.longValue
	}

	/**
	 * This is an own constructor.
	 */
	new(int value) {
		this.value = value
	}

	def int getValue() {
		return value
	}

}

@TraitClassAutoUsing
abstract class TraitClassConstruct2 {

	byte byteParam
	String strSecond

	@ConstructorMethod
	protected def void construct(String strSecond, byte byteParam) {
		this.byteParam = byteParam
		this.strSecond = strSecond
	}

	@ConstructorMethod
	protected def void construct(byte byteParam) {
		this.byteParam = byteParam
		this.strSecond = "notset"
	}

	@ExclusiveMethod
	override String getStringSecond() {
		return strSecond
	}

	@ExclusiveMethod
	override byte getByteParam() {
		return byteParam
	}

}

@TraitClassAutoUsing
abstract class TraitClassConstruct3 {

	int something

	@ConstructorMethod
	protected def void construct() {
		this.something = 100
	}

	@ExclusiveMethod
	override int getSomething() {
		return something
	}

}

@TraitClassAutoUsing
abstract class TraitClassConstruct4 {

	double doubleExt

	@ConstructorMethod
	protected def void construct(double doubleExt) {
		this.doubleExt = doubleExt
	}

	@ExclusiveMethod
	override double getDoubleExt() {
		return doubleExt
	}

}

@ExtendedByAuto
@ConstructRule(TraitClassConstructConcrete, TraitClassConstruct2,
	TraitClassConstruct4)
@FactoryMethodRule(factoryMethod="create%")
@ApplyRules()
class ExtendedClassConstructNoConstructorFourExtensions implements ITraitClassConstructConcrete, ITraitClassConstruct2, ITraitClassConstruct3, ITraitClassConstruct4 {
}

@FactoryMethodRule(factoryMethod="create%")
@ConstructRule(value=#[TraitClassConstructConcrete, TraitClassConstruct2, TraitClassConstruct4])
@ApplyRules
@ExtendedByAuto
class ExtendedClassConstructOwnConstructorsFourExtensions implements ITraitClassConstructConcrete, ITraitClassConstruct2, ITraitClassConstruct3, ITraitClassConstruct4 {

	int intNumber
	float floatNumber

	@CopyConstructorRule
	new(int intNumber) {
		this.intNumber = intNumber
	}

	@CopyConstructorRule
	new(float floatNumber) {
		this.floatNumber = floatNumber
	}

	def int getIntNumber() {
		return intNumber
	}

	def float getFloatNumber() {
		return floatNumber
	}

}

@ApplyRules
class ExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll extends ExtendedClassConstructOwnConstructorsFourExtensions {
}

@FactoryMethodRule(factoryMethod="create%")
@ConstructRule(TraitClassConstructDerivedOneConstructor)
@ApplyRules
@ExtendedByAuto
class ExtendedClassConstructDerivedOneConstructor implements ITraitClassConstructDerivedOneConstructor {
}

@TraitClassAutoUsing
abstract class TraitClassConstructDuplicateParameters {

	String strThird

	@ConstructorMethod
	protected def void construct(String str) {
		this.strThird = str
	}

	@ExclusiveMethod
	override String getStringThird() {
		return strThird
	}

}

@ApplyRules
@FactoryMethodRule(factoryMethod="create%")
@ConstructRule(TraitClassConstructDuplicateParameters, TraitClassConstructConcrete)
@ExtendedByAuto
class ExtendedClassConstructDuplicateParameters implements ITraitClassConstructConcrete, ITraitClassConstructDuplicateParameters {

	String localStr

	new(String str) {
		localStr = str
	}

	def getLocalStr() {
		localStr
	}

}

@ApplyRules
@FactoryMethodRule(factoryMethod="create%")
@ConstructRule(TraitClassConstructBase)
@ExtendedByAuto
class ExtendedClassConstructUsingThis implements ITraitClassConstructBase {

	String localStr1
	String localStr2

	new(String str1) {
		localStr1 = str1
	}

	new(String str1, String str2) {
		this(str1)
		localStr2 = str2
	}

	def getLocalStr1() {
		localStr1
	}

	def getLocalStr2() {
		localStr2
	}

}

@TraitClassAutoUsing
abstract class TraitClassConstructNonArgAndArg {

	int number

	@ConstructorMethod
	protected def void construct() {
		this.number = 100
	}

	@ConstructorMethod
	protected def void construct(int number) {
		this.number = number
	}

	@ExclusiveMethod
	override int getNumber() {
		return number
	}

}

@ApplyRules
@FactoryMethodRule(factoryMethod="create%")
@ConstructRule(TraitClassConstructNonArgAndArg)
@ExtendedByAuto
class ExtendedClassConstructNonArgAndArg implements ITraitClassConstructNonArgAndArg {

	String localStr

	new(String str) {
		localStr = str
	}

	def getLocalStr() {
		localStr
	}

}

class TraitsConstructTests extends TraitTestsBase {

	/**
	 * Method assert the given class contains the specified number of (protected) constructors and factory methods (locally). 
	 */
	protected def void assertConstructorsAndFactoryMethodCount(Class<?> clazz, int numberOfProtectedConstructors,
		int numberOfFactoryMethods) {

		assertEquals(numberOfProtectedConstructors, clazz.declaredConstructors.filter [
			Modifier.isProtected(it.modifiers)
		].size)
		assertEquals(numberOfFactoryMethods, clazz.declaredMethods.filter [
			it.name.startsWith("create")
		].size)

	}

	@Test
	def void testExtensionConstructructNotDerived() {

		assertConstructorsAndFactoryMethodCount(ExtendedClassConstructNoConstructor, 1, 2)

		var AdaptionClassDerived newInternalObject = new AdaptionClassDerived

		val obj1 = ExtendedClassConstructNoConstructor::createExtendedClassConstructNoConstructor(newInternalObject)
		assertSame(newInternalObject, obj1.internalObj)

		val obj2 = ExtendedClassConstructNoConstructor::createExtendedClassConstructNoConstructor("mystr", 'c')
		assertEquals("mystr", obj2.string)
		assertEquals(new Character('c'), obj2.character)

	}

	@Test
	def void testExtensionConstructructDerived() {

		assertConstructorsAndFactoryMethodCount(ExtendedClassConstructAdapted, 2, 4)

		var AdaptionClassDerived newInternalObject = new AdaptionClassDerived

		val obj1 = ExtendedClassConstructAdapted::createExtendedClassConstructAdapted(4, newInternalObject)
		assertEquals(4, obj1.value)
		assertSame(newInternalObject, obj1.internalObj)

		val obj2 = ExtendedClassConstructAdapted::createExtendedClassConstructAdapted(4, "mystr", 'c')
		assertEquals(4, obj2.value)
		assertEquals("mystr", obj2.string)
		assertEquals(new Character('c'), obj2.character)

		val obj3 = ExtendedClassConstructAdapted::createExtendedClassConstructAdapted(BigInteger::valueOf(5),
			newInternalObject)
		assertEquals(BigInteger::valueOf(5), obj3.bigInteger)
		assertSame(newInternalObject, obj3.internalObj)

		val obj4 = ExtendedClassConstructAdapted::createExtendedClassConstructAdapted(BigInteger::valueOf(5), "mystr",
			'c')
		assertEquals(BigInteger::valueOf(5), obj4.bigInteger)
		assertEquals("mystr", obj4.string)
		assertEquals(new Character('c'), obj4.character)

	}

	@Test
	def void testExtensionConstructructDerivedLocalInherited() {

		assertConstructorsAndFactoryMethodCount(ExtendedClassConstructAdaptedLocalInherited, 2, 4)

		var AdaptionClassDerived newInternalObject = new AdaptionClassDerived

		val obj1 = ExtendedClassConstructAdaptedLocalInherited::
			createExtendedClassConstructAdaptedLocalInherited(4, newInternalObject)
		assertEquals(4, obj1.value)
		assertSame(newInternalObject, obj1.internalObj)

		val obj2 = ExtendedClassConstructAdaptedLocalInherited::
			createExtendedClassConstructAdaptedLocalInherited(4, "mystr", 'c')
		assertEquals(4, obj2.value)
		assertEquals("mystr", obj2.string)
		assertEquals(new Character('c'), obj2.character)

		val obj3 = ExtendedClassConstructAdaptedLocalInherited::
			createExtendedClassConstructAdaptedLocalInherited(BigInteger::valueOf(5), newInternalObject)
		assertEquals(BigInteger::valueOf(5), obj3.bigInteger)
		assertSame(newInternalObject, obj3.internalObj)

		val obj4 = ExtendedClassConstructAdaptedLocalInherited::
			createExtendedClassConstructAdaptedLocalInherited(BigInteger::valueOf(5), "mystr", 'c')
		assertEquals(BigInteger::valueOf(5), obj4.bigInteger)
		assertEquals("mystr", obj4.string)
		assertEquals(new Character('c'), obj4.character)

	}

	@Test
	def void testExtensionConstructructOwnConstructor() {

		assertConstructorsAndFactoryMethodCount(ExtendedClassConstructOwnConstructor, 2, 2)

		var AdaptionClassDerived newInternalObject = new AdaptionClassDerived

		val obj1 = ExtendedClassConstructOwnConstructor::
			createExtendedClassConstructOwnConstructor(4, newInternalObject)
		assertEquals(4, obj1.value)
		assertSame(newInternalObject, obj1.internalObj)

		val obj2 = ExtendedClassConstructOwnConstructor::createExtendedClassConstructOwnConstructor(4, "mystr", 'c')
		assertEquals(4, obj2.value)
		assertEquals("mystr", obj2.string)
		assertEquals(new Character('c'), obj2.character)

	}

	@Test
	def void testExtensionConstructructDerivedOneConstructor() {

		assertConstructorsAndFactoryMethodCount(ExtendedClassConstructDerivedOneConstructor, 1, 1)

		val obj1 = ExtendedClassConstructDerivedOneConstructor::
			createExtendedClassConstructDerivedOneConstructor("mystr")
		assertEquals("mystr", obj1.string)
		assertEquals(new Character('X'), obj1.character)

	}

	@Test
	def void testExtensionConstructructFourExtensionsNoConstructor() {

		assertConstructorsAndFactoryMethodCount(ExtendedClassConstructNoConstructorFourExtensions, 1, 4)

		var AdaptionClassDerived newInternalObject = new AdaptionClassDerived
		var byte myByte = 1 as byte

		val obj1 = ExtendedClassConstructNoConstructorFourExtensions::
			createExtendedClassConstructNoConstructorFourExtensions(newInternalObject, "mystr", myByte, 8.0)
		assertSame(newInternalObject, obj1.internalObj)
		assertEquals(myByte, obj1.byteParam)
		assertEquals("mystr", obj1.stringSecond)
		assertEquals(8.0, obj1.doubleExt, 0.001)
		assertEquals(100, obj1.something)

		val obj2 = ExtendedClassConstructNoConstructorFourExtensions::
			createExtendedClassConstructNoConstructorFourExtensions(newInternalObject, myByte, 8.0)
		assertSame(newInternalObject, obj2.internalObj)
		assertEquals(myByte, obj2.byteParam)
		assertEquals("notset", obj2.stringSecond)
		assertEquals(8.0, obj2.doubleExt, 0.001)
		assertEquals(100, obj2.something)

		val obj3 = ExtendedClassConstructNoConstructorFourExtensions::
			createExtendedClassConstructNoConstructorFourExtensions("mystr1", 'c', "mystr", myByte, 8.0)
		assertEquals("mystr1", obj3.string)
		assertEquals(new Character('c'), obj3.character)
		assertEquals(myByte, obj3.byteParam)
		assertEquals("mystr", obj3.stringSecond)
		assertEquals(8.0, obj3.doubleExt, 0.001)
		assertEquals(100, obj3.something)

		val obj4 = ExtendedClassConstructNoConstructorFourExtensions::
			createExtendedClassConstructNoConstructorFourExtensions("mystr1", 'c', myByte, 8.0)
		assertEquals("mystr1", obj4.string)
		assertEquals(new Character('c'), obj4.character)
		assertEquals(myByte, obj4.byteParam)
		assertEquals("notset", obj4.stringSecond)
		assertEquals(8.0, obj4.doubleExt, 0.001)
		assertEquals(100, obj4.something)

	}

	@Test
	def void testExtensionConstructructFourExtensionsOwnConstructors() {

		assertConstructorsAndFactoryMethodCount(ExtendedClassConstructOwnConstructorsFourExtensions, 2, 8)

		var AdaptionClassDerived newInternalObject = new AdaptionClassDerived
		var byte myByte = 1 as byte

		val obj1 = ExtendedClassConstructOwnConstructorsFourExtensions::
			createExtendedClassConstructOwnConstructorsFourExtensions(22, newInternalObject, "mystr", myByte, 5.0)
		assertEquals(22, obj1.intNumber)
		assertSame(newInternalObject, obj1.internalObj)
		assertEquals(myByte, obj1.byteParam)
		assertEquals("mystr", obj1.stringSecond)
		assertEquals(5.0, obj1.doubleExt, 0.001)
		assertEquals(100, obj1.something)

		val obj2 = ExtendedClassConstructOwnConstructorsFourExtensions::
			createExtendedClassConstructOwnConstructorsFourExtensions(22, newInternalObject, myByte, 5.0)
		assertEquals(22, obj2.intNumber)
		assertSame(newInternalObject, obj2.internalObj)
		assertEquals(myByte, obj2.byteParam)
		assertEquals("notset", obj2.stringSecond)
		assertEquals(5.0, obj2.doubleExt, 0.001)
		assertEquals(100, obj2.something)

		val obj3 = ExtendedClassConstructOwnConstructorsFourExtensions::
			createExtendedClassConstructOwnConstructorsFourExtensions(22, "mystr1", 'c', "mystr", myByte, 5.0)
		assertEquals(22, obj3.intNumber)
		assertEquals("mystr1", obj3.string)
		assertEquals(new Character('c'), obj3.character)
		assertEquals(myByte, obj3.byteParam)
		assertEquals("mystr", obj3.stringSecond)
		assertEquals(5.0, obj3.doubleExt, 0.001)
		assertEquals(100, obj3.something)

		val obj4 = ExtendedClassConstructOwnConstructorsFourExtensions::
			createExtendedClassConstructOwnConstructorsFourExtensions(22, "mystr1", 'c', myByte, 5.0)
		assertEquals(22, obj4.intNumber)
		assertEquals("mystr1", obj4.string)
		assertEquals(new Character('c'), obj4.character)
		assertEquals(myByte, obj4.byteParam)
		assertEquals("notset", obj4.stringSecond)
		assertEquals(5.0, obj4.doubleExt, 0.001)
		assertEquals(100, obj4.something)

		val obj5 = ExtendedClassConstructOwnConstructorsFourExtensions::
			createExtendedClassConstructOwnConstructorsFourExtensions(23.0f, newInternalObject, "mystr", myByte, 5.0)
		assertEquals(23.0f, obj5.floatNumber, 0.00)
		assertSame(newInternalObject, obj5.internalObj)
		assertEquals(myByte, obj5.byteParam)
		assertEquals("mystr", obj5.stringSecond)
		assertEquals(5.0, obj5.doubleExt, 0.001)
		assertEquals(100, obj5.something)

		val obj6 = ExtendedClassConstructOwnConstructorsFourExtensions::
			createExtendedClassConstructOwnConstructorsFourExtensions(23.0f, newInternalObject, myByte, 5.0)
		assertEquals(23.0f, obj6.floatNumber, 0.00)
		assertSame(newInternalObject, obj6.internalObj)
		assertEquals(myByte, obj6.byteParam)
		assertEquals("notset", obj6.stringSecond)
		assertEquals(5.0, obj6.doubleExt, 0.001)
		assertEquals(100, obj6.something)

		val obj7 = ExtendedClassConstructOwnConstructorsFourExtensions::
			createExtendedClassConstructOwnConstructorsFourExtensions(23.0f, "mystr1", 'c', "mystr", myByte, 5.0)
		assertEquals(23.0f, obj7.floatNumber, 0.00)
		assertEquals("mystr1", obj7.string)
		assertEquals(new Character('c'), obj7.character)
		assertEquals(myByte, obj7.byteParam)
		assertEquals("mystr", obj7.stringSecond)
		assertEquals(5.0, obj7.doubleExt, 0.001)
		assertEquals(100, obj7.something)

		val obj8 = ExtendedClassConstructOwnConstructorsFourExtensions::
			createExtendedClassConstructOwnConstructorsFourExtensions(23.0f, "mystr1", 'c', myByte, 5.0)
		assertEquals(23.0f, obj8.floatNumber, 0.00)
		assertEquals("mystr1", obj8.string)
		assertEquals(new Character('c'), obj8.character)
		assertEquals(myByte, obj8.byteParam)
		assertEquals("notset", obj8.stringSecond)
		assertEquals(5.0, obj8.doubleExt, 0.001)
		assertEquals(100, obj8.something)

	}

	@Test
	def void testExtensionConstructructFourExtensionsOwnConstructorsAdaptedAll() {

		assertConstructorsAndFactoryMethodCount(ExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll, 2, 8)

		var AdaptionClassDerived newInternalObject = new AdaptionClassDerived
		var byte myByte = 1 as byte

		val obj1 = ExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll::
			createExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll(22, newInternalObject, "mystr", myByte,
				5.0)
		assertEquals(22, obj1.intNumber)
		assertSame(newInternalObject, obj1.internalObj)
		assertEquals(myByte, obj1.byteParam)
		assertEquals("mystr", obj1.stringSecond)
		assertEquals(5.0, obj1.doubleExt, 0.001)
		assertEquals(100, obj1.something)

		val obj2 = ExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll::
			createExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll(22, newInternalObject, myByte, 5.0)
		assertEquals(22, obj2.intNumber)
		assertSame(newInternalObject, obj2.internalObj)
		assertEquals(myByte, obj2.byteParam)
		assertEquals("notset", obj2.stringSecond)
		assertEquals(5.0, obj2.doubleExt, 0.001)
		assertEquals(100, obj2.something)

		val obj3 = ExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll::
			createExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll(22, "mystr1", 'c', "mystr", myByte, 5.0)
		assertEquals(22, obj3.intNumber)
		assertEquals("mystr1", obj3.string)
		assertEquals(new Character('c'), obj3.character)
		assertEquals(myByte, obj3.byteParam)
		assertEquals("mystr", obj3.stringSecond)
		assertEquals(5.0, obj3.doubleExt, 0.001)
		assertEquals(100, obj3.something)

		val obj4 = ExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll::
			createExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll(22, "mystr1", 'c', myByte, 5.0)
		assertEquals(22, obj4.intNumber)
		assertEquals("mystr1", obj4.string)
		assertEquals(new Character('c'), obj4.character)
		assertEquals(myByte, obj4.byteParam)
		assertEquals("notset", obj4.stringSecond)
		assertEquals(5.0, obj4.doubleExt, 0.001)
		assertEquals(100, obj4.something)

		val obj5 = ExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll::
			createExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll(23.0f, newInternalObject, "mystr",
				myByte, 5.0)
		assertEquals(23.0f, obj5.floatNumber, 0.00)
		assertSame(newInternalObject, obj5.internalObj)
		assertEquals(myByte, obj5.byteParam)
		assertEquals("mystr", obj5.stringSecond)
		assertEquals(5.0, obj5.doubleExt, 0.001)
		assertEquals(100, obj5.something)

		val obj6 = ExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll::
			createExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll(23.0f, newInternalObject, myByte, 5.0)
		assertEquals(23.0f, obj6.floatNumber, 0.00)
		assertSame(newInternalObject, obj6.internalObj)
		assertEquals(myByte, obj6.byteParam)
		assertEquals("notset", obj6.stringSecond)
		assertEquals(5.0, obj6.doubleExt, 0.001)
		assertEquals(100, obj6.something)

		val obj7 = ExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll::
			createExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll(23.0f, "mystr1", 'c', "mystr", myByte,
				5.0)
		assertEquals(23.0f, obj7.floatNumber, 0.00)
		assertEquals("mystr1", obj7.string)
		assertEquals(new Character('c'), obj7.character)
		assertEquals(myByte, obj7.byteParam)
		assertEquals("mystr", obj7.stringSecond)
		assertEquals(5.0, obj7.doubleExt, 0.001)
		assertEquals(100, obj7.something)

		val obj8 = ExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll::
			createExtendedClassConstructOwnConstructorsFourExtensionAdaptedAll(23.0f, "mystr1", 'c', myByte, 5.0)
		assertEquals(23.0f, obj8.floatNumber, 0.00)
		assertEquals("mystr1", obj8.string)
		assertEquals(new Character('c'), obj8.character)
		assertEquals(myByte, obj8.byteParam)
		assertEquals("notset", obj8.stringSecond)
		assertEquals(5.0, obj8.doubleExt, 0.001)
		assertEquals(100, obj8.something)

	}

	@Test
	def void testExtensionConstructructDuplicateParameters() {

		assertConstructorsAndFactoryMethodCount(ExtendedClassConstructDuplicateParameters, 1, 2)

		var AdaptionClassDerived newInternalObject = new AdaptionClassDerived

		val obj1 = ExtendedClassConstructDuplicateParameters::
			createExtendedClassConstructDuplicateParameters("mystr", newInternalObject)
		assertSame(newInternalObject, obj1.internalObj)
		assertNull(obj1.string)
		assertEquals("mystr", obj1.localStr)
		assertEquals("mystr", obj1.stringThird)

		val obj2 = ExtendedClassConstructDuplicateParameters::
			createExtendedClassConstructDuplicateParameters("mystr", 'c')
		assertEquals(new Character('c'), obj2.character)
		assertEquals("mystr", obj2.string)
		assertEquals("mystr", obj2.localStr)
		assertEquals("mystr", obj1.stringThird)

	}

	@Test
	def void testExtensionConstructructUsingThis() {

		assertConstructorsAndFactoryMethodCount(ExtendedClassConstructUsingThis, 2, 6)

		val obj = ExtendedClassConstructUsingThis::createExtendedClassConstructUsingThis("str1", "str2", "myStr", 'c')
		assertEquals("str1", obj.localStr1)
		assertEquals("str2", obj.localStr2)

	}

	@Test
	def void testExtensionConstructructNonArgAnd() {

		assertConstructorsAndFactoryMethodCount(ExtendedClassConstructNonArgAndArg, 1, 2)

		val obj1 = ExtendedClassConstructNonArgAndArg::createExtendedClassConstructNonArgAndArg("myStr")
		assertEquals("myStr", obj1.localStr)
		assertEquals(100, obj1.number)

		val obj2 = ExtendedClassConstructNonArgAndArg::createExtendedClassConstructNonArgAndArg("myStr2", 666)
		assertEquals("myStr2", obj2.localStr)
		assertEquals(666, obj2.number)

	}

	@Test
	def void testExtensionConstructructAutoPrefix() {

		// prefix "auto$" shall be used for construction helpers
		assertEquals(0, ExtendedClassConstructNoConstructorFourExtensions.declaredMethods.filter [
			it.name.startsWith("new$")
		].size)
		assertEquals(5, ExtendedClassConstructNoConstructorFourExtensions.declaredMethods.filter [
			it.name.startsWith("auto$new$")
		].size)

	}

}
