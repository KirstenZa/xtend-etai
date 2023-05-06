package org.eclipse.xtend.lib.annotation.etai.utils;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import org.eclipse.xtend.lib.annotation.etai.DefaultValueProvider;
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.TypeMatchingStrategy;

public class ReflectUtils {

	/**
	 * <p>Method for realizing sneaky throws.</p>
	 */
	@SuppressWarnings("unchecked")
	public static <E extends Throwable> void sneakyThrow(Throwable e) throws E {
		throw (E) e;
	}

	/**
	 * <p>
	 * This method retrieves the (private) method of a given class. If the method is
	 * not found within class, it will search recursively through super types as
	 * well.
	 * </p>
	 * 
	 * <p>
	 * The method returns the first method with the given name.
	 * </p>
	 * 
	 * <p>
	 * If the method cannot be found, <code>null</code> is returned.
	 * </p>
	 */
	public static Method getPrivateMethod(Class<?> clazz, String methodName) {

		// search through this clazz
		for (Method method : clazz.getDeclaredMethods())
			if (method.getName().equals(methodName))
				return method;

		// recursively go up the hierarchy if not found in this class
		if (clazz.getSuperclass() != null)
			return getPrivateMethod(clazz.getSuperclass(), methodName);

		return null;

	}

	/**
	 * <p>Helper method for implementing {@link #getPrivateMethodExactMatch} and
	 * {@link #getPrivateMethodCovariantMatch}.</p>
	 */
	private static Method getPrivateMethod(Class<?> clazz, String methodName, Class<?>[] parameterTypes,
			TypeMatchingStrategy typeMatchingStrategy) {

		int parameterCount = 0;
		if (parameterTypes != null)
			parameterCount = parameterTypes.length;

		// search through this clazz
		for (Method method : clazz.getDeclaredMethods()) {

			if (method.getName().equals(methodName) && method.getParameterCount() == parameterCount) {

				// also check types (exactly)
				boolean match = true;

				if (typeMatchingStrategy != TypeMatchingStrategy.MATCH_ALL
						&& typeMatchingStrategy != TypeMatchingStrategy.MATCH_ALL_CONSTRUCTOR_METHOD) {

					for (int i = 0; i < parameterCount && match; i++)
						if (typeMatchingStrategy == TypeMatchingStrategy.MATCH_COVARIANT
								|| typeMatchingStrategy == TypeMatchingStrategy.MATCH_COVARIANT_CONSTRUCTOR_METHOD) {
							if (parameterTypes[i] != null
									&& !method.getParameterTypes()[i].isAssignableFrom(parameterTypes[i]))
								match = false;
						} else if (typeMatchingStrategy == TypeMatchingStrategy.MATCH_CONTRAVARIANT
								|| typeMatchingStrategy == TypeMatchingStrategy.MATCH_CONTRAVARIANT_CONSTRUCTOR_METHOD) {
							if (parameterTypes[i] != null
									&& !parameterTypes[i].isAssignableFrom(method.getParameterTypes()[i]))
								match = false;
						} else if (typeMatchingStrategy == TypeMatchingStrategy.MATCH_INHERITED
								|| typeMatchingStrategy == TypeMatchingStrategy.MATCH_INHERITED_CONSTRUCTOR_METHOD) {
							if (parameterTypes[i] != null
									&& !method.getParameterTypes()[i].isAssignableFrom(parameterTypes[i])
									&& !parameterTypes[i].isAssignableFrom(method.getParameterTypes()[i]))
								match = false;
						} else {
							if (!method.getParameterTypes()[i].equals(parameterTypes[i]))
								match = false;
						}

				}

				if (match)
					return method;

			}

		}

		// recursively go up the hierarchy if not found in this class
		if (clazz.getSuperclass() != null)
			return getPrivateMethod(clazz.getSuperclass(), methodName, parameterTypes, typeMatchingStrategy);

		return null;

	}

	/**
	 * <p>
	 * This method retrieves the (private) method of a given class. If the method is
	 * not found within class, it will search recursively through super types as
	 * well.
	 * </p>
	 * 
	 * <p>
	 * The method tries to match the given parameter types exactly.
	 * </p>
	 * 
	 * <p>
	 * If the method cannot be found, <code>null</code> is returned.
	 * </p>
	 */
	public static Method getPrivateMethodExactMatch(Class<?> clazz, String methodName, Class<?>[] parameterTypes) {

		return getPrivateMethod(clazz, methodName, parameterTypes, TypeMatchingStrategy.MATCH_INVARIANT);

	}

	/**
	 * <p>
	 * This method retrieves the (private) method of a given class. If the method is
	 * not found within class, it will search recursively through super types as
	 * well.
	 * </p>
	 * 
	 * <p>
	 * The method tries to match the given parameter types if the given parameter
	 * type is at least a sub type of the method's parameter.
	 * </p>
	 * 
	 * <p>
	 * If the method cannot be found, <code>null</code> is returned.
	 * </p>
	 */
	public static Method getPrivateMethodCovariantMatch(Class<?> clazz, String methodName, Class<?>[] parameterTypes) {

		return getPrivateMethod(clazz, methodName, parameterTypes, TypeMatchingStrategy.MATCH_COVARIANT);

	}

