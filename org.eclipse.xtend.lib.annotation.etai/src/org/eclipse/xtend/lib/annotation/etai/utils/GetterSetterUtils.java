package org.eclipse.xtend.lib.annotation.etai.utils;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.IdentityHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.concurrent.locks.ReentrantReadWriteLock;

import org.eclipse.xtend.lib.annotation.etai.AdderRuleProcessor;
import org.eclipse.xtend.lib.annotation.etai.CollectionGetterPolicy;
import org.eclipse.xtend.lib.annotation.etai.RemoverRuleProcessor;
import org.eclipse.xtend.lib.annotation.etai.utils.CollectionUtils.StraightIndexList;
import org.eclipse.xtext.xbase.lib.StringExtensions;

/**
 * <p>Utility class for implementing getters/setters/adders/removers.</p>
 */
public class GetterSetterUtils {

	// this object can be used in order to avoid concurrent modification of fields
	// (with generated setters/adders/removers)
	final static ConcurrentModificationLock CONCURRENT_MODIFICATION_LOCK = new ConcurrentModificationLock();

	// this object can be used in order to synchronize multiple
	// generated getter/setter/adder/remover calls
	final static NamedSynchronizationLock NAMED_SYNCHRONIZATION_LOCK = new NamedSynchronizationLock();

	public static void addOppositeReference(Object obj, String fieldName, Object connectedObj) {

		// check for opposite methods
		Method addMethod = ReflectUtils.getPrivateMethod(obj.getClass(),
				"addTo" + StringExtensions.toFirstUpper(fieldName));
		if (addMethod == null)
			addMethod = ReflectUtils.getPrivateMethod(obj.getClass(), "set" + StringExtensions.toFirstUpper(fieldName));

		// call opposite method
		ReflectUtils.callPrivateMethod(obj, addMethod, new Object[] { connectedObj });

	}

	public static void removeOppositeReference(Object obj, String fieldName, Object connectedObj) {

		// check for opposite methods
		Method addMethod = ReflectUtils.getPrivateMethod(obj.getClass(),
				"removeFrom" + StringExtensions.toFirstUpper(fieldName));
		if (addMethod == null) {
			addMethod = ReflectUtils.getPrivateMethod(obj.getClass(), "set" + StringExtensions.toFirstUpper(fieldName));
			connectedObj = null;
		}

		// call opposite method
		ReflectUtils.callPrivateMethod(obj, addMethod, new Object[] { connectedObj });

	}

	/**
	 * <p>Interface for calling a method: no return type.</p>
	 */
	public static interface MethodCallVoid {
		void call();
	}

	/**
	 * <p>Interface for calling a method: return type <code>boolean</code>.</p>
	 */
	public static interface MethodCallBoolean {
		boolean call();
	}

	/**
	 * <p>Interface for calling value/reference change method: return type
	 * <code>void</code>.</p>
	 */
	public static interface MethodCallValueChangeVoid<E> {
		void call(E oldValue, E newValue);
	}

	/**
	 * <p>Interface for calling value/reference change method: return type
	 * <code>boolean</code>.</p>
	 */
	public static interface MethodCallValueChangeBoolean<E> {
		boolean call(E oldValue, E newValue);
	}

	/**
	 * <p>Interface for calling collection change method: multiple elements, indices
	 * and return type <code>boolean</code>.</p>
	 */
	public static interface MethodCallCollectionNameMultipleIndexBoolean<E> {
		boolean call(List<E> elements, List<Integer> indices, List<E> oldElements);
	}

	/**
	 * <p>Interface for calling collection change method: single element, index and
	 * return type <code>boolean</code>.</p>
	 */
	public static interface MethodCallCollectionNameSingleIndexBoolean<E> {
		boolean call(E element, int index, List<E> oldElements);
	}

	/**
	 * <p>Interface for calling collection change method: multiple elements, indices
	 * and return type <code>void</code>.</p>
	 */
	public static interface MethodCallCollectionNameMultipleIndexVoid<E> {
		void call(List<E> elements, List<Integer> indices, List<E> oldElements, List<E> newElements);
	}

