package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import java.lang.reflect.Modifier
import java.util.AbstractCollection
import java.util.ArrayList
import java.util.Collection
import java.util.ConcurrentModificationException
import java.util.HashMap
import java.util.HashSet
import java.util.List
import java.util.Map
import java.util.Set
import java.util.SortedMap
import java.util.SortedSet
import java.util.TreeMap
import java.util.TreeSet
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.ImplementDefault
import org.eclipse.xtend.lib.annotation.etai.LazyEvaluation
import org.eclipse.xtend.lib.annotation.etai.NoInterfaceExtract
import org.eclipse.xtend.lib.annotation.etai.NotNullRule
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.SetterRule
import org.eclipse.xtend.lib.annotation.etai.SynchronizationRule
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TraitMethodProcessor
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IClassWithGetterSetterTypeAdaptionBaseWithInterface
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IClassWithGetterSetterTypeAdaptionDerivedInterfaceAfterwards
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IClassWithGetterSetterTypeAdaptionDerivedWithInterface
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IClassWithSetterGetterProtectedWithExtractInterface
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IClassWithSetterGetterViaTraitProtected
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IClassWithSetterGetterWithExtractInterface
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITraitWithSetterGetter
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITraitWithSetterGetterProtected
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

import static extension org.eclipse.xtend.lib.macro.declaration.Visibility.*

@ApplyRules
class ClassWithSetterGetter {
	
	@GetterRule
	String eMail = "my@example.org"

	@GetterRule
	@SynchronizationRule("Lock1")
	package int dataWithGetter = 11

	@SetterRule
	@SynchronizationRule("Lock1")
	double dataWithSetter = 12.1

	@GetterRule
	@SetterRule
	@SynchronizationRule("Lock1")
	String dataWithSetterAndGetter = "13"

	@GetterRule
	protected int dataWithGetterNotSynchronized = 19

	@SetterRule
	double dataWithSetterNotSynchronized = 19.1

	@GetterRule
	@SetterRule
	String dataWithSetterAndGetterNotSynchronized = "29"

	@GetterRule
	@SetterRule
	String dataWithSetterAndGetterNotSynchronizedMixed = "31"

	@GetterRule
	@SynchronizationRule("Lock1")
	static int dataWithGetterStatic = 9

	@SetterRule
	@SynchronizationRule("Lock1")
	static int dataWithSetterStatic = 7

}

@ApplyRules
class ClassWithSetterGetterT<T> {

	@GetterRule
	@SetterRule
	T dataWithSetterAndGetter

}

@ApplyRules
@ExtractInterface
class ClassWithSetterGetterWithExtractInterface {

	@GetterRule
	final int dataWithGetter = 11

	@SetterRule
	double dataWithSetter = 12.1

	@GetterRule
	@SetterRule
	String dataWithSetterAndGetter = "13"

	@GetterRule
	@SetterRule
	@NoInterfaceExtract
	int dataWithGetterNoInterfaceExtract = 40

	@GetterRule
	@SetterRule
	boolean dataBool1 = false

	@GetterRule
	@SetterRule
	Boolean dataBool2 = false

}

@ApplyRules
@ExtractInterface
class ClassWithSetterGetterProtectedWithExtractInterface {

	@GetterRule(visibility=Visibility.PROTECTED)
	int dataWithGetter = 11

	@SetterRule(visibility=Visibility.PROTECTED)
	double dataWithSetter = 12.1

	@GetterRule(visibility=Visibility.PROTECTED)
	@SetterRule
	String dataWithSetterAndGetter = "13"

}

@ApplyRules
@ExtractInterface
class ClassWithCollectionGetterSetter {

	@ApplyRules
	@ImplementDefault
	static class MyCollection extends AbstractCollection<String> {

		override boolean add(String data) {
			return true
		}

		override String [] toArray() {
			return (new ArrayList<String>).toArray(#[""])
		}

	}

	@GetterRule(collectionPolicy=DIRECT)
	List<Integer> dataIntegerListDirect

	@GetterRule(collectionPolicy=UNMODIFIABLE)
	ArrayList<Double> dataDoubleArrayList

	@GetterRule(collectionPolicy=UNMODIFIABLE_COPY)
	List<?> dataUnspecifiedListCopy

	@GetterRule(collectionPolicy=DIRECT)
	ClassWithCollectionGetterSetter.MyCollection dataMyCollectionDirect = new ClassWithCollectionGetterSetter.MyCollection

	@GetterRule(collectionPolicy=UNMODIFIABLE)
	ClassWithCollectionGetterSetter.MyCollection dataMyCollectionUnmodifiable = new ClassWithCollectionGetterSetter.MyCollection

	@GetterRule(collectionPolicy=UNMODIFIABLE_COPY)
	ClassWithCollectionGetterSetter.MyCollection dataMyCollectionUnmodifiableCopy = new ClassWithCollectionGetterSetter.MyCollection

	@GetterRule
	Map<?, ?> dataUnspecifiedMap = new HashMap<Integer, String>

	@GetterRule
	val Map<Integer, String> dataMap = new HashMap<Integer, String>

	@GetterRule(collectionPolicy=UNMODIFIABLE_COPY)
	val Map<Integer, String> dataMapCopy = new HashMap<Integer, String>

	@GetterRule
	val TreeMap<Integer, String> dataSortedMap = new TreeMap<Integer, String>

	@GetterRule(collectionPolicy=UNMODIFIABLE_COPY)
	val TreeMap<Integer, String> dataSortedMapCopy = new TreeMap<Integer, String>

	@GetterRule
	val HashSet<Integer> dataSet = new HashSet<Integer>

	@GetterRule(collectionPolicy=UNMODIFIABLE_COPY)
	val HashSet<Integer> dataSetCopy = new HashSet<Integer>

	@GetterRule
	SortedSet<Integer> dataSortedSet = new TreeSet<Integer>