	/**
	 * <p>
	 * This method retrieves the (private) method of a given class. If the method is
	 * not found within class, it will search recursively through super types as
	 * well.
	 * </p>
	 * 
	 * <p>
	 * The method tries to match the given parameter types if the given parameter
	 * type is in an inheritance relation with the method's parameter.
	 * </p>
	 * 
	 * <p>
	 * If the method cannot be found, <code>null</code> is returned.
	 * </p>
	 */
	public static Method getPrivateMethodInheritanceMatch(Class<?> clazz, String methodName,
			Class<?>[] parameterTypes) {

		return getPrivateMethod(clazz, methodName, parameterTypes, TypeMatchingStrategy.MATCH_INHERITED);

	}

	/**
	 * <p>
	 * This method calls a method (can be private) with the given arguments.
	 * </p>
	 */
	public static Object callPrivateMethod(Object obj, Method method, Object[] arguments) {

		boolean previousAccessible = method.canAccess(obj);

		method.setAccessible(true);

		try {

			return method.invoke(obj, arguments);

		} catch (IllegalArgumentException | IllegalAccessException e) {

			ReflectUtils.<RuntimeException>sneakyThrow(e);

		} catch (InvocationTargetException e) {

			ReflectUtils.<RuntimeException>sneakyThrow(e.getTargetException());

		} finally {

			method.setAccessible(previousAccessible);

		}

		return null;

	}

	/**
	 * <p>
	 * This method calls a method (can be private) with the given arguments.
	 * </p>
	 * 
	 * @see getPrivateMethodCovariantMatch(Class, String, Class[])
	 */
	public static Object callPrivateMethod(Object obj, String methodName, Object[] arguments) {

		Class<?>[] parameterTypes = new Class<?>[arguments.length];
		for (int i = 0; i < arguments.length; i++) {
			if (arguments[i] == null)
				parameterTypes[i] = null;
			else
				parameterTypes[i] = arguments[i].getClass();
		}

		return callPrivateMethod(obj, getPrivateMethodCovariantMatch(obj.getClass(), methodName, parameterTypes),
				arguments);

	}

	/**
	 * <p>
	 * This method calls a method (can be private) without arguments.
	 * </p>
	 * 
	 * @see getPrivateMethodCovariantMatch(Class, String, Class[])
	 */
	public static Object callPrivateMethod(Object obj, String methodName) {

		return callPrivateMethod(obj, getPrivateMethodCovariantMatch(obj.getClass(), methodName, null), null);

	}

	/**
	 * <p>
	 * This method retrieves the (private) field of a given class. If the field is
	 * not found within class, it will search recursively through super types as
	 * well.
	 * </p>
	 * 
	 * <p>
	 * If the field cannot be found, <code>null</code> is returned.
	 * </p>
	 */
	public static Field getPrivateField(Class<?> clazz, String fieldName) {

		// search through this clazz
		for (Field field : clazz.getDeclaredFields())
			if (field.getName().equals(fieldName))
				return field;

		// recursively go up the hierarchy if not found in this class
		if (clazz.getSuperclass() != null)
			return getPrivateField(clazz.getSuperclass(), fieldName);

		return null;

	}

	/**
	 * <p>
	 * This method retrieves the value of a (private) field of the given object.
	 * </p>
	 */
	public static Object getPrivateFieldValue(Object obj, Field field) {

		boolean previousAccessible = field.canAccess(obj);
		field.setAccessible(true);

		try {

			return field.get(obj);

		} catch (IllegalArgumentException | IllegalAccessException e) {

			ReflectUtils.<RuntimeException>sneakyThrow(e);

		} finally {

			field.setAccessible(previousAccessible);

		}

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

		return getPrivateFieldValue(obj, getPrivateField(obj.getClass(), fieldName));

	}

	/**
	 * <p>
	 * This method sets the value of a (private) field of the given object.
	 * </p>
	 */
	public static void setPrivateFieldValue(Object obj, Field field, Object value) {

		boolean previousAccessible = field.canAccess(obj);
		field.setAccessible(true);

		try {

			field.set(obj, value);

		} catch (IllegalArgumentException | IllegalAccessException e) {

			ReflectUtils.<RuntimeException>sneakyThrow(e);

		} finally {

			field.setAccessible(previousAccessible);

		}

	}

	/**
	 * <p>
	 * This method sets the value of a (private) field of the given object.
	 * </p>
	 * 
	 * @see getPrivateField(Class, String)
	 */
	public static void setPrivateFieldValue(Object obj, String fieldName, Object value) {

		setPrivateFieldValue(obj, getPrivateField(obj.getClass(), fieldName), value);

	}

	/**
	 * <p>Helper method for calling a (non-public) method in the extended class.</p>
	 */
	public static Object callMethodInExtendedClass(Object obj, String methodName,
			Class<? extends DefaultValueProvider<?>> defaultValueProvider, boolean isVoid, Class<?>[] parameterTypes,
			Object[] args) {

		// search for method within extended class
		Method method = getPrivateMethodInheritanceMatch(obj.getClass(), methodName, parameterTypes);

		// use default value provider if no method found
		if (method == null) {

			if (isVoid)
				return null;

			if (defaultValueProvider == null) {

				throw new IllegalArgumentException(String.format(
						"Method \"%s\" not found in object of class \"%s\", so default value provider is necessary for non-void methods, but such a value provider has not been provided",
						methodName, obj.getClass()));
			}

			try {

				return defaultValueProvider.getConstructor().newInstance().getDefaultValue();

			} catch (InstantiationException | IllegalAccessException | IllegalArgumentException | InvocationTargetException | NoSuchMethodException | SecurityException e) {

				ReflectUtils.<RuntimeException>sneakyThrow(e);

			}

			return null;

		}

		return callPrivateMethod(obj, method, args);

	}

}