	/**
	 * <p>Interface for calling collection change method: single element, index and
	 * return type <code>void</code>.</p>
	 */
	public static interface MethodCallCollectionNameSingleIndexVoid<E> {
		void call(E element, int index, List<E> oldElements, List<E> newElements);
	}

	/**
	 * <p>Interface for calling bidirectional set/add method.</p>
	 */
	public static interface MethodCallBidirectional<E, F> {
		void call(E obj, F value);
	}

	/**
	 * <p>This class allows the tracking of fields (in context of an object and the
	 * current thread) which are currently modified. This way, it is possible to
	 * avoid the concurrent modification of a field (in the same thread).</p>
	 */
	static class ConcurrentModificationLock {

		private Map<Thread, Map<String, Map<Object, Integer>>> locks = new HashMap<Thread, Map<String, Map<Object, Integer>>>();

		/**
		 * <p>After calling this method, given field of the given object will not be
		 * changed by calling generated setter/adder/remover methods any more until the
		 * unlock method has been called. If such generated methods are called, they
		 * will return <code>false</code>.</p>
		 * 
		 * <p>The method can be called multiple times, i.e., also the unlock field must be
		 * called the same amount of times in order to unlock.</p>
		 * 
		 * @see #unlockField
		 */
		synchronized public void lockField(Object obj, String fieldName) {

			Thread currentThread = Thread.currentThread();
			Map<String, Map<Object, Integer>> mapStringObject = locks.get(currentThread);
			if (mapStringObject == null) {
				mapStringObject = new HashMap<String, Map<Object, Integer>>();
				locks.put(currentThread, mapStringObject);
			}

			Map<Object, Integer> mapObject = mapStringObject.get(fieldName);
			if (mapObject == null) {
				mapObject = new IdentityHashMap<Object, Integer>();
				mapStringObject.put(fieldName, mapObject);
			}

			Integer lockCount = mapObject.get(obj);
			if (lockCount == null)
				mapObject.put(obj, 1);
			else
				mapObject.put(obj, lockCount + 1);

		}

		/**
		 * <p>After calling this method, given field of the given object can be changed
		 * again (if called as often as the lock method).</p>
		 * 
		 * @see #lockField
		 */
		synchronized public void unlockField(Object obj, String fieldName) {

			Thread currentThread = Thread.currentThread();
			Map<String, Map<Object, Integer>> mapStringObject = locks.get(currentThread);
			Map<Object, Integer> mapObject = mapStringObject.get(fieldName);
			Integer lockCount = mapObject.get(obj);

			if (lockCount > 1) {
				mapObject.put(obj, lockCount - 1);
			} else {
				mapObject.remove(obj);
				if (mapObject.size() == 0) {
					mapStringObject.remove(fieldName);
					if (mapStringObject.size() == 0) {
						locks.remove(currentThread);
					}
				}
			}

		}

		/**
		 * <p>Returns if the given field of the given object is currently locked.</p>
		 */
		synchronized public boolean isFieldLocked(Object obj, String fieldName) {

			Thread currentThread = Thread.currentThread();
			Map<String, Map<Object, Integer>> mapStringObject = locks.get(currentThread);
			if (mapStringObject == null)
				return false;

			Map<Object, Integer> mapObject = mapStringObject.get(fieldName);
			if (mapObject == null)
				return false;

			Integer lockCount = mapObject.get(obj);
			if (lockCount == null || lockCount == 0)
				return false;

			return true;

		}

	}

	/**
	 * <p>This class allows to lock the getter/setter/adder/remover operations based on
	 * a given name.</p>
	 */
	static class NamedSynchronizationLock {

		private Map<String, ReentrantReadWriteLock> locks = new HashMap<String, ReentrantReadWriteLock>();