	@GetterRule(collectionPolicy=UNMODIFIABLE_COPY)
	SortedSet<Integer> dataSortedSetCopy = new TreeSet<Integer>

	@GetterRule(collectionPolicy=DIRECT)
	val TreeMap<Integer, String> dataTreeMapDirect = new TreeMap<Integer, String>

	@GetterRule(collectionPolicy=UNMODIFIABLE)
	val Set<Integer> dataSetNull = null

	@GetterRule(collectionPolicy=UNMODIFIABLE_COPY)
	val ArrayList<Integer> dataListNull = null

	@GetterRule(collectionPolicy=DIRECT)
	@SetterRule
	List<Integer> dataIntegerListDirectWithSetter = new ArrayList<Integer>

	@GetterRule(collectionPolicy=UNMODIFIABLE_COPY)
	@SetterRule
	List<? extends Number> dataNumberListCopyWithSetter = new ArrayList<Number>

	new() {

		dataIntegerListDirect = new ArrayList<Integer>
		dataDoubleArrayList = new ArrayList<Double>
		dataUnspecifiedListCopy = new ArrayList

	}

}

class CombinedStringsIfGet implements TraitMethodProcessor {

	override call(LazyEvaluation expressionTraitClass, LazyEvaluation expressionExtendedClass) {

		if (expressionTraitClass.method.name.startsWith("set")) {

			val resultTraitClass = expressionTraitClass.eval

			if (expressionExtendedClass !== null) {

				val resultExtendedClass = expressionExtendedClass.eval
				if (resultExtendedClass !== null)
					return (resultExtendedClass as Boolean) && (resultTraitClass as Boolean)

			}

			return resultTraitClass

		} else {

			val resultTraitClass = expressionTraitClass.eval

			if (expressionExtendedClass !== null) {

				val resultExtendedClass = expressionExtendedClass.eval
				if (resultExtendedClass !== null)
					return resultExtendedClass + "|" + resultTraitClass

			}

			return resultTraitClass

		}

	}

}

@ApplyRules
@TraitClass
abstract class TraitWithSetterGetter {

	@GetterRule
	@ExclusiveMethod
	final int dataWithGetter = 11

	@SetterRule
	@ExclusiveMethod
	double dataWithSetter = 12.1

	@GetterRule
	@SetterRule
	@ProcessedMethod(processor=CombinedStringsIfGet)
	String dataWithSetterAndGetter = "13"

	@ExclusiveMethod
	override boolean checkDataWithSetterValue(double value) {
		return value === dataWithSetter
	}

	@ExclusiveMethod
	override double getDataWithSetterManual() {
		return dataWithSetter
	}

	@GetterRule
	@SetterRule
	static int dataWithGetterStaticFromTrait = 40

}

@ApplyRules
@ExtendedByAuto
class ClassWithSetterGetterViaTrait implements ITraitWithSetterGetter {

	String anotherString = "Test"

	override String getDataWithSetterAndGetter() {
		return anotherString
	}

	override boolean setDataWithSetterAndGetter(String data) {
		anotherString = "_"
		return true
	}

}

@ApplyRules
@TraitClass
abstract class TraitWithSetterGetterProtected {

	@GetterRule(visibility=Visibility.PROTECTED)
	@ExclusiveMethod
	int dataWithGetter = 11

	@SetterRule(visibility=Visibility.PROTECTED)
	@ExclusiveMethod
	double dataWithSetter = 12.1

	@GetterRule(visibility=Visibility.PROTECTED)
	@SetterRule
	@ProcessedMethod(processor=CombinedStringsIfGet)
	String dataWithSetterAndGetter = "13"

	@ExclusiveMethod
	def protected boolean checkDataWithSetterValue(double value) {
		return value === dataWithSetter
	}

	@ExclusiveMethod
	def protected double getDataWithSetterManual() {
		return dataWithSetter
	}

}

@ApplyRules
@ExtendedByAuto
@ExtractInterface
class ClassWithSetterGetterViaTraitProtected implements ITraitWithSetterGetterProtected {

	String anotherString = "Test"

	def protected String getDataWithSetterAndGetter() {
		return anotherString
	}

	override boolean setDataWithSetterAndGetter(String data) {
		anotherString = "_"
		return true
	}

}

@ApplyRules
class ClassWithGetterSetterTypeAdaptionBase {

	@GetterRule
	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1)")
	ControllerBase dataWithGetter

	@SetterRule
	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1)")
	ControllerBase dataWithSetter

	@GetterRule
	@SetterRule
	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1)")
	ControllerBase dataWithSetterGetter

}

@ApplyRules
class ClassWithGetterSetterTypeAdaptionDerived extends ClassWithGetterSetterTypeAdaptionBase {
}

@ApplyRules
@ExtractInterface
class ClassWithGetterSetterTypeAdaptionDerivedInterfaceAfterwards extends ClassWithGetterSetterTypeAdaptionDerived {
}

@ApplyRules
@ExtractInterface
class ClassWithGetterSetterTypeAdaptionBaseWithInterface {

	@GetterRule
	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1)")
	ControllerBase dataWithGetter

	@SetterRule
	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1)")
	ControllerBase dataWithSetter

	@GetterRule
	@SetterRule
	@TypeAdaptionRule("apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1)")
	ControllerBase dataWithSetterGetter

}

@ApplyRules
@ExtractInterface
class ClassWithGetterSetterTypeAdaptionDerivedWithInterface extends ClassWithGetterSetterTypeAdaptionBaseWithInterface {
}

@ApplyRules
class ClassWithGetterSetterNotNull {

	static def boolean test() { true }

	@GetterRule
	@NotNullRule
	Integer dataIntGetter = 4

	@GetterRule
	@SetterRule
	@NotNullRule
	Integer dataIntGetterSetter = 14

	@GetterRule
	@NotNullRule
	String dataStringGetter = "Test1"

	@SetterRule
	@GetterRule
	@NotNullRule
	String dataStringGetterSetter = "Test2"

