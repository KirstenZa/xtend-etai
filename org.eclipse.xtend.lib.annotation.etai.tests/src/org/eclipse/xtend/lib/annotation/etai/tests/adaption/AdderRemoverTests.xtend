package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import java.util.AbstractCollection
import java.util.ArrayList
import java.util.Collection
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
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.EPDefault
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.ImplementDefault
import org.eclipse.xtend.lib.annotation.etai.NotNullRule
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.RemoverRule
import org.eclipse.xtend.lib.annotation.etai.SetterRule
import org.eclipse.xtend.lib.annotation.etai.SynchronizationRule
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeStringConcrete1
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.ITraitForClassWithCollectionGetterAdderTypeAdaptionDerived
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@ApplyRules
class ClassWithAdderRemover {

	@ApplyRules
	@ImplementDefault
	static class MyCollection extends AbstractCollection<String> {
		List<String> list = new ArrayList<String>

		override boolean remove(Object data) { return list.remove(data) }

		override boolean add(String data) { return list.add(data) }
	}

	@AdderRule(multiple=true)
	@GetterRule
	@NotNullRule
	@RemoverRule(multiple=true)
	Collection<String> dataWithAdderRemoverMyCollection = new MyCollection

	@AdderRule(multiple=true)
	@GetterRule
	@NotNullRule
	@RemoverRule(multiple=true)
	Collection<String> dataWithAdderRemoverAsCollection = new ArrayList<String>

	@AdderRule(multiple=true)
	@GetterRule
	@NotNullRule
	@RemoverRule(multiple=true)
	@SynchronizationRule("SimpleLock")
	List<Integer> dataWithAdderRemoverList = new ArrayList<Integer>

	@AdderRule(multiple=true)
	@GetterRule
	@NotNullRule
	@RemoverRule(multiple=true)
	Set<Integer> dataWithAdderRemoverSet = new HashSet<Integer>

	@AdderRule(multiple=true)
	@GetterRule
	@NotNullRule
	@RemoverRule(multiple=true)
	final SortedSet<Integer> dataWithAdderRemoverSortedSet = new TreeSet<Integer>

	@AdderRule(multiple=true)
	@GetterRule
	@NotNullRule(notNullValue=false)
	@RemoverRule(multiple=true)
	@SynchronizationRule("MapLock")
	Map<Integer, Double> dataWithAdderRemoverMap = new HashMap<Integer, Double>

	@AdderRule(multiple=true)
	@GetterRule
	@NotNullRule(notNullValue=false)
	@RemoverRule(multiple=true)
	TreeMap<Integer, String> dataWithAdderRemoverSortedMap = new TreeMap<Integer, String>

	@AdderRule(multiple=true, single=true)
	@RemoverRule(multiple=true, single=true)
	@GetterRule
	@SetterRule
	@SynchronizationRule("Something")
	static List<Integer> dataWithAdderRemoverListStatic = new ArrayList<Integer>

	@AdderRule(multiple=true, single=true)
	@RemoverRule(multiple=true, single=true)
	@GetterRule
	@SetterRule
	static Map<Integer, String> dataWithAdderRemoverMapStatic = new HashMap<Integer, String>

}

@ApplyRules
class ClassWithAdderRemoverSingleMultiple {

	@AdderRule(single=true, multiple=true)
	List<Integer> dataListAdderSingleTrueMultipleTrue

	@AdderRule(single=false, multiple=true)
	List<Integer> dataListAdderSingleFalseMultipleTrue

	@AdderRule(single=true, multiple=false)
	List<Integer> dataListAdderSingleTrueMultipleFalse

	@AdderRule(single=false, multiple=true)
	Map<Integer, Double> dataMapAdderSingleFalseMultipleTrue

	@AdderRule(single=true, multiple=false)
	Map<String, Integer> dataMapAdderSingleTrueMultipleFalse

	@RemoverRule(single=true, multiple=true)
	List<Integer> dataListRemoverSingleTrueMultipleTrue

	@RemoverRule(single=false, multiple=true)
	List<Integer> dataListRemoverSingleFalseMultipleTrue

	@RemoverRule(single=true, multiple=false)
	List<Integer> dataListRemoverSingleTrueMultipleFalse

	@RemoverRule(single=false, multiple=true)
	Map<Integer, Double> dataMapRemoverSingleFalseMultipleTrue

	@RemoverRule(single=true, multiple=false)
	Map<String, Integer> dataMapRemoverSingleTrueMultipleFalse

}

@ApplyRules
class ClassWithAdderRemoverNotNull {

	new() {
		dataListAdderContentNotNull = new ArrayList<Integer>
	}

	@AdderRule(single=true, multiple=true)
	@GetterRule
	@SetterRule
	@NotNullRule(notNullSelf=false, notNullKeyOrElement=true)
	List<Integer> dataListAdderContentNotNull

	def void addNullToDataListAdderContentNotNull() {
		dataListAdderContentNotNull.add(null);
	}

	@AdderRule(single=true, multiple=true)
	@SetterRule
	@GetterRule
	@NotNullRule(notNullSelf=true, notNullKeyOrElement=false)
	List<Integer> dataListAdderNotNull = new ArrayList<Integer>

	@AdderRule(single=true, multiple=true)
	@GetterRule
	@NotNullRule(notNullSelf=false, notNullKeyOrElement=true)
	Set<String> dataSetAdderContentNotNull = new HashSet<String>

	@AdderRule(single=true, multiple=true)
	@SetterRule
	@GetterRule
	@NotNullRule(notNullSelf=true, notNullKeyOrElement=true, notNullValue=true)
	SortedMap<String, String> dataMapAdderNothingNull = new TreeMap<String, String>

	def void addNullValueToDataMapAdderNothingNull() {
		dataMapAdderNothingNull.put("Something", null);
	}

	def void removeNullValueToDataMapAdderNothingNull() {
		dataMapAdderNothingNull.remove("Something");
	}

	@AdderRule(single=true, multiple=true)
	@NotNullRule(notNullSelf=false, notNullKeyOrElement=false, notNullValue=true)
	@SetterRule
	@GetterRule
	Map<String, String> dataMapAdderValueNotNull = new HashMap<String, String>

	def void addNullValueToDataMapAdderValueNotNull() {
		dataMapAdderValueNotNull.put("Something", null);
	}

	@AdderRule(single=true, multiple=true)
	@NotNullRule(notNullSelf=false, notNullKeyOrElement=true, notNullValue=false)
	@SetterRule
	@GetterRule
	Map<String, String> dataMapAdderKeyNotNull = new HashMap<String, String>

	def void addNullValueToDataMapAdderKeyNotNull() {
		dataMapAdderKeyNotNull.put(null, "Something");
	}

}

@ApplyRules
@ExtractInterface
class ClassWithCollectionGetterAdderTypeAdaptionBase {

	@GetterRule(collectionPolicy=DIRECT)
	@AdderRule(single=true, multiple=false)
	@RemoverRule(single=true, multiple=false)
	@TypeAdaptionRule("apply(java.util.List);addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString))")
	List<? extends ControllerBase> dataGenericListDirect = new ArrayList<ControllerBase>

	@GetterRule(collectionPolicy=UNMODIFIABLE)
	@AdderRule(single=true, multiple=false)
	@RemoverRule(single=true, multiple=false)
	@NotNullRule(notNullSelf=true, notNullKeyOrElement=true)
	@TypeAdaptionRule("apply(java.util.List);addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString))")
	List<? extends ControllerBase> dataGenericListUnmodifiable = new ArrayList<ControllerBase>

	@AdderRule(single=true, multiple=false)
	@RemoverRule(single=true, multiple=false)
	@GetterRule(collectionPolicy=UNMODIFIABLE_COPY)
	@TypeAdaptionRule("apply(java.util.List);addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString))")
	List<? extends ControllerBase> dataGenericListCopy = new ArrayList<ControllerBase>

