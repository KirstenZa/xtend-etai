package org.eclipse.xtend.lib.annotation.etai.utils;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.NoSuchElementException;

/**
 * Utility class providing collection utilities.
 */
public class CollectionUtils {

	/**
	 * This list is a specialized list containing array/list with increasing
	 * indices. It is initialized with the starting index and a length. It does not
	 * support any operation for modifying the list.
	 */
	public static class StraightIndexList implements List<Integer> {

		private int startingIndex;
		private int length;

		public StraightIndexList(int startingIndex, int length) {
			if (startingIndex < 0 || length < 0)
				throw new IllegalArgumentException();
			this.startingIndex = startingIndex;
			this.length = length;
		}

		@Override
		public boolean add(Integer e) {
			throw new UnsupportedOperationException();
		}

		@Override
		public void add(int index, Integer element) {
			throw new UnsupportedOperationException();
		}

		@Override
		public boolean addAll(Collection<? extends Integer> c) {
			throw new UnsupportedOperationException();
		}

		@Override
		public boolean addAll(int index, Collection<? extends Integer> c) {
			throw new UnsupportedOperationException();
		}

		@Override
		public void clear() {
			throw new UnsupportedOperationException();
		}

		@Override
		public boolean contains(Object o) {
			if (o instanceof Integer)
				return ((Integer) o >= startingIndex && (Integer) o < startingIndex + length);
			return false;
		}

		@Override
		public boolean containsAll(Collection<?> c) {
			for (Object obj : c)
				if (!(obj instanceof Integer)
						|| ((Integer) obj < startingIndex || (Integer) obj >= startingIndex + length))
					return false;
			return true;
		}

		@Override
		public Integer get(int index) {
			if (index < 0 || index >= length)
				throw new IndexOutOfBoundsException();
			return index + startingIndex;
		}

		@Override
		public int indexOf(Object o) {
			if (o instanceof Integer)
				if ((Integer) o >= startingIndex && (Integer) o < startingIndex + length)
					return (Integer) o - startingIndex;
			return -1;
		}

		@Override
		public boolean isEmpty() {
			return length <= 0;
		}

		@Override
		public Iterator<Integer> iterator() {
			return listIterator();
		}

		@Override
		public int lastIndexOf(Object o) {
			return indexOf(o);
		}

		@Override
		public ListIterator<Integer> listIterator() {
			return new StraightIndexListIterator(startingIndex, length, 0);
		}

		@Override
		public ListIterator<Integer> listIterator(int index) {
			if (index < 0 || index >= length)
				throw new IndexOutOfBoundsException();
			return new StraightIndexListIterator(startingIndex + index, length - index, index);
		}

		@Override
		public boolean remove(Object o) {
			throw new UnsupportedOperationException();
		}

		@Override
		public Integer remove(int index) {
			throw new UnsupportedOperationException();
		}

		@Override
		public boolean removeAll(Collection<?> c) {
			throw new UnsupportedOperationException();
		}

		@Override
		public boolean retainAll(Collection<?> c) {
			throw new UnsupportedOperationException();
		}

		@Override
		public Integer set(int index, Integer element) {
			throw new UnsupportedOperationException();
		}

		@Override
		public int size() {
			return length;
		}

		@Override
		public List<Integer> subList(int fromIndex, int toIndex) {
			if (fromIndex < 0 || toIndex > length || fromIndex > toIndex)
				throw new IndexOutOfBoundsException();
			return new StraightIndexList(startingIndex + fromIndex, toIndex - fromIndex);
		}

		@Override
		public Object[] toArray() {
			Integer[] newArray = new Integer[length];
			for (int i = 0; i < length; i++)
				newArray[i] = i + startingIndex;
			return newArray;
		}

		@SuppressWarnings("unchecked")
		@Override
		public <T> T[] toArray(T[] a) {
			for (int i = 0; i < length; i++)
				a[i] = (T) (Integer) (i + startingIndex);
			return a;
		}

	}

