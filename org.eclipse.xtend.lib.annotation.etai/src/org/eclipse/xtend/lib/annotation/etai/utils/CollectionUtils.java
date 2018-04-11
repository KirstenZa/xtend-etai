package org.eclipse.xtend.lib.annotation.etai.utils;

import java.util.ArrayList;
import java.util.List;

/**
 * Utility class providing collection utilities.
 */
public class CollectionUtils {

	/**
	 * Creates the cartesian product out of two lists (containing lists).
	 */
	public static <E> List<List<E>> cartesianProduct(List<List<E>> a, List<List<E>> b) {

		List<List<E>> result = new ArrayList<List<E>>(a.size() * b.size());
		
		for (List<E> elementA : a) {
					
			for (List<E> elementB : b)
			{
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

}
