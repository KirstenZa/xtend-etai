package org.eclipse.xtend.lib.annotation.etai.utils;

import java.lang.reflect.InvocationTargetException;
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
 * Utility class for implementing getters/setters/adders/removers.
 */
public class GetterSetterUtils {

	// this object can be used in order to avoid concurrent modification of fields
	// (with generated setters/adders/removers)
	final static ConcurrentModificationLock CONCURRENT_MODIFICATION_LOCK = new ConcurrentModificationLock();

	// this object can be used in order to synchronize multiple
	// generated getter/setter/adder/remover calls
	final static NamedSynchronizationLock NAMED_SYNCHRONIZATION_LOCK = new NamedSynchronizationLock();

	/**
	 * Method for realizing sneaky throws.
	 */
	@SuppressWarnings("unchecked")
	public static <E extends Throwable> void sneakyThrow(Throwable e) throws E {
		throw (E) e;
	}

	public static void addOppositeReference(Object obj, String fieldName, Object connectedObj) {

		// check for opposite methods
		Method addMethod = ReflectUtils.getPrivateMethod(obj.getClass(),
				"addTo" + StringExtensions.toFirstUpper(fieldName));
		if (addMethod == null)
			addMethod = ReflectUtils.getPrivateMethod(obj.getClass(), "set" + StringExtensions.toFirstUpper(fieldName));

		try {

			// call opposite method
			ReflectUtils.callPrivateMethod(obj, addMethod, new Object[] { connectedObj });

		} catch (IllegalAccessException | IllegalArgumentException e) {

			GetterSetterUtils.<RuntimeException>sneakyThrow(e);

		} catch (InvocationTargetException e) {

			GetterSetterUtils.<RuntimeException>sneakyThrow(e.getTargetException());

		}

	}

	public static void removeOppositeReference(Object obj, String fieldName, Object connectedObj) {

		// check for opposite methods
		Method addMethod = ReflectUtils.getPrivateMethod(obj.getClass(),
				"removeFrom" + StringExtensions.toFirstUpper(fieldName));
		if (addMethod == null) {
			addMethod = ReflectUtils.getPrivateMethod(obj.getClass(), "set" + StringExtensions.toFirstUpper(fieldName));
			connectedObj = null;
		}

		try {

			// call opposite method
			ReflectUtils.callPrivateMethod(obj, addMethod, new Object[] { connectedObj });

		} catch (IllegalAccessException | IllegalArgumentException e) {

			GetterSetterUtils.<RuntimeException>sneakyThrow(e);

		} catch (InvocationTargetException e) {

			GetterSetterUtils.<RuntimeException>sneakyThrow(e.getTargetException());

		}

	}

	/**
	 * Interface for calling a method: no return type
	 */
	public static interface MethodCallVoid {
		void call();
	}

	/**
	 * Interface for calling a method: return type <code>boolean</code>
	 */
	public static interface MethodCallBoolean {
		boolean call();
	}

	/**
	 * Interface for calling value/reference change method: return type
	 * <code>void</code>
	 */
	public static interface MethodCallValueChangeVoid<E> {
		void call(E oldValue, E newValue);
	}

	/**
	 * Interface for calling value/reference change method: return type
	 * <code>boolean</code>
	 */
	public static interface MethodCallValueChangeBoolean<E> {
		boolean call(E oldValue, E newValue);
	}

	/**
	 * Interface for calling collection change method: multiple elements, indices
	 * and return type <code>boolean</code>
	 */
	public static interface MethodCallCollectionNameMultipleIndexBoolean<E> {
		boolean call(List<E> elements, List<Integer> indices);
	}

	/**
	 * Interface for calling collection change method: single element, index and
	 * return type <code>boolean</code>
	 */
	public static interface MethodCallCollectionNameSingleIndexBoolean<E> {
		boolean call(E element, int index);
	}

	/**
	 * Interface for calling collection change method: multiple elements, indices
	 * and return type <code>void</code>
	 */
	public static interface MethodCallCollectionNameMultipleIndexVoid<E> {
		void call(List<E> elements, List<Integer> indices);
	}

	/**
	 * Interface for calling collection change method: single element, index and
	 * return type <code>void</code>
	 */
	public static interface MethodCallCollectionNameSingleIndexVoid<E> {
		void call(E element, int index);
	}

	/**
	 * Interface for calling bidirectional set/add method
	 */
	public static interface MethodCallBidirectional<E, F> {
		void call(E obj, F value);
	}

	/**
	 * This class allows the tracking of fields (in context of an object and the
	 * current thread) which are currently modified. This way, it is possible to
	 * avoid the concurrent modification of a field (in the same thread).
	 */
	static class ConcurrentModificationLock {

		private Map<Thread, Map<String, Map<Object, Integer>>> locks = new HashMap<Thread, Map<String, Map<Object, Integer>>>();

