package org.eclipse.xtend.lib.annotation.etai.utils;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import org.eclipse.xtend.lib.annotation.etai.DefaultValueProvider;

public class ReflectUtils {

	/**
	 * <p>
	 * This method retrieves the (private) method of a given class. If the
	 * method is not found within class, it will search recursively through
	 * super types as well.
	 * </p>
	 * 
	 * <p>
	 * The method returns the first method with the given name.
	 * </p>
	 * 
	 * <p>
	 * If the method cannot be found, null is returned.
	 * </p>
	 */
	public static Method getPrivateMethod(Class<?> clazz, String methodName) {

		// search through this clazz
		for (Method method : clazz.getDeclaredMethods()) {

			if (method.getName().equals(methodName))
				return method;

		}

		// recursively got up, if not found in this class
		if (clazz.getSuperclass() != null)
			return getPrivateMethod(clazz.getSuperclass(), methodName);

		return null;

	}

	/**
	 * <p>
	 * This method retrieves the (private) method of a given class. If the
	 * method is not found within class, it will search recursively through
	 * super types as well.
	 * </p>
	 * 
	 * <p>
	 * The method tries to match the given parameter types exactly.
	 * </p>
	 * 
	 * <p>
	 * If the method cannot be found, null is returned.
	 * </p>
	 */
	public static Method getPrivateMethod(Class<?> clazz, String methodName, Class<?>[] parameterTypes) {

		int parameterCount = 0;
		if (parameterTypes != null)
			parameterCount = parameterTypes.length;

		// search through this clazz
		for (Method method : clazz.getDeclaredMethods()) {

			if (method.getName().equals(methodName) && method.getParameterCount() == parameterCount) {

				// also check types (exactly)
				boolean match = true;
				for (int i = 0; i < parameterCount && match; i++)
					if (parameterTypes[i] != method.getParameterTypes()[i])
						match = false;

				if (match)
					return method;

			}

		}

		// recursively got up, if not found in this class
		if (clazz.getSuperclass() != null)
			return getPrivateMethod(clazz.getSuperclass(), methodName, parameterTypes);

		return null;

	}

	/**
	 * <p>
	 * This method retrieves the (private) field of a given class. If the field
	 * is not found within class, it will search recursively through super types
	 * as well.
	 * </p>
	 * 
	 * <p>
	 * If the field cannot be found, null is returned.
	 * </p>
	 */
	public static Field getPrivateField(Class<?> clazz, String fieldName) {

		// search through this clazz
		for (Field field : clazz.getDeclaredFields()) {

			if (field.getName().equals(fieldName)) {

				return field;

			}

		}

		// recursively got up, if not found in this class
		if (clazz.getSuperclass() != null)
			return getPrivateField(clazz.getSuperclass(), fieldName);

		return null;

	}

	/**
	 * <p>
	 * This method retrieves the value of a (private) field of the given object.
	 * </p>
	 * 
	 * @see getPrivateField(Class, String)
	 */
	public static Object getPrivateFieldValue(Object obj, String fieldName) {

		Field field = getPrivateField(obj.getClass(), fieldName);

		boolean previousAccessible = field.isAccessible();
		field.setAccessible(true);
		try {

			return field.get(obj);

		} catch (IllegalArgumentException | IllegalAccessException e) {
			throw new RuntimeException(e);
		} finally {
			field.setAccessible(previousAccessible);
		}

	}

	/**
	 * Helper method for calling an extended (non-public) method in the extended
	 * class. This method is used by an processed or envelope methods of
	 * extension classes.
	 * 
	 * @see org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
	 * @see org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
	 */
	public static Object callExtendedMethod(Object obj, String methodName, DefaultValueProvider<?> defaultValueProvider,
			boolean isVoid, Class<?>[] parameterTypes, Object[] args) {

		// search for method within extended class
		Method method = getPrivateMethod(obj.getClass(), methodName, parameterTypes);

		// use default value provider, if no method found
		if (method == null) {

			if (isVoid)
				return null;

			if (defaultValueProvider == null) {

				throw new IllegalArgumentException(String.format(
						"Method \"%s\" not found in object of class \"%s\", so default value provider is necessary for non-void methods, but such a value provider has not been provided",
						methodName, obj.getClass()));
			}

			return defaultValueProvider.getDefaultValue();

		}

		boolean previousAccessible = method.isAccessible();
		method.setAccessible(true);
		try {

			try {

				// invoke method
				return method.invoke(obj, args);

			} catch (IllegalAccessException | IllegalArgumentException | InvocationTargetException e) {
				throw new RuntimeException(e);
			}

		} finally {
			method.setAccessible(previousAccessible);
		}

	}

}