	/**
	 * This is a specialized iterator for the list for array/list indices.
	 * 
	 * @see org.eclipse.xtend.lib.annotation.etai.utils.CollectionUtils.StraightIndexList
	 */
	static public class StraightIndexListIterator implements ListIterator<Integer> {

		private int currentIndex;
		private int indicesBack;
		private int indicesFront;

		public StraightIndexListIterator(int currentIndex, int indicesFront, int indicesBack) {
			this.currentIndex = currentIndex;
			this.indicesBack = indicesBack;
			this.indicesFront = indicesFront;
		}

		@Override
		public void add(Integer e) {
			throw new UnsupportedOperationException();
		}

		@Override
		public boolean hasNext() {
			return indicesFront >= 1;
		}

		@Override
		public boolean hasPrevious() {
			return indicesBack >= 1;
		}

		@Override
		public Integer next() {
			if (indicesFront <= 0)
				throw new NoSuchElementException();
			indicesFront--;
			indicesBack++;
			return currentIndex++;
		}

		@Override
		public int nextIndex() {
			return indicesBack;
		}

		@Override
		public Integer previous() {
			if (indicesBack <= 0)
				throw new NoSuchElementException();
			indicesFront++;
			indicesBack--;
			return --currentIndex;
		}

		@Override
		public int previousIndex() {
			return indicesBack - 1;
		}

		@Override
		public void remove() {
			throw new UnsupportedOperationException();
		}

		@Override
		public void set(Integer e) {
			throw new UnsupportedOperationException();
		}
	};

	/**
	 * Creates the cartesian product out of two lists (containing lists).
	 */
	public static <E> List<List<E>> cartesianProduct(List<List<E>> a, List<List<E>> b) {

		List<List<E>> result = new ArrayList<List<E>>(a.size() * b.size());

		for (List<E> elementA : a) {

			for (List<E> elementB : b) {
				List<E> currentList = new ArrayList<E>();
				result.add(currentList);
				currentList.addAll(elementA);
				currentList.addAll(elementB);
			}

		}

		return result;

	}

	/**
	 * Creates the cartesian product out of multiple lists (containing lists).
	 */
	public static <E> List<List<E>> cartesianProduct(List<List<List<E>>> lists) {

		if (lists.size() == 0)
			return new ArrayList<List<E>>();

		if (lists.size() == 1)
			return new ArrayList<List<E>>(lists.get(0));

		List<List<E>> result = lists.get(0);
		for (int i = 1; i < lists.size(); i++)
			result = cartesianProduct(result, lists.get(i));

		return result;

	}

	/**
	 * Checks if given collection contains the specified element.
	 * 
	 * In contrast to the original method of java.util.Collection, this method
	 * ensures that no exception is thrown, if the specified element is not
	 * supported by the collection.
	 */
	public static boolean containsNoThrow(Collection<?> collection, Object element) {

		try {

			return collection.contains(element);

		} catch (Exception e) {

			if (collection == null)
				throw e;

		}

		return false;

	}

	/**
	 * Checks if given map contains the specified key.
	 * 
	 * In contrast to the original method of java.util.Map, this method ensures that
	 * no exception is thrown, if the specified key is not supported by the map.
	 */
	public static boolean containsKeyNoThrow(Map<?, ?> map, Object key) {

		try {

			return map.containsKey(key);

		} catch (Exception e) {

			if (map == null)
				throw e;

		}

		return false;

	}

	/**
	 * Checks if given map contains the specified value.
	 * 
	 * In contrast to the original method of java.util.Map, this method ensures that
	 * no exception is thrown, if the specified value is not supported by the map.
	 */
	public static boolean containsValueNoThrow(Map<?, ?> map, Object value) {

		try {

			return map.containsValue(value);

		} catch (Exception e) {

			if (map == null)
				throw e;

		}

		return false;

	}

}