		/**
		 * <p>Retrieves the lock with the given name.</p>
		 */
		synchronized protected ReentrantReadWriteLock getLock(String lockName) {

			ReentrantReadWriteLock lock = locks.get(lockName);

			if (lock == null) {
				lock = new ReentrantReadWriteLock(true);
				locks.put(lockName, lock);
			}

			return lock;

		}

		/**
		 * <p>Locks the given name until unlocked (write).</p>
		 * 
		 * <p>Internally, a fair reentrant read/write lock is used.</p>
		 * 
		 * @see #writeUnlockField
		 */
		public void writeLockField(String lockName) {

			if (lockName == null)
				return;

			ReentrantReadWriteLock lock = getLock(lockName);
			lock.writeLock().lock();

		}

		/**
		 * <p>Locks the given name until unlocked (read).</p>
		 * 
		 * <p>Internally, a fair reentrant read/write lock is used.</p>
		 * 
		 * @see #readUnlockField
		 */
		public void readLockField(String lockName) {

			if (lockName == null)
				return;

			ReentrantReadWriteLock lock = getLock(lockName);
			lock.readLock().lock();

		}

		/**
		 * <p>Unlocks the given name until unlocked (write).</p>
		 * 
		 * @see #writeLockField
		 */
		public void writeUnlockField(String lockName) {

			if (lockName == null)
				return;

			ReentrantReadWriteLock lock = getLock(lockName);
			lock.writeLock().unlock();

		}

		/**
		 * <p>Unlocks the given name until unlocked (read).</p>
		 * 
		 * @see #readLockField
		 */
		public void readUnlockField(String lockName) {

			if (lockName == null)
				return;

			ReentrantReadWriteLock lock = getLock(lockName);
			lock.readLock().unlock();

		}

	}