	@AdderRule(single=true, multiple=false)
	@RemoverRule(single=true, multiple=false)
	@GetterRule(collectionPolicy=UNMODIFIABLE_COPY)
	@TypeAdaptionRule("apply(java.util.Map);addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString));addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString))")
	Map<? extends ControllerBase, ? extends ControllerBase> dataGenericMapCopy = new HashMap<ControllerBase, ControllerBase>

	@AdderRule(single=true, multiple=false)
	@RemoverRule(single=true, multiple=false)
	@GetterRule(collectionPolicy=UNMODIFIABLE_COPY)
	@TypeAdaptionRule("apply(java.util.Map);addTypeParam(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase));addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString))")
	Map<ControllerBase, ? extends ControllerBase> dataGenericValueOnlyMapCopy = new HashMap<ControllerBase, ControllerBase>

	@AdderRule(single=true, multiple=false)
	@RemoverRule(single=true, multiple=false)
	@GetterRule(collectionPolicy=UNMODIFIABLE_COPY)
	@TypeAdaptionRule("apply(java.util.Map);addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString));addTypeParam(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase))")
	Map<? extends ControllerBase, ControllerBase> dataGenericKeyOnlyMapCopy = new HashMap<ControllerBase, ControllerBase>

}

@ApplyRules
@TraitClass
abstract class TraitForClassWithCollectionGetterAdderTypeAdaptionDerived {

	@AdderRule(multiple=true, single=true)
	@RemoverRule(multiple=true, single=true)
	@GetterRule
	@SetterRule
	static List<Integer> dataWithAdderRemoverListStaticFromTrait = new ArrayList<Integer>

	@ProcessedMethod(processor=EPDefault)
	@GetterRule(collectionPolicy=UNMODIFIABLE_COPY)
	@AdderRule(single=true, multiple=false)
	@RemoverRule(single=true, multiple=false)
	@NotNullRule(notNullSelf=true, notNullKeyOrElement=true)
	@TypeAdaptionRule("apply(java.util.List);addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString))")
	List<? extends ControllerBase> dataGenericListCopyFromTrait = new ArrayList<ControllerBase>

}

@ApplyRules
@ExtractInterface
@ExtendedByAuto
class ClassWithCollectionGetterAdderTypeAdaptionDerived extends ClassWithCollectionGetterAdderTypeAdaptionBase implements ITraitForClassWithCollectionGetterAdderTypeAdaptionDerived {
}

@ApplyRules
class ClassWithTypeAdaptionNoTypeParamBase {

	@AdderRule(single=true, multiple=true)
	@RemoverRule(single=true, multiple=true)
	@TypeAdaptionRule("apply(java.util.List)")
	List<? extends ControllerBase> dataGenericListWithAdder = new ArrayList<ControllerBase>

}

@ApplyRules
class ClassWithTypeAdaptionNoTypeParamDerived extends ClassWithTypeAdaptionNoTypeParamBase {
}

class AdderRemoverTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testAdderRemover() {

		val obj = new ClassWithAdderRemover

		// test: own collection (just check for existence of methods)
		assertEquals(1, obj.class.declaredMethods.filter [
			synthetic == false && name == "addToDataWithAdderRemoverMyCollection"
		].size)
		assertEquals(1, obj.class.declaredMethods.filter [
			synthetic == false && name == "addAllToDataWithAdderRemoverMyCollection"
		].size)
		assertEquals(0, obj.class.declaredMethods.filter [
			synthetic == false && name == "putToDataWithAdderRemoverMyCollection"
		].size)
		assertEquals(0, obj.class.declaredMethods.filter [
			synthetic == false && name == "putAllToDataWithAdderRemoverMyCollection"
		].size)
		assertEquals(1, obj.class.declaredMethods.filter [
			synthetic == false && name == "removeFromDataWithAdderRemoverMyCollection"
		].size)
		assertEquals(1, obj.class.declaredMethods.filter [
			synthetic == false && name == "removeAllFromDataWithAdderRemoverMyCollection"
		].size)
		assertEquals(1, obj.class.declaredMethods.filter [
			synthetic == false && name == "clearDataWithAdderRemoverMyCollection"
		].size)

