package org.eclipse.xtend.lib.annotation.etai.tests.adaption

import java.util.HashSet
import java.util.Set
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.BidirectionalRule
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.ExtendedByAuto
import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.NotNullRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule
import org.eclipse.xtend.lib.annotation.etai.SetterRule
import org.eclipse.xtend.lib.annotation.etai.SynchronizationRule
import org.eclipse.xtend.lib.annotation.etai.TraitClass
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IBidirectionalInterfaceB
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IBidirectionalOnlyInterfaceA
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IBidirectionalOnlyInterfaceB
import org.eclipse.xtend.lib.annotation.etai.tests.adaption.intf.IBidirectionalWithoutGenerationBBaseTrait
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Test

import static org.junit.Assert.*

@ApplyRules
class BidirectionalSelf {

	@GetterRule
	@SetterRule
	@BidirectionalRule("other")
	BidirectionalSelf other

}

@ApplyRules
class BidirectionalA<T> {

	public int singleBBeforeChangeCount = 0;
	public int singleBAfterChangeCount = 0;
	public int singleMultiBBeforeChangeCount = 0;
	public int singleMultiBAfterChangeCount = 0;
	public int multiMultiBBeforeAddCount = 0;
	public int multiMultiBAfterAddCount = 0;
	public int multiMultiBBeforeRemoveCount = 0;
	public int multiMultiBAfterRemoveCount = 0;

	def protected int singleBBeforeChange() {
		singleBBeforeChangeCount++
	}

	def protected singleBChanged() {
		singleBAfterChangeCount++
	}

	def protected int singleMultiBBeforeChange() {
		singleMultiBBeforeChangeCount++
	}

	def protected singleMultiBChanged() {
		singleMultiBAfterChangeCount++
	}

	def protected int multiMultiBBeforeElementAdd(BidirectionalB element) {
		multiMultiBBeforeAddCount++
	}

	def protected multiMultiBElementAdded(BidirectionalB element) {
		multiMultiBAfterAddCount++
	}

	def protected int multiMultiBBeforeElementRemove(BidirectionalB element) {
		multiMultiBBeforeRemoveCount++
	}

	def protected multiMultiBElementRemoved(BidirectionalB element) {
		multiMultiBAfterRemoveCount++
	}

	@GetterRule
	@SetterRule(beforeChange="%BeforeChange", afterChange="%Changed")
	@BidirectionalRule("singleA")
	@SynchronizationRule("BidiLock")
	BidirectionalB singleB

	@GetterRule
	@SetterRule(beforeChange="%BeforeChange", afterChange="%Changed")
	@BidirectionalRule("multiSingleA")
	@SynchronizationRule("BidiLock")
	BidirectionalB singleMultiB

