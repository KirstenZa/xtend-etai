package org.eclipse.xtend.lib.annotation.etai.utils;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;

/**
 * Utility class providing string utilities.
 */
public class StringUtils {

	/**
	 * <p>
	 * Splits strings by delimiter, which does not consider text in parenthesis
	 * (determined by start and stop character).
	 * </p>
	 * 
	 * <p>
	 * Example where delimiter is ',', start is '(', stop is ')':
	 * </p>
	 * 
	 * <code>String: "(test), test2,test3,(x,(y),z),(,),"</code>
	 * 
	 * <p>
	 * =&gt;
	 * </p>
	 * 
	 * <code>List&lt;String&gt;: {"test"},{" test2"},{"test3"},{"x,(y),z"},{","},{""}</code>
	 *
	 */
	public static List<String> splitConsideringParenthesis(String str, char delimiter, char start, char stop) {

		List<String> result = new ArrayList<String>();

		int inside = 0;
		char[] strArray = str.toCharArray();
		StringBuilder stringBuilderResult = new StringBuilder();
		for (int i = 0; i < strArray.length; i++) {
			char currentChar = strArray[i];
			if (currentChar == delimiter && inside == 0) {
				result.add(stringBuilderResult.toString());
				stringBuilderResult = new StringBuilder();
			} else {
				if (currentChar == start) {
					inside++;
				} else if (currentChar == stop) {

					// must be inside parenthesis
					if (inside == 0)
						throw new IllegalArgumentException(
								"Cannot parse string, because parenthesis closed but not opened");

					inside = inside > 0 ? inside - 1 : 0;
				}
				stringBuilderResult.append(currentChar);
			}
		}
		result.add(stringBuilderResult.toString());

		// must not be inside quotes at the end
		if (inside != 0)
			throw new IllegalArgumentException("Cannot parse string, because opened parenthesis have not been closed");

		return result;

	}

	/**
	 * Retrieves stack trace from throwable / exception.
	 */
	public static String getStackTrace(Throwable throwable) {

		StringWriter sw = new StringWriter();
		PrintWriter pw = new PrintWriter(sw);
		throwable.printStackTrace(pw);
		return sw.toString();

	}

}