		// test: collection
		assertTrue(obj.addToDataWithAdderRemoverAsCollection("Str1"))
		assertTrue(obj.addToDataWithAdderRemoverAsCollection("Str1"))
		assertTrue(obj.addAllToDataWithAdderRemoverAsCollection(#["Str2", "Str5", "Str3"]))
		assertTrue(obj.addAllToDataWithAdderRemoverAsCollection(#["Str2", "Str5", "Str3"]))
		assertTrue(obj.removeFromDataWithAdderRemoverAsCollection("Str2"))
		assertTrue(obj.removeAllFromDataWithAdderRemoverAsCollection(#["Str1", "Str4"]))
		assertArrayEquals(#["Str5", "Str3", "Str2", "Str5", "Str3"], obj.getDataWithAdderRemoverAsCollection())
		assertTrue(obj.clearDataWithAdderRemoverAsCollection)
		assertTrue(obj.getDataWithAdderRemoverAsCollection().empty)
		assertFalse(obj.clearDataWithAdderRemoverAsCollection)

		assertEquals(1, obj.class.declaredMethods.filter [
			synthetic == false && name == "addToDataWithAdderRemoverAsCollection"
		].size)
		assertEquals(1, obj.class.declaredMethods.filter [
			synthetic == false && name == "addAllToDataWithAdderRemoverAsCollection"
		].size)
		assertEquals(0, obj.class.declaredMethods.filter [
			synthetic == false && name == "putToDataWithAdderRemoverAsCollection"
		].size)
		assertEquals(0, obj.class.declaredMethods.filter [
			synthetic == false && name == "putAllToDataWithAdderRemoverAsCollection"
		].size)
		assertEquals(1, obj.class.declaredMethods.filter [
			synthetic == false && name == "removeFromDataWithAdderRemoverAsCollection"
		].size)

		// test: list
		assertTrue(obj.addToDataWithAdderRemoverList(10))
		assertTrue(obj.addAllToDataWithAdderRemoverList(#[2, 5, 3]))
		assertTrue(obj.addToDataWithAdderRemoverList(0, 0))
		assertTrue(obj.removeFromDataWithAdderRemoverList(Integer::valueOf(2)))
		assertTrue(obj.removeAllFromDataWithAdderRemoverList(#[10, 4]))
		assertTrue(obj.removeFromDataWithAdderRemoverList(1))
		assertArrayEquals(#[0, 3], obj.getDataWithAdderRemoverList())
		assertTrue(obj.addAllToDataWithAdderRemoverList(0, #[4, 4, 4]))
		assertArrayEquals(#[4, 4, 4, 0, 3], obj.getDataWithAdderRemoverList())
		assertTrue(obj.removeAllFromDataWithAdderRemoverList(#[4, 4]))
		assertArrayEquals(#[0, 3], obj.getDataWithAdderRemoverList())
		assertTrue(obj.clearDataWithAdderRemoverList)
		assertTrue(obj.getDataWithAdderRemoverList().empty)
		assertFalse(obj.clearDataWithAdderRemoverList)

		assertEquals(0,
			obj.class.declaredMethods.filter[synthetic == false && name == "putToDataWithAdderRemoverList"].size)
		assertEquals(0, obj.class.declaredMethods.filter [
			synthetic == false && name == "putAllToDataWithAdderRemoverList"
		].size)

		// test: set
		assertTrue(obj.addToDataWithAdderRemoverSet(10))
		assertFalse(obj.addToDataWithAdderRemoverSet(10))
		assertTrue(obj.addAllToDataWithAdderRemoverSet(#[2, 5, 3]))
		assertFalse(obj.addAllToDataWithAdderRemoverSet(#[2, 5, 3]))
		assertTrue(obj.removeFromDataWithAdderRemoverSet(Integer::valueOf(2)))
		assertFalse(obj.removeFromDataWithAdderRemoverSet(Integer::valueOf(2)))
		assertTrue(obj.removeAllFromDataWithAdderRemoverSet(#[10, 4]))
		assertFalse(obj.removeAllFromDataWithAdderRemoverSet(#[10, 4]))
		assertEquals(new HashSet(#[5, 3]), obj.getDataWithAdderRemoverSet())
		assertTrue(obj.clearDataWithAdderRemoverSet)
		assertTrue(obj.getDataWithAdderRemoverSet().empty)
		assertFalse(obj.clearDataWithAdderRemoverSet)

		assertEquals(1, obj.class.declaredMethods.filter [
			synthetic == false && name == "addToDataWithAdderRemoverSet"
		].size)
		assertEquals(1, obj.class.declaredMethods.filter [
			synthetic == false && name == "addAllToDataWithAdderRemoverSet"
		].size)
		assertEquals(0, obj.class.declaredMethods.filter [
			synthetic == false && name == "putToDataWithAdderRemoverSet"
		].size)
		assertEquals(0, obj.class.declaredMethods.filter [
			synthetic == false && name == "putAllToDataWithAdderRemoverSet"
		].size)
		assertEquals(1, obj.class.declaredMethods.filter [
			synthetic == false && name == "removeFromDataWithAdderRemoverSet"
		].size)

		// test: sorted set
		assertTrue(obj.addToDataWithAdderRemoverSortedSet(10))
		assertFalse(obj.addToDataWithAdderRemoverSortedSet(10))
		assertTrue(obj.addAllToDataWithAdderRemoverSortedSet(#[2, 5, 3]))
		assertFalse(obj.addAllToDataWithAdderRemoverSortedSet(#[2, 5, 3]))
		assertTrue(obj.removeFromDataWithAdderRemoverSortedSet(Integer::valueOf(2)))
		assertFalse(obj.removeFromDataWithAdderRemoverSortedSet(Integer::valueOf(2)))
		assertTrue(obj.removeAllFromDataWithAdderRemoverSortedSet(#[10, 4]))
		assertFalse(obj.removeAllFromDataWithAdderRemoverSortedSet(#[10, 4]))
		assertArrayEquals(#[3, 5], obj.getDataWithAdderRemoverSortedSet())
		assertTrue(obj.clearDataWithAdderRemoverSortedSet)
		assertTrue(obj.getDataWithAdderRemoverSortedSet().empty)
		assertFalse(obj.clearDataWithAdderRemoverSortedSet)

		assertEquals(1, obj.class.declaredMethods.filter [
			synthetic == false && name == "addToDataWithAdderRemoverSortedSet"
		].size)
		assertEquals(1, obj.class.declaredMethods.filter [
			synthetic == false && name == "addAllToDataWithAdderRemoverSortedSet"
		].size)
		assertEquals(0, obj.class.declaredMethods.filter [
			synthetic == false && name == "putToDataWithAdderRemoverSortedSet"
		].size)
		assertEquals(0, obj.class.declaredMethods.filter [
			synthetic == false && name == "putAllToDataWithAdderRemoverSortedSet"
		].size)
		assertEquals(1, obj.class.declaredMethods.filter [
			synthetic == false && name == "removeFromDataWithAdderRemoverSortedSet"
		].size)

		// test: map
		val tempMapIntegerDouble = new HashMap<Integer, Double>()
		tempMapIntegerDouble.put(11, 5.0)
		tempMapIntegerDouble.put(12, 6.0)

		assertNull(obj.putToDataWithAdderRemoverMap(10, 1.0))
		assertEquals(1.0, obj.putToDataWithAdderRemoverMap(10, 4.0), 0.1)
		obj.putAllToDataWithAdderRemoverMap(tempMapIntegerDouble)
		assertEquals(5.0, obj.removeFromDataWithAdderRemoverMap(11), 0.1)
		assertEquals(new HashSet(#[12, 10]), obj.getDataWithAdderRemoverMap().keySet)
		assertEquals(new HashSet(#[6.0, 4.0]), new HashSet(obj.getDataWithAdderRemoverMap().values))
		assertEquals(4.0, obj.getDataWithAdderRemoverMap().get(10), 0.1)
		assertTrue(obj.clearDataWithAdderRemoverMap)
		assertTrue(obj.getDataWithAdderRemoverMap().empty)
		assertFalse(obj.clearDataWithAdderRemoverMap)

		assertEquals(0, obj.class.declaredMethods.filter [
			synthetic == false && name == "addToDataWithAdderRemoverMap"
		].size)
		assertEquals(0, obj.class.declaredMethods.filter [
			synthetic == false && name == "addAllToDataWithAdderRemoverMap"
		].size)
		assertEquals(1, obj.class.declaredMethods.filter [
			synthetic == false && name == "removeFromDataWithAdderRemoverMap"
		].size)
		assertEquals(0, obj.class.declaredMethods.filter [
			synthetic == false && name == "removeAllFromDataWithAdderRemoverMap"
		].size)

		// test: sorted map
		val tempMapIntegerString = new HashMap<Integer, String>()
		tempMapIntegerString.put(11, "5")
		tempMapIntegerString.put(12, "6")

		assertNull(obj.putToDataWithAdderRemoverSortedMap(15, "1"))
		assertEquals("1", obj.putToDataWithAdderRemoverSortedMap(15, "4"))
		obj.putAllToDataWithAdderRemoverSortedMap(tempMapIntegerString)
		assertEquals("5", obj.removeFromDataWithAdderRemoverSortedMap(11))
		assertArrayEquals(#[12, 15], obj.getDataWithAdderRemoverSortedMap().keySet)
		assertArrayEquals(#["6", "4"], obj.getDataWithAdderRemoverSortedMap().values)
		assertEquals("4", obj.getDataWithAdderRemoverSortedMap().get(15))
		assertTrue(obj.clearDataWithAdderRemoverSortedMap)
		assertTrue(obj.getDataWithAdderRemoverSortedMap().empty)
		assertFalse(obj.clearDataWithAdderRemoverSortedMap)

		assertEquals(0, obj.class.declaredMethods.filter [
			synthetic == false && name == "addToDataWithAdderRemoverSortedMap"
		].size)
		assertEquals(0, obj.class.declaredMethods.filter [
			synthetic == false && name == "addAllToDataWithAdderRemoverSortedMap"
		].size)
		assertEquals(1, obj.class.declaredMethods.filter [
			synthetic == false && name == "removeFromDataWithAdderRemoverSortedMap"
		].size)
		assertEquals(0, obj.class.declaredMethods.filter [
			synthetic == false && name == "removeAllFromDataWithAdderRemoverSortedMap"
		].size)

	}

	@Test
	def void testAdderRemoverStatic() {

		// list
		ClassWithAdderRemover::setDataWithAdderRemoverListStatic(new ArrayList(#[99]))

		ClassWithAdderRemover::addToDataWithAdderRemoverListStatic(1)
		ClassWithAdderRemover::addToDataWithAdderRemoverListStatic(0, 2)
		ClassWithAdderRemover::addAllToDataWithAdderRemoverListStatic(#[3, 4])
		ClassWithAdderRemover::addAllToDataWithAdderRemoverListStatic(0, #[5, 6])

		assertEquals(#[5, 6, 2, 99, 1, 3, 4], ClassWithAdderRemover::getDataWithAdderRemoverListStatic())

		ClassWithAdderRemover::removeFromDataWithAdderRemoverListStatic(Integer::valueOf(4))
		ClassWithAdderRemover::removeFromDataWithAdderRemoverListStatic(3)
		ClassWithAdderRemover::removeAllFromDataWithAdderRemoverListStatic(#[5, 1])

		assertEquals(#[6, 2, 3], ClassWithAdderRemover::getDataWithAdderRemoverListStatic())

		assertTrue(ClassWithAdderRemover::clearDataWithAdderRemoverListStatic())
		assertEquals(0, ClassWithAdderRemover::getDataWithAdderRemoverListStatic().size)
		assertFalse(ClassWithAdderRemover::clearDataWithAdderRemoverListStatic())

		// map
		val map1 = new HashMap<Integer, String>
		map1.put(99, "99")
		val map2 = new HashMap<Integer, String>
		map2.put(2, "x")
		map2.put(3, "3")
		map2.put(4, "4")

		ClassWithAdderRemover::setDataWithAdderRemoverMapStatic(map1)

		ClassWithAdderRemover::putToDataWithAdderRemoverMapStatic(1, "1")
		ClassWithAdderRemover::putToDataWithAdderRemoverMapStatic(2, "2")
		ClassWithAdderRemover::putAllToDataWithAdderRemoverMapStatic(map2)

		assertEquals("99", ClassWithAdderRemover::getDataWithAdderRemoverMapStatic().get(99))
		assertEquals("1", ClassWithAdderRemover::getDataWithAdderRemoverMapStatic().get(1))
		assertEquals("x", ClassWithAdderRemover::getDataWithAdderRemoverMapStatic().get(2))
		assertEquals("3", ClassWithAdderRemover::getDataWithAdderRemoverMapStatic().get(3))
		assertEquals("4", ClassWithAdderRemover::getDataWithAdderRemoverMapStatic().get(4))

		ClassWithAdderRemover::removeFromDataWithAdderRemoverMapStatic(99)

		assertNull(ClassWithAdderRemover::getDataWithAdderRemoverMapStatic().get(99))

		ClassWithAdderRemover::clearDataWithAdderRemoverMapStatic()

		assertEquals(0, ClassWithAdderRemover::getDataWithAdderRemoverMapStatic().entrySet.length)

		// trait class - list
		TraitForClassWithCollectionGetterAdderTypeAdaptionDerived::
			setDataWithAdderRemoverListStaticFromTrait(new ArrayList(#[99]))

		TraitForClassWithCollectionGetterAdderTypeAdaptionDerived::addToDataWithAdderRemoverListStaticFromTrait(1)
		TraitForClassWithCollectionGetterAdderTypeAdaptionDerived::addToDataWithAdderRemoverListStaticFromTrait(0, 2)
		TraitForClassWithCollectionGetterAdderTypeAdaptionDerived::
			addAllToDataWithAdderRemoverListStaticFromTrait(#[3, 4])
		TraitForClassWithCollectionGetterAdderTypeAdaptionDerived::
			addAllToDataWithAdderRemoverListStaticFromTrait(0, #[5, 6])

		assertEquals(#[5, 6, 2, 99, 1, 3, 4],
			TraitForClassWithCollectionGetterAdderTypeAdaptionDerived::getDataWithAdderRemoverListStaticFromTrait())

		TraitForClassWithCollectionGetterAdderTypeAdaptionDerived::
			removeFromDataWithAdderRemoverListStaticFromTrait(Integer::valueOf(4))
		TraitForClassWithCollectionGetterAdderTypeAdaptionDerived::removeFromDataWithAdderRemoverListStaticFromTrait(3)
		TraitForClassWithCollectionGetterAdderTypeAdaptionDerived::
			removeAllFromDataWithAdderRemoverListStaticFromTrait(#[5, 1])

		assertEquals(#[6, 2, 3],
			TraitForClassWithCollectionGetterAdderTypeAdaptionDerived::getDataWithAdderRemoverListStaticFromTrait())

		TraitForClassWithCollectionGetterAdderTypeAdaptionDerived::clearDataWithAdderRemoverListStaticFromTrait()

		assertEquals(0,
			TraitForClassWithCollectionGetterAdderTypeAdaptionDerived::getDataWithAdderRemoverListStaticFromTrait().
				size)

	}

	@Test
	def void testFlagMultipleSingle() {

		// check generation of methods: adder
		assertEquals(2, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addToDataListAdderSingleTrueMultipleTrue"
		].size)
		assertEquals(2, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addAllToDataListAdderSingleTrueMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putToDataListAdderSingleTrueMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putAllToDataListAdderSingleTrueMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeFromDataListAdderSingleTrueMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeAllFromDataListAdderSingleTrueMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "clearDataListAdderSingleTrueMultipleTrue"
		].size)

		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addToDataListAdderSingleFalseMultipleTrue"
		].size)
		assertEquals(2, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addAllToDataListAdderSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putToDataListAdderSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putAllToDataListAdderSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeFromDataListAdderSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeAllFromDataListAdderSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "clearDataListAdderSingleFalseMultipleTrue"
		].size)

		assertEquals(2, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addToDataListAdderSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addAllToDataListAdderSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putToDataListAdderSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putAllToDataListAdderSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeFromDataListAdderSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeAllFromDataListAdderSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "clearDataListAdderSingleTrueMultipleFalse"
		].size)

		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addToDataMapAdderSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addAllToDataMapAdderSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putToDataMapAdderSingleFalseMultipleTrue"
		].size)
		assertEquals(1, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putAllToDataMapAdderSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeFromDataMapAdderSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeAllFromDataMapAdderSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "clearDataMapAdderSingleFalseMultipleTrue"
		].size)

		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addToDataMapAdderSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addAllToDataMapAdderSingleTrueMultipleFalse"
		].size)
		assertEquals(1, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putToDataMapAdderSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putAllToDataMapAdderSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeFromDataMapAdderSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeAllFromDataMapAdderSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "clearDataMapAdderSingleTrueMultipleFalse"
		].size)

		// check generation of methods: remover
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addToDataListRemoverSingleTrueMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addAllToDataListRemoverSingleTrueMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putToDataListRemoverSingleTrueMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putAllToDataListRemoverSingleTrueMultipleTrue"
		].size)
		assertEquals(2, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeFromDataListRemoverSingleTrueMultipleTrue"
		].size)
		assertEquals(1, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeAllFromDataListRemoverSingleTrueMultipleTrue"
		].size)
		assertEquals(1, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "clearDataListRemoverSingleTrueMultipleTrue"
		].size)

		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addToDataListRemoverSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addAllToDataListRemoverSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putToDataListRemoverSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putAllToDataListRemoverSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeFromDataListRemoverSingleFalseMultipleTrue"
		].size)
		assertEquals(1, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeAllFromDataListRemoverSingleFalseMultipleTrue"
		].size)
		assertEquals(1, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "clearDataListRemoverSingleFalseMultipleTrue"
		].size)

		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addToDataListRemoverSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addAllToDataListRemoverSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putToDataListRemoverSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putAllToDataListRemoverSingleTrueMultipleFalse"
		].size)
		assertEquals(2, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeFromDataListRemoverSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeAllFromDataListRemoverSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "clearDataListRemoverSingleTrueMultipleFalse"
		].size)

		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addToDataMapRemoverSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addAllToDataMapRemoverSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putToDataMapRemoverSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putAllToDataMapRemoverSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeFromDataMapRemoverSingleFalseMultipleTrue"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeAllFromDataMapRemoverSingleFalseMultipleTrue"
		].size)
		assertEquals(1, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "clearDataMapRemoverSingleFalseMultipleTrue"
		].size)

		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addToDataMapRemoverSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "addAllToDataMapRemoverSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putToDataMapRemoverSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "putAllToDataMapRemoverSingleTrueMultipleFalse"
		].size)
		assertEquals(1, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeFromDataMapRemoverSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "removeAllFromDataMapRemoverSingleTrueMultipleFalse"
		].size)
		assertEquals(0, ClassWithAdderRemoverSingleMultiple.declaredMethods.filter [
			synthetic == false && name == "clearDataMapRemoverSingleTrueMultipleFalse"
		].size)

	}

	@Test
	def void testFieldNotNullWithAdderRemover() {

		val obj = new ClassWithAdderRemoverNotNull
		var exceptionThrown = false
		var Map<String, String> tempMapStringString

		val tempMapStringStringNullKey = new HashMap<String, String>()
		tempMapStringStringNullKey.put(null, "NullKey")
		val tempMapStringStringNullValue = new HashMap<String, String>()
		tempMapStringStringNullValue.put("NullValue", null)

		// test: list, content not null
		obj.addToDataListAdderContentNotNull(0, 10)
		assertTrue(obj.addToDataListAdderContentNotNull(20))
		assertTrue(obj.addAllToDataListAdderContentNotNull(0, #[50, 60]))
		assertTrue(obj.addAllToDataListAdderContentNotNull(#[30, 40]))

		exceptionThrown = false
		try {
			obj.addToDataListAdderContentNotNull(0, null)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.addToDataListAdderContentNotNull(null)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.addAllToDataListAdderContentNotNull(#[null])
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.addAllToDataListAdderContentNotNull(0, #[null, null])
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.addAllToDataListAdderContentNotNull(0, #[])
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

		assertArrayEquals(#[50, 60, 10, 20, 30, 40], obj.dataListAdderContentNotNull)

		obj.addNullToDataListAdderContentNotNull
		exceptionThrown = false
		try {
			obj.dataListAdderContentNotNull
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.setDataListAdderContentNotNull(null)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

		assertNull(obj.dataListAdderContentNotNull)

		// test: list, not null
		obj.addToDataListAdderNotNull(0, 10)
		obj.addToDataListAdderNotNull(20)
		obj.addAllToDataListAdderNotNull(#[30, 40])
		obj.addAllToDataListAdderNotNull(0, #[50, 60])

		exceptionThrown = false
		try {
			obj.addToDataListAdderNotNull(0, null)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

		exceptionThrown = false
		try {
			assertTrue(obj.addToDataListAdderNotNull(null))
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

		exceptionThrown = false
		try {
			assertTrue(obj.addAllToDataListAdderNotNull(0, #[20, null]))
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

		exceptionThrown = false
		try {
			assertTrue(obj.addAllToDataListAdderNotNull(#[null]))
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

		exceptionThrown = false
		try {
			obj.setDataListAdderNotNull(null)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		assertArrayEquals(#[20, null, null, 50, 60, 10, 20, 30, 40, null, null], obj.dataListAdderNotNull)

		// test: set, content not null
		assertTrue(obj.addToDataSetAdderContentNotNull("10"))
		assertTrue(obj.addAllToDataSetAdderContentNotNull(#["30", "40"]))

		exceptionThrown = false
		try {
			obj.addToDataSetAdderContentNotNull(null)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.addAllToDataSetAdderContentNotNull(#[null, "80"])
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		assertEquals(new HashSet(#["10", "30", "40"]), obj.dataSetAdderContentNotNull)

		// test: map, nothing null
		tempMapStringString = new HashMap<String, String>()
		tempMapStringString.put("2", "20")
		tempMapStringString.put("3", "30")

		assertNull(obj.putToDataMapAdderNothingNull("1", "0"))
		assertEquals("0", obj.putToDataMapAdderNothingNull("1", "10"))
		obj.putAllToDataMapAdderNothingNull(tempMapStringString)

		exceptionThrown = false
		try {
			obj.putToDataMapAdderNothingNull(null, "Null")
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.putToDataMapAdderNothingNull("Null", null)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.putAllToDataMapAdderNothingNull(tempMapStringStringNullKey)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.putAllToDataMapAdderNothingNull(tempMapStringStringNullValue)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.setDataMapAdderNothingNull(null)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		assertEquals(new HashSet(#["1", "2", "3"]), obj.dataMapAdderNothingNull.keySet)
		assertEquals(new HashSet(#["10", "20", "30"]), new HashSet(obj.dataMapAdderNothingNull.values))

		// test: map, key not null
		tempMapStringString = new HashMap<String, String>()
		tempMapStringString.put("x", null)

		obj.putAllToDataMapAdderKeyNotNull(tempMapStringString)
		assertNull(obj.putToDataMapAdderKeyNotNull("1", null))
		assertNull("10", obj.putToDataMapAdderKeyNotNull("1", "10"))

		exceptionThrown = false
		try {
			obj.putToDataMapAdderKeyNotNull("3", null)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

		exceptionThrown = false
		try {
			obj.putAllToDataMapAdderKeyNotNull(tempMapStringStringNullKey)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.putAllToDataMapAdderKeyNotNull(tempMapStringStringNullValue)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

		assertEquals(new HashSet(#["NullValue", "x", "1", "3"]), obj.dataMapAdderKeyNotNull.keySet)
		assertEquals(new HashSet(#[null, "10"]), new HashSet(obj.dataMapAdderKeyNotNull.values))
		assertEquals(#[null, null, null], obj.dataMapAdderKeyNotNull.values.filter[it === null].toList)

		obj.addNullValueToDataMapAdderKeyNotNull()
		exceptionThrown = false
		try {
			obj.dataMapAdderKeyNotNull
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.setDataMapAdderKeyNotNull(null)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

		assertNull(obj.dataMapAdderKeyNotNull)

		// test: map, value not null
		tempMapStringString = new HashMap<String, String>()
		tempMapStringString.put(null, "x")

		obj.putAllToDataMapAdderValueNotNull(tempMapStringString)
		assertNull(obj.putToDataMapAdderValueNotNull("1", "10"))
		assertEquals("x", obj.putToDataMapAdderValueNotNull(null, "NullKey_Alt"))

		exceptionThrown = false
		try {
			obj.putToDataMapAdderValueNotNull("3", null)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.putAllToDataMapAdderValueNotNull(tempMapStringStringNullValue)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		assertEquals(new HashSet(#[null, "1"]), obj.dataMapAdderValueNotNull.keySet)
		assertEquals(new HashSet(#["NullKey_Alt", "10"]), new HashSet(obj.dataMapAdderValueNotNull.values))

		exceptionThrown = false
		try {
			obj.putAllToDataMapAdderValueNotNull(tempMapStringStringNullKey)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

		assertEquals(new HashSet(#[null, "1"]), obj.dataMapAdderValueNotNull.keySet)
		assertEquals(new HashSet(#["NullKey", "10"]), new HashSet(obj.dataMapAdderValueNotNull.values))

		obj.addNullValueToDataMapAdderValueNotNull()
		exceptionThrown = false
		try {
			obj.dataMapAdderValueNotNull
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

		exceptionThrown = false
		try {
			obj.setDataMapAdderValueNotNull(null)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)

		assertNull(obj.dataMapAdderValueNotNull)

	}

	@Test
	def void testGetterAdderRemoverTypeAdaption() {

		var exceptionThrown = false

		val ControllerAttributeString controllerAttributeString1 = new ControllerAttributeStringConcrete1(null)
		val ControllerAttributeStringConcrete1 controllerAttributeString2 = new ControllerAttributeStringConcrete1(null)
		val ControllerAttributeString controllerAttributeString3 = new ControllerAttributeStringConcrete2(null)
		val ControllerBase controllerBase1 = new ControllerBase(null)
		val ControllerBase controllerBase2 = new ControllerBase(null)

		val obj = new ClassWithCollectionGetterAdderTypeAdaptionDerived

		// test: generic, list, direct
		obj.addToDataGenericListDirect(controllerAttributeString1)
		obj.addToDataGenericListDirect(controllerAttributeString2)
		obj.addToDataGenericListDirect(1, controllerAttributeString3)
		exceptionThrown = false
		try {
			obj.addToDataGenericListDirect(controllerBase1)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		exceptionThrown = false
		try {
			obj.addToDataGenericListDirect(0, controllerBase2)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		obj.removeFromDataGenericListDirect(controllerAttributeString1)
		exceptionThrown = false
		try {
			obj.removeFromDataGenericListDirect(controllerBase1)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		assertEquals("ControllerAttributeStringConcrete2", obj.getDataGenericListDirect().get(0).AString)
		assertEquals("ControllerAttributeStringConcrete1", obj.getDataGenericListDirect().get(1).AString)

		// test: generic, list, unmodifiable
		obj.addToDataGenericListUnmodifiable(controllerAttributeString1)
		obj.addToDataGenericListUnmodifiable(controllerAttributeString2)
		obj.addToDataGenericListUnmodifiable(1, controllerAttributeString3)
		exceptionThrown = false
		try {
			obj.addToDataGenericListUnmodifiable(controllerBase1)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		exceptionThrown = false
		try {
			obj.addToDataGenericListUnmodifiable(0, controllerBase2)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		obj.removeFromDataGenericListUnmodifiable(controllerAttributeString1)
		exceptionThrown = false
		try {
			obj.removeFromDataGenericListUnmodifiable(controllerBase1)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		assertEquals("ControllerAttributeStringConcrete2", obj.getDataGenericListUnmodifiable().get(0).AString)
		assertEquals("ControllerAttributeStringConcrete1", obj.getDataGenericListUnmodifiable().get(1).AString)

		// test: generic, list, copy
		obj.addToDataGenericListCopy(controllerAttributeString1)
		obj.addToDataGenericListCopy(controllerAttributeString2)
		obj.addToDataGenericListCopy(1, controllerAttributeString3)
		exceptionThrown = false
		try {
			obj.addToDataGenericListCopy(controllerBase1)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		exceptionThrown = false
		try {
			obj.addToDataGenericListCopy(0, controllerBase2)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		obj.removeFromDataGenericListCopy(controllerAttributeString1)
		exceptionThrown = false
		try {
			obj.removeFromDataGenericListCopy(controllerBase1)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		assertEquals("ControllerAttributeStringConcrete2", obj.getDataGenericListCopy().get(0).AString)
		assertEquals("ControllerAttributeStringConcrete1", obj.getDataGenericListCopy().get(1).AString)

		// test: generic, list, copy (from trait)
		obj.addToDataGenericListCopyFromTrait(controllerAttributeString1)
		obj.addToDataGenericListCopyFromTrait(controllerAttributeString2)
		obj.addToDataGenericListCopyFromTrait(1, controllerAttributeString3)
		exceptionThrown = false
		try {
			obj.addToDataGenericListCopyFromTrait(controllerBase1)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		exceptionThrown = false
		try {
			obj.addToDataGenericListCopyFromTrait(0, controllerBase2)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		obj.removeFromDataGenericListCopyFromTrait(controllerAttributeString1)
		exceptionThrown = false
		try {
			obj.removeFromDataGenericListCopyFromTrait(controllerBase1)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		assertEquals("ControllerAttributeStringConcrete2", obj.getDataGenericListCopyFromTrait().get(0).AString)
		assertEquals("ControllerAttributeStringConcrete1", obj.getDataGenericListCopyFromTrait().get(1).AString)

		// test: generic, map, copy
		obj.putToDataGenericMapCopy(controllerAttributeString1, controllerAttributeString2)
		obj.putToDataGenericMapCopy(controllerAttributeString2, controllerAttributeString3)
		exceptionThrown = false
		try {
			obj.putToDataGenericMapCopy(controllerBase1, controllerAttributeString3)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		exceptionThrown = false
		try {
			obj.putToDataGenericMapCopy(controllerAttributeString3, controllerBase1)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		assertEquals("ControllerAttributeStringConcrete1",
			obj.getDataGenericMapCopy().get(controllerAttributeString1).AString)
		assertEquals("ControllerAttributeStringConcrete2",
			obj.getDataGenericMapCopy().get(controllerAttributeString2).AString)
		assertNull(obj.getDataGenericMapCopy().get(controllerBase1))
		obj.removeFromDataGenericMapCopy(controllerAttributeString1)
		exceptionThrown = false
		try {
			obj.removeFromDataGenericMapCopy(controllerBase1)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		assertEquals(1, obj.getDataGenericMapCopy().entrySet.length)

		// test: generic, map, copy (only value)
		obj.putToDataGenericValueOnlyMapCopy(controllerAttributeString1, controllerAttributeString2)
		obj.putToDataGenericValueOnlyMapCopy(controllerAttributeString2, controllerAttributeString3)
		exceptionThrown = false
		try {
			obj.putToDataGenericValueOnlyMapCopy(controllerBase1, controllerAttributeString3)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)
		exceptionThrown = false
		try {
			obj.putToDataGenericValueOnlyMapCopy(controllerAttributeString3, controllerBase1)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		assertEquals("ControllerAttributeStringConcrete1",
			obj.getDataGenericValueOnlyMapCopy().get(controllerAttributeString1).AString)
		assertEquals("ControllerAttributeStringConcrete2",
			obj.getDataGenericValueOnlyMapCopy().get(controllerAttributeString2).AString)
		assertEquals("ControllerAttributeStringConcrete2",
			obj.getDataGenericValueOnlyMapCopy().get(controllerBase1).AString)
		obj.removeFromDataGenericValueOnlyMapCopy(controllerBase1)
		obj.removeFromDataGenericValueOnlyMapCopy(controllerAttributeString2)
		assertEquals("ControllerAttributeStringConcrete1",
			obj.getDataGenericValueOnlyMapCopy().get(controllerAttributeString1).AString)
		assertEquals(1, obj.getDataGenericValueOnlyMapCopy().entrySet.length)

		// test: generic, map, copy (only key)
		obj.putToDataGenericKeyOnlyMapCopy(controllerAttributeString1, controllerAttributeString2)
		obj.putToDataGenericKeyOnlyMapCopy(controllerAttributeString2, controllerAttributeString3)
		exceptionThrown = false
		try {
			obj.putToDataGenericKeyOnlyMapCopy(controllerBase1, controllerAttributeString3)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		exceptionThrown = false
		try {
			obj.putToDataGenericKeyOnlyMapCopy(controllerAttributeString3, controllerBase1)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertFalse(exceptionThrown)
		assertSame(controllerAttributeString2, obj.getDataGenericKeyOnlyMapCopy().get(controllerAttributeString1))
		assertSame(controllerAttributeString3, obj.getDataGenericKeyOnlyMapCopy().get(controllerAttributeString2))
		assertSame(controllerBase1, obj.getDataGenericKeyOnlyMapCopy().get(controllerAttributeString3))
		obj.removeFromDataGenericKeyOnlyMapCopy(controllerAttributeString1)
		exceptionThrown = false
		try {
			obj.removeFromDataGenericKeyOnlyMapCopy(controllerBase1)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)
		assertEquals(2, obj.getDataGenericKeyOnlyMapCopy().entrySet.length)

	}

	@Test
	def void testNoAdderRemoverTypeAdaptionWithoutTypeParamAdaption() {

		assertEquals(0, ClassWithTypeAdaptionNoTypeParamDerived.declaredMethods.length)

	}

	@Test
	def void testObjectUsedIfNoGenerics() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule

@ApplyRules
class ClassWithAdderRemoverNoGenerics {

	@AdderRule(single=true, multiple=true)
	@RemoverRule(single=true, multiple=true)
	java.util.ArrayList dataWithAdderRemoverList = new java.util.ArrayList
	
	@AdderRule(single=true, multiple=true)
	@RemoverRule(single=true, multiple=true)
	java.util.Map dataWithAdderRemoverMap = new java.util.HashMap

	static def void method() {

		var Object oldObject

		val stringList = new java.util.ArrayList<String>
		stringList.add("Test2")

		val stringMap = new java.util.HashMap<String, String>
		stringMap.put("SomeMapKey", "SomeMapValue")

		val obj = new ClassWithAdderRemoverNoGenerics
		obj.addToDataWithAdderRemoverList("Test1")
		obj.addToDataWithAdderRemoverList(0, 4.5)
		obj.addAllToDataWithAdderRemoverList(stringList)
		obj.removeFromDataWithAdderRemoverList("Test1")
		obj.removeFromDataWithAdderRemoverList(4.5)
		oldObject = obj.removeFromDataWithAdderRemoverList(0)
		obj.removeAllFromDataWithAdderRemoverList(stringList)

		oldObject = obj.putToDataWithAdderRemoverMap("TestKey", 4.9)
		oldObject = obj.putToDataWithAdderRemoverMap(9, "TestValue")
		obj.putAllToDataWithAdderRemoverMap(stringMap)
		oldObject = obj.removeFromDataWithAdderRemoverMap("TestKey")
		oldObject = obj.removeFromDataWithAdderRemoverMap("9")

	}

}

		'''.compile [

			// do assertions
			assertEquals(0, allProblems.size)

		]

	}

	@Test
	def void testNoAdderRemoverRulesWithoutApplyRules() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule

class ClassWithAdderRemover {

	@AdderRule
	java.util.List<Double> dataAdder

	@RemoverRule
	java.util.List<Double> dataRemover

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ClassWithAdderRemover')

			val problemsFieldDataSetter = (clazz.findDeclaredField("dataAdder").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataGetter = (clazz.findDeclaredField("dataRemover").
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
	def void testAdderRemoverMustBeCollection() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules

@ApplyRules
class ClassWithRemoverAdderNoCollection {

	@RemoverRule
	Integer dataRemoverNoCollection

	@AdderRule
	double dataAdderNoCollection

	@RemoverRule
	java.util.Map<Double, Integer> dataRemoverCollection

	@AdderRule
	java.util.HashSet<Double> dataAdderCollection

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ClassWithRemoverAdderNoCollection')

			val problemsFieldDataRemoverNoCollection = (clazz.findDeclaredField("dataRemoverNoCollection").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataAdderNoCollection = (clazz.findDeclaredField("dataAdderNoCollection").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(1, problemsFieldDataRemoverNoCollection.size)
			assertEquals(Severity.ERROR, problemsFieldDataRemoverNoCollection.get(0).severity)
			assertTrue(problemsFieldDataRemoverNoCollection.get(0).message.contains("collection"))

			assertEquals(1, problemsFieldDataAdderNoCollection.size)
			assertEquals(Severity.ERROR, problemsFieldDataAdderNoCollection.get(0).severity)
			assertTrue(problemsFieldDataAdderNoCollection.get(0).message.contains("collection"))

			assertEquals(2, allProblems.size)

		]

	}

	@Test
	def void testAdderRemoverWrongDeclaration() {

		'''

package virtual

import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules

@ApplyRules
class ClassWithRemoverAdder {

	@RemoverRule
	public java.util.List<Integer> dataRemoverPublic

	@AdderRule
	public java.util.List<Integer> dataAdderPublic

	@RemoverRule(single=false, multiple=false)
	java.util.List<Integer> dataRemoverBothFalse

	@AdderRule(single=false, multiple=false)
	java.util.List<Integer> dataAdderBothFalse

	@RemoverRule(visibility=Visibility.PRIVATE)
	java.util.List<Integer> dataRemoverGeneratePrivate

	@AdderRule(visibility=Visibility.PRIVATE)
	java.util.List<Integer> dataAdderGeneratePrivate

	@AdderRule
	val dataAdderInferred = 0

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ClassWithRemoverAdder')

			val problemsFieldDataRemoverPublic = (clazz.findDeclaredField("dataRemoverPublic").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataAdderPublic = (clazz.findDeclaredField("dataAdderPublic").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataRemoverBothFalse = (clazz.findDeclaredField("dataRemoverBothFalse").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataAdderBothFalse = (clazz.findDeclaredField("dataAdderBothFalse").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataRemoverGeneratePrivate = (clazz.findDeclaredField("dataRemoverGeneratePrivate").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataAdderGeneratePrivate = (clazz.findDeclaredField("dataAdderGeneratePrivate").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataAdderInferred = (clazz.findDeclaredField("dataAdderInferred").
				primarySourceElement as FieldDeclaration).problems

			assertEquals(1, problemsFieldDataRemoverPublic.size)
			assertEquals(Severity.ERROR, problemsFieldDataRemoverPublic.get(0).severity)
			assertTrue(problemsFieldDataRemoverPublic.get(0).message.contains("public"))

			assertEquals(1, problemsFieldDataAdderPublic.size)
			assertEquals(Severity.ERROR, problemsFieldDataAdderPublic.get(0).severity)
			assertTrue(problemsFieldDataAdderPublic.get(0).message.contains("public"))

			assertEquals(1, problemsFieldDataRemoverBothFalse.size)
			assertEquals(Severity.ERROR, problemsFieldDataRemoverBothFalse.get(0).severity)
			assertTrue(problemsFieldDataRemoverBothFalse.get(0).message.contains("both"))

			assertEquals(1, problemsFieldDataAdderBothFalse.size)
			assertEquals(Severity.ERROR, problemsFieldDataAdderBothFalse.get(0).severity)
			assertTrue(problemsFieldDataAdderBothFalse.get(0).message.contains("both"))

			assertEquals(1, problemsFieldDataRemoverGeneratePrivate.size)
			assertEquals(Severity.ERROR, problemsFieldDataRemoverGeneratePrivate.get(0).severity)
			assertTrue(problemsFieldDataRemoverGeneratePrivate.get(0).message.contains("Only public and"))

			assertEquals(1, problemsFieldDataAdderGeneratePrivate.size)
			assertEquals(Severity.ERROR, problemsFieldDataAdderGeneratePrivate.get(0).severity)
			assertTrue(problemsFieldDataAdderGeneratePrivate.get(0).message.contains("Only public and"))

			assertEquals(1, problemsFieldDataAdderInferred.size)
			assertEquals(Severity.ERROR, problemsFieldDataAdderInferred.get(0).severity)
			assertTrue(problemsFieldDataAdderInferred.get(0).message.contains("inferred"))

			assertEquals(7, allProblems.size)

		]

	}

	@Test
	def void testTraitAdderRemoverOnFieldsWithoutTraitMethod() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule

@TraitClass
@ApplyRules
abstract class TraitClassWithRemoverAdder {

	@AdderRule
	java.util.List<Integer> dataAdderWithoutTraitMethodAnnotation

	@RemoverRule
	java.util.List<Integer> dataRemoverWithoutTraitMethodAnnotation

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.TraitClassWithRemoverAdder')

			val problemsFieldDataAdderWithoutTraitMethodAnnotation = (clazz.findDeclaredField(
				"dataAdderWithoutTraitMethodAnnotation").primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataRemoverWithoutTraitMethodAnnotation = (clazz.findDeclaredField(
				"dataRemoverWithoutTraitMethodAnnotation").primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(1, problemsFieldDataAdderWithoutTraitMethodAnnotation.size)
			assertEquals(Severity.ERROR, problemsFieldDataAdderWithoutTraitMethodAnnotation.get(0).severity)
			assertTrue(problemsFieldDataAdderWithoutTraitMethodAnnotation.get(0).message.contains("trait method"))

			assertEquals(1, problemsFieldDataRemoverWithoutTraitMethodAnnotation.size)
			assertEquals(Severity.ERROR, problemsFieldDataRemoverWithoutTraitMethodAnnotation.get(0).severity)
			assertTrue(problemsFieldDataRemoverWithoutTraitMethodAnnotation.get(0).message.contains("trait method"))

			assertEquals(2, allProblems.size)

		]

	}

	@Test
	def void testTraitAdderRemoverWithErrorsInTraitClass() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod

@TraitClass
@ApplyRules
abstract class TraitClassWithAdderRemover {

	@AdderRule
	@ExclusiveMethod
	static java.util.List<Integer> dataAdderStatic

	@RemoverRule
	@ExclusiveMethod
	static java.util.List<Integer> dataRemoverStatic

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.TraitClassWithAdderRemover')

			val problemsFieldDataAdderStatic = (clazz.findDeclaredField("dataAdderStatic").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataRemoverStatic = (clazz.findDeclaredField("dataRemoverStatic").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(1, problemsFieldDataAdderStatic.size)
			assertEquals(Severity.ERROR, problemsFieldDataAdderStatic.get(0).severity)
			assertTrue(problemsFieldDataAdderStatic.get(0).message.contains("static"))

			assertEquals(1, problemsFieldDataRemoverStatic.size)
			assertEquals(Severity.ERROR, problemsFieldDataRemoverStatic.get(0).severity)
			assertTrue(problemsFieldDataRemoverStatic.get(0).message.contains("static"))

			assertEquals(2, allProblems.size)

		]

	}

	@Test
	def void testFieldNotNullErrorsWithAdderRemover() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.NotNullRule

@ApplyRules
class ClassWithNotNull {

	@NotNullRule(notNullSelf=true, notNullKeyOrElement=true)
	@AdderRule
	java.util.List<String> dataNotNullNoSetter = new java.util.ArrayList<String>

	@NotNullRule(notNullSelf=false, notNullKeyOrElement=true)
	java.util.List<String> dataNotNullNoAdder = new java.util.ArrayList<String>

	@NotNullRule(notNullSelf=false, notNullKeyOrElement=false, notNullValue=true)
	@AdderRule
	java.util.List<String> dataNotNullNotMap = new java.util.ArrayList<String>

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ClassWithNotNull')

			val problemsDataNotNullNoSetter = (clazz.findDeclaredField("dataNotNullNoSetter").
				primarySourceElement as FieldDeclaration).problems
			val problemsDataNotNullNoAdder = (clazz.findDeclaredField("dataNotNullNoAdder").
				primarySourceElement as FieldDeclaration).problems
			val problemsDataNotNullNotMap = (clazz.findDeclaredField("dataNotNullNotMap").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(1, problemsDataNotNullNoSetter.size)
			assertEquals(Severity.ERROR, problemsDataNotNullNoSetter.get(0).severity)
			assertTrue(problemsDataNotNullNoSetter.get(0).message.contains("@SetterRule"))

			assertEquals(1, problemsDataNotNullNoAdder.size)
			assertEquals(Severity.ERROR, problemsDataNotNullNoAdder.get(0).severity)
			assertTrue(problemsDataNotNullNoAdder.get(0).message.contains("@AdderRule"))

			assertEquals(1, problemsDataNotNullNotMap.size)
			assertEquals(Severity.ERROR, problemsDataNotNullNotMap.get(0).severity)
			assertTrue(problemsDataNotNullNotMap.get(0).message.contains("map"))

			assertEquals(3, allProblems.size)

		]

	}

	@Test
	def void testTypeAdaptionWithAdderRemoverGetterSetterWarning() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.SetterRule
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule

@ApplyRules
class ClassWithCollectionGetterSetterAdderRemoverTypeAdaptionBase {

	@AdderRule(single=true, multiple=false)
	@TypeAdaptionRule("apply(java.util.List);addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString))")
	java.util.List<? extends org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase> dataAdderSingleAdapted = new java.util.ArrayList<org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase>

	@AdderRule(single=false, multiple=true)
	@TypeAdaptionRule("apply(java.util.List);addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString))")
	java.util.List<? extends org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase> dataAdderMultipleAdapted = new java.util.ArrayList<org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase>

	@AdderRule(single=true, multiple=false)
	@TypeAdaptionRule("apply(java.util.List);addTypeParamWildcardExtends(apply(java.util.List);addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString)))")
	java.util.List<? extends java.util.List<? extends org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase>> dataAdderSingleSubListAdapted = new java.util.ArrayList<java.util.List<? extends org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase>>

	@RemoverRule(single=true, multiple=false)
	@TypeAdaptionRule("apply(java.util.List);addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString))")
	java.util.List<? extends org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase> dataRemoverSingleAdapted = new java.util.ArrayList<org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase>

	@RemoverRule(single=false, multiple=true)
	@TypeAdaptionRule("apply(java.util.List);addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString))")
	java.util.Set<? extends org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase> dataRemoverMultipleAdapted = new java.util.HashSet<org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase>

	@GetterRule
	@TypeAdaptionRule("apply(java.util.List);addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString))")
	java.util.List<? extends org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase> dataGetterAdapted = new java.util.ArrayList<org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase>

	@SetterRule
	@TypeAdaptionRule("apply(java.util.List);addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString))")
	java.util.List<? extends org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase> dataSetterAdapted = new java.util.ArrayList<org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase>

}

@ApplyRules
class ClassWithCollectionGetterSetterAdderRemoverTypeAdaptionDerived extends ClassWithCollectionGetterSetterAdderRemoverTypeAdaptionBase {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ClassWithCollectionGetterSetterAdderRemoverTypeAdaptionDerived')

			val problemsClass = (clazz.primarySourceElement as ClassDeclaration).problems

			// do assertions
			assertEquals(6, problemsClass.size)
			assertEquals(Severity.WARNING, problemsClass.get(0).severity)
			assertEquals(Severity.WARNING, problemsClass.get(1).severity)
			assertEquals(Severity.WARNING, problemsClass.get(2).severity)
			assertEquals(Severity.WARNING, problemsClass.get(3).severity)
			assertEquals(Severity.WARNING, problemsClass.get(4).severity)
			assertEquals(Severity.WARNING, problemsClass.get(5).severity)
			assertTrue(problemsClass.get(0).message.contains("type arguments"))
			assertTrue(problemsClass.get(1).message.contains("type arguments"))
			assertTrue(problemsClass.get(2).message.contains("type arguments"))
			assertTrue(problemsClass.get(3).message.contains("type arguments"))
			assertTrue(problemsClass.get(4).message.contains("type arguments"))
			assertTrue(problemsClass.get(5).message.contains("type arguments"))

			val messages = problemsClass.map[it.message]
			assertEquals(2, messages.filter[contains("addAllToDataAdderMultipleAdapted")].length)
			assertEquals(2, messages.filter[contains("addToDataAdderSingleSubListAdapted")].length)
			assertEquals(1, messages.filter[contains("removeAllFromDataRemoverMultipleAdapted")].length)
			assertEquals(1, messages.filter[contains("setDataSetterAdapted")].length)

			assertEquals(6, allProblems.size)

		]

	}

	@Test
	def void testTypeAdaptionAlternativeError() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule

@ApplyRules
class ClassWithAlternativeTypeAdaption {

	@GetterRule
	@TypeAdaptionRule("apply(java.util.List);addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString));alternative(apply(java.lang.Integer))")
	java.util.List<? extends org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase> dataGenericListWithGetter = new java.util.ArrayList<org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase>

	@AdderRule
	@TypeAdaptionRule("apply(java.util.List);addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString));alternative(apply(java.lang.Integer))")
	java.util.List<? extends org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase> dataGenericListWithAdder = new java.util.ArrayList<org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase>

	@RemoverRule
	@TypeAdaptionRule("apply(java.util.List);addTypeParamWildcardExtends(apply(org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerAttributeString));alternative(apply(java.lang.Integer))")
	java.util.List<? extends org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase> dataGenericListWithRemover = new java.util.ArrayList<org.eclipse.xtend.lib.annotation.etai.tests.adaption.complex1.ControllerBase>

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.ClassWithAlternativeTypeAdaption')

			val problemsFieldDataGenericListWithGetter = (clazz.findDeclaredField("dataGenericListWithGetter").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataGenericListWithAdder = (clazz.findDeclaredField("dataGenericListWithAdder").
				primarySourceElement as FieldDeclaration).problems
			val problemsFieldDataGenericListWithRemover = (clazz.findDeclaredField("dataGenericListWithRemover").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(0, problemsFieldDataGenericListWithGetter.size)

			assertEquals(1, problemsFieldDataGenericListWithAdder.size)
			assertEquals(Severity.ERROR, problemsFieldDataGenericListWithAdder.get(0).severity)
			assertTrue(problemsFieldDataGenericListWithAdder.get(0).message.contains("must not be used"))

			assertEquals(1, problemsFieldDataGenericListWithRemover.size)
			assertEquals(Severity.ERROR, problemsFieldDataGenericListWithRemover.get(0).severity)
			assertTrue(problemsFieldDataGenericListWithRemover.get(0).message.contains("must not be used"))

			assertEquals(2, allProblems.size)

		]

	}

}
