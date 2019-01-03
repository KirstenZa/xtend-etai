package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import java.util.ArrayList
import java.util.HashSet
import java.util.List
import java.util.Set
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.eclipse.xtend.lib.annotation.etai.tests.adaption.ClassWithAdderRemoverChangeStatic.*
import static org.junit.Assert.*

@ApplyRules
class ClassWithAdderRemoverChangeBasic {

	public int beforeElementAdd = 0
	public int afterElementAdd = 0
	public int beforeAdd = 0
	public int afterAdd = 0
	public int beforeElementRemove = 0
	public int afterElementRemove = 0
	public int beforeRemove = 0
	public int afterRemove = 0

	@AdderRule(multiple=true, beforeAdd="%BeforeAdd", afterAdd="%Added")
	@RemoverRule(multiple=true, beforeRemove="%BeforeRemove", afterRemove="%Removed")
	@GetterRule
	List<Integer> listData = new ArrayList<Integer>

	def void listDataBeforeAdd() {
		beforeAdd++
	}

	def void listDataAdded() {
		afterAdd++
	}

	def void listDataBeforeRemove() {
		beforeRemove++
	}

	def void listDataRemoved() {
		afterRemove++
	}

	@AdderRule(multiple=true, beforeAdd="%BeforeAdd", afterAdd="%Added", beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	@RemoverRule(multiple=true, beforeRemove="%BeforeRemove", afterRemove="%Removed", beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	@GetterRule
	List<Integer> listDataParam = new ArrayList<Integer>

	protected def void listDataParamBeforeElementAdd(Integer addedValue) {
		beforeElementAdd++
	}

	private def void listDataParamElementAdded(Integer addedValue) {
		afterElementAdd++
		assertTrue(addedValue >= 20 || addedValue <= 30)
	}

	def void listDataParamBeforeAdd(List<Integer> addedValues) {
		assertTrue(addedValues.size > 0)
		var int curValue = 20
		for (addedValue : addedValues)
			assertEquals(curValue++, addedValue)
		beforeAdd++
	}

	def void listDataParamAdded(List<Integer> addedValues) {
		assertTrue(addedValues.size > 0)
		var int curValue = 20
		for (addedValue : addedValues)
			assertEquals(curValue++, addedValue)
		afterAdd++
	}

	protected def void listDataParamBeforeElementRemove(Integer removedValue) {
		beforeElementRemove++
	}

	private def void listDataParamElementRemoved(Integer removedValue) {
		afterElementRemove++
		assertTrue(removedValue >= 20 || removedValue <= 30)
	}

	def boolean listDataParamBeforeRemove(List<Integer> removedValues) {
		beforeRemove++
		if (removedValues.size == 2)
			return removedValues.get(0) == 21 && removedValues.get(1) == 21
		else if (removedValues.size == 4)
			return removedValues.get(0) == 20 && removedValues.get(1) == 20 && removedValues.get(2) == 20 &&
				removedValues.get(3) == 20
		return false
	}

	def void listDataParamRemoved(List<Integer> removedValues) {
		if (removedValues.size == 2)
			assertEquals(#[21, 21], removedValues)
		else
			assertEquals(#[20, 20, 20, 20], removedValues)
		afterRemove++
	}

	@AdderRule(multiple=true, beforeAdd="%BeforeAdd", afterAdd="%Added", beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	@RemoverRule(multiple=true, beforeRemove="%BeforeRemove", afterRemove="%Removed", beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	@GetterRule
	List<Integer> listDataParamIndex = new ArrayList<Integer>

	protected def boolean listDataParamIndexBeforeElementAdd(int index, Integer addedValue) {
		beforeElementAdd++
		return index <= 6 && addedValue < 30
	}

	private def void listDataParamIndexElementAdded(int index, Integer addedValue) {
		afterElementAdd++
		assertTrue(addedValue == index + 10)
	}

	def boolean listDataParamIndexBeforeAdd(List<Integer> indices, List<Integer> addedValues) {
		beforeAdd++
		return !(indices.size == 2 && indices.get(0) == 2 && indices.get(1) == 3 && addedValues.size == 2 &&
			addedValues.get(0) == 12 && addedValues.get(1) == 13)
	}

	def void listDataParamIndexAdded(List<Integer> indices, List<Integer> addedValues) {
		afterAdd++
		if (indices.size == 3 && indices.get(0) == 2 && indices.get(1) == 3 && indices.get(2) == 4 &&
			addedValues.size == 3 && addedValues.get(0) == 12 && addedValues.get(1) == 13 && addedValues.get(2) == 14)
			afterAdd += 1000
	}

	protected def boolean listDataParamIndexBeforeElementRemove(int index, Integer removedValue) {
		beforeElementRemove++
		return index != 0 && removedValue != 11
	}

	private def void listDataParamIndexElementRemoved(int index, Integer removedValue) {
		afterElementRemove++
		assertTrue(removedValue == index + 10)
		assertTrue(removedValue >= 12 || removedValue <= 15)
	}

	def boolean listDataParamIndexBeforeRemove(List<Integer> indices, List<Integer> removedValues) {
		beforeRemove++
		return !(indices.size == 2 && indices.get(0) == 2 && indices.get(1) == 3 && removedValues.size == 2 &&
			removedValues.get(0) == 12 && removedValues.get(1) == 13)
	}

	def void listDataParamIndexRemoved(List<Integer> indices, List<Integer> removedValues) {
		afterRemove++
		if (indices.size == 3 && indices.get(0) == 2 && indices.get(1) == 3 && indices.get(2) == 4 &&
			removedValues.size == 3 && removedValues.get(0) == 12 && removedValues.get(1) == 13 &&
			removedValues.get(2) == 14)
			afterRemove += 1000
	}

	@AdderRule(multiple=true, beforeAdd="%BeforeAdd", afterAdd="%Added", beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	@RemoverRule(multiple=true, beforeRemove="%BeforeRemove", afterRemove="%Removed", beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	@GetterRule
	Set<Integer> setDataParam = new HashSet<Integer>

	protected def boolean setDataParamBeforeElementAdd(Integer addedValue) {
		beforeElementAdd++
		return addedValue < 30
	}

	private def void setDataParamElementAdded(Integer addedValue) {
		afterElementAdd++
		assertTrue(addedValue > 9)
	}

	def boolean setDataParamBeforeAdd(List<Integer> addedValues) {
		beforeAdd++
		return !(addedValues.size == 2 && addedValues.contains(12) && addedValues.contains(13))
	}

	def void setDataParamAdded(List<Integer> addedValues) {
		afterAdd++
		if (addedValues.size == 3 && addedValues.contains(12) && addedValues.contains(13) && addedValues.contains(14))
			afterAdd += 1000
	}

	// this method should not cause a problem
	def void setDataParamAdded(Set<Integer> addedValues) {
	}

	protected def boolean setDataParamBeforeElementRemove(Integer removedValue) {
		beforeElementRemove++
		return removedValue != 18
	}

	private def void setDataParamElementRemoved(Integer removedValue) {
		afterElementRemove++
		assertTrue(removedValue >= 11 || removedValue <= 17)
	}

	def void setDataParamBeforeRemove(List<Integer> removedValues) {
		beforeRemove++
		assertTrue(removedValues.size > 0)
	}

	private def void setDataParamRemoved(List<Integer> removedValues) {
		afterRemove++
		assertTrue(removedValues.size > 0)
		if (removedValues.size == 2) {
			assertTrue(removedValues.contains(12))
			assertTrue(removedValues.contains(13))
		}

	}

	// this method should not cause a problem
	def void setDataParamRemoved(Set<Integer> addedValues) {
	}

}

// This is and shall be a modified copy of ClassWithAdderRemoverChange in which
// each event method is called with field name in addition
@ApplyRules
class ClassWithAdderRemoverChangeWithName {

	public int beforeElementAdd = 0
	public int afterElementAdd = 0
	public int beforeAdd = 0
	public int afterAdd = 0
	public int beforeElementRemove = 0
	public int afterElementRemove = 0
	public int beforeRemove = 0
	public int afterRemove = 0

	@AdderRule(multiple=true, beforeAdd="%BeforeAdd", afterAdd="%Added", beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	@RemoverRule(multiple=true, beforeRemove="%BeforeRemove", afterRemove="%Removed", beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	@GetterRule
	List<Integer> listDataParam = new ArrayList<Integer>

	protected def void listDataParamBeforeElementAdd(String fieldName, Integer addedValue) {
		assertEquals("listDataParam", fieldName)
		beforeElementAdd++
	}

	private def void listDataParamElementAdded(String fieldName, Integer addedValue) {
		assertEquals("listDataParam", fieldName)
		afterElementAdd++
		assertTrue(addedValue >= 20 || addedValue <= 30)
	}

	def void listDataParamBeforeAdd(String fieldName, List<Integer> addedValues) {
		assertEquals("listDataParam", fieldName)
		assertTrue(addedValues.size > 0)
		var int curValue = 20
		for (addedValue : addedValues)
			assertEquals(curValue++, addedValue)
		beforeAdd++
	}

	def void listDataParamAdded(String fieldName, List<Integer> addedValues) {
		assertEquals("listDataParam", fieldName)
		assertTrue(addedValues.size > 0)
		var int curValue = 20
		for (addedValue : addedValues)
			assertEquals(curValue++, addedValue)
		afterAdd++
	}

	protected def void listDataParamBeforeElementRemove(String fieldName, Integer removedValue) {
		assertEquals("listDataParam", fieldName)
		beforeElementRemove++
	}

	private def void listDataParamElementRemoved(String fieldName, Integer removedValue) {
		assertEquals("listDataParam", fieldName)
		afterElementRemove++
		assertTrue(removedValue >= 20 || removedValue <= 30)
	}

	def boolean listDataParamBeforeRemove(String fieldName, List<Integer> removedValues) {
		assertEquals("listDataParam", fieldName)
		beforeRemove++
		if (removedValues.size == 2)
			return removedValues.get(0) == 21 && removedValues.get(1) == 21
		else if (removedValues.size == 4)
			return removedValues.get(0) == 20 && removedValues.get(1) == 20 && removedValues.get(2) == 20 &&
				removedValues.get(3) == 20
		return false
	}

	def void listDataParamRemoved(String fieldName, List<Integer> removedValues) {
		assertEquals("listDataParam", fieldName)
		if (removedValues.size == 2)
			assertEquals(#[21, 21], removedValues)
		else
			assertEquals(#[20, 20, 20, 20], removedValues)
		afterRemove++
	}

	@AdderRule(multiple=true, beforeAdd="%BeforeAdd", afterAdd="%Added", beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	@RemoverRule(multiple=true, beforeRemove="%BeforeRemove", afterRemove="%Removed", beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	@GetterRule
	List<Integer> listDataParamIndex = new ArrayList<Integer>

	protected def boolean listDataParamIndexBeforeElementAdd(String fieldName, int index, Integer addedValue) {
		assertEquals("listDataParamIndex", fieldName)
		beforeElementAdd++
		return index <= 6 && addedValue < 30
	}

	private def void listDataParamIndexElementAdded(String fieldName, int index, Integer addedValue) {
		assertEquals("listDataParamIndex", fieldName)
		afterElementAdd++
		assertTrue(addedValue == index + 10)
	}

	def boolean listDataParamIndexBeforeAdd(String fieldName, List<Integer> indices, List<Integer> addedValues) {
		assertEquals("listDataParamIndex", fieldName)
		beforeAdd++
		return !(indices.size == 2 && indices.get(0) == 2 && indices.get(1) == 3 && addedValues.size == 2 &&
			addedValues.get(0) == 12 && addedValues.get(1) == 13)
	}

	def void listDataParamIndexAdded(String fieldName, List<Integer> indices, List<Integer> addedValues) {
		assertEquals("listDataParamIndex", fieldName)
		afterAdd++
		if (indices.size == 3 && indices.get(0) == 2 && indices.get(1) == 3 && indices.get(2) == 4 &&
			addedValues.size == 3 && addedValues.get(0) == 12 && addedValues.get(1) == 13 && addedValues.get(2) == 14)
			afterAdd += 1000
	}

	protected def boolean listDataParamIndexBeforeElementRemove(String fieldName, int index, Integer removedValue) {
		assertEquals("listDataParamIndex", fieldName)
		beforeElementRemove++
		return index != 0 && removedValue != 11
	}

	private def void listDataParamIndexElementRemoved(String fieldName, int index, Integer removedValue) {
		assertEquals("listDataParamIndex", fieldName)
		afterElementRemove++
		assertTrue(removedValue == index + 10)
		assertTrue(removedValue >= 12 || removedValue <= 15)
	}

	def boolean listDataParamIndexBeforeRemove(String fieldName, List<Integer> indices, List<Integer> removedValues) {
		assertEquals("listDataParamIndex", fieldName)
		beforeRemove++
		return !(indices.size == 2 && indices.get(0) == 2 && indices.get(1) == 3 && removedValues.size == 2 &&
			removedValues.get(0) == 12 && removedValues.get(1) == 13)
	}

	def void listDataParamIndexRemoved(String fieldName, List<Integer> indices, List<Integer> removedValues) {
		assertEquals("listDataParamIndex", fieldName)
		afterRemove++
		if (indices.size == 3 && indices.get(0) == 2 && indices.get(1) == 3 && indices.get(2) == 4 &&
			removedValues.size == 3 && removedValues.get(0) == 12 && removedValues.get(1) == 13 &&
			removedValues.get(2) == 14)
			afterRemove += 1000
	}

	@AdderRule(multiple=true, beforeAdd="%BeforeAdd", afterAdd="%Added", beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	@RemoverRule(multiple=true, beforeRemove="%BeforeRemove", afterRemove="%Removed", beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	@GetterRule
	Set<Integer> setDataParam = new HashSet<Integer>

	protected def boolean setDataParamBeforeElementAdd(String fieldName, Integer addedValue) {
		assertEquals("setDataParam", fieldName)
		beforeElementAdd++
		return addedValue < 30
	}

	private def void setDataParamElementAdded(String fieldName, Integer addedValue) {
		assertEquals("setDataParam", fieldName)
		afterElementAdd++
		assertTrue(addedValue > 9)
	}

	def boolean setDataParamBeforeAdd(String fieldName, List<Integer> addedValues) {
		assertEquals("setDataParam", fieldName)
		beforeAdd++
		return !(addedValues.size == 2 && addedValues.contains(12) && addedValues.contains(13))
	}

	def void setDataParamAdded(String fieldName, List<Integer> addedValues) {
		assertEquals("setDataParam", fieldName)
		afterAdd++
		if (addedValues.size == 3 && addedValues.contains(12) && addedValues.contains(13) && addedValues.contains(14))
			afterAdd += 1000
	}

	// this method should not cause a problem
	def void setDataParamAdded(String fieldName, Set<Integer> addedValues) {
	}

	protected def boolean setDataParamBeforeElementRemove(String fieldName, Integer removedValue) {
		assertEquals("setDataParam", fieldName)
		beforeElementRemove++
		return removedValue != 18
	}

	private def void setDataParamElementRemoved(String fieldName, Integer removedValue) {
		assertEquals("setDataParam", fieldName)
		afterElementRemove++
		assertTrue(removedValue >= 11 || removedValue <= 17)
	}

	def void setDataParamBeforeRemove(String fieldName, List<Integer> removedValues) {
		assertEquals("setDataParam", fieldName)
		beforeRemove++
		assertTrue(removedValues.size > 0)
	}

	private def void setDataParamRemoved(String fieldName, List<Integer> removedValues) {
		assertEquals("setDataParam", fieldName)
		afterRemove++
		assertTrue(removedValues.size > 0)
		if (removedValues.size == 2) {
			assertTrue(removedValues.contains(12))
			assertTrue(removedValues.contains(13))
		}

	}

	// this method should not cause a problem
	def void setDataParamRemoved(String fieldName, Set<Integer> addedValues) {
	}

}

@ApplyRules
class ClassWithAdderRemoverChangeMultiUse {

	public int beforeElementAdd = 0
	public int afterElementAdd = 0
	public int beforeAdd = 0
	public int afterAdd = 0
	public int beforeElementRemove = 0
	public int afterElementRemove = 0
	public int beforeRemove = 0
	public int afterRemove = 0

	@AdderRule(multiple=true, beforeAdd="beforeAddMultiUse", afterAdd="afterAddMultiUse", beforeElementAdd="beforeElementAddMultiUse", afterElementAdd="afterElementAddMultiUse")
	@RemoverRule(multiple=true, beforeRemove="beforeRemoveMultiUse", afterRemove="afterRemoveMultiUse", beforeElementRemove="beforeElementRemoveMultiUse", afterElementRemove="afterElementRemoveMultiUse")
	@GetterRule
	List<List<String>> listData1 = new ArrayList<List<String>>

	@AdderRule(multiple=true, beforeAdd="beforeAddMultiUse", afterAdd="afterAddMultiUse", beforeElementAdd="beforeElementAddMultiUse", afterElementAdd="afterElementAddMultiUse")
	@RemoverRule(multiple=true, beforeRemove="beforeRemoveMultiUse", afterRemove="afterRemoveMultiUse", beforeElementRemove="beforeElementRemoveMultiUse", afterElementRemove="afterElementRemoveMultiUse")
	@GetterRule
	List<List<String>> listData2 = new ArrayList<List<String>>

	protected def void beforeAddMultiUse(List<List<String>> elements) {
		beforeAdd++
	}

	protected def void afterAddMultiUse(List<List<String>> elements) {
		afterAdd++
	}

	protected def void beforeElementAddMultiUse(String fieldName, List<String> element) {
		if (fieldName == "listData1")
			beforeElementAdd++
		else if (fieldName == "listData2")
			beforeElementAdd += 1000
	}

	protected def void afterElementAddMultiUse(List<String> element) {
		afterElementAdd++
	}

	protected def void beforeRemoveMultiUse(List<List<String>> elements) {
		beforeRemove++
	}

	protected def void afterRemoveMultiUse(List<List<String>> elements) {
		afterRemove++
	}

	protected def void beforeElementRemoveMultiUse(List<String> element) {
		beforeElementRemove++
	}

	protected def void afterElementRemoveMultiUse(List<String> element) {
		afterElementRemove++
	}

}

@ApplyRules
class ClassWithAdderRemoverChangeStatic {

	public static int beforeElementAdd = 0
	public static int afterElementAdd = 0
	public static int beforeAdd = 0
	public static int afterAdd = 0
	public static int beforeElementRemove = 0
	public static int afterElementRemove = 0
	public static int beforeRemove = 0
	public static int afterRemove = 0

	@AdderRule(multiple=true, beforeAdd="%BeforeAdd", afterAdd="%Added", beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	@RemoverRule(multiple=true, beforeRemove="%BeforeRemove", afterRemove="%Removed", beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	@GetterRule
	static List<Integer> listDataParamStatic = new ArrayList<Integer>

	static protected def void listDataParamStaticBeforeElementAdd(Integer addedValue) {
		beforeElementAdd++
	}

	static private def void listDataParamStaticElementAdded(String fieldname, Integer addedValue) {
		afterElementAdd++
		assertEquals("listDataParamStatic", fieldname)
		assertTrue(addedValue >= 20 || addedValue <= 30)
	}

	static def void listDataParamStaticBeforeAdd(List<Integer> addedValues) {
		assertTrue(addedValues.size > 0)
		var int curValue = 20
		for (addedValue : addedValues)
			assertEquals(curValue++, addedValue)
		beforeAdd++
	}

	static def void listDataParamStaticAdded(List<Integer> addedValues) {
		assertTrue(addedValues.size > 0)
		var int curValue = 20
		for (addedValue : addedValues)
			assertEquals(curValue++, addedValue)
		afterAdd++
	}

	static protected def void listDataParamStaticBeforeElementRemove(Integer removedValue) {
		beforeElementRemove++
	}

	static private def void listDataParamStaticElementRemoved(Integer removedValue) {
		afterElementRemove++
		assertTrue(removedValue >= 20 || removedValue <= 30)
	}

	static def boolean listDataParamStaticBeforeRemove(List<Integer> removedValues) {
		beforeRemove++
		if (removedValues.size == 2)
			return removedValues.get(0) == 21 && removedValues.get(1) == 21
		else if (removedValues.size == 4)
			return removedValues.get(0) == 20 && removedValues.get(1) == 20 && removedValues.get(2) == 20 &&
				removedValues.get(3) == 20
		return false
	}

	static def void listDataParamStaticRemoved(List<Integer> removedValues) {
		if (removedValues.size == 2)
			assertEquals(#[21, 21], removedValues)
		else
			assertEquals(#[20, 20, 20, 20], removedValues)
		afterRemove++
	}

	@AdderRule(multiple=true, beforeAdd="%BeforeAdd", afterAdd="%Added", beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	@RemoverRule(multiple=true, beforeRemove="%BeforeRemove", afterRemove="%Removed", beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	@GetterRule
	List<String> listDataParamNonStaticCallStatic = new ArrayList<String>

	static def boolean listDataParamNonStaticCallStaticBeforeElementAdd(String element) {
		beforeElementAdd++
		return true
	}

	static def void listDataParamNonStaticCallStaticBeforeAdd(List<String> elements) {
		beforeAdd++
	}

	static def void listDataParamNonStaticCallStaticElementAdded(String element) {
		afterElementAdd++
	}

	static def void listDataParamNonStaticCallStaticAdded() {
		afterAdd++
	}

	def void listDataParamNonStaticCallStaticBeforeElementRemove(String element) {
		beforeElementRemove++
	}

	private def void listDataParamNonStaticCallStaticBeforeRemove() {
		beforeRemove++
	}

	static def void listDataParamNonStaticCallStaticElementRemoved(String element) {
		afterElementRemove++
	}

	static def void listDataParamNonStaticCallStaticRemoved() {
		afterRemove++
	}

}

@ApplyRules
class ClassWithAdderRemoverChangeIndices {

	public Set<String> doNotAdd = new HashSet<String>
	public Set<String> doNotRemove = new HashSet<String>
	public List<String> expectedElements = null
	public List<Integer> expectedIndices = null

	@AdderRule(multiple=true, beforeElementAdd="%BeforeElementAdd", afterAdd="%Added")
	@RemoverRule(multiple=true, beforeElementRemove="%BeforeElementRemove", afterRemove="%Removed")
	@GetterRule
	List<String> listData = new ArrayList<String>

	def boolean listDataBeforeElementAdd(String element) {
		return !doNotAdd.contains(element)
	}

	def void listDataAdded(List<Integer> indices, List<String> elements) {
		if (expectedElements !== null)
			assertEquals(expectedElements, elements)
		if (expectedIndices !== null)
			assertEquals(expectedIndices, indices)
	}

	def boolean listDataBeforeElementRemove(String element) {
		return !doNotRemove.contains(element)
	}

	def void listDataRemoved(List<Integer> indices, List<String> elements) {
		if (expectedElements !== null)
			assertEquals(expectedElements, elements)
		if (expectedIndices !== null)
			assertEquals(expectedIndices, indices)
	}

}

@ApplyRules
class ClassWithAdderRemoverNoConcurrent {

	@AdderRule(multiple=true, afterAdd="%Added")
	@RemoverRule(multiple=true, afterRemove="%Removed")
	@GetterRule
	List<Integer> listData = new ArrayList<Integer>

	protected def void listDataAdded() {
		if (addToListData(8))
			listData.add(99)
		else
			listData.add(100)
	}

	protected def void listDataRemoved() {
		assertFalse(removeFromListData(0))
	}

}

@ApplyRules
class ClassWithAdderRemoverChangeWithOldNewList {

	public int beforeElementAdd = 0
	public int afterElementAdd = 0
	public int beforeAdd = 0
	public int afterAdd = 0
	public int beforeElementRemove = 0
	public int afterElementRemove = 0
	public int beforeRemove = 0
	public int afterRemove = 0

	public List<Object> expectedOldElements = null
	public List<Object> expectedNewElements = null
	public List<Integer> expectedIndices = null
	public Object notAllowed = null

	@AdderRule(multiple=true, beforeAdd="%BeforeAdd", afterAdd="%Added", beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	@RemoverRule(multiple=true, beforeRemove="%BeforeRemove", afterRemove="%Removed", beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	@GetterRule
	List<Integer> listDataJustOldNew = new ArrayList<Integer>

	def boolean listDataJustOldNewBeforeAdd(List<Integer> oldElements, List<Integer> indices, List<Integer> elements) {
		beforeAdd++
		assertEquals(expectedOldElements, oldElements)
		assertEquals(expectedIndices, indices)
		return elements.size() <= 2
	}

	def void listDataJustOldNewAdded(List<Integer> oldElements, List<Integer> newElements, List<Integer> indices,
		List<Integer> elements) {
		afterAdd++
		assertEquals(expectedOldElements, oldElements)
		assertEquals(expectedNewElements, newElements)
		assertEquals(expectedIndices, indices)
	}

	def boolean listDataJustOldNewBeforeElementAdd(List<Integer> oldElements, int index, Integer element) {
		beforeElementAdd++
		assertEquals(expectedOldElements, oldElements)
		if (notAllowed === null || !element.equals(notAllowed))
			assertTrue(expectedIndices.contains(index))
		return notAllowed === null || !element.equals(notAllowed)
	}

	def void listDataJustOldNewElementAdded(List<Integer> oldElements, List<Integer> newElements, int index,
		Integer element) {
		afterElementAdd++
		assertEquals(expectedOldElements, oldElements)
		assertEquals(expectedNewElements, newElements)
		assertTrue(expectedIndices.contains(index))
	}

	def boolean listDataJustOldNewBeforeRemove(List<Integer> oldElements, List<Integer> indices,
		List<Integer> elements) {
		beforeRemove++
		assertEquals(expectedOldElements, oldElements)
		assertEquals(expectedIndices, indices)
		return elements.size() <= 2
	}

	def void listDataJustOldNewRemoved(List<Integer> oldElements, List<Integer> newElements, List<Integer> indices,
		List<Integer> elements) {
		afterRemove++
		assertEquals(expectedOldElements, oldElements)
		assertEquals(expectedNewElements, newElements)
		assertEquals(expectedIndices, indices)
	}

	def boolean listDataJustOldNewBeforeElementRemove(List<Integer> oldElements, int index, Integer element) {
		beforeElementRemove++
		assertEquals(expectedOldElements, oldElements)
		if (notAllowed === null || !element.equals(notAllowed))
			assertTrue(expectedIndices.contains(index))
		return notAllowed === null || !element.equals(notAllowed)
	}

	def void listDataJustOldNewElementRemoved(List<Integer> oldElements, List<Integer> newElements, int index,
		Integer element) {
		afterElementRemove++
		assertEquals(expectedOldElements, oldElements)
		assertEquals(expectedNewElements, newElements)
		assertTrue(expectedIndices.contains(index))
	}

// TODO: obiges funktioniert nur mit index, tests?
}

@ApplyRules
class ClassWithAdderRemoverChangeWithOldNewListAndFieldName {

	public int beforeElementAdd = 0
	public int afterElementAdd = 0
	public int beforeAdd = 0
	public int afterAdd = 0
	public int beforeElementRemove = 0
	public int afterElementRemove = 0
	public int beforeRemove = 0
	public int afterRemove = 0

	public List<Object> expectedOldElements = null
	public List<Object> expectedNewElements = null
	public List<Integer> expectedIndices = null
	public Object notAllowed = null

	@AdderRule(multiple=true, beforeAdd="%BeforeAdd", afterAdd="%Added", beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	@RemoverRule(multiple=true, beforeRemove="%BeforeRemove", afterRemove="%Removed", beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	@GetterRule
	List<Integer> listDataJustOldNew = new ArrayList<Integer>

	def boolean listDataJustOldNewBeforeAdd(String fieldName, List<Integer> oldElements, List<Integer> indices,
		List<Integer> elements) {
		assertEquals("listDataJustOldNew", fieldName)
		beforeAdd++
		assertEquals(expectedOldElements, oldElements)
		assertEquals(expectedIndices, indices)
		return elements.size() <= 2
	}

	def void listDataJustOldNewAdded(String fieldName, List<Integer> oldElements, List<Integer> newElements,
		List<Integer> indices, List<Integer> elements) {
		assertEquals("listDataJustOldNew", fieldName)
		afterAdd++
		assertEquals(expectedOldElements, oldElements)
		assertEquals(expectedNewElements, newElements)
		assertEquals(expectedIndices, indices)
	}

	def boolean listDataJustOldNewBeforeElementAdd(String fieldName, List<Integer> oldElements, int index,
		Integer element) {
		assertEquals("listDataJustOldNew", fieldName)
		beforeElementAdd++
		assertEquals(expectedOldElements, oldElements)
		if (notAllowed === null || !element.equals(notAllowed))
			assertTrue(expectedIndices.contains(index))
		return notAllowed === null || !element.equals(notAllowed)
	}

	def void listDataJustOldNewElementAdded(String fieldName, List<Integer> oldElements, List<Integer> newElements,
		int index, Integer element) {
		assertEquals("listDataJustOldNew", fieldName)
		afterElementAdd++
		assertEquals(expectedOldElements, oldElements)
		assertEquals(expectedNewElements, newElements)
		assertTrue(expectedIndices.contains(index))
	}

	def boolean listDataJustOldNewBeforeRemove(String fieldName, List<Integer> oldElements, List<Integer> indices,
		List<Integer> elements) {
		assertEquals("listDataJustOldNew", fieldName)
		beforeRemove++
		assertEquals(expectedOldElements, oldElements)
		assertEquals(expectedIndices, indices)
		return elements.size() <= 2
	}

	def void listDataJustOldNewRemoved(String fieldName, List<Integer> oldElements, List<Integer> newElements,
		List<Integer> indices, List<Integer> elements) {
		assertEquals("listDataJustOldNew", fieldName)
		afterRemove++
		assertEquals(expectedOldElements, oldElements)
		assertEquals(expectedNewElements, newElements)
		assertEquals(expectedIndices, indices)
	}

	def boolean listDataJustOldNewBeforeElementRemove(String fieldName, List<Integer> oldElements, int index,
		Integer element) {
		assertEquals("listDataJustOldNew", fieldName)
		beforeElementRemove++
		assertEquals(expectedOldElements, oldElements)
		if (notAllowed === null || !element.equals(notAllowed))
			assertTrue(expectedIndices.contains(index))
		return notAllowed === null || !element.equals(notAllowed)
	}

	def void listDataJustOldNewElementRemoved(String fieldName, List<Integer> oldElements, List<Integer> newElements,
		int index, Integer element) {
		assertEquals("listDataJustOldNew", fieldName)
		afterElementRemove++
		assertEquals(expectedOldElements, oldElements)
		assertEquals(expectedNewElements, newElements)
		assertTrue(expectedIndices.contains(index))
	}

}

@ApplyRules
class ClassWithAdderRemoverChangeWithOldNewSet {

	public int beforeElementAdd = 0
	public int afterElementAdd = 0
	public int beforeAdd = 0
	public int afterAdd = 0
	public int beforeElementRemove = 0
	public int afterElementRemove = 0
	public int beforeRemove = 0
	public int afterRemove = 0

	public List<Object> expectedOldElements = null
	public List<Object> expectedNewElements = null
	public Object notAllowed = null

	@AdderRule(multiple=true, beforeAdd="%BeforeAdd", afterAdd="%Added", beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	@RemoverRule(multiple=true, beforeRemove="%BeforeRemove", afterRemove="%Removed", beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	@GetterRule
	Set<Integer> setDataJustOldNew = new HashSet<Integer>

	def boolean setDataJustOldNewBeforeAdd(List<Integer> oldElements, List<Integer> elements) {
		beforeAdd++
		assertEquals(new HashSet<Object>(expectedOldElements), new HashSet<Object>(oldElements))
		return elements.size() <= 2
	}

	def void setDataJustOldNewAdded(List<Integer> oldElements, List<Integer> newElements, List<Integer> elements) {
		afterAdd++
		assertEquals(new HashSet<Object>(expectedOldElements), new HashSet<Object>(oldElements))
		assertEquals(new HashSet<Object>(expectedNewElements), new HashSet<Object>(newElements))
	}

	def boolean setDataJustOldNewBeforeElementAdd(List<Integer> oldElements, Integer element) {
		beforeElementAdd++
		assertEquals(new HashSet<Object>(expectedOldElements), new HashSet<Object>(oldElements))
		return notAllowed === null || !element.equals(notAllowed)
	}

	def void setDataJustOldNewElementAdded(List<Integer> oldElements, List<Integer> newElements, Integer element) {
		afterElementAdd++
		assertEquals(new HashSet<Object>(expectedOldElements), new HashSet<Object>(oldElements))
		assertEquals(new HashSet<Object>(expectedNewElements), new HashSet<Object>(newElements))
	}

	def boolean setDataJustOldNewBeforeRemove(List<Integer> oldElements, List<Integer> elements) {
		beforeRemove++
		assertEquals(new HashSet<Object>(expectedOldElements), new HashSet<Object>(oldElements))
		return elements.size() <= 2
	}

	def void setDataJustOldNewRemoved(List<Integer> oldElements, List<Integer> newElements, List<Integer> elements) {
		afterRemove++
		assertEquals(new HashSet<Object>(expectedOldElements), new HashSet<Object>(oldElements))
		assertEquals(new HashSet<Object>(expectedNewElements), new HashSet<Object>(newElements))
	}

	def boolean setDataJustOldNewBeforeElementRemove(List<Integer> oldElements, Integer element) {
		beforeElementRemove++
		assertEquals(new HashSet<Object>(expectedOldElements), new HashSet<Object>(oldElements))
		return notAllowed === null || !element.equals(notAllowed)
	}

	def void setDataJustOldNewElementRemoved(List<Integer> oldElements, List<Integer> newElements, Integer element) {
		afterElementRemove++
		assertEquals(new HashSet<Object>(expectedOldElements), new HashSet<Object>(oldElements))
		assertEquals(new HashSet<Object>(expectedNewElements), new HashSet<Object>(newElements))
	}

}

@ApplyRules
class ClassWithAdderRemoverChangeWithOldNewSetAndFieldName {

	public int beforeElementAdd = 0
	public int afterElementAdd = 0
	public int beforeAdd = 0
	public int afterAdd = 0
	public int beforeElementRemove = 0
	public int afterElementRemove = 0
	public int beforeRemove = 0
	public int afterRemove = 0

	public List<Object> expectedOldElements = null
	public List<Object> expectedNewElements = null
	public Object notAllowed = null

	@AdderRule(multiple=true, beforeAdd="%BeforeAdd", afterAdd="%Added", beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	@RemoverRule(multiple=true, beforeRemove="%BeforeRemove", afterRemove="%Removed", beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	@GetterRule
	Set<Integer> setDataJustOldNew = new HashSet<Integer>

	def boolean setDataJustOldNewBeforeAdd(String fieldName, List<Integer> oldElements, List<Integer> elements) {
		assertEquals("setDataJustOldNew", fieldName)
		beforeAdd++
		assertEquals(new HashSet<Object>(expectedOldElements), new HashSet<Object>(oldElements))
		return elements.size() <= 2
	}

	def void setDataJustOldNewAdded(String fieldName, List<Integer> oldElements, List<Integer> newElements,
		List<Integer> elements) {
		assertEquals("setDataJustOldNew", fieldName)
		afterAdd++
		assertEquals(new HashSet<Object>(expectedOldElements), new HashSet<Object>(oldElements))
		assertEquals(new HashSet<Object>(expectedNewElements), new HashSet<Object>(newElements))
	}

	def boolean setDataJustOldNewBeforeElementAdd(String fieldName, List<Integer> oldElements, Integer element) {
		assertEquals("setDataJustOldNew", fieldName)
		beforeElementAdd++
		assertEquals(new HashSet<Object>(expectedOldElements), new HashSet<Object>(oldElements))
		return notAllowed === null || !element.equals(notAllowed)
	}

	def void setDataJustOldNewElementAdded(String fieldName, List<Integer> oldElements, List<Integer> newElements,
		Integer element) {
		assertEquals("setDataJustOldNew", fieldName)
		afterElementAdd++
		assertEquals(new HashSet<Object>(expectedOldElements), new HashSet<Object>(oldElements))
		assertEquals(new HashSet<Object>(expectedNewElements), new HashSet<Object>(newElements))
	}

	def boolean setDataJustOldNewBeforeRemove(String fieldName, List<Integer> oldElements, List<Integer> elements) {
		assertEquals("setDataJustOldNew", fieldName)
		beforeRemove++
		assertEquals(new HashSet<Object>(expectedOldElements), new HashSet<Object>(oldElements))
		return elements.size() <= 2
	}

	def void setDataJustOldNewRemoved(String fieldName, List<Integer> oldElements, List<Integer> newElements,
		List<Integer> elements) {
		assertEquals("setDataJustOldNew", fieldName)
		afterRemove++
		assertEquals(new HashSet<Object>(expectedOldElements), new HashSet<Object>(oldElements))
		assertEquals(new HashSet<Object>(expectedNewElements), new HashSet<Object>(newElements))
	}

	def boolean setDataJustOldNewBeforeElementRemove(String fieldName, List<Integer> oldElements, Integer element) {
		assertEquals("setDataJustOldNew", fieldName)
		beforeElementRemove++
		assertEquals(new HashSet<Object>(expectedOldElements), new HashSet<Object>(oldElements))
		return notAllowed === null || !element.equals(notAllowed)
	}

	def void setDataJustOldNewElementRemoved(String fieldName, List<Integer> oldElements, List<Integer> newElements,
		Integer element) {
		assertEquals("setDataJustOldNew", fieldName)
		afterElementRemove++
		assertEquals(new HashSet<Object>(expectedOldElements), new HashSet<Object>(oldElements))
		assertEquals(new HashSet<Object>(expectedNewElements), new HashSet<Object>(newElements))
	}

}

class AdderRemoverChangeTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testListChangeNoParams() {

		val obj = new ClassWithAdderRemoverChangeBasic

		assertTrue(obj.addAllToListData(#[21, 10, 22]))
		assertArrayEquals(#[21, 10, 22], obj.listData)
		assertTrue(obj.addAllToListData(1, #[25, 10, 25, 26]))
		assertArrayEquals(#[21, 25, 10, 25, 26, 10, 22], obj.listData)
		assertTrue(obj.addToListData(20))
		assertArrayEquals(#[21, 25, 10, 25, 26, 10, 22, 20], obj.listData)
		assertTrue(obj.addToListData(1, 11))
		assertArrayEquals(#[21, 11, 25, 10, 25, 26, 10, 22, 20], obj.listData)
		assertTrue(obj.addAllToListData(#[30, 30, 30]))
		assertArrayEquals(#[21, 11, 25, 10, 25, 26, 10, 22, 20, 30, 30, 30], obj.listData)

		assertTrue(obj.removeFromListData(0))
		assertArrayEquals(#[11, 25, 10, 25, 26, 10, 22, 20, 30, 30, 30], obj.listData)
		assertTrue(obj.removeFromListData(new Integer(25)))
		assertArrayEquals(#[11, 10, 25, 26, 10, 22, 20, 30, 30, 30], obj.listData)
		assertTrue(obj.removeFromListData(new Integer(25)))
		assertArrayEquals(#[11, 10, 26, 10, 22, 20, 30, 30, 30], obj.listData)
		assertFalse(obj.removeFromListData(new Integer(29)))
		assertArrayEquals(#[11, 10, 26, 10, 22, 20, 30, 30, 30], obj.listData)
		assertTrue(obj.removeAllFromListData(#[30]))
		assertArrayEquals(#[11, 10, 26, 10, 22, 20], obj.listData)
		assertTrue(obj.removeAllFromListData(#[20, 22]))
		assertArrayEquals(#[11, 10, 26, 10], obj.listData)
		assertTrue(obj.clearListData())
		assertEquals(0, obj.listData.size)
		assertFalse(obj.clearListData())
		assertEquals(0, obj.listData.size)

		assertEquals(5, obj.beforeAdd)
		assertEquals(5, obj.afterAdd)

		assertEquals(6, obj.beforeRemove)
		assertEquals(6, obj.afterRemove)

	}

	@Test
	def void testListChangeParams() {

		val obj = new ClassWithAdderRemoverChangeBasic

		assertTrue(obj.addAllToListDataParam(#[20, 21]))
		assertArrayEquals(#[20, 21], obj.listDataParam)
		assertTrue(obj.addAllToListDataParam(1, #[20, 21]))
		assertArrayEquals(#[20, 20, 21, 21], obj.listDataParam)
		assertTrue(obj.addToListDataParam(20))
		assertArrayEquals(#[20, 20, 21, 21, 20], obj.listDataParam)
		assertTrue(obj.addToListDataParam(3, 20))
		assertArrayEquals(#[20, 20, 21, 20, 21, 20], obj.listDataParam)

		assertEquals(6, obj.beforeElementAdd)
		assertEquals(4, obj.beforeAdd)
		assertEquals(6, obj.afterElementAdd)
		assertEquals(4, obj.afterAdd)

		assertFalse(obj.removeFromListDataParam(0))
		assertArrayEquals(#[20, 20, 21, 20, 21, 20], obj.listDataParam)
		assertFalse(obj.removeFromListDataParam(new Integer(22)))
		assertArrayEquals(#[20, 20, 21, 20, 21, 20], obj.listDataParam)
		assertFalse(obj.removeAllFromListDataParam(#[20, 21]))
		assertArrayEquals(#[20, 20, 21, 20, 21, 20], obj.listDataParam)
		assertTrue(obj.removeAllFromListDataParam(#[20]))
		assertArrayEquals(#[21, 21], obj.listDataParam)
		assertTrue(obj.clearListDataParam())
		assertEquals(0, obj.listDataParam.size)
		assertFalse(obj.clearListDataParam())
		assertEquals(0, obj.listDataParam.size)

		assertEquals(13, obj.beforeElementRemove)
		assertEquals(4, obj.beforeRemove)
		assertEquals(6, obj.afterElementRemove)
		assertEquals(2, obj.afterRemove)

	}

	@Test
	def void testListChangeParamsAndIndex() {

		val obj = new ClassWithAdderRemoverChangeBasic

		assertTrue(obj.addToListDataParamIndex(10))
		assertArrayEquals(#[10], obj.listDataParamIndex)
		assertTrue(obj.addToListDataParamIndex(1, 11))
		assertArrayEquals(#[10, 11], obj.listDataParamIndex)
		assertFalse(obj.addAllToListDataParamIndex(#[12, 13]))
		assertArrayEquals(#[10, 11], obj.listDataParamIndex)
		assertTrue(obj.addAllToListDataParamIndex(2, #[12, 13, 14]))
		assertArrayEquals(#[10, 11, 12, 13, 14], obj.listDataParamIndex)
		assertFalse(obj.addAllToListDataParamIndex(#[40, 41]))
		assertArrayEquals(#[10, 11, 12, 13, 14], obj.listDataParamIndex)
		assertTrue(obj.addAllToListDataParamIndex(#[15, 16, 17]))
		assertArrayEquals(#[10, 11, 12, 13, 14, 15, 16], obj.listDataParamIndex)

		assertEquals(12, obj.beforeElementAdd)
		assertEquals(5, obj.beforeAdd)
		assertEquals(7, obj.afterElementAdd)
		assertEquals(1004, obj.afterAdd)

		assertFalse(obj.removeFromListDataParamIndex(0))
		assertArrayEquals(#[10, 11, 12, 13, 14, 15, 16], obj.listDataParamIndex)
		assertFalse(obj.removeFromListDataParamIndex(1))
		assertArrayEquals(#[10, 11, 12, 13, 14, 15, 16], obj.listDataParamIndex)
		assertTrue(obj.removeFromListDataParamIndex(6))
		assertArrayEquals(#[10, 11, 12, 13, 14, 15], obj.listDataParamIndex)
		assertTrue(obj.removeFromListDataParamIndex(new Integer(15)))
		assertArrayEquals(#[10, 11, 12, 13, 14], obj.listDataParamIndex)
		assertFalse(obj.removeAllFromListDataParamIndex(#[12, 13]))
		assertArrayEquals(#[10, 11, 12, 13, 14], obj.listDataParamIndex)
		assertTrue(obj.removeAllFromListDataParamIndex(#[12, 13, 14]))
		assertArrayEquals(#[10, 11], obj.listDataParamIndex)
		assertFalse(obj.clearListDataParamIndex())

		assertEquals(11, obj.beforeElementRemove)
		assertEquals(4, obj.beforeRemove)
		assertEquals(5, obj.afterElementRemove)
		assertEquals(1003, obj.afterRemove)

	}

	@Test
	def void testSetChange() {

		val obj = new ClassWithAdderRemoverChangeBasic

		assertTrue(obj.addToSetDataParam(10))
		assertArrayEquals(#[10], obj.setDataParam.sort)
		assertFalse(obj.addToSetDataParam(10))
		assertArrayEquals(#[10], obj.setDataParam.sort)
		assertFalse(obj.addToSetDataParam(30))
		assertArrayEquals(#[10], obj.setDataParam.sort)
		assertTrue(obj.addAllToSetDataParam(#[10, 17, 18]))
		assertArrayEquals(#[10, 17, 18], obj.setDataParam.sort)
		assertFalse(obj.addAllToSetDataParam(#[17, 18]))
		assertArrayEquals(#[10, 17, 18], obj.setDataParam.sort)
		assertFalse(obj.addAllToSetDataParam(#[12, 13]))
		assertArrayEquals(#[10, 17, 18], obj.setDataParam.sort)
		assertTrue(obj.addAllToSetDataParam(#[12, 13, 14]))
		assertArrayEquals(#[10, 12, 13, 14, 17, 18], obj.setDataParam.sort)

		assertEquals(9, obj.beforeElementAdd)
		assertEquals(4, obj.beforeAdd)
		assertEquals(6, obj.afterElementAdd)
		assertEquals(1003, obj.afterAdd)

		assertFalse(obj.removeFromSetDataParam(0))
		assertArrayEquals(#[10, 12, 13, 14, 17, 18], obj.setDataParam.sort)
		assertFalse(obj.removeFromSetDataParam(18))
		assertArrayEquals(#[10, 12, 13, 14, 17, 18], obj.setDataParam.sort)
		assertTrue(obj.removeFromSetDataParam(17))
		assertArrayEquals(#[10, 12, 13, 14, 18], obj.setDataParam.sort)
		assertTrue(obj.removeAllFromSetDataParam(#[12, 13]))
		assertArrayEquals(#[10, 14, 18], obj.setDataParam.sort)
		assertTrue(obj.removeAllFromSetDataParam(#[14, 14, 14, 14, 14, 14, 14, 14, 15]))
		assertArrayEquals(#[10, 18], obj.setDataParam.sort)
		assertTrue(obj.clearSetDataParam())
		assertArrayEquals(#[18], obj.setDataParam.sort)
		assertFalse(obj.clearSetDataParam())
		assertArrayEquals(#[18], obj.setDataParam.sort)

		assertEquals(8, obj.beforeElementRemove)
		assertEquals(4, obj.beforeRemove)
		assertEquals(5, obj.afterElementRemove)
		assertEquals(4, obj.afterRemove)

	}

	@Test
	def void testListChangeParamsWithName() {

		val obj = new ClassWithAdderRemoverChangeWithName

		assertTrue(obj.addAllToListDataParam(#[20, 21]))
		assertArrayEquals(#[20, 21], obj.listDataParam)
		assertTrue(obj.addAllToListDataParam(1, #[20, 21]))
		assertArrayEquals(#[20, 20, 21, 21], obj.listDataParam)
		assertTrue(obj.addToListDataParam(20))
		assertArrayEquals(#[20, 20, 21, 21, 20], obj.listDataParam)
		assertTrue(obj.addToListDataParam(3, 20))
		assertArrayEquals(#[20, 20, 21, 20, 21, 20], obj.listDataParam)

		assertEquals(6, obj.beforeElementAdd)
		assertEquals(4, obj.beforeAdd)
		assertEquals(6, obj.afterElementAdd)
		assertEquals(4, obj.afterAdd)

		assertFalse(obj.removeFromListDataParam(0))
		assertArrayEquals(#[20, 20, 21, 20, 21, 20], obj.listDataParam)
		assertFalse(obj.removeFromListDataParam(new Integer(22)))
		assertArrayEquals(#[20, 20, 21, 20, 21, 20], obj.listDataParam)
		assertFalse(obj.removeAllFromListDataParam(#[20, 21]))
		assertArrayEquals(#[20, 20, 21, 20, 21, 20], obj.listDataParam)
		assertTrue(obj.removeAllFromListDataParam(#[20]))
		assertArrayEquals(#[21, 21], obj.listDataParam)
		assertTrue(obj.clearListDataParam())
		assertEquals(0, obj.listDataParam.size)
		assertFalse(obj.clearListDataParam())
		assertEquals(0, obj.listDataParam.size)

		assertEquals(13, obj.beforeElementRemove)
		assertEquals(4, obj.beforeRemove)
		assertEquals(6, obj.afterElementRemove)
		assertEquals(2, obj.afterRemove)

	}

	@Test
	def void testListChangeParamsAndIndexWithName() {

		val obj = new ClassWithAdderRemoverChangeWithName

		assertTrue(obj.addToListDataParamIndex(10))
		assertArrayEquals(#[10], obj.listDataParamIndex)
		assertTrue(obj.addToListDataParamIndex(1, 11))
		assertArrayEquals(#[10, 11], obj.listDataParamIndex)
		assertFalse(obj.addAllToListDataParamIndex(#[12, 13]))
		assertArrayEquals(#[10, 11], obj.listDataParamIndex)
		assertTrue(obj.addAllToListDataParamIndex(2, #[12, 13, 14]))
		assertArrayEquals(#[10, 11, 12, 13, 14], obj.listDataParamIndex)
		assertFalse(obj.addAllToListDataParamIndex(#[40, 41]))
		assertArrayEquals(#[10, 11, 12, 13, 14], obj.listDataParamIndex)
		assertTrue(obj.addAllToListDataParamIndex(#[15, 16, 17]))
		assertArrayEquals(#[10, 11, 12, 13, 14, 15, 16], obj.listDataParamIndex)

		assertEquals(12, obj.beforeElementAdd)
		assertEquals(5, obj.beforeAdd)
		assertEquals(7, obj.afterElementAdd)
		assertEquals(1004, obj.afterAdd)

		assertFalse(obj.removeFromListDataParamIndex(0))
		assertArrayEquals(#[10, 11, 12, 13, 14, 15, 16], obj.listDataParamIndex)
		assertFalse(obj.removeFromListDataParamIndex(1))
		assertArrayEquals(#[10, 11, 12, 13, 14, 15, 16], obj.listDataParamIndex)
		assertTrue(obj.removeFromListDataParamIndex(6))
		assertArrayEquals(#[10, 11, 12, 13, 14, 15], obj.listDataParamIndex)
		assertTrue(obj.removeFromListDataParamIndex(new Integer(15)))
		assertArrayEquals(#[10, 11, 12, 13, 14], obj.listDataParamIndex)
		assertFalse(obj.removeAllFromListDataParamIndex(#[12, 13]))
		assertArrayEquals(#[10, 11, 12, 13, 14], obj.listDataParamIndex)
		assertTrue(obj.removeAllFromListDataParamIndex(#[12, 13, 14]))
		assertArrayEquals(#[10, 11], obj.listDataParamIndex)
		assertFalse(obj.clearListDataParamIndex())

		assertEquals(11, obj.beforeElementRemove)
		assertEquals(4, obj.beforeRemove)
		assertEquals(5, obj.afterElementRemove)
		assertEquals(1003, obj.afterRemove)

	}

	@Test
	def void testListChangeParamsWithOldNewElements() {

		val obj = new ClassWithAdderRemoverChangeWithOldNewList

		obj.expectedOldElements = new ArrayList<Object>(#[])
		obj.expectedNewElements = new ArrayList<Object>(#[4])
		obj.expectedIndices = new ArrayList<Integer>(#[0])
		obj.notAllowed = null
		assertTrue(obj.addToListDataJustOldNew(4))
		assertArrayEquals(#[4], obj.listDataJustOldNew)
		assertEquals(1, obj.beforeElementAdd)
		assertEquals(1, obj.beforeAdd)
		assertEquals(1, obj.afterElementAdd)
		assertEquals(1, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[4])
		obj.expectedNewElements = null
		obj.expectedIndices = new ArrayList<Integer>(#[1, 2, 3])
		obj.notAllowed = null
		assertFalse(obj.addAllToListDataJustOldNew(#[5, 6, 7]))
		assertArrayEquals(#[4], obj.listDataJustOldNew)
		assertEquals(4, obj.beforeElementAdd)
		assertEquals(2, obj.beforeAdd)
		assertEquals(1, obj.afterElementAdd)
		assertEquals(1, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[4])
		obj.expectedNewElements = new ArrayList<Object>(#[4, 8, 10])
		obj.expectedIndices = new ArrayList<Integer>(#[1, 2])
		obj.notAllowed = 9
		assertTrue(obj.addAllToListDataJustOldNew(#[8, 9, 10]))
		assertArrayEquals(#[4, 8, 10], obj.listDataJustOldNew)
		assertEquals(7, obj.beforeElementAdd)
		assertEquals(3, obj.beforeAdd)
		assertEquals(3, obj.afterElementAdd)
		assertEquals(2, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[4, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[14, 15, 4, 8, 10])
		obj.expectedIndices = new ArrayList<Integer>(#[0, 1])
		obj.notAllowed = null
		assertTrue(obj.addAllToListDataJustOldNew(0, #[14, 15]))
		assertArrayEquals(#[14, 15, 4, 8, 10], obj.listDataJustOldNew)
		assertEquals(9, obj.beforeElementAdd)
		assertEquals(4, obj.beforeAdd)
		assertEquals(5, obj.afterElementAdd)
		assertEquals(3, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 15, 4, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[14, 30, 15, 4, 8, 10])
		obj.expectedIndices = new ArrayList<Integer>(#[1])
		obj.notAllowed = null
		assertTrue(obj.addToListDataJustOldNew(1, 30))
		assertArrayEquals(#[14, 30, 15, 4, 8, 10], obj.listDataJustOldNew)
		assertEquals(10, obj.beforeElementAdd)
		assertEquals(5, obj.beforeAdd)
		assertEquals(6, obj.afterElementAdd)
		assertEquals(4, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 30, 15, 4, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[14, 15, 4, 8, 10])
		obj.expectedIndices = new ArrayList<Integer>(#[1])
		obj.notAllowed = null
		assertTrue(obj.removeFromListDataJustOldNew(new Integer(30)))
		assertArrayEquals(#[14, 15, 4, 8, 10], obj.listDataJustOldNew)
		assertEquals(1, obj.beforeElementRemove)
		assertEquals(1, obj.beforeRemove)
		assertEquals(1, obj.afterElementRemove)
		assertEquals(1, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 15, 4, 8, 10])
		obj.expectedNewElements = null
		obj.expectedIndices = new ArrayList<Integer>(#[0, 1, 3])
		obj.notAllowed = null
		assertFalse(obj.removeAllFromListDataJustOldNew(#[14, 15, 8]))
		assertArrayEquals(#[14, 15, 4, 8, 10], obj.listDataJustOldNew)
		assertEquals(4, obj.beforeElementRemove)
		assertEquals(2, obj.beforeRemove)
		assertEquals(1, obj.afterElementRemove)
		assertEquals(1, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 15, 4, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[14, 15, 8, 10])
		obj.expectedIndices = new ArrayList<Integer>(#[2])
		obj.notAllowed = null
		assertTrue(obj.removeFromListDataJustOldNew(2))
		assertArrayEquals(#[14, 15, 8, 10], obj.listDataJustOldNew)
		assertEquals(5, obj.beforeElementRemove)
		assertEquals(3, obj.beforeRemove)
		assertEquals(2, obj.afterElementRemove)
		assertEquals(2, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 15, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[14, 15, 8])
		obj.expectedIndices = new ArrayList<Integer>(#[3])
		obj.notAllowed = null
		assertTrue(obj.removeFromListDataJustOldNew(new Integer(10)))
		assertArrayEquals(#[14, 15, 8], obj.listDataJustOldNew)
		assertEquals(6, obj.beforeElementRemove)
		assertEquals(4, obj.beforeRemove)
		assertEquals(3, obj.afterElementRemove)
		assertEquals(3, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 15, 8])
		obj.expectedNewElements = new ArrayList<Object>(#[15, 8])
		obj.expectedIndices = new ArrayList<Integer>(#[0])
		obj.notAllowed = 8
		assertTrue(obj.removeAllFromListDataJustOldNew(#[14, 8]))
		assertArrayEquals(#[15, 8], obj.listDataJustOldNew)
		assertEquals(8, obj.beforeElementRemove)
		assertEquals(5, obj.beforeRemove)
		assertEquals(4, obj.afterElementRemove)
		assertEquals(4, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[15, 8])
		obj.expectedNewElements = new ArrayList<Object>(#[15])
		obj.expectedIndices = new ArrayList<Integer>(#[1])
		obj.notAllowed = null
		assertTrue(obj.removeAllFromListDataJustOldNew(#[8]))
		assertArrayEquals(#[15], obj.listDataJustOldNew)
		assertEquals(9, obj.beforeElementRemove)
		assertEquals(6, obj.beforeRemove)
		assertEquals(5, obj.afterElementRemove)
		assertEquals(5, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[15])
		obj.expectedNewElements = new ArrayList<Object>(#[])
		obj.expectedIndices = new ArrayList<Integer>(#[0])
		obj.notAllowed = null
		assertTrue(obj.clearListDataJustOldNew)
		assertTrue(obj.listDataJustOldNew.isEmpty)
		assertEquals(10, obj.beforeElementRemove)
		assertEquals(7, obj.beforeRemove)
		assertEquals(6, obj.afterElementRemove)
		assertEquals(6, obj.afterRemove)

		obj.beforeElementRemove = 0
		obj.beforeRemove = 0
		obj.afterElementRemove = 0
		obj.afterRemove = 0

	}

	@Test
	def void testListChangeParamsWithOldNewElementsAndFieldName() {

		val obj = new ClassWithAdderRemoverChangeWithOldNewListAndFieldName

		obj.expectedOldElements = new ArrayList<Object>(#[])
		obj.expectedNewElements = new ArrayList<Object>(#[4])
		obj.expectedIndices = new ArrayList<Integer>(#[0])
		obj.notAllowed = null
		assertTrue(obj.addToListDataJustOldNew(4))
		assertArrayEquals(#[4], obj.listDataJustOldNew)
		assertEquals(1, obj.beforeElementAdd)
		assertEquals(1, obj.beforeAdd)
		assertEquals(1, obj.afterElementAdd)
		assertEquals(1, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[4])
		obj.expectedNewElements = null
		obj.expectedIndices = new ArrayList<Integer>(#[1, 2, 3])
		obj.notAllowed = null
		assertFalse(obj.addAllToListDataJustOldNew(#[5, 6, 7]))
		assertArrayEquals(#[4], obj.listDataJustOldNew)
		assertEquals(4, obj.beforeElementAdd)
		assertEquals(2, obj.beforeAdd)
		assertEquals(1, obj.afterElementAdd)
		assertEquals(1, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[4])
		obj.expectedNewElements = new ArrayList<Object>(#[4, 8, 10])
		obj.expectedIndices = new ArrayList<Integer>(#[1, 2])
		obj.notAllowed = 9
		assertTrue(obj.addAllToListDataJustOldNew(#[8, 9, 10]))
		assertArrayEquals(#[4, 8, 10], obj.listDataJustOldNew)
		assertEquals(7, obj.beforeElementAdd)
		assertEquals(3, obj.beforeAdd)
		assertEquals(3, obj.afterElementAdd)
		assertEquals(2, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[4, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[14, 15, 4, 8, 10])
		obj.expectedIndices = new ArrayList<Integer>(#[0, 1])
		obj.notAllowed = null
		assertTrue(obj.addAllToListDataJustOldNew(0, #[14, 15]))
		assertArrayEquals(#[14, 15, 4, 8, 10], obj.listDataJustOldNew)
		assertEquals(9, obj.beforeElementAdd)
		assertEquals(4, obj.beforeAdd)
		assertEquals(5, obj.afterElementAdd)
		assertEquals(3, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 15, 4, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[14, 30, 15, 4, 8, 10])
		obj.expectedIndices = new ArrayList<Integer>(#[1])
		obj.notAllowed = null
		assertTrue(obj.addToListDataJustOldNew(1, 30))
		assertArrayEquals(#[14, 30, 15, 4, 8, 10], obj.listDataJustOldNew)
		assertEquals(10, obj.beforeElementAdd)
		assertEquals(5, obj.beforeAdd)
		assertEquals(6, obj.afterElementAdd)
		assertEquals(4, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 30, 15, 4, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[14, 15, 4, 8, 10])
		obj.expectedIndices = new ArrayList<Integer>(#[1])
		obj.notAllowed = null
		assertTrue(obj.removeFromListDataJustOldNew(new Integer(30)))
		assertArrayEquals(#[14, 15, 4, 8, 10], obj.listDataJustOldNew)
		assertEquals(1, obj.beforeElementRemove)
		assertEquals(1, obj.beforeRemove)
		assertEquals(1, obj.afterElementRemove)
		assertEquals(1, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 15, 4, 8, 10])
		obj.expectedNewElements = null
		obj.expectedIndices = new ArrayList<Integer>(#[0, 1, 3])
		obj.notAllowed = null
		assertFalse(obj.removeAllFromListDataJustOldNew(#[14, 15, 8]))
		assertArrayEquals(#[14, 15, 4, 8, 10], obj.listDataJustOldNew)
		assertEquals(4, obj.beforeElementRemove)
		assertEquals(2, obj.beforeRemove)
		assertEquals(1, obj.afterElementRemove)
		assertEquals(1, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 15, 4, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[14, 15, 8, 10])
		obj.expectedIndices = new ArrayList<Integer>(#[2])
		obj.notAllowed = null
		assertTrue(obj.removeFromListDataJustOldNew(2))
		assertArrayEquals(#[14, 15, 8, 10], obj.listDataJustOldNew)
		assertEquals(5, obj.beforeElementRemove)
		assertEquals(3, obj.beforeRemove)
		assertEquals(2, obj.afterElementRemove)
		assertEquals(2, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 15, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[15, 8, 10])
		obj.expectedIndices = new ArrayList<Integer>(#[0])
		obj.notAllowed = 8
		assertTrue(obj.removeAllFromListDataJustOldNew(#[14, 8]))
		assertArrayEquals(#[15, 8, 10], obj.listDataJustOldNew)
		assertEquals(7, obj.beforeElementRemove)
		assertEquals(4, obj.beforeRemove)
		assertEquals(3, obj.afterElementRemove)
		assertEquals(3, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[15, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[15, 8])
		obj.expectedIndices = new ArrayList<Integer>(#[2])
		obj.notAllowed = null
		assertTrue(obj.removeAllFromListDataJustOldNew(#[10]))
		assertArrayEquals(#[15, 8], obj.listDataJustOldNew)
		assertEquals(8, obj.beforeElementRemove)
		assertEquals(5, obj.beforeRemove)
		assertEquals(4, obj.afterElementRemove)
		assertEquals(4, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[15, 8])
		obj.expectedNewElements = new ArrayList<Object>(#[])
		obj.expectedIndices = new ArrayList<Integer>(#[0, 1])
		obj.notAllowed = null
		assertTrue(obj.clearListDataJustOldNew)
		assertTrue(obj.listDataJustOldNew.isEmpty)
		assertEquals(10, obj.beforeElementRemove)
		assertEquals(6, obj.beforeRemove)
		assertEquals(6, obj.afterElementRemove)
		assertEquals(5, obj.afterRemove)

		obj.beforeElementRemove = 0
		obj.beforeRemove = 0
		obj.afterElementRemove = 0
		obj.afterRemove = 0

	}

	@Test
	def void testSetChangeParamsWithOldNewElements() {

		val obj = new ClassWithAdderRemoverChangeWithOldNewSet

		obj.expectedOldElements = new ArrayList<Object>(#[])
		obj.expectedNewElements = new ArrayList<Object>(#[4])
		obj.notAllowed = null
		assertTrue(obj.addToSetDataJustOldNew(4))
		assertEquals(new HashSet(#[4]), obj.setDataJustOldNew)
		assertEquals(1, obj.beforeElementAdd)
		assertEquals(1, obj.beforeAdd)
		assertEquals(1, obj.afterElementAdd)
		assertEquals(1, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[4])
		obj.expectedNewElements = null
		obj.notAllowed = null
		assertFalse(obj.addAllToSetDataJustOldNew(#[5, 6, 7]))
		assertEquals(new HashSet(#[4]), obj.setDataJustOldNew)
		assertEquals(4, obj.beforeElementAdd)
		assertEquals(2, obj.beforeAdd)
		assertEquals(1, obj.afterElementAdd)
		assertEquals(1, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[4])
		obj.expectedNewElements = new ArrayList<Object>(#[4, 8, 10])
		obj.notAllowed = 9
		assertTrue(obj.addAllToSetDataJustOldNew(#[8, 9, 10]))
		assertEquals(new HashSet(#[4, 8, 10]), obj.setDataJustOldNew)
		assertEquals(7, obj.beforeElementAdd)
		assertEquals(3, obj.beforeAdd)
		assertEquals(3, obj.afterElementAdd)
		assertEquals(2, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[4, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[14, 30, 4, 8, 10])
		obj.notAllowed = null
		assertTrue(obj.addAllToSetDataJustOldNew(#[30, 14]))
		assertEquals(new HashSet(#[14, 30, 4, 8, 10]), obj.setDataJustOldNew)
		assertEquals(9, obj.beforeElementAdd)
		assertEquals(4, obj.beforeAdd)
		assertEquals(5, obj.afterElementAdd)
		assertEquals(3, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 30, 4, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[14, 30, 15, 4, 8, 10])
		obj.notAllowed = null
		assertTrue(obj.addAllToSetDataJustOldNew(#[15]))
		assertEquals(new HashSet(#[14, 30, 4, 8, 15, 10]), obj.setDataJustOldNew)
		assertEquals(10, obj.beforeElementAdd)
		assertEquals(5, obj.beforeAdd)
		assertEquals(6, obj.afterElementAdd)
		assertEquals(4, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 30, 15, 4, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[14, 15, 4, 8, 10])
		obj.notAllowed = null
		assertTrue(obj.removeFromSetDataJustOldNew(new Integer(30)))
		assertEquals(new HashSet(#[14, 15, 4, 8, 10]), obj.setDataJustOldNew)
		assertEquals(1, obj.beforeElementRemove)
		assertEquals(1, obj.beforeRemove)
		assertEquals(1, obj.afterElementRemove)
		assertEquals(1, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 15, 4, 8, 10])
		obj.expectedNewElements = null
		obj.notAllowed = null
		assertFalse(obj.removeAllFromSetDataJustOldNew(#[14, 15, 8]))
		assertEquals(new HashSet(#[14, 15, 4, 8, 10]), obj.setDataJustOldNew)
		assertEquals(4, obj.beforeElementRemove)
		assertEquals(2, obj.beforeRemove)
		assertEquals(1, obj.afterElementRemove)
		assertEquals(1, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 15, 4, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[14, 15, 8, 10])
		obj.notAllowed = null
		assertTrue(obj.removeFromSetDataJustOldNew(4))
		assertEquals(new HashSet(#[14, 15, 8, 10]), obj.setDataJustOldNew)
		assertEquals(5, obj.beforeElementRemove)
		assertEquals(3, obj.beforeRemove)
		assertEquals(2, obj.afterElementRemove)
		assertEquals(2, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 15, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[15, 8, 10])
		obj.notAllowed = 8
		assertTrue(obj.removeAllFromSetDataJustOldNew(#[14, 8]))
		assertEquals(new HashSet(#[15, 8, 10]), obj.setDataJustOldNew)
		assertEquals(7, obj.beforeElementRemove)
		assertEquals(4, obj.beforeRemove)
		assertEquals(3, obj.afterElementRemove)
		assertEquals(3, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[15, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[15, 8])
		obj.notAllowed = null
		assertTrue(obj.removeAllFromSetDataJustOldNew(#[10]))
		assertEquals(new HashSet(#[15, 8]), obj.setDataJustOldNew)
		assertEquals(8, obj.beforeElementRemove)
		assertEquals(5, obj.beforeRemove)
		assertEquals(4, obj.afterElementRemove)
		assertEquals(4, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[15, 8])
		obj.expectedNewElements = new ArrayList<Object>(#[])
		obj.notAllowed = null
		assertTrue(obj.clearSetDataJustOldNew)
		assertTrue(obj.setDataJustOldNew.isEmpty)
		assertEquals(10, obj.beforeElementRemove)
		assertEquals(6, obj.beforeRemove)
		assertEquals(6, obj.afterElementRemove)
		assertEquals(5, obj.afterRemove)

	}

	@Test
	def void testSetChangeParamsWithOldNewElementsAndFieldName() {

		val obj = new ClassWithAdderRemoverChangeWithOldNewSetAndFieldName

		obj.expectedOldElements = new ArrayList<Object>(#[])
		obj.expectedNewElements = new ArrayList<Object>(#[4])
		obj.notAllowed = null
		assertTrue(obj.addToSetDataJustOldNew(4))
		assertEquals(new HashSet(#[4]), obj.setDataJustOldNew)
		assertEquals(1, obj.beforeElementAdd)
		assertEquals(1, obj.beforeAdd)
		assertEquals(1, obj.afterElementAdd)
		assertEquals(1, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[4])
		obj.expectedNewElements = null
		obj.notAllowed = null
		assertFalse(obj.addAllToSetDataJustOldNew(#[5, 6, 7]))
		assertEquals(new HashSet(#[4]), obj.setDataJustOldNew)
		assertEquals(4, obj.beforeElementAdd)
		assertEquals(2, obj.beforeAdd)
		assertEquals(1, obj.afterElementAdd)
		assertEquals(1, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[4])
		obj.expectedNewElements = new ArrayList<Object>(#[4, 8, 10])
		obj.notAllowed = 9
		assertTrue(obj.addAllToSetDataJustOldNew(#[8, 9, 10]))
		assertEquals(new HashSet(#[4, 8, 10]), obj.setDataJustOldNew)
		assertEquals(7, obj.beforeElementAdd)
		assertEquals(3, obj.beforeAdd)
		assertEquals(3, obj.afterElementAdd)
		assertEquals(2, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[4, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[14, 30, 4, 8, 10])
		obj.notAllowed = null
		assertTrue(obj.addAllToSetDataJustOldNew(#[30, 14]))
		assertEquals(new HashSet(#[14, 30, 4, 8, 10]), obj.setDataJustOldNew)
		assertEquals(9, obj.beforeElementAdd)
		assertEquals(4, obj.beforeAdd)
		assertEquals(5, obj.afterElementAdd)
		assertEquals(3, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 30, 4, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[14, 30, 15, 4, 8, 10])
		obj.notAllowed = null
		assertTrue(obj.addAllToSetDataJustOldNew(#[15]))
		assertEquals(new HashSet(#[14, 30, 4, 8, 15, 10]), obj.setDataJustOldNew)
		assertEquals(10, obj.beforeElementAdd)
		assertEquals(5, obj.beforeAdd)
		assertEquals(6, obj.afterElementAdd)
		assertEquals(4, obj.afterAdd)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 30, 15, 4, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[14, 15, 4, 8, 10])
		obj.notAllowed = null
		assertTrue(obj.removeFromSetDataJustOldNew(new Integer(30)))
		assertEquals(new HashSet(#[14, 15, 4, 8, 10]), obj.setDataJustOldNew)
		assertEquals(1, obj.beforeElementRemove)
		assertEquals(1, obj.beforeRemove)
		assertEquals(1, obj.afterElementRemove)
		assertEquals(1, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 15, 4, 8, 10])
		obj.expectedNewElements = null
		obj.notAllowed = null
		assertFalse(obj.removeAllFromSetDataJustOldNew(#[14, 15, 8]))
		assertEquals(new HashSet(#[14, 15, 4, 8, 10]), obj.setDataJustOldNew)
		assertEquals(4, obj.beforeElementRemove)
		assertEquals(2, obj.beforeRemove)
		assertEquals(1, obj.afterElementRemove)
		assertEquals(1, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 15, 4, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[14, 15, 8, 10])
		obj.notAllowed = null
		assertTrue(obj.removeFromSetDataJustOldNew(4))
		assertEquals(new HashSet(#[14, 15, 8, 10]), obj.setDataJustOldNew)
		assertEquals(5, obj.beforeElementRemove)
		assertEquals(3, obj.beforeRemove)
		assertEquals(2, obj.afterElementRemove)
		assertEquals(2, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[14, 15, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[15, 8, 10])
		obj.notAllowed = 8
		assertTrue(obj.removeAllFromSetDataJustOldNew(#[14, 8]))
		assertEquals(new HashSet(#[15, 8, 10]), obj.setDataJustOldNew)
		assertEquals(7, obj.beforeElementRemove)
		assertEquals(4, obj.beforeRemove)
		assertEquals(3, obj.afterElementRemove)
		assertEquals(3, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[15, 8, 10])
		obj.expectedNewElements = new ArrayList<Object>(#[15, 8])
		obj.notAllowed = null
		assertTrue(obj.removeAllFromSetDataJustOldNew(#[10]))
		assertEquals(new HashSet(#[15, 8]), obj.setDataJustOldNew)
		assertEquals(8, obj.beforeElementRemove)
		assertEquals(5, obj.beforeRemove)
		assertEquals(4, obj.afterElementRemove)
		assertEquals(4, obj.afterRemove)

		obj.expectedOldElements = new ArrayList<Object>(#[15, 8])
		obj.expectedNewElements = new ArrayList<Object>(#[])
		obj.notAllowed = null
		assertTrue(obj.clearSetDataJustOldNew)
		assertTrue(obj.setDataJustOldNew.isEmpty)
		assertEquals(10, obj.beforeElementRemove)
		assertEquals(6, obj.beforeRemove)
		assertEquals(6, obj.afterElementRemove)
		assertEquals(5, obj.afterRemove)

		obj.beforeElementRemove = 0
		obj.beforeRemove = 0
		obj.afterElementRemove = 0
		obj.afterRemove = 0

	}

	@Test
	def void testSetChangeWithName() {

		val obj = new ClassWithAdderRemoverChangeWithName

		assertTrue(obj.addToSetDataParam(10))
		assertArrayEquals(#[10], obj.setDataParam.sort)
		assertFalse(obj.addToSetDataParam(10))
		assertArrayEquals(#[10], obj.setDataParam.sort)
		assertFalse(obj.addToSetDataParam(30))
		assertArrayEquals(#[10], obj.setDataParam.sort)
		assertTrue(obj.addAllToSetDataParam(#[10, 17, 18]))
		assertArrayEquals(#[10, 17, 18], obj.setDataParam.sort)
		assertFalse(obj.addAllToSetDataParam(#[17, 18]))
		assertArrayEquals(#[10, 17, 18], obj.setDataParam.sort)
		assertFalse(obj.addAllToSetDataParam(#[12, 13]))
		assertArrayEquals(#[10, 17, 18], obj.setDataParam.sort)
		assertTrue(obj.addAllToSetDataParam(#[12, 13, 14]))
		assertArrayEquals(#[10, 12, 13, 14, 17, 18], obj.setDataParam.sort)

		assertEquals(9, obj.beforeElementAdd)
		assertEquals(4, obj.beforeAdd)
		assertEquals(6, obj.afterElementAdd)
		assertEquals(1003, obj.afterAdd)

		assertFalse(obj.removeFromSetDataParam(0))
		assertArrayEquals(#[10, 12, 13, 14, 17, 18], obj.setDataParam.sort)
		assertFalse(obj.removeFromSetDataParam(18))
		assertArrayEquals(#[10, 12, 13, 14, 17, 18], obj.setDataParam.sort)
		assertTrue(obj.removeFromSetDataParam(17))
		assertArrayEquals(#[10, 12, 13, 14, 18], obj.setDataParam.sort)
		assertTrue(obj.removeAllFromSetDataParam(#[12, 13]))
		assertArrayEquals(#[10, 14, 18], obj.setDataParam.sort)
		assertTrue(obj.removeAllFromSetDataParam(#[14, 14, 14, 14, 14, 14, 14, 14, 15]))
		assertArrayEquals(#[10, 18], obj.setDataParam.sort)
		assertTrue(obj.clearSetDataParam())
		assertArrayEquals(#[18], obj.setDataParam.sort)
		assertFalse(obj.clearSetDataParam())
		assertArrayEquals(#[18], obj.setDataParam.sort)

		assertEquals(8, obj.beforeElementRemove)
		assertEquals(4, obj.beforeRemove)
		assertEquals(5, obj.afterElementRemove)
		assertEquals(4, obj.afterRemove)

	}

	@Test
	def void testSetChangeMultiUse() {

		val obj = new ClassWithAdderRemoverChangeMultiUse

		val values = new ArrayList<String>
		values.add("str")

		assertTrue(obj.addToListData1(values))
		assertEquals("str", obj.listData1.get(0).get(0))
		assertTrue(obj.removeFromListData1(values))
		assertEquals(0, obj.listData1.size)
		assertTrue(obj.addToListData2(values))
		assertEquals("str", obj.listData2.get(0).get(0))
		assertTrue(obj.removeFromListData2(values))
		assertEquals(0, obj.listData2.size)

		assertEquals(1001, obj.beforeElementAdd)
		assertEquals(2, obj.beforeAdd)
		assertEquals(2, obj.afterElementAdd)
		assertEquals(2, obj.afterAdd)
		assertEquals(2, obj.beforeElementRemove)
		assertEquals(2, obj.beforeRemove)
		assertEquals(2, obj.afterElementRemove)
		assertEquals(2, obj.afterRemove)

	}

	@Test
	def void testListChangeStatic() {

		ClassWithAdderRemoverChangeStatic::beforeElementAdd = 0
		ClassWithAdderRemoverChangeStatic::beforeAdd = 0
		ClassWithAdderRemoverChangeStatic::afterElementAdd = 0
		ClassWithAdderRemoverChangeStatic::afterAdd = 0
		ClassWithAdderRemoverChangeStatic::beforeElementRemove = 0
		ClassWithAdderRemoverChangeStatic::beforeRemove = 0
		ClassWithAdderRemoverChangeStatic::afterElementRemove = 0
		ClassWithAdderRemoverChangeStatic::afterRemove = 0

		assertTrue(ClassWithAdderRemoverChangeStatic::addAllToListDataParamStatic(#[20, 21]))
		assertArrayEquals(#[20, 21], ClassWithAdderRemoverChangeStatic::listDataParamStatic)
		assertTrue(ClassWithAdderRemoverChangeStatic::addAllToListDataParamStatic(1, #[20, 21]))
		assertArrayEquals(#[20, 20, 21, 21], ClassWithAdderRemoverChangeStatic::listDataParamStatic)
		assertTrue(ClassWithAdderRemoverChangeStatic::addToListDataParamStatic(20))
		assertArrayEquals(#[20, 20, 21, 21, 20], ClassWithAdderRemoverChangeStatic::listDataParamStatic)
		assertTrue(ClassWithAdderRemoverChangeStatic::addToListDataParamStatic(3, 20))
		assertArrayEquals(#[20, 20, 21, 20, 21, 20], ClassWithAdderRemoverChangeStatic::listDataParamStatic)

		assertEquals(6, ClassWithAdderRemoverChangeStatic::beforeElementAdd)
		assertEquals(4, ClassWithAdderRemoverChangeStatic::beforeAdd)
		assertEquals(6, ClassWithAdderRemoverChangeStatic::afterElementAdd)
		assertEquals(4, ClassWithAdderRemoverChangeStatic::afterAdd)

		assertFalse(ClassWithAdderRemoverChangeStatic::removeFromListDataParamStatic(0))
		assertArrayEquals(#[20, 20, 21, 20, 21, 20], ClassWithAdderRemoverChangeStatic::listDataParamStatic)
		assertFalse(ClassWithAdderRemoverChangeStatic::removeFromListDataParamStatic(new Integer(22)))
		assertArrayEquals(#[20, 20, 21, 20, 21, 20], ClassWithAdderRemoverChangeStatic::listDataParamStatic)
		assertFalse(ClassWithAdderRemoverChangeStatic::removeAllFromListDataParamStatic(#[20, 21]))
		assertArrayEquals(#[20, 20, 21, 20, 21, 20], ClassWithAdderRemoverChangeStatic::listDataParamStatic)
		assertTrue(ClassWithAdderRemoverChangeStatic::removeAllFromListDataParamStatic(#[20]))
		assertArrayEquals(#[21, 21], ClassWithAdderRemoverChangeStatic::listDataParamStatic)
		assertTrue(ClassWithAdderRemoverChangeStatic::clearListDataParamStatic())
		assertEquals(0, ClassWithAdderRemoverChangeStatic::listDataParamStatic.size)
		assertFalse(ClassWithAdderRemoverChangeStatic::clearListDataParamStatic())
		assertEquals(0, ClassWithAdderRemoverChangeStatic::listDataParamStatic.size)

		assertEquals(13, ClassWithAdderRemoverChangeStatic::beforeElementRemove)
		assertEquals(4, ClassWithAdderRemoverChangeStatic::beforeRemove)
		assertEquals(6, ClassWithAdderRemoverChangeStatic::afterElementRemove)
		assertEquals(2, ClassWithAdderRemoverChangeStatic::afterRemove)

		ClassWithAdderRemoverChangeStatic::beforeElementAdd = 0
		ClassWithAdderRemoverChangeStatic::beforeAdd = 0
		ClassWithAdderRemoverChangeStatic::afterElementAdd = 0
		ClassWithAdderRemoverChangeStatic::afterAdd = 0
		ClassWithAdderRemoverChangeStatic::beforeElementRemove = 0
		ClassWithAdderRemoverChangeStatic::beforeRemove = 0
		ClassWithAdderRemoverChangeStatic::afterElementRemove = 0
		ClassWithAdderRemoverChangeStatic::afterRemove = 0

		val obj = new ClassWithAdderRemoverChangeStatic

		assertTrue(obj.addToListDataParamNonStaticCallStatic("x"))
		assertArrayEquals(#["x"], obj.listDataParamNonStaticCallStatic)
		assertTrue(obj.addAllToListDataParamNonStaticCallStatic(1, #["y", "z"]))
		assertArrayEquals(#["x", "y", "z"], obj.listDataParamNonStaticCallStatic)
		assertTrue(obj.removeFromListDataParamNonStaticCallStatic("x"))
		assertArrayEquals(#["y", "z"], obj.listDataParamNonStaticCallStatic)
		assertTrue(obj.clearListDataParamNonStaticCallStatic)
		assertEquals(0, obj.listDataParamNonStaticCallStatic.size)

		assertEquals(3, ClassWithAdderRemoverChangeStatic::beforeElementAdd)
		assertEquals(2, ClassWithAdderRemoverChangeStatic::beforeAdd)
		assertEquals(3, ClassWithAdderRemoverChangeStatic::afterElementAdd)
		assertEquals(2, ClassWithAdderRemoverChangeStatic::afterAdd)
		assertEquals(3, ClassWithAdderRemoverChangeStatic::beforeElementRemove)
		assertEquals(2, ClassWithAdderRemoverChangeStatic::beforeRemove)
		assertEquals(3, ClassWithAdderRemoverChangeStatic::afterElementRemove)
		assertEquals(2, ClassWithAdderRemoverChangeStatic::afterRemove)

	}

	@Test
	def void testIndicesInChangeMethods() {

		val obj = new ClassWithAdderRemoverChangeIndices

		obj.expectedIndices = new ArrayList<Integer>(#[0, 1, 2, 3, 4, 5, 6, 7, 8])
		obj.expectedElements = new ArrayList<String>(#["a", "b", "c", "d", "e", "f", "g", "h", "j"])
		obj.doNotAdd = new HashSet(#["i"]);

		obj.addAllToListData(#["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"])

		obj.expectedIndices = new ArrayList<Integer>(#[4, 2, 6])
		obj.expectedElements = new ArrayList<String>(#["e", "c", "g"])
		obj.doNotRemove = new HashSet(#["d"]);

		obj.removeAllFromListData(#["e", "c", "x", "d", "g"])

	}

	@Test
	def void testChangeMethodsNoConcurrentChange() {

		val obj = new ClassWithAdderRemoverNoConcurrent

		obj.addToListData(1)
		assertEquals(#[1, 100], obj.listData)

		obj.removeFromListData(100 as Integer)
		assertEquals(#[1], obj.listData)

	}

	@Test
	def void testMethodNotFoundError() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule

@ApplyRules
class ClassWithAdderRemover {

	@AdderRule(beforeAdd="m1", afterAdd="m2", afterElementAdd="m3", beforeElementAdd="m4")
	java.util.List<String> dataWithAdder = new java.util.ArrayList<String>

	@RemoverRule(beforeRemove="n1", afterRemove="n2", afterElementRemove="n3", beforeElementRemove="n4")
	java.util.List<Double> dataWithRemover = new java.util.ArrayList<Double>

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ClassWithAdderRemover")

			val problemsAttributeDataWithAdder = (clazz.findDeclaredField("dataWithAdder").
				primarySourceElement as FieldDeclaration).problems
			val problemsAttributeDataWithRemover = (clazz.findDeclaredField("dataWithRemover").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(4, problemsAttributeDataWithAdder.size)
			assertEquals(Severity.ERROR, problemsAttributeDataWithAdder.get(0).severity)
			assertTrue(problemsAttributeDataWithAdder.get(0).message.contains("Cannot find"))
			assertEquals(Severity.ERROR, problemsAttributeDataWithAdder.get(1).severity)
			assertTrue(problemsAttributeDataWithAdder.get(1).message.contains("Cannot find"))
			assertEquals(Severity.ERROR, problemsAttributeDataWithAdder.get(2).severity)
			assertTrue(problemsAttributeDataWithAdder.get(2).message.contains("Cannot find"))
			assertEquals(Severity.ERROR, problemsAttributeDataWithAdder.get(3).severity)
			assertTrue(problemsAttributeDataWithAdder.get(3).message.contains("Cannot find"))

			assertEquals(4, problemsAttributeDataWithRemover.size)
			assertEquals(Severity.ERROR, problemsAttributeDataWithRemover.get(0).severity)
			assertTrue(problemsAttributeDataWithRemover.get(0).message.contains("Cannot find"))
			assertEquals(Severity.ERROR, problemsAttributeDataWithRemover.get(1).severity)
			assertTrue(problemsAttributeDataWithRemover.get(1).message.contains("Cannot find"))
			assertEquals(Severity.ERROR, problemsAttributeDataWithRemover.get(2).severity)
			assertTrue(problemsAttributeDataWithRemover.get(2).message.contains("Cannot find"))
			assertEquals(Severity.ERROR, problemsAttributeDataWithRemover.get(3).severity)
			assertTrue(problemsAttributeDataWithRemover.get(3).message.contains("Cannot find"))

			assertEquals(8, allProblems.size)

		]

	}

	def void testMultipleMethodCandidatesError() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule

@ApplyRules
class ClassWithMultipleCandidates {

	@AdderRule(multiple=true, beforeAdd="%BeforeAdd", afterAdd="%Added", beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	java.util.List<Integer> listData1 = new java.util.ArrayList<Integer>

	def void listData1Added(java.util.List<Integer> addedValues) {
	}

	protected def void listData1Added() {
	}

	@AdderRule(multiple=true, beforeAdd="%BeforeAdd", afterAdd="%Added", beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	java.util.List<Integer> listData2 = new java.util.ArrayList<Integer>

	def boolean listData2BeforeAdd(java.util.List<Integer> addedValues) {
		return true
	}

	def void listData2BeforeAdd() {
	}

	@AdderRule(multiple=true, beforeAdd="%BeforeAdd", afterAdd="%Added", beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	java.util.List<Integer> listData3 = new java.util.ArrayList<Integer>

	def void listData3ElementAdded(Integer addedValue) {
	}

	def void listData3ElementAdded(int index, Integer addedValue) {
	}

	@AdderRule(multiple=true, beforeAdd="%BeforeAdd", afterAdd="%Added", beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	java.util.List<Integer> listData4 = new java.util.ArrayList<Integer>

	def boolean listData4BeforeElementAdd(Integer addedValue) {
		return true
	}

	def boolean listData4BeforeElementAdd(String fieldName, Integer addedValue) {
		return true
	}

	@RemoverRule(multiple=true, beforeRemove="%BeforeRemove", afterRemove="%Removed", beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	java.util.List<Integer> listData5 = new java.util.ArrayList<Integer>

	def void listData5Removed(java.util.List<Integer> removedValues) {
	}

	protected def void listData5Removed(String fieldName, java.util.List<Integer> removedValues) {
	}

	@RemoverRule(multiple=true, beforeRemove="%BeforeRemove", afterRemove="%Removed", beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	java.util.Set<Integer> setData6 = new java.util.HashSet<Integer>

	def void setData6BeforeRemove(java.util.List<Integer> removedValues) {
	}

	def void setData6BeforeRemove() {
	}

	@RemoverRule(multiple=true, beforeRemove="%BeforeRemove", afterRemove="%Removed", beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	java.util.List<Integer> listData7 = new java.util.ArrayList<Integer>

	def void listData7ElementRemoved(Integer removedValue) {
	}

	protected def void listData7ElementRemoved(int index, Integer removedValue) {
	}

	@RemoverRule(multiple=true, beforeRemove="%BeforeRemove", afterRemove="%Removed", beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	java.util.Set<Integer> setData8 = new java.util.HashSet<Integer>

	def boolean setData8BeforeElementRemove(Integer removedValue) {
		return true
	}

	def void setData8BeforeElementRemove(String fieldName, Integer removedValue) {
	}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazzWithMultipleCandidates = findClass("virtual.ClassWithMultipleCandidates")

			val problemsListData1 = (clazzWithMultipleCandidates.findDeclaredField("listData1").
				primarySourceElement as FieldDeclaration).problems
			val problemsListData2 = (clazzWithMultipleCandidates.findDeclaredField("listData2").
				primarySourceElement as FieldDeclaration).problems
			val problemsListData3 = (clazzWithMultipleCandidates.findDeclaredField("listData3").
				primarySourceElement as FieldDeclaration).problems
			val problemsListData4 = (clazzWithMultipleCandidates.findDeclaredField("listData4").
				primarySourceElement as FieldDeclaration).problems
			val problemsListData5 = (clazzWithMultipleCandidates.findDeclaredField("listData5").
				primarySourceElement as FieldDeclaration).problems
			val problemsListData6 = (clazzWithMultipleCandidates.findDeclaredField("setData6").
				primarySourceElement as FieldDeclaration).problems
			val problemsListData7 = (clazzWithMultipleCandidates.findDeclaredField("listData7").
				primarySourceElement as FieldDeclaration).problems
			val problemsListData8 = (clazzWithMultipleCandidates.findDeclaredField("setData8").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(1, problemsListData1.size)
			assertEquals(Severity.ERROR, problemsListData1.get(0).severity)
			assertTrue(problemsListData1.get(0).message.contains("candidates"))

			assertEquals(1, problemsListData2.size)
			assertEquals(Severity.ERROR, problemsListData2.get(0).severity)
			assertTrue(problemsListData2.get(0).message.contains("candidates"))

			assertEquals(1, problemsListData3.size)
			assertEquals(Severity.ERROR, problemsListData3.get(0).severity)
			assertTrue(problemsListData3.get(0).message.contains("candidates"))

			assertEquals(1, problemsListData4.size)
			assertEquals(Severity.ERROR, problemsListData4.get(0).severity)
			assertTrue(problemsListData4.get(0).message.contains("candidates"))

			assertEquals(1, problemsListData5.size)
			assertEquals(Severity.ERROR, problemsListData5.get(0).severity)
			assertTrue(problemsListData5.get(0).message.contains("candidates"))

			assertEquals(1, problemsListData6.size)
			assertEquals(Severity.ERROR, problemsListData6.get(0).severity)
			assertTrue(problemsListData6.get(0).message.contains("candidates"))

			assertEquals(1, problemsListData7.size)
			assertEquals(Severity.ERROR, problemsListData7.get(0).severity)
			assertTrue(problemsListData7.get(0).message.contains("candidates"))

			assertEquals(1, problemsListData8.size)
			assertEquals(Severity.ERROR, problemsListData8.get(0).severity)
			assertTrue(problemsListData8.get(0).message.contains("candidates"))

			assertEquals(8, allProblems.size)

		]

	}

	@Test
	def void testMapNotSupported() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule

@ApplyRules
class ClassWithAdderRemover {

	@AdderRule(beforeAdd="m1", afterAdd="m2", afterElementAdd="m3", beforeElementAdd="m4")
	java.util.Map<String, Integer> dataWithAdder = new java.util.HashMap<String, Integer>

	@RemoverRule(beforeRemove="n1", afterRemove="n2", afterElementRemove="n3", beforeElementRemove="n4")
	java.util.Map<String, Integer> dataWithRemover = new java.util.HashMap<String, Integer>

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass("virtual.ClassWithAdderRemover")

			val problemsAttributeDataWithAdder = (clazz.findDeclaredField("dataWithAdder").
				primarySourceElement as FieldDeclaration).problems
			val problemsAttributeDataWithRemover = (clazz.findDeclaredField("dataWithRemover").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(4, problemsAttributeDataWithAdder.size)
			assertEquals(Severity.ERROR, problemsAttributeDataWithAdder.get(0).severity)
			assertTrue(problemsAttributeDataWithAdder.get(0).message.contains("support"))
			assertEquals(Severity.ERROR, problemsAttributeDataWithAdder.get(1).severity)
			assertTrue(problemsAttributeDataWithAdder.get(1).message.contains("support"))
			assertEquals(Severity.ERROR, problemsAttributeDataWithAdder.get(2).severity)
			assertTrue(problemsAttributeDataWithAdder.get(2).message.contains("support"))
			assertEquals(Severity.ERROR, problemsAttributeDataWithAdder.get(3).severity)
			assertTrue(problemsAttributeDataWithAdder.get(3).message.contains("support"))

			assertEquals(4, problemsAttributeDataWithRemover.size)
			assertEquals(Severity.ERROR, problemsAttributeDataWithRemover.get(0).severity)
			assertTrue(problemsAttributeDataWithRemover.get(0).message.contains("support"))
			assertEquals(Severity.ERROR, problemsAttributeDataWithRemover.get(1).severity)
			assertTrue(problemsAttributeDataWithRemover.get(1).message.contains("support"))
			assertEquals(Severity.ERROR, problemsAttributeDataWithRemover.get(2).severity)
			assertTrue(problemsAttributeDataWithRemover.get(2).message.contains("support"))
			assertEquals(Severity.ERROR, problemsAttributeDataWithRemover.get(3).severity)
			assertTrue(problemsAttributeDataWithRemover.get(3).message.contains("support"))

			assertEquals(8, allProblems.size)

		]

	}

}