	/**
	 * <p>This method can be used for the implementation of getter methods.</p>
	 * 
	 * <p>It will return the value/reference of the given field considering all given
	 * features (e.g. "not null", collection policy etc.).</p>
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public static <E> E getValue(E value, CollectionGetterPolicy collectionGetterPolicy, String fieldName,
			boolean notNullSelf, boolean notNullKeyOrElement, boolean notNullValue, String synchronizationLock) {

		// lock this operation
		NAMED_SYNCHRONIZATION_LOCK.readLockField(synchronizationLock);

		try {

			// null checks
			assert !notNullSelf || value != null : String.format(
					org.eclipse.xtend.lib.annotation.etai.NotNullRuleProcessor.VALUE_NULL_GETTER_ERROR, fieldName);

			assert !notNullKeyOrElement || value == null || (value instanceof Map<?, ?>
					&& !CollectionUtils.containsKeyNoThrow((Map<?, ?>) value, null)
					|| (value instanceof Collection<?>
							&& !CollectionUtils.containsNoThrow((Collection<?>) value, null))) : String.format(
									org.eclipse.xtend.lib.annotation.etai.NotNullRuleProcessor.VALUE_NULL_GETTER_KEY_ERROR,
									fieldName);

			assert !notNullValue || value == null || (value instanceof Map<?, ?>
					&& !CollectionUtils.containsValueNoThrow((Map<?, ?>) value, null)) : String.format(
							org.eclipse.xtend.lib.annotation.etai.NotNullRuleProcessor.VALUE_NULL_GETTER_VALUE_ERROR,
							fieldName);

			// consider collection policies

			if (collectionGetterPolicy == CollectionGetterPolicy.UNMODIFIABLE) {

				if (value instanceof SortedMap<?, ?>)
					return (E) Collections.unmodifiableSortedMap((SortedMap<?, ?>) value);
				else if (value instanceof Map<?, ?>)
					return (E) Collections.unmodifiableMap((Map<?, ?>) value);
				else if (value instanceof SortedSet<?>)
					return (E) Collections.unmodifiableSortedSet((SortedSet<?>) value);
				else if (value instanceof Set<?>)
					return (E) Collections.unmodifiableSet((Set<?>) value);
				else if (value instanceof List<?>)
					return (E) Collections.unmodifiableList((List<?>) value);
				else if (value instanceof Collection<?>)
					return (E) Collections.unmodifiableCollection((Collection<?>) value);

			}

			if (collectionGetterPolicy == CollectionGetterPolicy.UNMODIFIABLE_COPY) {

				if (value instanceof SortedMap<?, ?>)
					return (E) Collections.unmodifiableSortedMap(new TreeMap((SortedMap<?, ?>) value));
				else if (value instanceof Map<?, ?>)
					return (E) Collections.unmodifiableMap(new HashMap((Map<?, ?>) value));
				else if (value instanceof SortedSet<?>)
					return (E) Collections.unmodifiableSortedSet(new TreeSet((SortedSet<?>) value));
				else if (value instanceof Set<?>)
					return (E) Collections.unmodifiableSet(new HashSet((Set<?>) value));
				else if (value instanceof List<?>)
					return (E) Collections.unmodifiableList(new ArrayList((ArrayList<?>) value));
				else if (value instanceof Collection<?>)
					return (E) Collections.unmodifiableCollection(new ArrayList((Collection<?>) value));

			}

			// return the given value
			return value;

		} finally {

			// unlock this operation
			NAMED_SYNCHRONIZATION_LOCK.readUnlockField(synchronizationLock);

		}

	}

	/**
	 * <p>This method can be used for the implementation of setter methods.</p>
	 * 
	 * <p>It will change the value/reference of the given field considering all given
	 * features (e.g. "not null", calling methods on changes etc.). It will return,
	 * if there has been a change.</p>
	 */
	public static <E> boolean setValue(E oldValue, E newValue, MethodCallBoolean compareValues, MethodCallVoid doSet,
			MethodCallValueChangeBoolean<E> beforeChange, MethodCallValueChangeVoid<E> afterChange, String fieldName,
			Object currentObject, boolean notNullSelf, String oppositeFieldName, String synchronizationLock) {

		// lock this operation
		NAMED_SYNCHRONIZATION_LOCK.writeLockField(synchronizationLock);

		try {

			// no concurrent modifications
			if (CONCURRENT_MODIFICATION_LOCK.isFieldLocked(currentObject, fieldName))
				return false;

			// start block which avoids concurrent modifications
			CONCURRENT_MODIFICATION_LOCK.lockField(currentObject, fieldName);

			try {

				// null check
				assert !notNullSelf || newValue != null : String.format(
						org.eclipse.xtend.lib.annotation.etai.NotNullRuleProcessor.VALUE_NULL_SETTER_ERROR, fieldName);

				// do nothing if value/reference would not be changed
				if (!compareValues.call())
					return false;

				// call "before change" method and check if change is valid
				if (beforeChange != null)
					if (!beforeChange.call(oldValue, newValue))
						return false;

				// perform actual change
				doSet.call();

				if (oppositeFieldName != null && !oppositeFieldName.isEmpty()) {

					if (oldValue != null)
						removeOppositeReference(oldValue, oppositeFieldName, currentObject);

					if (newValue != null)
						addOppositeReference(newValue, oppositeFieldName, currentObject);

				}

				// call "before change" method
				if (afterChange != null)
					afterChange.call(oldValue, newValue);

				return true;

			} finally {

				// stop block which avoids concurrent modifications
				CONCURRENT_MODIFICATION_LOCK.unlockField(currentObject, fieldName);

			}

		} finally

		{

			// unlock this operation
			NAMED_SYNCHRONIZATION_LOCK.writeUnlockField(synchronizationLock);

		}

	}