	@AdderRule(single=true, multiple=true, beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	@RemoverRule(single=true, multiple=true, beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	@BidirectionalRule("multiMultiA")
	@SynchronizationRule("BidiLock")
	@GetterRule
	Set<BidirectionalB> multiMultiB = new HashSet<BidirectionalB>

	@GetterRule
	@SynchronizationRule("BidiLock")
	@SetterRule
	@BidirectionalRule("multiSingleANotNull")
	@NotNullRule
	BidirectionalB singleMultiBNotNull

}

@ApplyRules
class BidirectionalB {

	public int singleABeforeChangeCount = 0;
	public int singleAAfterChangeCount = 0;
	public int multiSingleABeforeAddCount = 0;
	public int multiSingleAAfterAddCount = 0;
	public int multiSingleABeforeRemoveCount = 0;
	public int multiSingleAAfterRemoveCount = 0;
	public int multiMultiABeforeAddCount = 0;
	public int multiMultiAAfterAddCount = 0;
	public int multiMultiABeforeRemoveCount = 0;
	public int multiMultiAAfterRemoveCount = 0;

	def protected int singleABeforeChange() {
		singleABeforeChangeCount++
	}

	def protected singleAChanged() {
		singleAAfterChangeCount++
	}

	def protected int multiSingleABeforeElementAdd(BidirectionalA<Integer> element) {
		multiSingleABeforeAddCount++
	}

	def protected int multiSingleAElementAdded(BidirectionalA<Integer> element) {
		multiSingleAAfterAddCount++
	}

	def protected multiSingleABeforeElementRemove(BidirectionalA<Integer> element) {
		multiSingleABeforeRemoveCount++
	}

	def protected multiSingleAElementRemoved(BidirectionalA<Integer> element) {
		multiSingleAAfterRemoveCount++
	}

	def protected int multiMultiABeforeElementAdd(BidirectionalA<Integer> element) {
		multiMultiABeforeAddCount++
	}

	def protected multiMultiAElementAdded(BidirectionalA<Integer> element) {
		multiMultiAAfterAddCount++
	}

	def protected int multiMultiABeforeElementRemove(BidirectionalA<Integer> element) {
		multiMultiABeforeRemoveCount++
	}

	def protected multiMultiAElementRemoved(BidirectionalA<Integer> element) {
		multiMultiAAfterRemoveCount++
	}

	@GetterRule
	@SetterRule(beforeChange="%BeforeChange", afterChange="%Changed")
	@SynchronizationRule("BidiLock")
	@BidirectionalRule("singleB")
	BidirectionalA<Integer> singleA

	@AdderRule(single=true, multiple=true, beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	@RemoverRule(single=true, multiple=true, beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	@BidirectionalRule("singleMultiB")
	@GetterRule
	@SynchronizationRule("BidiLock")
	Set<BidirectionalA<Integer>> multiSingleA = new HashSet<BidirectionalA<Integer>>

	@AdderRule(single=true, multiple=true, beforeElementAdd="%BeforeElementAdd", afterElementAdd="%ElementAdded")
	@RemoverRule(single=true, multiple=true, beforeElementRemove="%BeforeElementRemove", afterElementRemove="%ElementRemoved")
	@BidirectionalRule("multiMultiB")
	@GetterRule
	@SynchronizationRule("BidiLock")
	Set<BidirectionalA<Integer>> multiMultiA = new HashSet<BidirectionalA<Integer>>

	@AdderRule(single=true, multiple=true)
	@RemoverRule(single=true, multiple=true)
	@BidirectionalRule("singleMultiBNotNull")
	@GetterRule
	@SynchronizationRule("BidiLock")
	Set<BidirectionalA<Integer>> multiSingleANotNull = new HashSet<BidirectionalA<Integer>>

}

interface IBidirectionalInterfaceA {

	def boolean addToMultiB(IBidirectionalInterfaceB element)

	def boolean removeFromMultiB(IBidirectionalInterfaceB element)

	def boolean setSingleB(IBidirectionalInterfaceB value)

}

@ApplyRules
class BidirectionalInterfaceA implements IBidirectionalInterfaceA {

	@BidirectionalRule("singleA")
	@AdderRule(single=true, multiple=true)
	@RemoverRule(single=true, multiple=true)
	@GetterRule
	Set<IBidirectionalInterfaceB> multiB = new HashSet<IBidirectionalInterfaceB>

	@BidirectionalRule("multiA")
	@SetterRule
	@GetterRule
	IBidirectionalInterfaceB singleB

}

@ApplyRules
@ExtractInterface
class BidirectionalInterfaceB {

	@GetterRule
	@SetterRule
	@BidirectionalRule("multiB")
	IBidirectionalInterfaceA singleA

	@GetterRule
	@AdderRule(single=true, multiple=true)
	@RemoverRule(single=true, multiple=true)
	@BidirectionalRule("singleB")
	Set<IBidirectionalInterfaceA> multiA = new HashSet<IBidirectionalInterfaceA>

}

@ApplyRules
@ExtractInterface
class BidirectionalOnlyInterfaceA {

	@BidirectionalRule("singleA")
	@AdderRule(single=true, multiple=true)
	@RemoverRule(single=true, multiple=true)
	@GetterRule
	Set<IBidirectionalOnlyInterfaceB> multiB = new HashSet<IBidirectionalOnlyInterfaceB>

	@BidirectionalRule("multiA")
	@SetterRule
	@GetterRule
	IBidirectionalOnlyInterfaceB singleB

}

@ApplyRules
@ExtractInterface
class BidirectionalOnlyInterfaceB {

	@GetterRule
	@SetterRule
	@BidirectionalRule("multiB")
	IBidirectionalOnlyInterfaceA singleA

	@GetterRule
	@AdderRule(single=true, multiple=true)
	@RemoverRule(single=true, multiple=true)
	@BidirectionalRule("singleB")
	Set<IBidirectionalOnlyInterfaceA> multiA = new HashSet<IBidirectionalOnlyInterfaceA>

}

@ApplyRules
class BidirectionalWithoutGenerationA {

	@GetterRule
	@SetterRule
	@BidirectionalRule("singleA")
	BidirectionalWithoutGenerationB singleB

	@GetterRule
	@SetterRule
	@BidirectionalRule("multiSingleA")
	BidirectionalWithoutGenerationB singleMultiB

}

@TraitClass
abstract class BidirectionalWithoutGenerationBBaseTrait {

	public int calledAddToMultiSingleA = 0

	@ExclusiveMethod
	override void addToMultiSingleA(BidirectionalWithoutGenerationA element) {
		calledAddToMultiSingleA++;
	}

	@ExclusiveMethod
	override int getCalledAddToMultiSingleA() {
		calledAddToMultiSingleA
	}

}

@ApplyRules
@ExtendedByAuto
abstract class BidirectionalWithoutGenerationBBase implements IBidirectionalWithoutGenerationBBaseTrait {
}

@ApplyRules
class BidirectionalWithoutGenerationB extends BidirectionalWithoutGenerationBBase {

	public int calledSetSingleA = 0
	public int calledRemoveFromMultiSingleA = 0

	def void setSingleA(BidirectionalWithoutGenerationA bidirectionalWithoutGenerationA) {
		calledSetSingleA++;
	}

	def void removeFromMultiSingleA(BidirectionalWithoutGenerationA element) {
		calledRemoveFromMultiSingleA++;
	}

}

class BidirectionalTests {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Extension.classLoader)

	@Test
	def void testBidirectionalSelf() {

		val obj1 = new BidirectionalSelf
		val obj2 = new BidirectionalSelf
		val obj3 = new BidirectionalSelf

		assertNull(obj1.other)
		assertNull(obj2.other)
		assertNull(obj3.other)

		obj1.other = obj2
		assertSame(obj1.other, obj2)
		assertSame(obj2.other, obj1)
		assertNull(obj3.other)

		obj2.other = obj3
		assertNull(obj1.other)
		assertSame(obj3.other, obj2)
		assertSame(obj2.other, obj3)

		obj2.other = null
		assertNull(obj1.other)
		assertNull(obj2.other)
		assertNull(obj3.other)

	}

	@Test
	def void testBidirectionalSingleSingle() {

		val objA1 = new BidirectionalA
		val objA2 = new BidirectionalA
		val objB1 = new BidirectionalB
		val objB2 = new BidirectionalB

		assertNull(objA1.singleB)
		assertNull(objA2.singleB)
		assertNull(objB1.singleA)
		assertNull(objB2.singleA)

		assertTrue(objA1.singleB = objB1)

		assertSame(objB1, objA1.singleB)
		assertNull(objA2.singleB)
		assertSame(objA1, objB1.singleA)
		assertNull(objB2.singleA)

		assertEquals(1, objA1.singleBBeforeChangeCount)
		assertEquals(1, objA1.singleBAfterChangeCount)
		assertEquals(0, objA2.singleBBeforeChangeCount)
		assertEquals(0, objA2.singleBAfterChangeCount)
		assertEquals(1, objB1.singleABeforeChangeCount)
		assertEquals(1, objB1.singleAAfterChangeCount)
		assertEquals(0, objB2.singleABeforeChangeCount)
		assertEquals(0, objB2.singleAAfterChangeCount)

		assertTrue(objA1.singleB = objB2)

		assertSame(objB2, objA1.singleB)
		assertNull(objA2.singleB)
		assertNull(objB1.singleA)
		assertSame(objA1, objB2.singleA)

		assertEquals(2, objA1.singleBBeforeChangeCount)
		assertEquals(2, objA1.singleBAfterChangeCount)
		assertEquals(0, objA2.singleBBeforeChangeCount)
		assertEquals(0, objA2.singleBAfterChangeCount)
		assertEquals(2, objB1.singleABeforeChangeCount)
		assertEquals(2, objB1.singleAAfterChangeCount)
		assertEquals(1, objB2.singleABeforeChangeCount)
		assertEquals(1, objB2.singleAAfterChangeCount)

		assertTrue(objA2.singleB = objB1)

		assertSame(objB2, objA1.singleB)
		assertSame(objB1, objA2.singleB)
		assertSame(objA2, objB1.singleA)
		assertSame(objA1, objB2.singleA)

		assertEquals(2, objA1.singleBBeforeChangeCount)
		assertEquals(2, objA1.singleBAfterChangeCount)
		assertEquals(1, objA2.singleBBeforeChangeCount)
		assertEquals(1, objA2.singleBAfterChangeCount)
		assertEquals(3, objB1.singleABeforeChangeCount)
		assertEquals(3, objB1.singleAAfterChangeCount)
		assertEquals(1, objB2.singleABeforeChangeCount)
		assertEquals(1, objB2.singleAAfterChangeCount)

		assertTrue(objA2.singleB = objB2)

		assertNull(objA1.singleB)
		assertSame(objB2, objA2.singleB)
		assertNull(objB1.singleA)
		assertSame(objA2, objB2.singleA)

		assertEquals(3, objA1.singleBBeforeChangeCount)
		assertEquals(3, objA1.singleBAfterChangeCount)
		assertEquals(2, objA2.singleBBeforeChangeCount)
		assertEquals(2, objA2.singleBAfterChangeCount)
		assertEquals(4, objB1.singleABeforeChangeCount)
		assertEquals(4, objB1.singleAAfterChangeCount)
		assertEquals(2, objB2.singleABeforeChangeCount)
		assertEquals(2, objB2.singleAAfterChangeCount)

		assertTrue(objA2.singleB = null)

		assertNull(objA1.singleB)
		assertNull(objA2.singleB)
		assertNull(objB1.singleA)
		assertNull(objB2.singleA)

		assertEquals(3, objA1.singleBBeforeChangeCount)
		assertEquals(3, objA1.singleBAfterChangeCount)
		assertEquals(3, objA2.singleBBeforeChangeCount)
		assertEquals(3, objA2.singleBAfterChangeCount)
		assertEquals(4, objB1.singleABeforeChangeCount)
		assertEquals(4, objB1.singleAAfterChangeCount)
		assertEquals(3, objB2.singleABeforeChangeCount)
		assertEquals(3, objB2.singleAAfterChangeCount)

	}

	@Test
	def void testBidirectionalSingleMulti() {

		val objA1 = new BidirectionalA
		val objA2 = new BidirectionalA
		val objB1 = new BidirectionalB
		val objB2 = new BidirectionalB
		val objB3 = new BidirectionalB

		assertNull(objA1.singleMultiB)
		assertNull(objA2.singleMultiB)
		assertTrue(!objB1.multiSingleA.contains(objA1))
		assertTrue(!objB1.multiSingleA.contains(objA2))
		assertTrue(!objB2.multiSingleA.contains(objA1))
		assertTrue(!objB2.multiSingleA.contains(objA2))
		assertTrue(!objB3.multiSingleA.contains(objA1))
		assertTrue(!objB3.multiSingleA.contains(objA2))

		assertTrue(objA1.singleMultiB = objB1)

		assertSame(objB1, objA1.singleMultiB)
		assertNull(objA2.singleMultiB)
		assertTrue(objB1.multiSingleA.contains(objA1))
		assertTrue(!objB1.multiSingleA.contains(objA2))
		assertTrue(!objB2.multiSingleA.contains(objA1))
		assertTrue(!objB2.multiSingleA.contains(objA2))
		assertTrue(!objB3.multiSingleA.contains(objA1))
		assertTrue(!objB3.multiSingleA.contains(objA2))

		assertEquals(1, objA1.singleMultiBBeforeChangeCount)
		assertEquals(1, objA1.singleMultiBAfterChangeCount)
		assertEquals(0, objA2.singleMultiBBeforeChangeCount)
		assertEquals(0, objA2.singleMultiBAfterChangeCount)
		assertEquals(1, objB1.multiSingleABeforeAddCount)
		assertEquals(1, objB1.multiSingleAAfterAddCount)
		assertEquals(0, objB1.multiSingleABeforeRemoveCount)
		assertEquals(0, objB1.multiSingleAAfterRemoveCount)
		assertEquals(0, objB2.multiSingleABeforeAddCount)
		assertEquals(0, objB2.multiSingleAAfterAddCount)
		assertEquals(0, objB2.multiSingleABeforeRemoveCount)
		assertEquals(0, objB2.multiSingleAAfterRemoveCount)
		assertEquals(0, objB3.multiSingleABeforeAddCount)
		assertEquals(0, objB3.multiSingleAAfterAddCount)
		assertEquals(0, objB3.multiSingleABeforeRemoveCount)
		assertEquals(0, objB3.multiSingleAAfterRemoveCount)

		assertTrue(objA1.singleMultiB = objB2)

		assertSame(objB2, objA1.singleMultiB)
		assertNull(objA2.singleMultiB)
		assertTrue(!objB1.multiSingleA.contains(objA1))
		assertTrue(!objB1.multiSingleA.contains(objA2))
		assertTrue(objB2.multiSingleA.contains(objA1))
		assertTrue(!objB2.multiSingleA.contains(objA2))
		assertTrue(!objB3.multiSingleA.contains(objA1))
		assertTrue(!objB3.multiSingleA.contains(objA2))

		assertEquals(2, objA1.singleMultiBBeforeChangeCount)
		assertEquals(2, objA1.singleMultiBAfterChangeCount)
		assertEquals(0, objA2.singleMultiBBeforeChangeCount)
		assertEquals(0, objA2.singleMultiBAfterChangeCount)
		assertEquals(1, objB1.multiSingleABeforeAddCount)
		assertEquals(1, objB1.multiSingleAAfterAddCount)
		assertEquals(1, objB1.multiSingleABeforeRemoveCount)
		assertEquals(1, objB1.multiSingleAAfterRemoveCount)
		assertEquals(1, objB2.multiSingleABeforeAddCount)
		assertEquals(1, objB2.multiSingleAAfterAddCount)
		assertEquals(0, objB2.multiSingleABeforeRemoveCount)
		assertEquals(0, objB2.multiSingleAAfterRemoveCount)
		assertEquals(0, objB3.multiSingleABeforeAddCount)
		assertEquals(0, objB3.multiSingleAAfterAddCount)
		assertEquals(0, objB3.multiSingleABeforeRemoveCount)
		assertEquals(0, objB3.multiSingleAAfterRemoveCount)

		assertTrue(objA1.singleMultiB = null)

		assertNull(objA1.singleMultiB)
		assertNull(objA2.singleMultiB)
		assertTrue(!objB1.multiSingleA.contains(objA1))
		assertTrue(!objB1.multiSingleA.contains(objA2))
		assertTrue(!objB2.multiSingleA.contains(objA1))
		assertTrue(!objB2.multiSingleA.contains(objA2))
		assertTrue(!objB3.multiSingleA.contains(objA1))
		assertTrue(!objB3.multiSingleA.contains(objA2))

		assertEquals(3, objA1.singleMultiBBeforeChangeCount)
		assertEquals(3, objA1.singleMultiBAfterChangeCount)
		assertEquals(0, objA2.singleMultiBBeforeChangeCount)
		assertEquals(0, objA2.singleMultiBAfterChangeCount)
		assertEquals(1, objB1.multiSingleABeforeAddCount)
		assertEquals(1, objB1.multiSingleAAfterAddCount)
		assertEquals(1, objB1.multiSingleABeforeRemoveCount)
		assertEquals(1, objB1.multiSingleAAfterRemoveCount)
		assertEquals(1, objB2.multiSingleABeforeAddCount)
		assertEquals(1, objB2.multiSingleAAfterAddCount)
		assertEquals(1, objB2.multiSingleABeforeRemoveCount)
		assertEquals(1, objB2.multiSingleAAfterRemoveCount)
		assertEquals(0, objB3.multiSingleABeforeAddCount)
		assertEquals(0, objB3.multiSingleAAfterAddCount)
		assertEquals(0, objB3.multiSingleABeforeRemoveCount)
		assertEquals(0, objB3.multiSingleAAfterRemoveCount)

		assertTrue(objA1.singleMultiB = objB2)

		assertSame(objB2, objA1.singleMultiB)
		assertNull(objA2.singleMultiB)
		assertTrue(!objB1.multiSingleA.contains(objA1))
		assertTrue(!objB1.multiSingleA.contains(objA2))
		assertTrue(objB2.multiSingleA.contains(objA1))
		assertTrue(!objB2.multiSingleA.contains(objA2))
		assertTrue(!objB3.multiSingleA.contains(objA1))
		assertTrue(!objB3.multiSingleA.contains(objA2))

		assertEquals(4, objA1.singleMultiBBeforeChangeCount)
		assertEquals(4, objA1.singleMultiBAfterChangeCount)
		assertEquals(0, objA2.singleMultiBBeforeChangeCount)
		assertEquals(0, objA2.singleMultiBAfterChangeCount)
		assertEquals(1, objB1.multiSingleABeforeAddCount)
		assertEquals(1, objB1.multiSingleAAfterAddCount)
		assertEquals(1, objB1.multiSingleABeforeRemoveCount)
		assertEquals(1, objB1.multiSingleAAfterRemoveCount)
		assertEquals(2, objB2.multiSingleABeforeAddCount)
		assertEquals(2, objB2.multiSingleAAfterAddCount)
		assertEquals(1, objB2.multiSingleABeforeRemoveCount)
		assertEquals(1, objB2.multiSingleAAfterRemoveCount)
		assertEquals(0, objB3.multiSingleABeforeAddCount)
		assertEquals(0, objB3.multiSingleAAfterAddCount)
		assertEquals(0, objB3.multiSingleABeforeRemoveCount)
		assertEquals(0, objB3.multiSingleAAfterRemoveCount)

		assertTrue(objA2.singleMultiB = objB2)

		assertSame(objB2, objA1.singleMultiB)
		assertSame(objB2, objA2.singleMultiB)
		assertTrue(!objB1.multiSingleA.contains(objA1))
		assertTrue(!objB1.multiSingleA.contains(objA2))
		assertTrue(objB2.multiSingleA.contains(objA1))
		assertTrue(objB2.multiSingleA.contains(objA2))
		assertTrue(!objB3.multiSingleA.contains(objA1))
		assertTrue(!objB3.multiSingleA.contains(objA2))

		assertEquals(4, objA1.singleMultiBBeforeChangeCount)
		assertEquals(4, objA1.singleMultiBAfterChangeCount)
		assertEquals(1, objA2.singleMultiBBeforeChangeCount)
		assertEquals(1, objA2.singleMultiBAfterChangeCount)
		assertEquals(1, objB1.multiSingleABeforeAddCount)
		assertEquals(1, objB1.multiSingleAAfterAddCount)
		assertEquals(1, objB1.multiSingleABeforeRemoveCount)
		assertEquals(1, objB1.multiSingleAAfterRemoveCount)
		assertEquals(3, objB2.multiSingleABeforeAddCount)
		assertEquals(3, objB2.multiSingleAAfterAddCount)
		assertEquals(1, objB2.multiSingleABeforeRemoveCount)
		assertEquals(1, objB2.multiSingleAAfterRemoveCount)
		assertEquals(0, objB3.multiSingleABeforeAddCount)
		assertEquals(0, objB3.multiSingleAAfterAddCount)
		assertEquals(0, objB3.multiSingleABeforeRemoveCount)
		assertEquals(0, objB3.multiSingleAAfterRemoveCount)

		assertTrue(objA1.singleMultiB = null)

		assertNull(objA1.singleMultiB)
		assertSame(objB2, objA2.singleMultiB)
		assertTrue(!objB1.multiSingleA.contains(objA1))
		assertTrue(!objB1.multiSingleA.contains(objA2))
		assertTrue(!objB2.multiSingleA.contains(objA1))
		assertTrue(objB2.multiSingleA.contains(objA2))
		assertTrue(!objB3.multiSingleA.contains(objA1))
		assertTrue(!objB3.multiSingleA.contains(objA2))

		assertEquals(5, objA1.singleMultiBBeforeChangeCount)
		assertEquals(5, objA1.singleMultiBAfterChangeCount)
		assertEquals(1, objA2.singleMultiBBeforeChangeCount)
		assertEquals(1, objA2.singleMultiBAfterChangeCount)
		assertEquals(1, objB1.multiSingleABeforeAddCount)
		assertEquals(1, objB1.multiSingleAAfterAddCount)
		assertEquals(1, objB1.multiSingleABeforeRemoveCount)
		assertEquals(1, objB1.multiSingleAAfterRemoveCount)
		assertEquals(3, objB2.multiSingleABeforeAddCount)
		assertEquals(3, objB2.multiSingleAAfterAddCount)
		assertEquals(2, objB2.multiSingleABeforeRemoveCount)
		assertEquals(2, objB2.multiSingleAAfterRemoveCount)
		assertEquals(0, objB3.multiSingleABeforeAddCount)
		assertEquals(0, objB3.multiSingleAAfterAddCount)
		assertEquals(0, objB3.multiSingleABeforeRemoveCount)
		assertEquals(0, objB3.multiSingleAAfterRemoveCount)

		assertTrue(objB2.addToMultiSingleA(objA1))

		assertSame(objB2, objA1.singleMultiB)
		assertSame(objB2, objA2.singleMultiB)
		assertTrue(!objB1.multiSingleA.contains(objA1))
		assertTrue(!objB1.multiSingleA.contains(objA2))
		assertTrue(objB2.multiSingleA.contains(objA1))
		assertTrue(objB2.multiSingleA.contains(objA2))
		assertTrue(!objB3.multiSingleA.contains(objA1))
		assertTrue(!objB3.multiSingleA.contains(objA2))

		assertEquals(6, objA1.singleMultiBBeforeChangeCount)
		assertEquals(6, objA1.singleMultiBAfterChangeCount)
		assertEquals(1, objA2.singleMultiBBeforeChangeCount)
		assertEquals(1, objA2.singleMultiBAfterChangeCount)
		assertEquals(1, objB1.multiSingleABeforeAddCount)
		assertEquals(1, objB1.multiSingleAAfterAddCount)
		assertEquals(1, objB1.multiSingleABeforeRemoveCount)
		assertEquals(1, objB1.multiSingleAAfterRemoveCount)
		assertEquals(4, objB2.multiSingleABeforeAddCount)
		assertEquals(4, objB2.multiSingleAAfterAddCount)
		assertEquals(2, objB2.multiSingleABeforeRemoveCount)
		assertEquals(2, objB2.multiSingleAAfterRemoveCount)
		assertEquals(0, objB3.multiSingleABeforeAddCount)
		assertEquals(0, objB3.multiSingleAAfterAddCount)
		assertEquals(0, objB3.multiSingleABeforeRemoveCount)
		assertEquals(0, objB3.multiSingleAAfterRemoveCount)

		assertTrue(objB2.removeFromMultiSingleA(objA1))

		assertNull(objA1.singleMultiB)
		assertSame(objB2, objA2.singleMultiB)
		assertTrue(!objB1.multiSingleA.contains(objA1))
		assertTrue(!objB1.multiSingleA.contains(objA2))
		assertTrue(!objB2.multiSingleA.contains(objA1))
		assertTrue(objB2.multiSingleA.contains(objA2))
		assertTrue(!objB3.multiSingleA.contains(objA1))
		assertTrue(!objB3.multiSingleA.contains(objA2))

		assertEquals(7, objA1.singleMultiBBeforeChangeCount)
		assertEquals(7, objA1.singleMultiBAfterChangeCount)
		assertEquals(1, objA2.singleMultiBBeforeChangeCount)
		assertEquals(1, objA2.singleMultiBAfterChangeCount)
		assertEquals(1, objB1.multiSingleABeforeAddCount)
		assertEquals(1, objB1.multiSingleAAfterAddCount)
		assertEquals(1, objB1.multiSingleABeforeRemoveCount)
		assertEquals(1, objB1.multiSingleAAfterRemoveCount)
		assertEquals(4, objB2.multiSingleABeforeAddCount)
		assertEquals(4, objB2.multiSingleAAfterAddCount)
		assertEquals(3, objB2.multiSingleABeforeRemoveCount)
		assertEquals(3, objB2.multiSingleAAfterRemoveCount)
		assertEquals(0, objB3.multiSingleABeforeAddCount)
		assertEquals(0, objB3.multiSingleAAfterAddCount)
		assertEquals(0, objB3.multiSingleABeforeRemoveCount)
		assertEquals(0, objB3.multiSingleAAfterRemoveCount)

		assertTrue(objB2.clearMultiSingleA())

		assertNull(objA1.singleMultiB)
		assertNull(objA2.singleMultiB)
		assertTrue(!objB1.multiSingleA.contains(objA1))
		assertTrue(!objB1.multiSingleA.contains(objA2))
		assertTrue(!objB2.multiSingleA.contains(objA1))
		assertTrue(!objB2.multiSingleA.contains(objA2))
		assertTrue(!objB3.multiSingleA.contains(objA1))
		assertTrue(!objB3.multiSingleA.contains(objA2))

		assertEquals(7, objA1.singleMultiBBeforeChangeCount)
		assertEquals(7, objA1.singleMultiBAfterChangeCount)
		assertEquals(2, objA2.singleMultiBBeforeChangeCount)
		assertEquals(2, objA2.singleMultiBAfterChangeCount)
		assertEquals(1, objB1.multiSingleABeforeAddCount)
		assertEquals(1, objB1.multiSingleAAfterAddCount)
		assertEquals(1, objB1.multiSingleABeforeRemoveCount)
		assertEquals(1, objB1.multiSingleAAfterRemoveCount)
		assertEquals(4, objB2.multiSingleABeforeAddCount)
		assertEquals(4, objB2.multiSingleAAfterAddCount)
		assertEquals(4, objB2.multiSingleABeforeRemoveCount)
		assertEquals(4, objB2.multiSingleAAfterRemoveCount)
		assertEquals(0, objB3.multiSingleABeforeAddCount)
		assertEquals(0, objB3.multiSingleAAfterAddCount)
		assertEquals(0, objB3.multiSingleABeforeRemoveCount)
		assertEquals(0, objB3.multiSingleAAfterRemoveCount)

		assertTrue(objB3.addAllToMultiSingleA(#[objA2, objA1]))

		assertSame(objB3, objA1.singleMultiB)
		assertSame(objB3, objA2.singleMultiB)
		assertTrue(!objB1.multiSingleA.contains(objA1))
		assertTrue(!objB1.multiSingleA.contains(objA2))
		assertTrue(!objB2.multiSingleA.contains(objA1))
		assertTrue(!objB2.multiSingleA.contains(objA2))
		assertTrue(objB3.multiSingleA.contains(objA1))
		assertTrue(objB3.multiSingleA.contains(objA2))

		assertEquals(8, objA1.singleMultiBBeforeChangeCount)
		assertEquals(8, objA1.singleMultiBAfterChangeCount)
		assertEquals(3, objA2.singleMultiBBeforeChangeCount)
		assertEquals(3, objA2.singleMultiBAfterChangeCount)
		assertEquals(1, objB1.multiSingleABeforeAddCount)
		assertEquals(1, objB1.multiSingleAAfterAddCount)
		assertEquals(1, objB1.multiSingleABeforeRemoveCount)
		assertEquals(1, objB1.multiSingleAAfterRemoveCount)
		assertEquals(4, objB2.multiSingleABeforeAddCount)
		assertEquals(4, objB2.multiSingleAAfterAddCount)
		assertEquals(4, objB2.multiSingleABeforeRemoveCount)
		assertEquals(4, objB2.multiSingleAAfterRemoveCount)
		assertEquals(2, objB3.multiSingleABeforeAddCount)
		assertEquals(2, objB3.multiSingleAAfterAddCount)
		assertEquals(0, objB3.multiSingleABeforeRemoveCount)
		assertEquals(0, objB3.multiSingleAAfterRemoveCount)

		assertTrue(objB3.removeAllFromMultiSingleA(#[objA1, objA2]))

		assertNull(objA1.singleMultiB)
		assertNull(objA2.singleMultiB)
		assertTrue(!objB1.multiSingleA.contains(objA1))
		assertTrue(!objB1.multiSingleA.contains(objA2))
		assertTrue(!objB2.multiSingleA.contains(objA1))
		assertTrue(!objB2.multiSingleA.contains(objA2))
		assertTrue(!objB3.multiSingleA.contains(objA1))
		assertTrue(!objB3.multiSingleA.contains(objA2))

		assertEquals(9, objA1.singleMultiBBeforeChangeCount)
		assertEquals(9, objA1.singleMultiBAfterChangeCount)
		assertEquals(4, objA2.singleMultiBBeforeChangeCount)
		assertEquals(4, objA2.singleMultiBAfterChangeCount)
		assertEquals(1, objB1.multiSingleABeforeAddCount)
		assertEquals(1, objB1.multiSingleAAfterAddCount)
		assertEquals(1, objB1.multiSingleABeforeRemoveCount)
		assertEquals(1, objB1.multiSingleAAfterRemoveCount)
		assertEquals(4, objB2.multiSingleABeforeAddCount)
		assertEquals(4, objB2.multiSingleAAfterAddCount)
		assertEquals(4, objB2.multiSingleABeforeRemoveCount)
		assertEquals(4, objB2.multiSingleAAfterRemoveCount)
		assertEquals(2, objB3.multiSingleABeforeAddCount)
		assertEquals(2, objB3.multiSingleAAfterAddCount)
		assertEquals(2, objB3.multiSingleABeforeRemoveCount)
		assertEquals(2, objB3.multiSingleAAfterRemoveCount)

		assertTrue(objA1.singleMultiB = objB1)

		assertSame(objB1, objA1.singleMultiB)
		assertNull(objA2.singleMultiB)
		assertTrue(objB1.multiSingleA.contains(objA1))
		assertTrue(!objB1.multiSingleA.contains(objA2))
		assertTrue(!objB2.multiSingleA.contains(objA1))
		assertTrue(!objB2.multiSingleA.contains(objA2))
		assertTrue(!objB3.multiSingleA.contains(objA1))
		assertTrue(!objB3.multiSingleA.contains(objA2))

		assertEquals(10, objA1.singleMultiBBeforeChangeCount)
		assertEquals(10, objA1.singleMultiBAfterChangeCount)
		assertEquals(4, objA2.singleMultiBBeforeChangeCount)
		assertEquals(4, objA2.singleMultiBAfterChangeCount)
		assertEquals(2, objB1.multiSingleABeforeAddCount)
		assertEquals(2, objB1.multiSingleAAfterAddCount)
		assertEquals(1, objB1.multiSingleABeforeRemoveCount)
		assertEquals(1, objB1.multiSingleAAfterRemoveCount)
		assertEquals(4, objB2.multiSingleABeforeAddCount)
		assertEquals(4, objB2.multiSingleAAfterAddCount)
		assertEquals(4, objB2.multiSingleABeforeRemoveCount)
		assertEquals(4, objB2.multiSingleAAfterRemoveCount)
		assertEquals(2, objB3.multiSingleABeforeAddCount)
		assertEquals(2, objB3.multiSingleAAfterAddCount)
		assertEquals(2, objB3.multiSingleABeforeRemoveCount)
		assertEquals(2, objB3.multiSingleAAfterRemoveCount)

		assertTrue(objB2.addToMultiSingleA(objA1))

		assertSame(objB2, objA1.singleMultiB)
		assertNull(objA2.singleMultiB)
		assertTrue(!objB1.multiSingleA.contains(objA1))
		assertTrue(!objB1.multiSingleA.contains(objA2))
		assertTrue(objB2.multiSingleA.contains(objA1))
		assertTrue(!objB2.multiSingleA.contains(objA2))
		assertTrue(!objB3.multiSingleA.contains(objA1))
		assertTrue(!objB3.multiSingleA.contains(objA2))

		assertEquals(11, objA1.singleMultiBBeforeChangeCount)
		assertEquals(11, objA1.singleMultiBAfterChangeCount)
		assertEquals(4, objA2.singleMultiBBeforeChangeCount)
		assertEquals(4, objA2.singleMultiBAfterChangeCount)
		assertEquals(2, objB1.multiSingleABeforeAddCount)
		assertEquals(2, objB1.multiSingleAAfterAddCount)
		assertEquals(2, objB1.multiSingleABeforeRemoveCount)
		assertEquals(2, objB1.multiSingleAAfterRemoveCount)
		assertEquals(5, objB2.multiSingleABeforeAddCount)
		assertEquals(5, objB2.multiSingleAAfterAddCount)
		assertEquals(4, objB2.multiSingleABeforeRemoveCount)
		assertEquals(4, objB2.multiSingleAAfterRemoveCount)
		assertEquals(2, objB3.multiSingleABeforeAddCount)
		assertEquals(2, objB3.multiSingleAAfterAddCount)
		assertEquals(2, objB3.multiSingleABeforeRemoveCount)
		assertEquals(2, objB3.multiSingleAAfterRemoveCount)

		assertTrue(objB3.addAllToMultiSingleA(#[objA1, objA2]))

		assertSame(objB3, objA1.singleMultiB)
		assertSame(objB3, objA2.singleMultiB)
		assertTrue(!objB1.multiSingleA.contains(objA1))
		assertTrue(!objB1.multiSingleA.contains(objA2))
		assertTrue(!objB2.multiSingleA.contains(objA1))
		assertTrue(!objB2.multiSingleA.contains(objA2))
		assertTrue(objB3.multiSingleA.contains(objA1))
		assertTrue(objB3.multiSingleA.contains(objA2))

		assertEquals(12, objA1.singleMultiBBeforeChangeCount)
		assertEquals(12, objA1.singleMultiBAfterChangeCount)
		assertEquals(5, objA2.singleMultiBBeforeChangeCount)
		assertEquals(5, objA2.singleMultiBAfterChangeCount)
		assertEquals(2, objB1.multiSingleABeforeAddCount)
		assertEquals(2, objB1.multiSingleAAfterAddCount)
		assertEquals(2, objB1.multiSingleABeforeRemoveCount)
		assertEquals(2, objB1.multiSingleAAfterRemoveCount)
		assertEquals(5, objB2.multiSingleABeforeAddCount)
		assertEquals(5, objB2.multiSingleAAfterAddCount)
		assertEquals(5, objB2.multiSingleABeforeRemoveCount)
		assertEquals(5, objB2.multiSingleAAfterRemoveCount)
		assertEquals(4, objB3.multiSingleABeforeAddCount)
		assertEquals(4, objB3.multiSingleAAfterAddCount)
		assertEquals(2, objB3.multiSingleABeforeRemoveCount)
		assertEquals(2, objB3.multiSingleAAfterRemoveCount)

	}

	@Test
	def void testBidirectionalSingleMultiNotNull() {

		var boolean exceptionThrown

		val objA = new BidirectionalA
		val objB1 = new BidirectionalB
		val objB2 = new BidirectionalB

		objA.singleMultiBNotNull = objB1

		assertSame(objB1, objA.singleMultiBNotNull)
		assertTrue(objB1.multiSingleANotNull.contains(objA))
		assertTrue(!objB2.multiSingleANotNull.contains(objA))

		objA.singleMultiBNotNull = objB2

		assertSame(objB2, objA.singleMultiBNotNull)
		assertTrue(!objB1.multiSingleANotNull.contains(objA))
		assertTrue(objB2.multiSingleANotNull.contains(objA))

		exceptionThrown = false
		try {
			objB2.removeFromMultiSingleANotNull(objA)
		} catch (AssertionError assertionError) {
			exceptionThrown = true
		}
		assertTrue(exceptionThrown)

	}

	@Test
	def void testBidirectionalMultiMulti() {

		val objA1 = new BidirectionalA
		val objA2 = new BidirectionalA
		val objA3 = new BidirectionalA
		val objB1 = new BidirectionalB
		val objB2 = new BidirectionalB
		val objB3 = new BidirectionalB

		assertTrue(!objA1.multiMultiB.contains(objB1))
		assertTrue(!objA1.multiMultiB.contains(objB2))
		assertTrue(!objA1.multiMultiB.contains(objB3))
		assertTrue(!objA2.multiMultiB.contains(objB1))
		assertTrue(!objA2.multiMultiB.contains(objB2))
		assertTrue(!objA2.multiMultiB.contains(objB3))
		assertTrue(!objA3.multiMultiB.contains(objB1))
		assertTrue(!objA3.multiMultiB.contains(objB2))
		assertTrue(!objA3.multiMultiB.contains(objB3))
		assertTrue(!objB1.multiMultiA.contains(objA1))
		assertTrue(!objB1.multiMultiA.contains(objA2))
		assertTrue(!objB1.multiMultiA.contains(objA3))
		assertTrue(!objB2.multiMultiA.contains(objA1))
		assertTrue(!objB2.multiMultiA.contains(objA2))
		assertTrue(!objB2.multiMultiA.contains(objA3))
		assertTrue(!objB3.multiMultiA.contains(objA1))
		assertTrue(!objB3.multiMultiA.contains(objA2))
		assertTrue(!objB3.multiMultiA.contains(objA3))

		assertTrue(objA1.addToMultiMultiB(objB1))

		assertTrue(objA1.multiMultiB.contains(objB1))
		assertTrue(!objA1.multiMultiB.contains(objB2))
		assertTrue(!objA1.multiMultiB.contains(objB3))
		assertTrue(!objA2.multiMultiB.contains(objB1))
		assertTrue(!objA2.multiMultiB.contains(objB2))
		assertTrue(!objA2.multiMultiB.contains(objB3))
		assertTrue(!objA3.multiMultiB.contains(objB1))
		assertTrue(!objA3.multiMultiB.contains(objB2))
		assertTrue(!objA3.multiMultiB.contains(objB3))
		assertTrue(objB1.multiMultiA.contains(objA1))
		assertTrue(!objB1.multiMultiA.contains(objA2))
		assertTrue(!objB1.multiMultiA.contains(objA3))
		assertTrue(!objB2.multiMultiA.contains(objA1))
		assertTrue(!objB2.multiMultiA.contains(objA2))
		assertTrue(!objB2.multiMultiA.contains(objA3))
		assertTrue(!objB3.multiMultiA.contains(objA1))
		assertTrue(!objB3.multiMultiA.contains(objA2))
		assertTrue(!objB3.multiMultiA.contains(objA3))

		assertEquals(1, objA1.multiMultiBBeforeAddCount)
		assertEquals(1, objA1.multiMultiBAfterAddCount)
		assertEquals(0, objA1.multiMultiBBeforeRemoveCount)
		assertEquals(0, objA1.multiMultiBAfterRemoveCount)
		assertEquals(0, objA2.multiMultiBBeforeAddCount)
		assertEquals(0, objA2.multiMultiBAfterAddCount)
		assertEquals(0, objA2.multiMultiBBeforeRemoveCount)
		assertEquals(0, objA2.multiMultiBAfterRemoveCount)
		assertEquals(0, objA3.multiMultiBBeforeAddCount)
		assertEquals(0, objA3.multiMultiBAfterAddCount)
		assertEquals(0, objA3.multiMultiBBeforeRemoveCount)
		assertEquals(0, objA3.multiMultiBAfterRemoveCount)
		assertEquals(1, objB1.multiMultiABeforeAddCount)
		assertEquals(1, objB1.multiMultiAAfterAddCount)
		assertEquals(0, objB1.multiMultiABeforeRemoveCount)
		assertEquals(0, objB1.multiMultiAAfterRemoveCount)
		assertEquals(0, objB2.multiMultiABeforeAddCount)
		assertEquals(0, objB2.multiMultiAAfterAddCount)
		assertEquals(0, objB2.multiMultiABeforeRemoveCount)
		assertEquals(0, objB2.multiMultiAAfterRemoveCount)
		assertEquals(0, objB3.multiMultiABeforeAddCount)
		assertEquals(0, objB3.multiMultiAAfterAddCount)
		assertEquals(0, objB3.multiMultiABeforeRemoveCount)
		assertEquals(0, objB3.multiMultiAAfterRemoveCount)

		assertTrue(objA1.addToMultiMultiB(objB2))

		assertTrue(objA1.multiMultiB.contains(objB1))
		assertTrue(objA1.multiMultiB.contains(objB2))
		assertTrue(!objA1.multiMultiB.contains(objB3))
		assertTrue(!objA2.multiMultiB.contains(objB1))
		assertTrue(!objA2.multiMultiB.contains(objB2))
		assertTrue(!objA2.multiMultiB.contains(objB3))
		assertTrue(!objA3.multiMultiB.contains(objB1))
		assertTrue(!objA3.multiMultiB.contains(objB2))
		assertTrue(!objA3.multiMultiB.contains(objB3))
		assertTrue(objB1.multiMultiA.contains(objA1))
		assertTrue(!objB1.multiMultiA.contains(objA2))
		assertTrue(!objB1.multiMultiA.contains(objA3))
		assertTrue(objB2.multiMultiA.contains(objA1))
		assertTrue(!objB2.multiMultiA.contains(objA2))
		assertTrue(!objB2.multiMultiA.contains(objA3))
		assertTrue(!objB3.multiMultiA.contains(objA1))
		assertTrue(!objB3.multiMultiA.contains(objA2))
		assertTrue(!objB3.multiMultiA.contains(objA3))

		assertEquals(2, objA1.multiMultiBBeforeAddCount)
		assertEquals(2, objA1.multiMultiBAfterAddCount)
		assertEquals(0, objA1.multiMultiBBeforeRemoveCount)
		assertEquals(0, objA1.multiMultiBAfterRemoveCount)
		assertEquals(0, objA2.multiMultiBBeforeAddCount)
		assertEquals(0, objA2.multiMultiBAfterAddCount)
		assertEquals(0, objA2.multiMultiBBeforeRemoveCount)
		assertEquals(0, objA2.multiMultiBAfterRemoveCount)
		assertEquals(0, objA3.multiMultiBBeforeAddCount)
		assertEquals(0, objA3.multiMultiBAfterAddCount)
		assertEquals(0, objA3.multiMultiBBeforeRemoveCount)
		assertEquals(0, objA3.multiMultiBAfterRemoveCount)
		assertEquals(1, objB1.multiMultiABeforeAddCount)
		assertEquals(1, objB1.multiMultiAAfterAddCount)
		assertEquals(0, objB1.multiMultiABeforeRemoveCount)
		assertEquals(0, objB1.multiMultiAAfterRemoveCount)
		assertEquals(1, objB2.multiMultiABeforeAddCount)
		assertEquals(1, objB2.multiMultiAAfterAddCount)
		assertEquals(0, objB2.multiMultiABeforeRemoveCount)
		assertEquals(0, objB2.multiMultiAAfterRemoveCount)
		assertEquals(0, objB3.multiMultiABeforeAddCount)
		assertEquals(0, objB3.multiMultiAAfterAddCount)
		assertEquals(0, objB3.multiMultiABeforeRemoveCount)
		assertEquals(0, objB3.multiMultiAAfterRemoveCount)

		assertTrue(objB3.addToMultiMultiA(objA1))

		assertTrue(objA1.multiMultiB.contains(objB1))
		assertTrue(objA1.multiMultiB.contains(objB2))
		assertTrue(objA1.multiMultiB.contains(objB3))
		assertTrue(!objA2.multiMultiB.contains(objB1))
		assertTrue(!objA2.multiMultiB.contains(objB2))
		assertTrue(!objA2.multiMultiB.contains(objB3))
		assertTrue(!objA3.multiMultiB.contains(objB1))
		assertTrue(!objA3.multiMultiB.contains(objB2))
		assertTrue(!objA3.multiMultiB.contains(objB3))
		assertTrue(objB1.multiMultiA.contains(objA1))
		assertTrue(!objB1.multiMultiA.contains(objA2))
		assertTrue(!objB1.multiMultiA.contains(objA3))
		assertTrue(objB2.multiMultiA.contains(objA1))
		assertTrue(!objB2.multiMultiA.contains(objA2))
		assertTrue(!objB2.multiMultiA.contains(objA3))
		assertTrue(objB3.multiMultiA.contains(objA1))
		assertTrue(!objB3.multiMultiA.contains(objA2))
		assertTrue(!objB3.multiMultiA.contains(objA3))

		assertEquals(3, objA1.multiMultiBBeforeAddCount)
		assertEquals(3, objA1.multiMultiBAfterAddCount)
		assertEquals(0, objA1.multiMultiBBeforeRemoveCount)
		assertEquals(0, objA1.multiMultiBAfterRemoveCount)
		assertEquals(0, objA2.multiMultiBBeforeAddCount)
		assertEquals(0, objA2.multiMultiBAfterAddCount)
		assertEquals(0, objA2.multiMultiBBeforeRemoveCount)
		assertEquals(0, objA2.multiMultiBAfterRemoveCount)
		assertEquals(0, objA3.multiMultiBBeforeAddCount)
		assertEquals(0, objA3.multiMultiBAfterAddCount)
		assertEquals(0, objA3.multiMultiBBeforeRemoveCount)
		assertEquals(0, objA3.multiMultiBAfterRemoveCount)
		assertEquals(1, objB1.multiMultiABeforeAddCount)
		assertEquals(1, objB1.multiMultiAAfterAddCount)
		assertEquals(0, objB1.multiMultiABeforeRemoveCount)
		assertEquals(0, objB1.multiMultiAAfterRemoveCount)
		assertEquals(1, objB2.multiMultiABeforeAddCount)
		assertEquals(1, objB2.multiMultiAAfterAddCount)
		assertEquals(0, objB2.multiMultiABeforeRemoveCount)
		assertEquals(0, objB2.multiMultiAAfterRemoveCount)
		assertEquals(1, objB3.multiMultiABeforeAddCount)
		assertEquals(1, objB3.multiMultiAAfterAddCount)
		assertEquals(0, objB3.multiMultiABeforeRemoveCount)
		assertEquals(0, objB3.multiMultiAAfterRemoveCount)

		assertTrue(objB3.addToMultiMultiA(objA3))

		assertTrue(objA1.multiMultiB.contains(objB1))
		assertTrue(objA1.multiMultiB.contains(objB2))
		assertTrue(objA1.multiMultiB.contains(objB3))
		assertTrue(!objA2.multiMultiB.contains(objB1))
		assertTrue(!objA2.multiMultiB.contains(objB2))
		assertTrue(!objA2.multiMultiB.contains(objB3))
		assertTrue(!objA3.multiMultiB.contains(objB1))
		assertTrue(!objA3.multiMultiB.contains(objB2))
		assertTrue(objA3.multiMultiB.contains(objB3))
		assertTrue(objB1.multiMultiA.contains(objA1))
		assertTrue(!objB1.multiMultiA.contains(objA2))
		assertTrue(!objB1.multiMultiA.contains(objA3))
		assertTrue(objB2.multiMultiA.contains(objA1))
		assertTrue(!objB2.multiMultiA.contains(objA2))
		assertTrue(!objB2.multiMultiA.contains(objA3))
		assertTrue(objB3.multiMultiA.contains(objA1))
		assertTrue(!objB3.multiMultiA.contains(objA2))
		assertTrue(objB3.multiMultiA.contains(objA3))

		assertEquals(3, objA1.multiMultiBBeforeAddCount)
		assertEquals(3, objA1.multiMultiBAfterAddCount)
		assertEquals(0, objA1.multiMultiBBeforeRemoveCount)
		assertEquals(0, objA1.multiMultiBAfterRemoveCount)
		assertEquals(0, objA2.multiMultiBBeforeAddCount)
		assertEquals(0, objA2.multiMultiBAfterAddCount)
		assertEquals(0, objA2.multiMultiBBeforeRemoveCount)
		assertEquals(0, objA2.multiMultiBAfterRemoveCount)
		assertEquals(1, objA3.multiMultiBBeforeAddCount)
		assertEquals(1, objA3.multiMultiBAfterAddCount)
		assertEquals(0, objA3.multiMultiBBeforeRemoveCount)
		assertEquals(0, objA3.multiMultiBAfterRemoveCount)
		assertEquals(1, objB1.multiMultiABeforeAddCount)
		assertEquals(1, objB1.multiMultiAAfterAddCount)
		assertEquals(0, objB1.multiMultiABeforeRemoveCount)
		assertEquals(0, objB1.multiMultiAAfterRemoveCount)
		assertEquals(1, objB2.multiMultiABeforeAddCount)
		assertEquals(1, objB2.multiMultiAAfterAddCount)
		assertEquals(0, objB2.multiMultiABeforeRemoveCount)
		assertEquals(0, objB2.multiMultiAAfterRemoveCount)
		assertEquals(2, objB3.multiMultiABeforeAddCount)
		assertEquals(2, objB3.multiMultiAAfterAddCount)
		assertEquals(0, objB3.multiMultiABeforeRemoveCount)
		assertEquals(0, objB3.multiMultiAAfterRemoveCount)

		assertFalse(objB3.addAllToMultiMultiA(#[objA1, objA3]))

		assertTrue(objA1.multiMultiB.contains(objB1))
		assertTrue(objA1.multiMultiB.contains(objB2))
		assertTrue(objA1.multiMultiB.contains(objB3))
		assertTrue(!objA2.multiMultiB.contains(objB1))
		assertTrue(!objA2.multiMultiB.contains(objB2))
		assertTrue(!objA2.multiMultiB.contains(objB3))
		assertTrue(!objA3.multiMultiB.contains(objB1))
		assertTrue(!objA3.multiMultiB.contains(objB2))
		assertTrue(objA3.multiMultiB.contains(objB3))
		assertTrue(objB1.multiMultiA.contains(objA1))
		assertTrue(!objB1.multiMultiA.contains(objA2))
		assertTrue(!objB1.multiMultiA.contains(objA3))
		assertTrue(objB2.multiMultiA.contains(objA1))
		assertTrue(!objB2.multiMultiA.contains(objA2))
		assertTrue(!objB2.multiMultiA.contains(objA3))
		assertTrue(objB3.multiMultiA.contains(objA1))
		assertTrue(!objB3.multiMultiA.contains(objA2))
		assertTrue(objB3.multiMultiA.contains(objA3))

		assertEquals(3, objA1.multiMultiBBeforeAddCount)
		assertEquals(3, objA1.multiMultiBAfterAddCount)
		assertEquals(0, objA1.multiMultiBBeforeRemoveCount)
		assertEquals(0, objA1.multiMultiBAfterRemoveCount)
		assertEquals(0, objA2.multiMultiBBeforeAddCount)
		assertEquals(0, objA2.multiMultiBAfterAddCount)
		assertEquals(0, objA2.multiMultiBBeforeRemoveCount)
		assertEquals(0, objA2.multiMultiBAfterRemoveCount)
		assertEquals(1, objA3.multiMultiBBeforeAddCount)
		assertEquals(1, objA3.multiMultiBAfterAddCount)
		assertEquals(0, objA3.multiMultiBBeforeRemoveCount)
		assertEquals(0, objA3.multiMultiBAfterRemoveCount)
		assertEquals(1, objB1.multiMultiABeforeAddCount)
		assertEquals(1, objB1.multiMultiAAfterAddCount)
		assertEquals(0, objB1.multiMultiABeforeRemoveCount)
		assertEquals(0, objB1.multiMultiAAfterRemoveCount)
		assertEquals(1, objB2.multiMultiABeforeAddCount)
		assertEquals(1, objB2.multiMultiAAfterAddCount)
		assertEquals(0, objB2.multiMultiABeforeRemoveCount)
		assertEquals(0, objB2.multiMultiAAfterRemoveCount)
		assertEquals(2, objB3.multiMultiABeforeAddCount)
		assertEquals(2, objB3.multiMultiAAfterAddCount)
		assertEquals(0, objB3.multiMultiABeforeRemoveCount)
		assertEquals(0, objB3.multiMultiAAfterRemoveCount)

		assertTrue(objB3.clearMultiMultiA())

		assertTrue(objA1.multiMultiB.contains(objB1))
		assertTrue(objA1.multiMultiB.contains(objB2))
		assertTrue(!objA1.multiMultiB.contains(objB3))
		assertTrue(!objA2.multiMultiB.contains(objB1))
		assertTrue(!objA2.multiMultiB.contains(objB2))
		assertTrue(!objA2.multiMultiB.contains(objB3))
		assertTrue(!objA3.multiMultiB.contains(objB1))
		assertTrue(!objA3.multiMultiB.contains(objB2))
		assertTrue(!objA3.multiMultiB.contains(objB3))
		assertTrue(objB1.multiMultiA.contains(objA1))
		assertTrue(!objB1.multiMultiA.contains(objA2))
		assertTrue(!objB1.multiMultiA.contains(objA3))
		assertTrue(objB2.multiMultiA.contains(objA1))
		assertTrue(!objB2.multiMultiA.contains(objA2))
		assertTrue(!objB2.multiMultiA.contains(objA3))
		assertTrue(!objB3.multiMultiA.contains(objA1))
		assertTrue(!objB3.multiMultiA.contains(objA2))
		assertTrue(!objB3.multiMultiA.contains(objA3))

		assertEquals(3, objA1.multiMultiBBeforeAddCount)
		assertEquals(3, objA1.multiMultiBAfterAddCount)
		assertEquals(1, objA1.multiMultiBBeforeRemoveCount)
		assertEquals(1, objA1.multiMultiBAfterRemoveCount)
		assertEquals(0, objA2.multiMultiBBeforeAddCount)
		assertEquals(0, objA2.multiMultiBAfterAddCount)
		assertEquals(0, objA2.multiMultiBBeforeRemoveCount)
		assertEquals(0, objA2.multiMultiBAfterRemoveCount)
		assertEquals(1, objA3.multiMultiBBeforeAddCount)
		assertEquals(1, objA3.multiMultiBAfterAddCount)
		assertEquals(1, objA3.multiMultiBBeforeRemoveCount)
		assertEquals(1, objA3.multiMultiBAfterRemoveCount)
		assertEquals(1, objB1.multiMultiABeforeAddCount)
		assertEquals(1, objB1.multiMultiAAfterAddCount)
		assertEquals(0, objB1.multiMultiABeforeRemoveCount)
		assertEquals(0, objB1.multiMultiAAfterRemoveCount)
		assertEquals(1, objB2.multiMultiABeforeAddCount)
		assertEquals(1, objB2.multiMultiAAfterAddCount)
		assertEquals(0, objB2.multiMultiABeforeRemoveCount)
		assertEquals(0, objB2.multiMultiAAfterRemoveCount)
		assertEquals(2, objB3.multiMultiABeforeAddCount)
		assertEquals(2, objB3.multiMultiAAfterAddCount)
		assertEquals(2, objB3.multiMultiABeforeRemoveCount)
		assertEquals(2, objB3.multiMultiAAfterRemoveCount)

		assertTrue(objB3.addAllToMultiMultiA(#[objA1, objA2, objA3]))

		assertTrue(objA1.multiMultiB.contains(objB1))
		assertTrue(objA1.multiMultiB.contains(objB2))
		assertTrue(objA1.multiMultiB.contains(objB3))
		assertTrue(!objA2.multiMultiB.contains(objB1))
		assertTrue(!objA2.multiMultiB.contains(objB2))
		assertTrue(objA2.multiMultiB.contains(objB3))
		assertTrue(!objA3.multiMultiB.contains(objB1))
		assertTrue(!objA3.multiMultiB.contains(objB2))
		assertTrue(objA3.multiMultiB.contains(objB3))
		assertTrue(objB1.multiMultiA.contains(objA1))
		assertTrue(!objB1.multiMultiA.contains(objA2))
		assertTrue(!objB1.multiMultiA.contains(objA3))
		assertTrue(objB2.multiMultiA.contains(objA1))
		assertTrue(!objB2.multiMultiA.contains(objA2))
		assertTrue(!objB2.multiMultiA.contains(objA3))
		assertTrue(objB3.multiMultiA.contains(objA1))
		assertTrue(objB3.multiMultiA.contains(objA2))
		assertTrue(objB3.multiMultiA.contains(objA3))

		assertEquals(4, objA1.multiMultiBBeforeAddCount)
		assertEquals(4, objA1.multiMultiBAfterAddCount)
		assertEquals(1, objA1.multiMultiBBeforeRemoveCount)
		assertEquals(1, objA1.multiMultiBAfterRemoveCount)
		assertEquals(1, objA2.multiMultiBBeforeAddCount)
		assertEquals(1, objA2.multiMultiBAfterAddCount)
		assertEquals(0, objA2.multiMultiBBeforeRemoveCount)
		assertEquals(0, objA2.multiMultiBAfterRemoveCount)
		assertEquals(2, objA3.multiMultiBBeforeAddCount)
		assertEquals(2, objA3.multiMultiBAfterAddCount)
		assertEquals(1, objA3.multiMultiBBeforeRemoveCount)
		assertEquals(1, objA3.multiMultiBAfterRemoveCount)
		assertEquals(1, objB1.multiMultiABeforeAddCount)
		assertEquals(1, objB1.multiMultiAAfterAddCount)
		assertEquals(0, objB1.multiMultiABeforeRemoveCount)
		assertEquals(0, objB1.multiMultiAAfterRemoveCount)
		assertEquals(1, objB2.multiMultiABeforeAddCount)
		assertEquals(1, objB2.multiMultiAAfterAddCount)
		assertEquals(0, objB2.multiMultiABeforeRemoveCount)
		assertEquals(0, objB2.multiMultiAAfterRemoveCount)
		assertEquals(5, objB3.multiMultiABeforeAddCount)
		assertEquals(5, objB3.multiMultiAAfterAddCount)
		assertEquals(2, objB3.multiMultiABeforeRemoveCount)
		assertEquals(2, objB3.multiMultiAAfterRemoveCount)

		assertTrue(objB3.removeAllFromMultiMultiA(#[objA2, objA3]))

		assertTrue(objA1.multiMultiB.contains(objB1))
		assertTrue(objA1.multiMultiB.contains(objB2))
		assertTrue(objA1.multiMultiB.contains(objB3))
		assertTrue(!objA2.multiMultiB.contains(objB1))
		assertTrue(!objA2.multiMultiB.contains(objB2))
		assertTrue(!objA2.multiMultiB.contains(objB3))
		assertTrue(!objA3.multiMultiB.contains(objB1))
		assertTrue(!objA3.multiMultiB.contains(objB2))
		assertTrue(!objA3.multiMultiB.contains(objB3))
		assertTrue(objB1.multiMultiA.contains(objA1))
		assertTrue(!objB1.multiMultiA.contains(objA2))
		assertTrue(!objB1.multiMultiA.contains(objA3))
		assertTrue(objB2.multiMultiA.contains(objA1))
		assertTrue(!objB2.multiMultiA.contains(objA2))
		assertTrue(!objB2.multiMultiA.contains(objA3))
		assertTrue(objB3.multiMultiA.contains(objA1))
		assertTrue(!objB3.multiMultiA.contains(objA2))
		assertTrue(!objB3.multiMultiA.contains(objA3))

		assertEquals(4, objA1.multiMultiBBeforeAddCount)
		assertEquals(4, objA1.multiMultiBAfterAddCount)
		assertEquals(1, objA1.multiMultiBBeforeRemoveCount)
		assertEquals(1, objA1.multiMultiBAfterRemoveCount)
		assertEquals(1, objA2.multiMultiBBeforeAddCount)
		assertEquals(1, objA2.multiMultiBAfterAddCount)
		assertEquals(1, objA2.multiMultiBBeforeRemoveCount)
		assertEquals(1, objA2.multiMultiBAfterRemoveCount)
		assertEquals(2, objA3.multiMultiBBeforeAddCount)
		assertEquals(2, objA3.multiMultiBAfterAddCount)
		assertEquals(2, objA3.multiMultiBBeforeRemoveCount)
		assertEquals(2, objA3.multiMultiBAfterRemoveCount)
		assertEquals(1, objB1.multiMultiABeforeAddCount)
		assertEquals(1, objB1.multiMultiAAfterAddCount)
		assertEquals(0, objB1.multiMultiABeforeRemoveCount)
		assertEquals(0, objB1.multiMultiAAfterRemoveCount)
		assertEquals(1, objB2.multiMultiABeforeAddCount)
		assertEquals(1, objB2.multiMultiAAfterAddCount)
		assertEquals(0, objB2.multiMultiABeforeRemoveCount)
		assertEquals(0, objB2.multiMultiAAfterRemoveCount)
		assertEquals(5, objB3.multiMultiABeforeAddCount)
		assertEquals(5, objB3.multiMultiAAfterAddCount)
		assertEquals(4, objB3.multiMultiABeforeRemoveCount)
		assertEquals(4, objB3.multiMultiAAfterRemoveCount)

	}

	@Test
	def void testBidirectionalViaInterface() {

		{
			val objA1 = new BidirectionalInterfaceA
			val objA2 = new BidirectionalInterfaceA
			val objB1 = new BidirectionalInterfaceB
			val objB2 = new BidirectionalInterfaceB

			assertTrue(objA1.addAllToMultiB(#[objB1]))
			assertTrue(objB2.singleA = objA1)
			assertTrue(objB2.addAllToMultiA(#[objA1, objA2]))

			assertSame(objA1, objB1.singleA)
			assertSame(objA1, objB2.singleA)
			assertTrue(objA1.multiB.contains(objB1))
			assertTrue(objA1.multiB.contains(objB2))

			assertSame(objB2, objA1.singleB)
			assertSame(objB2, objA2.singleB)
			assertTrue(objB2.multiA.contains(objA1))
			assertTrue(objB2.multiA.contains(objA2))
		}

		{
			val objA1 = new BidirectionalOnlyInterfaceA
			val objA2 = new BidirectionalOnlyInterfaceA
			val objB1 = new BidirectionalOnlyInterfaceB
			val objB2 = new BidirectionalOnlyInterfaceB

			assertTrue(objA1.addAllToMultiB(#[objB1]))
			assertTrue(objB2.singleA = objA1)
			assertTrue(objB2.addAllToMultiA(#[objA1, objA2]))

			assertSame(objA1, objB1.singleA)
			assertSame(objA1, objB2.singleA)
			assertTrue(objA1.multiB.contains(objB1))
			assertTrue(objA1.multiB.contains(objB2))

			assertSame(objB2, objA1.singleB)
			assertSame(objB2, objA2.singleB)
			assertTrue(objB2.multiA.contains(objA1))
			assertTrue(objB2.multiA.contains(objA2))
		}

	}

	@Test
	def void testBidirectionalWithoutGeneration() {

		val objA = new BidirectionalWithoutGenerationA
		val objB = new BidirectionalWithoutGenerationB

		assertTrue(objA.singleB = objB)
		assertTrue(objA.singleMultiB = objB)

		assertEquals(1, objB.calledSetSingleA)
		assertEquals(1, objB.calledAddToMultiSingleA)
		assertEquals(0, objB.calledRemoveFromMultiSingleA)

		assertTrue(objA.singleB = null)
		assertTrue(objA.singleMultiB = null)

		assertEquals(2, objB.calledSetSingleA)
		assertEquals(1, objB.calledAddToMultiSingleA)
		assertEquals(1, objB.calledRemoveFromMultiSingleA)

	}

	@Test
	def void testBidirectionalUsedIncorrectly() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.SetterRule
import org.eclipse.xtend.lib.annotation.etai.BidirectionalRule

@ApplyRules
class UsingBidirectional {

	@BidirectionalRule("singleA")
	Object noSetterGetterAdder

	@SetterRule
	@BidirectionalRule
	UsingBidirectionalCounter noBidirectionalName

	@SetterRule
	@BidirectionalRule("counter")
	int noBidirectionalClassOrInterface

}

@ApplyRules
class UsingBidirectionalCounter {

	def void setCounter(UsingBidirectional obj) {}

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.UsingBidirectional')

			val problemsNoGetterSetterAdder = (clazz.findDeclaredField("noSetterGetterAdder").
				primarySourceElement as FieldDeclaration).problems
			val problemsNoBidirectionalName = (clazz.findDeclaredField("noBidirectionalName").
				primarySourceElement as FieldDeclaration).problems
			val problemsNoBidirectionalClassOrInterface = (clazz.findDeclaredField("noBidirectionalClassOrInterface").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(3, allProblems.size)

			assertEquals(1, problemsNoGetterSetterAdder.size)
			assertEquals(Severity.ERROR, problemsNoGetterSetterAdder.get(0).severity)
			assertTrue(problemsNoGetterSetterAdder.get(0).message.contains("only be used, if also @SetterRule"))

			assertEquals(1, problemsNoBidirectionalName.size)
			assertEquals(Severity.ERROR, problemsNoBidirectionalName.get(0).severity)
			assertTrue(problemsNoBidirectionalName.get(0).message.contains("name of opposite field"))

			assertEquals(1, problemsNoBidirectionalClassOrInterface.size)
			assertEquals(Severity.ERROR, problemsNoBidirectionalClassOrInterface.get(0).severity)
			assertTrue(problemsNoBidirectionalClassOrInterface.get(0).message.contains("interface/class type"))

		]

	}

	@Test
	def void testBidirectionalColletionUsageError() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule
import org.eclipse.xtend.lib.annotation.etai.BidirectionalRule

@ApplyRules
class UsingBidirectional {

	@BidirectionalRule("counter")
	@AdderRule(single=true, multiple=true)
	@RemoverRule(single=true, multiple=true)
	java.util.Set noTypeForSet

}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.UsingBidirectional')

			val problemsNoTypeForSet = (clazz.findDeclaredField("noTypeForSet").
				primarySourceElement as FieldDeclaration).problems

			// do assertions
			assertEquals(1, allProblems.size)

			assertEquals(1, problemsNoTypeForSet.size)
			assertEquals(Severity.ERROR, problemsNoTypeForSet.get(0).severity)
			assertTrue(problemsNoTypeForSet.get(0).message.contains("type argument"))

		]

	}

	@Test
	def void testBidirectionalOppositeFieldDoesNotExist() {

		'''

package virtual

import org.eclipse.xtend.lib.annotation.etai.ApplyRules
import org.eclipse.xtend.lib.annotation.etai.SetterRule
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.RemoverRule
import org.eclipse.xtend.lib.annotation.etai.BidirectionalRule

@ApplyRules
class UsingBidirectional {

	@BidirectionalRule("counter1")
	@AdderRule(single=true, multiple=true)
	@RemoverRule(single=true, multiple=true)
	java.util.Set<UsingBidirectionalOpposite> opposite1

	@BidirectionalRule("counter2")
	@SetterRule
	UsingBidirectionalOpposite opposite2

}

@ApplyRules
class UsingBidirectionalOpposite {
}

		'''.compile [

			val extension ctx = transformationContext

			val clazz = findClass('virtual.UsingBidirectional')

			val problemsOpposite1 = (clazz.findDeclaredField("opposite1").primarySourceElement as FieldDeclaration).
				problems
			val problemsOpposite2 = (clazz.findDeclaredField("opposite2").primarySourceElement as FieldDeclaration).
				problems

			// do assertions
			assertEquals(2, allProblems.size)

			assertEquals(1, problemsOpposite1.size)
			assertEquals(Severity.ERROR, problemsOpposite1.get(0).severity)
			assertTrue(problemsOpposite1.get(0).message.contains("Cannot find appropriate method"))

			assertEquals(1, problemsOpposite2.size)
			assertEquals(Severity.ERROR, problemsOpposite2.get(0).severity)
			assertTrue(problemsOpposite2.get(0).message.contains("Cannot find appropriate method"))

		]

	}

}