		/**
		 * After calling this method, given field of the given object will not be
		 * changed by calling generated setter/adder/remover methods any more until the
		 * unlock method has been called. If such generated methods are called, they
		 * will return <code>false</code>.
		 * 
		 * The method can be called multiple times, i.e. also the unlock field must be
		 * called the same amount of times in order to unlock.
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
		 * After calling this method, given field of the given object can be changed
		 * again (if called as often as the lock method).
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
		 * Returns if the given field of the given object is currently locked.
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
	 * This class allows to lock the getter/setter/adder/remover operations based on
	 * a given name.
	 */
	static class NamedSynchronizationLock {

		private Map<String, ReentrantReadWriteLock> locks = new HashMap<String, ReentrantReadWriteLock>();

		/**
		 * Retrieves the lock with the given name.
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
		 * Locks the given name until unlocked (write).
		 * 
		 * Internally, a fair reentrant read/write lock is used.
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
		 * Locks the given name until unlocked (read).
		 * 
		 * Internally, a fair reentrant read/write lock is used.
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
		 * Unlocks the given name until unlocked (write).
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
		 * Unlocks the given name until unlocked (read).
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
	 * This method can be used for the implementation of getter methods.
	 * 
	 * It will return the value/reference of the given field considering all given
	 * features (e.g. "not null", collection policy etc.).
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
	 * This method can be used for the implementation of setter methods.
	 * 
	 * It will change the value/reference of the given field considering all given
	 * features (e.g. "not null", calling methods on changes etc.). It will return,
	 * if there has been a change.
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

				// do nothing, if value/reference would not be changed
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
	 * This method can be used for the implementation of adder methods for lists
	 * (adding to its end).
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
	 * This method can be used for the implementation of adder methods for
	 * collections.
	 * 
	 * It will add the given list of elements to the given collection considering
	 * all given features (e.g. "not null", calling methods on changes etc.). It
	 * will return, if there has been a change.
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

				// special preparation for sets: remove elements from given set which already
				// exist in destination set
				if (collection instanceof Set<?>) {

					java.util.Set<E> newElements = new java.util.HashSet<E>();

					for (E obj : elements)
						if (!collection.contains(obj))
							newElements.add(obj);

					elements = newElements;

				}

				// go through each element, call "before element add" method and check, if it
				// will be added
				if (beforeElementAdd != null) {

					objsToBeAdded = new ArrayList<E>();
					int currentIndex = startIndex;
					for (E element : elements) {
						if (beforeElementAdd.call(element, currentIndex)) {
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

				// call "before add" method for whole change package and check, if it will be
				// added
				if (beforeAdd != null) {
					if (!beforeAdd.call(objsToBeAdded, indicesToBeAdded))
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

				// go through each element, which has been added, and call "after element add"
				// method
				if (afterElementAdd != null) {

					int currentIndex = startIndex;
					for (E element : objsAdded) {
						afterElementAdd.call(element, currentIndex);
						currentIndex++;
					}

				}

				// call "after add" method for whole change package, which has been added
				if (afterAdd != null) {
					afterAdd.call(objsAdded, indicesToBeAdded);
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
	 * This method can be used for the implementation of remover methods for
	 * collections.
	 * 
	 * Either it will remove the given list of elements from the given collection
	 * (<code>elements != null</code>), or it will remove the element with the given
	 * index from the given list (<code>index != null</code>) considering all given
	 * features (e.g. "not null", calling methods on changes etc.). It will return,
	 * if there has been a change.
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

				// reduce elements to elements which are really in the collection
				if (elements != null) {

					java.util.Collection<E> newElements = new java.util.HashSet<E>();

					for (E obj : elements)
						if (collection.contains(obj))
							newElements.add(obj);

					elements = newElements;

				}

				// go through each element, call "before element remove" method and check,
				// if it will be removed
				objsToBeRemoved = new ArrayList<E>();
				if (index != null) {

					indicesToBeRemoved = new ArrayList<Integer>();
					E element = ((List<? extends E>) collection).get(index);

					if (beforeElementRemove == null || beforeElementRemove.call(element, index)) {
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
									if (beforeElementRemove == null || beforeElementRemove.call(element, i)) {
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
							if (beforeElementRemove == null || beforeElementRemove.call(element, -1))
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
					if (!beforeRemove.call(objsToBeRemoved, indicesToBeRemoved))
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

				// go through each element, which has been removed,
				// and call "after element remove" method
				if (afterElementRemove != null) {

					for (int i = 0; i < objsRemoved.size(); i++) {

						int currentIndex = -1;

						if (indicesToBeRemoved != null)
							currentIndex = indicesToBeRemoved.get(i);
						afterElementRemove.call(objsRemoved.get(i), currentIndex);

					}

				}

				// call "after remove" method for whole change package, which has been removed
				if (afterRemove != null) {
					afterRemove.call(objsRemoved, indicesToBeRemoved);
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
	 * This method can be used for the implementation of adder methods for maps.
	 * 
	 * It will put the given key/value entries to the map considering all given
	 * features (e.g. "not null" etc.).
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
	 * This method can be used for the implementation of remover methods for maps.
	 * 
	 * It will remove the given key from the given map. It will return the
	 * associated value (or null, if there was no entry).
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
	 * This method can be used for the implementation of remover methods for maps
	 * (clear).
	 * 
	 * It will remove all elements from the map. It will return, if there has been a
	 * change.
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