	/**
	 * <p>This method can be used for the implementation of adder methods for lists
	 * (adding to its end).</p>
	 * 
	 * @see #addToCollection
	 */
	public static <E> boolean addToList(List<? extends E> list, Collection<? extends E> elements,
			MethodCallCollectionNameSingleIndexBoolean<E> beforeElementAdd,
			MethodCallCollectionNameMultipleIndexBoolean<E> beforeAdd,
			MethodCallCollectionNameSingleIndexVoid<E> afterElementAdd,
			MethodCallCollectionNameMultipleIndexVoid<E> afterAdd, String fieldName, Object currentObject,
			boolean notNullElement, String oppositeFieldName, String synchronizationLock) {

		// lock this operation
		NAMED_SYNCHRONIZATION_LOCK.writeLockField(synchronizationLock);

		try {

			return addToCollection(list, elements, list.size(), beforeElementAdd, beforeAdd, afterElementAdd, afterAdd,
					fieldName, currentObject, notNullElement, oppositeFieldName, synchronizationLock);

		} finally {

			// unlock this operation
			NAMED_SYNCHRONIZATION_LOCK.writeUnlockField(synchronizationLock);

		}

	}

	/**
	 * <p>This method can be used for the implementation of adder methods for
	 * collections.</p>
	 * 
	 * <p>It will add the given list of elements to the given collection considering
	 * all given features (e.g. "not null", calling methods on changes etc.). It
	 * will return if there has been a change.</p>
	 */
	@SuppressWarnings("unchecked")
	public static <E> boolean addToCollection(Collection<? extends E> collection, Collection<? extends E> elements,
			int startIndex, MethodCallCollectionNameSingleIndexBoolean<E> beforeElementAdd,
			MethodCallCollectionNameMultipleIndexBoolean<E> beforeAdd,
			MethodCallCollectionNameSingleIndexVoid<E> afterElementAdd,
			MethodCallCollectionNameMultipleIndexVoid<E> afterAdd, String fieldName, Object currentObject,
			boolean notNullElement, String oppositeFieldName, String synchronizationLock) {

		// lock this operation
		NAMED_SYNCHRONIZATION_LOCK.writeLockField(synchronizationLock);

		try {

			// no concurrent modifications
			if (CONCURRENT_MODIFICATION_LOCK.isFieldLocked(currentObject, fieldName))
				return false;

			// start block which avoids concurrent modifications
			CONCURRENT_MODIFICATION_LOCK.lockField(currentObject, fieldName);

			try {

				// null checks
				assert !notNullElement || collection == null
						|| (!CollectionUtils.containsNoThrow((Collection<?>) elements, null)) : String.format(
								org.eclipse.xtend.lib.annotation.etai.NotNullRuleProcessor.VALUE_NULL_ADDER_ERROR,
								fieldName);

				List<E> objsToBeAdded;

				// copy of old elements
				List<E> oldElements = Collections.unmodifiableList(new ArrayList<E>(collection));

				// special preparation for sets: remove elements from given set which already
				// exist in destination set
				if (collection instanceof Set<?>) {

					java.util.Set<E> newElements = new java.util.HashSet<E>();

					for (E obj : elements)
						if (!collection.contains(obj))
							newElements.add(obj);

					elements = newElements;

				}

				// go through each element, call "before element add" method and check if it
				// will be added
				if (beforeElementAdd != null) {

					objsToBeAdded = new ArrayList<E>();
					int currentIndex = startIndex;
					for (E element : elements) {
						if (beforeElementAdd.call(element, currentIndex, oldElements)) {
							objsToBeAdded.add(element);
							currentIndex++;
						}
					}
					objsToBeAdded = Collections.unmodifiableList(objsToBeAdded);

				} else {

					objsToBeAdded = Collections.unmodifiableList(new ArrayList<E>(elements));

				}

				// return if nothing will be changed
				if (objsToBeAdded.size() == 0)
					return false;

				// create list of indices
				List<Integer> indicesToBeAdded = new StraightIndexList(startIndex, objsToBeAdded.size());

				// call "before add" method for whole change package and check if it will be
				// added
				if (beforeAdd != null) {
					if (!beforeAdd.call(objsToBeAdded, indicesToBeAdded, oldElements))
						return false;
				}

				List<E> objsAdded;
				if (oppositeFieldName != null && !oppositeFieldName.isEmpty()) {

					// set new bidirectional connection
					objsAdded = new ArrayList<E>();

					// add each element individually and try to set new bidirectional connection
					for (E obj : objsToBeAdded) {

						// add element individually
						if (((Collection<Object>) collection).add(obj)) {

							addOppositeReference(obj, oppositeFieldName, currentObject);

							objsAdded.add(obj);

						} else {

							assert false : AdderRuleProcessor.INCOMPLETE_ADD_ERROR;

						}

					}

					if (objsAdded.size() == 0)
						return false;

					objsAdded = Collections.unmodifiableList(objsAdded);

				} else {

					int numberOfElementsBefore = collection.size();

					// do add elements
					if (startIndex >= 0 && collection instanceof List) {
						if (!((List<E>) collection).addAll(startIndex, objsToBeAdded))
							return false;
					} else {
						if (!((Collection<E>) collection).addAll(objsToBeAdded))
							return false;
					}

					// expectation on operation is that ALL elements have actually been added
					assert collection.size()
							- objsToBeAdded.size() == numberOfElementsBefore : AdderRuleProcessor.INCOMPLETE_ADD_ERROR;

					objsAdded = objsToBeAdded;

				}

				// copy of new elements
				List<E> newElements = Collections.unmodifiableList(new ArrayList<E>(collection));

				// go through each element which has been added, and call "after element add"
				// method
				if (afterElementAdd != null) {

					int currentIndex = startIndex;
					for (E element : objsAdded) {
						afterElementAdd.call(element, currentIndex, oldElements, newElements);
						currentIndex++;
					}

				}

				// call "after add" method for whole change package which has been added
				if (afterAdd != null) {
					afterAdd.call(objsAdded, indicesToBeAdded, oldElements, newElements);
				}

				return true;

			} finally {

				// stop block which avoids concurrent modifications
				CONCURRENT_MODIFICATION_LOCK.unlockField(currentObject, fieldName);

			}

		} finally {

			// unlock this operation
			NAMED_SYNCHRONIZATION_LOCK.writeUnlockField(synchronizationLock);

		}

	}

