package org.eclipse.xtend.lib.annotation.etai.utils;

import java.lang.invoke.MethodHandle;
import java.lang.invoke.MethodHandles;
import java.lang.invoke.MethodType;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.xtend.lib.annotation.etai.DefaultValueProvider;

public class ReflectUtils {

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

		// recursively got up, if not found in this class
		if (clazz.getSuperclass() != null)
			return getPrivateMethod(clazz.getSuperclass(), methodName);

		return null;

	}

	/**
	 * Helper method for implementing {@link #getPrivateMethodExactMatch} and
	 * {@link #getPrivateMethodCompatibleMatch}.
	 */
	private static Method getPrivateMethod(Class<?> clazz, String methodName, Class<?>[] parameterTypes,
			boolean compatible) {

		int parameterCount = 0;
		if (parameterTypes != null)
			parameterCount = parameterTypes.length;

		// search through this clazz
		for (Method method : clazz.getDeclaredMethods()) {

			if (method.getName().equals(methodName) && method.getParameterCount() == parameterCount) {

				// also check types (exactly)
				boolean match = true;
				for (int i = 0; i < parameterCount && match; i++)
					if (compatible) {
						if (parameterTypes[i] != null
								&& !method.getParameterTypes()[i].isAssignableFrom(parameterTypes[i]))
							match = false;
					} else {
						if (method.getParameterTypes()[i] != parameterTypes[i])
							match = false;
					}

				if (match)
					return method;

			}

		}

		// recursively got up, if not found in this class
		if (clazz.getSuperclass() != null)
			return getPrivateMethod(clazz.getSuperclass(), methodName, parameterTypes, compatible);

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

		return getPrivateMethod(clazz, methodName, parameterTypes, false);

	}

	/**
	 * <p>
	 * This method retrieves the (private) method of a given class. If the method is
	 * not found within class, it will search recursively through super types as
	 * well.
	 * </p>
	 * 
	 * <p>
	 * The method tries to match the given parameter types, if compatible (i.e the
	 * given parameter type is at least a sub type).
	 * </p>
	 * 
	 * <p>
	 * If the method cannot be found, <code>null</code> is returned.
	 * </p>
	 */
	public static Method getPrivateMethodCompatibleMatch(Class<?> clazz, String methodName, Class<?>[] parameterTypes) {

		return getPrivateMethod(clazz, methodName, parameterTypes, true);

	}

	/**
	 * <p>
	 * This method calls a method (can be private) with the given arguments.
	 * </p>
	 */
	public static Object callPrivateMethod(Object obj, Method method, Object[] arguments)
			throws IllegalAccessException, IllegalArgumentException, InvocationTargetException {

		boolean previousAccessible = method.isAccessible();
		method.setAccessible(true);
		try {

			return method.invoke(obj, arguments);

		} catch (IllegalArgumentException | IllegalAccessException e) {
			throw new RuntimeException(e);
		} finally {
			method.setAccessible(previousAccessible);
		}

	}

	/**
	 * <p>
	 * This method calls a method (can be private) with the given arguments.
	 * </p>
	 * 
	 * @see getPrivateMethodCompatibleMatch(Class, String, Class[])
	 */
	public static Object callPrivateMethod(Object obj, String methodName, Object[] arguments)
			throws IllegalAccessException, IllegalArgumentException, InvocationTargetException {

		Class<?>[] parameterTypes = new Class<?>[arguments.length];
		for (int i = 0; i < arguments.length; i++) {
			if (arguments[i] == null)
				parameterTypes[i] = null;
			else
				parameterTypes[i] = arguments[i].getClass();
		}

		return callPrivateMethod(obj, getPrivateMethodCompatibleMatch(obj.getClass(), methodName, parameterTypes),
				arguments);

	}

	/**
	 * <p>
	 * This method calls a method (can be private) without arguments.
	 * </p>
	 * 
	 * @see getPrivateMethodCompatibleMatch(Class, String, Class[])
	 */
	public static Object callPrivateMethod(Object obj, String methodName)
			throws IllegalAccessException, IllegalArgumentException, InvocationTargetException {

		return callPrivateMethod(obj, getPrivateMethodCompatibleMatch(obj.getClass(), methodName, null), null);

	}

	/**
	 * TODO: here 
	 * 
	 * TODO: description
	 * 
	 * TODO: this does not work, because target is not accessible
	 * 
	 * @throws Throwable
	 */
	public static Object callPrivateMethodSpecial(Class<?> clazz, Object obj, String methodName, Class<?>[] types,
			Object[] arguments) throws Throwable {

		MethodHandle methodHandle;

		// search method in given clazz (exact class, exact parameter match)
		if (types.length > 1) {

			List<Class<?>> parameters = new ArrayList<Class<?>>();
			for (int i = 1; i < types.length; i++)
				parameters.add(types[i]);

			methodHandle = MethodHandles.lookup().findSpecial(clazz, methodName,
					MethodType.methodType(types[0], parameters), clazz);

		} else {

			methodHandle = MethodHandles.lookup().findSpecial(clazz, methodName, MethodType.methodType(types[0]),
					clazz);

		}

		// invoke found method and return result
		return methodHandle.invoke(obj, arguments);

	}
	
	/**
	 * TODO: here 
	 * 
	 * TODO: description
	 * 
	 * TODO: this does not work, because target is not accessible
	 * 
	 * @throws Throwable
	 */
	public static Object callPrivateMethodSpecial2(Class<?> clazz, Object obj, String methodName, Class<?>[] parameterTypes,
			Object[] arguments) throws Throwable {

		Method method = getPrivateMethodExactMatch(clazz, methodName, parameterTypes);
		
		boolean previousAccessible = method.isAccessible();
		method.setAccessible(true);
		try {

			MethodHandle methodHandle = MethodHandles.lookup().unreflectSpecial(method, clazz);

			// invoke found method and return result
			return methodHandle.invoke(obj, arguments);

		} catch (IllegalArgumentException | IllegalAccessException e) {
			throw new RuntimeException(e);
		} finally {
			method.setAccessible(previousAccessible);
		}

			

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

		// recursively got up, if not found in this class
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

		boolean previousAccessible = field.isAccessible();
		field.setAccessible(true);
		try {

			field.set(obj, value);

		} catch (IllegalArgumentException | IllegalAccessException e) {
			throw new RuntimeException(e);
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
	 * Helper method for calling an extended (non-public) method in the extended
	 * class. This method is used by an processed or envelope methods of extension
	 * classes.
	 * 
	 * @see org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
	 * @see org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
	 */
	public static Object callExtendedMethod(Object obj, String methodName, DefaultValueProvider<?> defaultValueProvider,
			boolean isVoid, Class<?>[] parameterTypes, Object[] args) {

		// search for method within extended class
		Method method = getPrivateMethodExactMatch(obj.getClass(), methodName, parameterTypes);

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
