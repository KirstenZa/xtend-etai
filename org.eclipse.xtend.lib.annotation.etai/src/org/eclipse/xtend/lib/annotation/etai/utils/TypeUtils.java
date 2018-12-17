package org.eclipse.xtend.lib.annotation.etai.utils;

/**
 * Utility class for handling types and type strings.
 */
public class TypeUtils {

	/**
	 * <p>Retrieves the simple type name from the qualified one.</p>
	 * 
	 * <pre>
	 * Example:
	 *   qualifiedName       com.example.test.MyClass
	 *   result              MyClass
	 * </pre>
	 */
	public static String getSimpleNameFromQualifiedName(String qualifiedName) {

		if (qualifiedName.lastIndexOf('.') == -1)
			return qualifiedName;

		return qualifiedName.substring(qualifiedName.lastIndexOf('.') + 1, qualifiedName.length());

	}

	/**
	 * <p>Removes the given simple type name from the qualified one.</p>
	 * 
	 * <pre>
	 * Example:
	 *   qualifiedName       com.example.test.MyClass
	 *   result              com.example.test.
	 * </pre>
	 */
	public static String removeSimpleNameFromQualifiedName(String qualifiedName) {

		if (qualifiedName.lastIndexOf('.') == -1)
			return "";

		return qualifiedName.substring(0, qualifiedName.lastIndexOf('.') + 1);

	}

	/**
	 * <p>Prepends a string to the simple type name of a qualified one.</p>
	 * 
	 * <pre>
	 * Example:
	 *   qualifiedName       com.example.test.MyClass
	 *   str                 I
	 *   result              com.example.test.IMyClass
	 * </pre>
	 */
	public static String prependToSimpleNameFromQualifiedName(String qualifiedName, String str) {

		if (qualifiedName.lastIndexOf('.') == -1)
			return str + qualifiedName;

		return removeSimpleNameFromQualifiedName(qualifiedName) + "." + str
				+ getSimpleNameFromQualifiedName(qualifiedName);

	}

}