	/**
	 * <p>This method can be used for the implementation of remover methods for
	 * collections.</p>
	 * 
	 * <p>Either it will remove the given list of elements from the given collection
	 * (<code>elements != null</code>), or it will remove the element with the given
	 * index from the given list (<code>index != null</code>) considering all given
	 * features (e.g. "not null", calling methods on changes etc.). It will return,
	 * if there has been a change.</p>
	 */
	@SuppressWarnings("unchecked")
	public static <E> boolean removeFromCollection(Collection<? extends E> collection, Collection<? extends E> elements,
			Integer index, boolean removeAll, MethodCallCollectionNameSingleIndexBoolean<E> beforeElementRemove,
			MethodCallCollectionNameMultipleIndexBoolean<E> beforeRemove,
			MethodCallCollectionNameSingleIndexVoid<E> afterElementRemove,
			MethodCallCollectionNameMultipleIndexVoid<E> afterRemove, String fieldName, Object currentObject,
			String oppositeFieldName, String synchronizationLock) {

		// lock this operation
		NAMED_SYNCHRONIZATION_LOCK.writeLockField(synchronizationLock);

		try {

			// no concurrent modifications
			if (CONCURRENT_MODIFICATION_LOCK.isFieldLocked(currentObject, fieldName))
				return false;

			// start block which avoids concurrent modifications
			CONCURRENT_MODIFICATION_LOCK.lockField(currentObject, fieldName);

			try {

				// either elements or index must be set
				assert ((elements == null) != (index == null));

				List<Integer> indicesToBeRemoved = null;
				List<E> objsToBeRemoved;

				// copy of old elements
				List<E> oldElements = Collections.unmodifiableList(new ArrayList<E>(collection));

				// reduce elements to elements which are really in the collection
				if (elements != null) {

					java.util.List<E> newElements = new java.util.ArrayList<E>();

					for (E obj : elements)
						if (collection.contains(obj) && !newElements.contains(obj))
							newElements.add(obj);

					elements = newElements;

				}

				// go through each element, call "before element remove" method and check,
				// if it will be removed
				objsToBeRemoved = new ArrayList<E>();
				if (index != null) {

					indicesToBeRemoved = new ArrayList<Integer>();
					E element = ((List<? extends E>) collection).get(index);

					if (beforeElementRemove == null || beforeElementRemove.call(element, index, oldElements)) {
						objsToBeRemoved.add(element);
						indicesToBeRemoved.add(index);
					}

				} else {

					if (collection instanceof List<?>) {

						indicesToBeRemoved = new ArrayList<Integer>();

						for (E element : elements) {

							for (int i = 0; i < collection.size(); i++) {

								Object elementInCollection = ((List<? extends E>) collection).get(i);
								if ((elementInCollection == null && element == null)
										|| element.equals(elementInCollection)) {
									if (beforeElementRemove == null
											|| beforeElementRemove.call(element, i, oldElements)) {
										objsToBeRemoved.add(element);
										indicesToBeRemoved.add(i);
									}
									if (!removeAll)
										break;
								}

							}

						}

					} else {

						for (E element : elements)
							if (beforeElementRemove == null || beforeElementRemove.call(element, -1, oldElements))
								objsToBeRemoved.add(element);

					}

				}

				// return if nothing will be changed
				if (objsToBeRemoved.size() == 0)
					return false;

				// make collections read-only
				objsToBeRemoved = Collections.unmodifiableList(new ArrayList<E>(objsToBeRemoved));
				if (indicesToBeRemoved != null)
					indicesToBeRemoved = Collections.unmodifiableList(indicesToBeRemoved);

				// call "before remove" method for whole change package and check,
				// if it will be removed
				if (beforeRemove != null) {
					if (!beforeRemove.call(objsToBeRemoved, indicesToBeRemoved, oldElements))
						return false;
				}

				List<E> objsRemoved;
				if (oppositeFieldName != null && !oppositeFieldName.isEmpty()) {

					// try to reset bidirectional connections
					objsRemoved = new ArrayList<E>();

					// remove each element individually and try to remove bidirectional connection
					for (int i = 0; i < objsToBeRemoved.size(); i++) {

						E obj = objsToBeRemoved.get(i);

						// add element individually
						if (((Collection<Object>) collection).remove(obj)) {

							removeOppositeReference(obj, oppositeFieldName, currentObject);

							objsRemoved.add(obj);

						} else {

							assert false : RemoverRuleProcessor.INCOMPLETE_REMOVE_ERROR;

						}

					}

					if (objsRemoved.size() == 0)
						return false;

					objsRemoved = Collections.unmodifiableList(objsRemoved);

				} else {

					int numberOfElementsBefore = collection.size();

					// do remove elements
					if (index != null) {

						((List<? extends E>) collection).remove(index.intValue());

						// expectation on operation is that element has actually been removed
						assert collection.size()
								+ 1 == numberOfElementsBefore : RemoverRuleProcessor.INCOMPLETE_REMOVE_ERROR;

					} else {

						if (removeAll) {
							if (!collection.removeAll(objsToBeRemoved))
								return false;
						} else {
							assert objsToBeRemoved.size() == 1;
							if (!collection.remove(objsToBeRemoved.get(0)))
								return false;

						}

						// expectation on operation is that ALL elements have actually been removed
						assert collection.size() + objsToBeRemoved
								.size() == numberOfElementsBefore : RemoverRuleProcessor.INCOMPLETE_REMOVE_ERROR;

					}

					objsRemoved = objsToBeRemoved;

				}

				// copy of new elements
				List<E> newElements = Collections.unmodifiableList(new ArrayList<E>(collection));

				// go through each element which has been removed,
				// and call "after element remove" method
				if (afterElementRemove != null) {

					for (int i = 0; i < objsRemoved.size(); i++) {

						int currentIndex = -1;

						if (indicesToBeRemoved != null)
							currentIndex = indicesToBeRemoved.get(i);
						afterElementRemove.call(objsRemoved.get(i), currentIndex, oldElements, newElements);

					}

				}

				// call "after remove" method for whole change package which has been removed
				if (afterRemove != null) {
					afterRemove.call(objsRemoved, indicesToBeRemoved, oldElements, newElements);
				}

				return true;

			} finally {

				// stop block which avoids concurrent modifications
				CONCURRENT_MODIFICATION_LOCK.unlockField(currentObject, fieldName);

			}

		} finally {

			// unlock this operation
			NAMED_SYNCHRONIZATION_LOCK.writeUnlockField(synchronizationLock);

		}

	}