	@SetterRule
	@NotNullRule
	String dataStringSetterOnly = "Test3"

	@GetterRule
	@NotNullRule
	String dataStringGetterWrongInitialized = {
		if(test()) null else null
	}

}

class GetterSetterTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testGetterSetter() {

		val obj = new ClassWithSetterGetter
		
		val fieldDataWithSetter = obj.class.getDeclaredField("dataWithSetter")
		fieldDataWithSetter.accessible = true

		assertEquals("my@example.org", obj.EMail)

		assertEquals(11, obj.getDataWithGetter())
		assertEquals("13", obj.getDataWithSetterAndGetter())

		assertEquals(true, obj.setDataWithSetter(22))
		obj.setDataWithSetterAndGetter("23")

		assertEquals(22.0, fieldDataWithSetter.get(obj) as Double, 0.0)
		assertEquals("23", obj.getDataWithSetterAndGetter())

		assertEquals(false, obj.setDataWithSetter(22))

		obj.setDataWithSetterAndGetter(null)
		assertNull(obj.getDataWithSetterAndGetter())

	}

	@Test
	def void testGetterSetterBoolean() {

		val IClassWithSetterGetterWithExtractInterface obj = new ClassWithSetterGetterWithExtractInterface

		obj.setDataBool1(true)
		assertEquals(true, obj.isDataBool1())

		obj.setDataBool2(true)
		assertEquals(true, obj.getDataBool2())

	}

	@ApplyRules
	@ImplementDefault
	static class MyCollection implements Collection<String> {
	}

	// Helper method for collection tests
	protected def assertUnmodifiable(String getterName, boolean unmodifiable, Object addObject1, Object addObject2) {

		val obj = new ClassWithCollectionGetterSetter

		var boolean exceptionThrown

		exceptionThrown = false
		try {

			val collectionOrMap = obj.class.declaredMethods.findFirst [
				name == getterName && synthetic == false
			].invoke(obj)

			if (collectionOrMap instanceof Collection<?>) {
				(collectionOrMap as Collection<Object>).size
			} else {
				(collectionOrMap as Map<Object, Object>).size
			}

		} catch (UnsupportedOperationException unsupportedOperationException) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

		exceptionThrown = false
		try {

			val collectionOrMap = obj.class.declaredMethods.findFirst [
				name == getterName && synthetic == false
			].invoke(obj)

			if (collectionOrMap instanceof Collection<?>) {
				(collectionOrMap as Collection<Object>).add(addObject1)
			} else {
				(collectionOrMap as Map<Object, Object>).put(addObject1, addObject2)
			}

		} catch (UnsupportedOperationException unsupportedOperationException) {
			exceptionThrown = true
		}
		assertEquals(unmodifiable, exceptionThrown)

	}

	@Test
	def void testGetterCollection() {

		val obj = new ClassWithCollectionGetterSetter

		var boolean exceptionThrown

		val fieldListUnmodifiable = obj.class.getDeclaredField("dataDoubleArrayList")
		val fieldListUnmodifiableCopy = obj.class.getDeclaredField("dataUnspecifiedListCopy")
		val fieldMapUnmodifiable = obj.class.getDeclaredField("dataSortedMap")
		val fieldMapUnmodifiableCopy = obj.class.getDeclaredField("dataSortedMapCopy")
		fieldListUnmodifiable.accessible = true
		fieldListUnmodifiableCopy.accessible = true
		fieldMapUnmodifiable.accessible = true
		fieldMapUnmodifiableCopy.accessible = true
		val originalListUnmodifiable = fieldListUnmodifiable.get(obj) as List<Double>
		val originalListUnmodifiableCopy = fieldListUnmodifiableCopy.get(obj) as List<Object>
		val originalMapUnmodifiable = fieldMapUnmodifiable.get(obj) as Map<Integer, String>
		val originalMapUnmodifiableCopy = fieldMapUnmodifiableCopy.get(obj) as Map<Integer, String>

		// check returned types
		assertSame(
			List,
			ClassWithCollectionGetterSetter.declaredMethods.findFirst [
				name == "getDataIntegerListDirect" && synthetic == false
			].returnType
		)
		assertSame(
			List,
			ClassWithCollectionGetterSetter.declaredMethods.findFirst [
				name == "getDataDoubleArrayList" && synthetic == false
			].returnType
		)
		assertSame(
			List,
			ClassWithCollectionGetterSetter.declaredMethods.findFirst [
				name == "getDataUnspecifiedListCopy" && synthetic == false
			].returnType
		)
		assertSame(
			ClassWithCollectionGetterSetter.MyCollection,
			ClassWithCollectionGetterSetter.declaredMethods.findFirst [
				name == "getDataMyCollectionDirect" && synthetic == false
			].returnType
		)
		assertSame(
			Collection,
			ClassWithCollectionGetterSetter.declaredMethods.findFirst [
				name == "getDataMyCollectionUnmodifiable" && synthetic == false
			].returnType
		)
		assertSame(
			Collection,
			ClassWithCollectionGetterSetter.declaredMethods.findFirst [
				name == "getDataMyCollectionUnmodifiableCopy" && synthetic == false
			].returnType
		)
		assertSame(
			Map,
			ClassWithCollectionGetterSetter.declaredMethods.findFirst [
				name == "getDataUnspecifiedMap" && synthetic == false
			].returnType
		)
		assertSame(
			Map,
			ClassWithCollectionGetterSetter.declaredMethods.findFirst [
				name == "getDataMap" && synthetic == false
			].returnType
		)
		assertSame(
			Map,
			ClassWithCollectionGetterSetter.declaredMethods.findFirst [
				name == "getDataMapCopy" && synthetic == false
			].returnType
		)
		assertSame(
			SortedMap,
			ClassWithCollectionGetterSetter.declaredMethods.findFirst [
				name == "getDataSortedMap" && synthetic == false
			].returnType
		)
		assertSame(
			SortedMap,
			ClassWithCollectionGetterSetter.declaredMethods.findFirst [
				name == "getDataSortedMapCopy" && synthetic == false
			].returnType
		)
		assertSame(
			Set,
			ClassWithCollectionGetterSetter.declaredMethods.findFirst [
				name == "getDataSet" && synthetic == false
			].returnType
		)
		assertSame(
			Set,
			ClassWithCollectionGetterSetter.declaredMethods.findFirst [
				name == "getDataSetCopy" && synthetic == false
			].returnType
		)
		assertSame(
			SortedSet,
			ClassWithCollectionGetterSetter.declaredMethods.findFirst [
				name == "getDataSortedSet" && synthetic == false
			].returnType
		)
		assertSame(
			SortedSet,
			ClassWithCollectionGetterSetter.declaredMethods.findFirst [
				name == "getDataSortedSetCopy" && synthetic == false
			].returnType
		)
		assertSame(
			TreeMap,
			ClassWithCollectionGetterSetter.declaredMethods.findFirst [
				name == "getDataTreeMapDirect" && synthetic == false
			].returnType
		)
		assertSame(
			Collection,
			ClassWithCollectionGetterSetter.declaredMethods.findFirst [
				name == "getDataMyCollectionUnmodifiable" && synthetic == false
			].returnType
		)

		// check modifiable
		obj.getDataIntegerListDirect.add(10)
		assertEquals(10, obj.getDataIntegerListDirect.get(obj.getDataIntegerListDirect.size - 1))

		// check unmodifiable
		assertUnmodifiable("getDataIntegerListDirect", false, Integer::valueOf(1), null)
		assertUnmodifiable("getDataDoubleArrayList", true, Double::valueOf(1.0), null)
		assertUnmodifiable("getDataUnspecifiedListCopy", true, Integer::valueOf(1), null)
		assertUnmodifiable("getDataMyCollectionDirect", false, "a string", null)
		assertUnmodifiable("getDataMyCollectionUnmodifiable", true, "a string", null)
		assertUnmodifiable("getDataMyCollectionUnmodifiableCopy", true, "a string", null)
		assertUnmodifiable("getDataUnspecifiedMap", true, Integer::valueOf(1), null)
		assertUnmodifiable("getDataMap", true, Integer::valueOf(1), "something")
		assertUnmodifiable("getDataMapCopy", true, Integer::valueOf(1), "something")
		assertUnmodifiable("getDataSortedMap", true, Integer::valueOf(1), "something")
		assertUnmodifiable("getDataSortedMapCopy", true, Integer::valueOf(1), "something")
		assertUnmodifiable("getDataSet", true, Integer::valueOf(1), null)
		assertUnmodifiable("getDataSetCopy", true, Integer::valueOf(1), null)
		assertUnmodifiable("getDataSortedSet", true, Integer::valueOf(1), null)
		assertUnmodifiable("getDataSortedSetCopy", true, Integer::valueOf(1), null)
		assertUnmodifiable("getDataTreeMapDirect", false, Integer::valueOf(1), null)

		// add some data via original lists
		originalListUnmodifiable.add(4.0)
		originalListUnmodifiable.add(5.0)
		originalListUnmodifiable.add(6.0)
		originalListUnmodifiableCopy.add(1)
		originalListUnmodifiableCopy.add(2)
		originalListUnmodifiableCopy.add(3)
		originalMapUnmodifiable.put(4, "test1")
		originalMapUnmodifiable.put(5, "test2")
		originalMapUnmodifiable.put(3, "test3")
		originalMapUnmodifiableCopy.put(4, "test1")
		originalMapUnmodifiableCopy.put(5, "test2")
		originalMapUnmodifiableCopy.put(3, "test3")

		assertEquals(3, originalMapUnmodifiableCopy.size)

		// check unmodifiable (is not copy)
		exceptionThrown = false
		try {

			for (item : obj.getDataDoubleArrayList)
				originalListUnmodifiable.add(10.0)

		} catch (ConcurrentModificationException concurrentModificationException) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {

			for (item : obj.getDataSortedMap.entrySet)
				originalMapUnmodifiable.put(10, "test4")

		} catch (ConcurrentModificationException concurrentModificationException) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		// check unmodifiable (is copy)
		exceptionThrown = false
		try {

			for (item : obj.getDataUnspecifiedListCopy)
				originalListUnmodifiableCopy.add(10)

		} catch (ConcurrentModificationException concurrentModificationException) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

		exceptionThrown = false
		try {

			for (item : obj.getDataSortedMapCopy.entrySet)
				originalMapUnmodifiableCopy.put(10, "test4")

		} catch (ConcurrentModificationException concurrentModificationException) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

		// ensure that no null exception is thrown
		assertNull(obj.getDataListNull)
		assertNull(obj.dataSetNull)

	}

	@Test
	def void testSetterCollection() {

		val obj = new ClassWithCollectionGetterSetter

		assertTrue(obj.getDataIntegerListDirectWithSetter().isEmpty)
		assertTrue(obj.getDataNumberListCopyWithSetter().isEmpty)

		val newIntegerList = new ArrayList<Integer>
		newIntegerList.add(4)
		newIntegerList.add(44)
		newIntegerList.add(88)

		val newDoubleList = new ArrayList<Double>
		newDoubleList.add(5.5)
		newDoubleList.add(77.8)
		newDoubleList.add(90.0)

		obj.setDataIntegerListDirectWithSetter(newIntegerList)
		obj.setDataNumberListCopyWithSetter(newIntegerList)

		assertEquals(4, obj.getDataIntegerListDirectWithSetter().get(0))
		assertEquals(44, obj.getDataIntegerListDirectWithSetter().get(1))
		assertEquals(88, obj.getDataIntegerListDirectWithSetter().get(2))

		assertEquals(4, obj.getDataNumberListCopyWithSetter().get(0))
		assertEquals(44, obj.getDataNumberListCopyWithSetter().get(1))
		assertEquals(88, obj.getDataNumberListCopyWithSetter().get(2))

		obj.setDataNumberListCopyWithSetter(newDoubleList)

		assertEquals(5.5, obj.getDataNumberListCopyWithSetter().get(0))
		assertEquals(77.8, obj.getDataNumberListCopyWithSetter().get(1))
		assertEquals(90.0, obj.getDataNumberListCopyWithSetter().get(2))

	}

	@Test
	def void testGetterSetterT() {

		val obj1 = new ClassWithSetterGetterT<String>

		obj1.setDataWithSetterAndGetter("23")
		assertEquals("23", obj1.getDataWithSetterAndGetter())

		val obj2 = new ClassWithSetterGetterT<Integer>

		obj2.setDataWithSetterAndGetter(4)
		assertEquals(4, obj2.getDataWithSetterAndGetter())

	}

	@Test
	def void testGetterSetterProtected() {

		val obj = new ClassWithSetterGetterProtectedWithExtractInterface

		val fieldDataWithSetter = obj.class.getDeclaredField("dataWithSetter")
		fieldDataWithSetter.accessible = true

		assertEquals(11, obj.getDataWithGetter())
		assertEquals("13", obj.getDataWithSetterAndGetter())

		obj.setDataWithSetter(22)
		(obj as IClassWithSetterGetterProtectedWithExtractInterface).setDataWithSetterAndGetter("23")

		assertEquals(22.0, fieldDataWithSetter.get(obj) as Double, 0.0)
		assertEquals("23", obj.getDataWithSetterAndGetter())

		// ensure that methods are protected
		assertTrue(Modifier.isProtected(obj.class.declaredMethods.findFirst [
			name == "getDataWithGetter" && synthetic == false
		].modifiers))
		assertTrue(Modifier.isProtected(obj.class.declaredMethods.findFirst [
			name == "setDataWithSetter" && synthetic == false
		].modifiers))
		assertTrue(Modifier.isProtected(obj.class.declaredMethods.findFirst [
			name == "getDataWithSetterAndGetter" && synthetic == false
		].modifiers))
		assertTrue(Modifier.isPublic(obj.class.declaredMethods.findFirst [
			name == "setDataWithSetterAndGetter" && synthetic == false
		].modifiers))

		// ensure that extracted interface is correct
		assertEquals(1, IClassWithSetterGetterProtectedWithExtractInterface.declaredMethods.size)

	}

	@Test
	def void testGetterSetterStatic() {

		// regular
		val fieldDataWithSetterStatic = ClassWithSetterGetter.getDeclaredField("dataWithSetterStatic")
		fieldDataWithSetterStatic.accessible = true

		ClassWithSetterGetter::setDataWithSetterStatic(87)
		assertEquals(87, fieldDataWithSetterStatic.get(null))

		assertEquals(9, ClassWithSetterGetter::getDataWithGetterStatic())

		// within trait class
		TraitWithSetterGetter::setDataWithGetterStaticFromTrait(89)
		assertEquals(89, TraitWithSetterGetter::getDataWithGetterStaticFromTrait())

	}

	@Test
	def void testGetterSetterViaInterface() {

		val IClassWithSetterGetterWithExtractInterface obj = new ClassWithSetterGetterWithExtractInterface

		val fieldDataWithSetter = obj.class.getDeclaredField("dataWithSetter")
		fieldDataWithSetter.accessible = true

		assertEquals(11, obj.getDataWithGetter())
		assertEquals("13", obj.getDataWithSetterAndGetter())

		obj.setDataWithSetter(22)
		obj.setDataWithSetterAndGetter("23")

		assertEquals(22.0, fieldDataWithSetter.get(obj) as Double, 0.0)
		assertEquals("23", obj.getDataWithSetterAndGetter())

		// ensure that get/setDataWithGetterNoInterfaceExtract are not extracted
		assertEquals(8, IClassWithSetterGetterWithExtractInterface.declaredMethods.size)
		assertNull(IClassWithSetterGetterWithExtractInterface.declaredMethods.findFirst [
			name == "setDataWithGetterNoInterfaceExtract" && synthetic == false
		])
		assertNull(IClassWithSetterGetterWithExtractInterface.declaredMethods.findFirst [
			name == "getDataWithGetterNoInterfaceExtract" && synthetic == false
		])

	}

	@Test
	def void testGetterSetterInTraits() {

		val obj = new ClassWithSetterGetterViaTrait

		assertEquals(11, obj.getDataWithGetter())
		assertEquals("Test|13", obj.getDataWithSetterAndGetter())

		obj.setDataWithSetter(22)
		obj.setDataWithSetterAndGetter("23")

		assertEquals(22.0, obj.getDataWithSetterManual(), 0.0)
		assertEquals("_|23", obj.getDataWithSetterAndGetter())

	}

	@Test
	def void testGetterSetterInTraitsProtected() {

		val obj = new ClassWithSetterGetterViaTraitProtected

		assertEquals(11, obj.getDataWithGetter())
		assertEquals("Test|13", obj.getDataWithSetterAndGetter())

		obj.setDataWithSetter(22)
		obj.setDataWithSetterAndGetter("23")

		assertEquals(22.0, obj.getDataWithSetterManual(), 0.0)
		assertEquals("_|23", obj.getDataWithSetterAndGetter())

		// ensure that methods are protected
		assertTrue(Modifier.isProtected(obj.class.declaredMethods.findFirst [
			name == "getDataWithGetter" && synthetic == false
		].modifiers))
		assertTrue(Modifier.isProtected(obj.class.declaredMethods.findFirst [
			name == "setDataWithSetter" && synthetic == false
		].modifiers))
		assertTrue(Modifier.isProtected(obj.class.declaredMethods.findFirst [
			name == "getDataWithSetterAndGetter" && synthetic == false
		].modifiers))
		assertTrue(Modifier.isPublic(obj.class.declaredMethods.findFirst [
			name == "setDataWithSetterAndGetter" && synthetic == false
		].modifiers))

		// ensure that extracted interface is correct
		assertEquals(1, ITraitWithSetterGetterProtected.declaredMethods.size)
		assertEquals(0, IClassWithSetterGetterViaTraitProtected.declaredMethods.size)

	}

	@Test
	def void testGetterSetterAdaption() {

		assertEquals(0, ClassWithGetterSetterTypeAdaptionDerivedInterfaceAfterwards.declaredMethods.size)

		// getDataWithGetter
		assertEquals(ControllerBase, ClassWithGetterSetterTypeAdaptionBase.declaredMethods.findFirst [
			name == "getDataWithGetter" && synthetic == false
		].returnType)
		assertEquals(ControllerAttributeStringConcrete1,
			ClassWithGetterSetterTypeAdaptionDerived.declaredMethods.findFirst [
				name == "getDataWithGetter" && synthetic == false
			].returnType)
		assertEquals(ControllerAttributeStringConcrete1,
			IClassWithGetterSetterTypeAdaptionDerivedInterfaceAfterwards.declaredMethods.findFirst [
				name == "getDataWithGetter" && synthetic == false
			].returnType)

		assertEquals(ControllerBase, ClassWithGetterSetterTypeAdaptionBaseWithInterface.declaredMethods.findFirst [
			name == "getDataWithGetter" && synthetic == false
		].returnType)
		assertEquals(ControllerBase, IClassWithGetterSetterTypeAdaptionBaseWithInterface.declaredMethods.findFirst [
			name == "getDataWithGetter" && synthetic == false
		].returnType)
		assertEquals(ControllerAttributeStringConcrete1,
			ClassWithGetterSetterTypeAdaptionDerivedWithInterface.declaredMethods.findFirst [
				name == "getDataWithGetter" && synthetic == false
			].returnType)
		assertEquals(ControllerAttributeStringConcrete1,
			IClassWithGetterSetterTypeAdaptionDerivedWithInterface.declaredMethods.findFirst [
				name == "getDataWithGetter" && synthetic == false
			].returnType)

		// setDataWithSetter
		assertEquals(ControllerBase, ClassWithGetterSetterTypeAdaptionBase.declaredMethods.findFirst [
			name == "setDataWithSetter" && synthetic == false
		].parameters.get(0).type)
		assertEquals(ControllerBase, ClassWithGetterSetterTypeAdaptionDerived.declaredMethods.findFirst [
			name == "setDataWithSetter" && synthetic == false
		].parameters.get(0).type)
		assertEquals(ControllerBase,
			IClassWithGetterSetterTypeAdaptionDerivedInterfaceAfterwards.declaredMethods.findFirst [
				name == "setDataWithSetter" && synthetic == false
			].parameters.get(0).type)

		assertEquals(ControllerBase, ClassWithGetterSetterTypeAdaptionBaseWithInterface.declaredMethods.findFirst [
			name == "setDataWithSetter" && synthetic == false
		].parameters.get(0).type)
		assertEquals(ControllerBase, IClassWithGetterSetterTypeAdaptionBaseWithInterface.declaredMethods.findFirst [
			name == "setDataWithSetter" && synthetic == false
		].parameters.get(0).type)
		assertEquals(ControllerBase, ClassWithGetterSetterTypeAdaptionDerivedWithInterface.declaredMethods.findFirst [
			name == "setDataWithSetter" && synthetic == false
		].parameters.get(0).type)
		assertEquals(0, IClassWithGetterSetterTypeAdaptionDerivedWithInterface.declaredMethods.filter [
			name == "setDataWithSetter" && synthetic == false
		].size)

		// getDataWithSetterGetter
		assertEquals(ControllerBase, ClassWithGetterSetterTypeAdaptionBase.declaredMethods.findFirst [
			name == "getDataWithSetterGetter" && synthetic == false
		].returnType)
		assertEquals(ControllerAttributeStringConcrete1,
			ClassWithGetterSetterTypeAdaptionDerived.declaredMethods.findFirst [
				name == "getDataWithSetterGetter" && synthetic == false
			].returnType)
		assertEquals(ControllerAttributeStringConcrete1,
			IClassWithGetterSetterTypeAdaptionDerivedInterfaceAfterwards.declaredMethods.findFirst [
				name == "getDataWithSetterGetter" && synthetic == false
			].returnType)

		assertEquals(ControllerBase, ClassWithGetterSetterTypeAdaptionBaseWithInterface.declaredMethods.findFirst [
			name == "getDataWithSetterGetter" && synthetic == false
		].returnType)
		assertEquals(ControllerBase, IClassWithGetterSetterTypeAdaptionBaseWithInterface.declaredMethods.findFirst [
			name == "getDataWithSetterGetter" && synthetic == false
		].returnType)
		assertEquals(ControllerAttributeStringConcrete1,
			ClassWithGetterSetterTypeAdaptionDerivedWithInterface.declaredMethods.findFirst [
				name == "getDataWithSetterGetter" && synthetic == false
			].returnType)
		assertEquals(ControllerAttributeStringConcrete1,
			IClassWithGetterSetterTypeAdaptionDerivedWithInterface.declaredMethods.findFirst [
				name == "getDataWithSetterGetter" && synthetic == false
			].returnType)

		assertEquals(ControllerBase, ClassWithGetterSetterTypeAdaptionBase.declaredMethods.findFirst [
			name == "setDataWithSetterGetter" && synthetic == false
		].parameters.get(0).type)
		assertEquals(ControllerBase, ClassWithGetterSetterTypeAdaptionDerived.declaredMethods.findFirst [
			name == "setDataWithSetterGetter" && synthetic == false
		].parameters.get(0).type)
		assertEquals(ControllerBase,
			IClassWithGetterSetterTypeAdaptionDerivedInterfaceAfterwards.declaredMethods.findFirst [
				name == "setDataWithSetterGetter" && synthetic == false
			].parameters.get(0).type)

		assertEquals(ControllerBase, ClassWithGetterSetterTypeAdaptionBaseWithInterface.declaredMethods.findFirst [
			name == "setDataWithSetterGetter" && synthetic == false
		].parameters.get(0).type)
		assertEquals(ControllerBase, IClassWithGetterSetterTypeAdaptionBaseWithInterface.declaredMethods.findFirst [
			name == "setDataWithSetterGetter" && synthetic == false
		].parameters.get(0).type)
		assertEquals(ControllerBase, ClassWithGetterSetterTypeAdaptionDerivedWithInterface.declaredMethods.findFirst [
			name == "setDataWithSetterGetter" && synthetic == false
		].parameters.get(0).type)
		assertEquals(0, IClassWithGetterSetterTypeAdaptionDerivedWithInterface.declaredMethods.filter [
			name == "setDataWithSetterGetter" && synthetic == false
		].size)

		// execute setters and check for assertions
		var boolean exceptionThrown

		val obj = new ClassWithGetterSetterTypeAdaptionDerived

		exceptionThrown = false
		try {
			obj.setDataWithSetter(new ControllerBase(null))
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.setDataWithSetterGetter(new ControllerBase(null))
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		obj.setDataWithSetterGetter(null)
		assertNull(obj.getDataWithSetterGetter);

	}

	@Test
	def void testFieldNotNullWithGetterSetter() {

		val obj = new ClassWithGetterSetterNotNull
		var exceptionThrown = false

		val dataSetterOnlyFieldAccess = obj.class.getDeclaredField("dataStringSetterOnly")
		dataSetterOnlyFieldAccess.accessible = true

		assertEquals(4, obj.getDataIntGetter)
		assertEquals(14, obj.getDataIntGetterSetter)
		assertEquals("Test1", obj.getDataStringGetter)
		assertEquals("Test2", obj.getDataStringGetterSetter)

		exceptionThrown = false
		try {
			obj.getDataStringGetterWrongInitialized()
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.setDataIntGetterSetter(null)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		assertEquals(14, obj.getDataIntGetterSetter)

		obj.setDataIntGetterSetter(15)
		assertEquals(15, obj.getDataIntGetterSetter)

		exceptionThrown = false
		try {
			obj.dataStringGetterSetter = null
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		assertEquals("Test2", obj.getDataStringGetterSetter)

		obj.dataStringGetterSetter = "SetOk2"
		assertEquals("SetOk2", obj.getDataStringGetterSetter)

		exceptionThrown = false
		try {
			obj.dataStringSetterOnly = null
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		assertEquals("Test3", dataSetterOnlyFieldAccess.get(obj))

		obj.dataStringSetterOnly = "SetOk3"
		assertEquals("SetOk3", dataSetterOnlyFieldAccess.get(obj))

	}

	@Test
	def void testMethodNonFinal() {

		assertTrue(!Modifier.isFinal(ClassWithSetterGetterWithExtractInterface.getDeclaredMethod("getDataWithGetter").modifiers))
		assertTrue(!Modifier.isFinal(TraitWithSetterGetter.getDeclaredMethod("getDataWithGetter").modifiers))

	}

	@Test
	def void testNoGetterSetterRulesWithoutApplyRules() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.SetterRule

class ClassWithSetterGetter {

	@SetterRule
	int dataSetter

	@GetterRule
	int dataGetter

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ClassWithSetterGetter')

			val problemsFieldDataSetter = (clazz.findDeclaredField("dataSetter").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataGetter = (clazz.findDeclaredField("dataGetter").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(1, problemsFieldDataSetter.size)
			assertEquals(Severity.ERROR, problemsFieldDataSetter.get(0).severity)
			assertTrue(problemsFieldDataSetter.get(0).message.contains("@ApplyRules"))

			assertEquals(1, problemsFieldDataGetter.size)
			assertEquals(Severity.ERROR, problemsFieldDataGetter.get(0).severity)
			assertTrue(problemsFieldDataGetter.get(0).message.contains("@ApplyRules"))

			assertEquals(2, allProblems.size)

		]

	}

	@Test
	def void testGetterSetterWrongDeclaration() {

		'''

package virtual

import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.SetterRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules

@ApplyRules
class ClassWithSetterGetter {

	@SetterRule
	public int dataSetterPublic

	@GetterRule
	public int dataGetterPublic

	@SetterRule(visibility=Visibility.PRIVATE)
	int dataSetterGeneratePrivate

	@GetterRule(visibility=Visibility.PRIVATE)
	int dataGetterGeneratePrivate

	@GetterRule
	val dataGetterInferred = 0

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ClassWithSetterGetter')

			val problemsFieldDataSetterPublic = (clazz.findDeclaredField("dataSetterPublic").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataGetterPublic = (clazz.findDeclaredField("dataGetterPublic").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataSetterGeneratePrivate = (clazz.findDeclaredField("dataSetterGeneratePrivate").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataGetterGeneratePrivate = (clazz.findDeclaredField("dataGetterGeneratePrivate").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataGetterInferred = (clazz.findDeclaredField("dataGetterInferred").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(1, problemsFieldDataSetterPublic.size)
			assertEquals(Severity.ERROR, problemsFieldDataSetterPublic.get(0).severity)
			assertTrue(problemsFieldDataSetterPublic.get(0).message.contains("public"))

			assertEquals(1, problemsFieldDataGetterPublic.size)
			assertEquals(Severity.ERROR, problemsFieldDataGetterPublic.get(0).severity)
			assertTrue(problemsFieldDataGetterPublic.get(0).message.contains("public"))

			assertEquals(1, problemsFieldDataSetterGeneratePrivate.size)
			assertEquals(Severity.ERROR, problemsFieldDataSetterGeneratePrivate.get(0).severity)
			assertTrue(problemsFieldDataSetterGeneratePrivate.get(0).message.contains("Only public and"))

			assertEquals(1, problemsFieldDataGetterGeneratePrivate.size)
			assertEquals(Severity.ERROR, problemsFieldDataGetterGeneratePrivate.get(0).severity)
			assertTrue(problemsFieldDataGetterGeneratePrivate.get(0).message.contains("Only public and"))

			assertEquals(1, problemsFieldDataGetterInferred.size)
			assertEquals(Severity.ERROR, problemsFieldDataGetterInferred.get(0).severity)
			assertTrue(problemsFieldDataGetterInferred.get(0).message.contains("inferred"))

			assertEquals(5, allProblems.size)

		]

	}

	@Test
	def void testTraitGetterSetterOnFieldsWithoutTraitMethod() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.SetterRule

@TraitClass
@ApplyRules
abstract class TraitClassWithSetterGetter {

	@GetterRule
	int dataGetterWithoutTraitMethodAnnotation

	@SetterRule
	int dataSetterWithoutTraitMethodAnnotation

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.TraitClassWithSetterGetter')

			val problemsFieldDataGetterWithoutTraitMethodAnnotation = (clazz.findDeclaredField(
				"dataGetterWithoutTraitMethodAnnotation").primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataSetterWithoutTraitMethodAnnotation = (clazz.findDeclaredField(
				"dataSetterWithoutTraitMethodAnnotation").primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(1, problemsFieldDataGetterWithoutTraitMethodAnnotation.size)
			assertEquals(Severity.ERROR, problemsFieldDataGetterWithoutTraitMethodAnnotation.get(0).severity)
			assertTrue(problemsFieldDataGetterWithoutTraitMethodAnnotation.get(0).message.contains("trait method"))

			assertEquals(1, problemsFieldDataSetterWithoutTraitMethodAnnotation.size)
			assertEquals(Severity.ERROR, problemsFieldDataSetterWithoutTraitMethodAnnotation.get(0).severity)
			assertTrue(problemsFieldDataSetterWithoutTraitMethodAnnotation.get(0).message.contains("trait method"))

			assertEquals(2, allProblems.size)

		]

	}

	@Test
	def void testTraitGetterSetterWithErrorsInTraitClass() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.SetterRule
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod

@TraitClass
@ApplyRules
abstract class TraitClassWithSetterGetter {

	@GetterRule
	@ExclusiveMethod
	static int dataGetterStatic

	@SetterRule
	@ExclusiveMethod
	static int dataSetterStatic

	@GetterRule
	@ExclusiveMethod
	final int dataGetterFinal = 10

	@SetterRule
	@ExclusiveMethod
	final int dataSetterFinal = 20

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.TraitClassWithSetterGetter')

			val problemsFieldDataGetterStatic = (clazz.findDeclaredField("dataGetterStatic").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataSetterStatic = (clazz.findDeclaredField("dataSetterStatic").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataGetterFinal = (clazz.findDeclaredField("dataGetterFinal").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataSetterFinal = (clazz.findDeclaredField("dataSetterFinal").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(1, problemsFieldDataGetterStatic.size)
			assertEquals(Severity.ERROR, problemsFieldDataGetterStatic.get(0).severity)
			assertTrue(problemsFieldDataGetterStatic.get(0).message.contains("static"))

			assertEquals(1, problemsFieldDataSetterStatic.size)
			assertEquals(Severity.ERROR, problemsFieldDataSetterStatic.get(0).severity)
			assertTrue(problemsFieldDataSetterStatic.get(0).message.contains("static"))

			assertEquals(0, problemsFieldDataGetterFinal.size)

			assertEquals(1, problemsFieldDataSetterFinal.size)
			assertEquals(Severity.ERROR, problemsFieldDataSetterFinal.get(0).severity)
			assertTrue(problemsFieldDataSetterFinal.get(0).message.contains("final"))

			assertEquals(3, allProblems.size)

		]

	}

	@Test
	def void testGetterRuleExclusiveViolation() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto

import virtual.intf.ITraitClassWithGetter;

@TraitClass
@ApplyRules
abstract class TraitClassWithGetter {

	@GetterRule
	@ExclusiveMethod
	int dataSetterExclusive = 10

}

@ExtendedByAuto
@ApplyRules
class ClassWithGetter implements ITraitClassWithGetter {

	override int getDataSetterExclusive() {
		return 11;
	}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ClassWithGetter')

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(1, problemsClass.size)
			assertEquals(Severity.ERROR, problemsClass.get(0).severity)
			assertTrue(problemsClass.get(0).message.contains("exclusive trait method"))

			assertEquals(1, allProblems.size)

		]

	}

	@Test
	def void testFieldNotNullErrorsWithGetterSetter() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.SetterRule
import org.eclipse.xtend.lib.annotation.etai.NotNullRule

@ApplyRules
class ClassWithNotNull {

	@NotNullRule
	String dataNotNullNoGetterSetter

	@GetterRule
	@NotNullRule
	int dataIntNotNull

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ClassWithNotNull')

			val problemsDataNotNullNoGetterSetter = (clazz.findDeclaredField("dataNotNullNoGetterSetter").
				primarySourceElement as FieldDeclaration).problems
			val problemsDataIntNotNull = (clazz.findDeclaredField("dataIntNotNull").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(1, problemsDataNotNullNoGetterSetter.size)
			assertEquals(Severity.ERROR, problemsDataNotNullNoGetterSetter.get(0).severity)
			assertTrue(problemsDataNotNullNoGetterSetter.get(0).message.contains("must be used together with"))

			assertEquals(1, problemsDataIntNotNull.size)
			assertEquals(Severity.ERROR, problemsDataIntNotNull.get(0).severity)
			assertTrue(problemsDataIntNotNull.get(0).message.contains("primitive"))

			assertEquals(2, allProblems.size)

		]

	}

}