	/**
	 * <p>This method can be used for the implementation of adder methods for maps.</p>
	 * 
	 * <p>It will put the given key/value entries to the map considering all given
	 * features (e.g. "not null" etc.).</p>
	 */
	@SuppressWarnings("unchecked")
	public static <K, V> V putToMap(Map<? extends K, ? extends V> map, Map<? extends K, ? extends V> elements,
			String fieldName, Object currentObject, boolean notNullKey, boolean notNullValue,
			String synchronizationLock) {

		// lock this operation
		NAMED_SYNCHRONIZATION_LOCK.writeLockField(synchronizationLock);

		try {

			// null checks
			assert !notNullKey || map == null
					|| (!CollectionUtils.containsKeyNoThrow((Map<?, ?>) elements, null)) : String.format(
							org.eclipse.xtend.lib.annotation.etai.NotNullRuleProcessor.VALUE_NULL_ADDER_PUT_KEY_ERROR,
							fieldName);

			assert !notNullValue || map == null
					|| (!CollectionUtils.containsValueNoThrow((Map<?, ?>) elements, null)) : String.format(
							org.eclipse.xtend.lib.annotation.etai.NotNullRuleProcessor.VALUE_NULL_ADDER_PUT_VALUE_ERROR,
							fieldName);

			// put elements to map
			if (elements.size() == 1) {
				Map.Entry<? extends K, ? extends V> entry = elements.entrySet().iterator().next();
				return ((Map<K, V>) map).put(entry.getKey(), entry.getValue());
			} else {
				((Map<K, V>) map).putAll(elements);
			}

			return null;

		} finally {

			// unlock this operation
			NAMED_SYNCHRONIZATION_LOCK.writeUnlockField(synchronizationLock);

		}

	}

	/**
	 * <p>This method can be used for the implementation of remover methods for maps.</p>
	 * 
	 * <p>It will remove the given key from the given map. It will return the
	 * associated value (or null if there was no entry).</p>
	 */
	@SuppressWarnings("unchecked")
	public static <K, V> V removeFromMap(Map<? extends K, ? extends V> map, K key, String fieldName,
			Object currentObject, String synchronizationLock) {

		// lock this operation
		NAMED_SYNCHRONIZATION_LOCK.writeLockField(synchronizationLock);

		try {

			// put via key
			return ((Map<K, V>) map).remove(key);

		} finally {

			// unlock this operation
			NAMED_SYNCHRONIZATION_LOCK.writeUnlockField(synchronizationLock);

		}

	}

	/**
	 * <p>This method can be used for the implementation of remover methods for maps
	 * (clear).</p>
	 * 
	 * <p>It will remove all elements from the map. It will return if there has been a
	 * change.</p>
	 */

	public static <K, V> boolean clearMap(Map<? extends K, ? extends V> map, String fieldName, Object currentObject,
			String synchronizationLock) {

		// lock this operation
		NAMED_SYNCHRONIZATION_LOCK.writeLockField(synchronizationLock);

		try {

			if (map.size() == 0)
				return false;

			// clear map
			map.clear();

			assert map.size() == 0;

			return true;

		} finally {

			// unlock this operation
			NAMED_SYNCHRONIZATION_LOCK.writeUnlockField(synchronizationLock);

		}

	}

}
