package org.eclipse.xtend.lib.annotation.etai

import java.util.ArrayList
import java.util.HashMap
import java.util.List
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.TypeErasureMethod
import org.eclipse.xtend.lib.annotation.etai.utils.ReflectUtils
import org.eclipse.xtend.lib.macro.declaration.ExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.expression.Expression
import org.eclipse.xtend.lib.macro.services.AnnotationReferenceProvider
import org.eclipse.xtend.lib.macro.services.TypeReferenceProvider

import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*

/**
 * <p>Helper class for retrieving and setting bodies for executables
 * (methods or constructors) correctly.
 * It will provide a workaround for the problem that bodies are
 * not available after setting it via string. However, bodies
 * must be available immediately after setting via string, so this class
 * will cache all body processing.</p>
 * 
 * <p>After using the class, the flush method must be used in order to
 * commit all bodies.</p>
 */
class BodySetter {

	static class BodyInfo {

		public boolean flushed = false
		public String methodBody
		public TypeReferenceProvider context

		new(boolean flushed, String methodBody, TypeReferenceProvider context) {
			this.flushed = flushed
			this.methodBody = methodBody
			this.context = context
		}

	}

	val cachedBodies = new HashMap<MutableExecutableDeclaration, BodyInfo>

	/**
	 * <p>Returns the body of the given executable.</p>
	 */
	def String getBody(ExecutableDeclaration executable) {
		if (cachedBodies.containsKey(executable))
			return cachedBodies.get(executable).methodBody
		return executable.body.toString
	}

	/**
	 * <p>Returns if a body has been set for the given executable.</p>
	 */
	def boolean hasBody(MutableExecutableDeclaration executable) {

		if (cachedBodies.containsKey(executable))
			return cachedBodies.get(executable) !== null
		return executable.body !== null

	}

	/**
	 * <p>Sets method body via string by using the internal cache.
	 * Also, <code>null</code> as body string is allowed.</p>
	 */
	def setBody(MutableExecutableDeclaration executable, String bodyString, TypeReferenceProvider context) {

		cachedBodies.put(executable, new BodyInfo(false, bodyString, context))
		executable.body = null as Expression

	}

	/**
	 * <p>Move body of specified source method to given destination method considering
	 * the internal cache.</p>
	 */
	def moveBody(MutableExecutableDeclaration dest, MethodDeclaration src, TypeReferenceProvider context) {

		if (cachedBodies.containsKey(src)) {

			// set method body using cache
			setBody(dest, cachedBodies.get(src).methodBody, context)

			// ensure that source method's body is set to null (if mutable)
			if (src instanceof MutableMethodDeclaration)
				setBody(src, null, context)

		} else {

			if (src.body !== null) {

				// assignment is enough for moving body
				dest.body = src.body

				// some code to move already created local classes in addition to body as well
				if (dest.class.simpleName.startsWith("MutableJvm") && (src.class.simpleName.startsWith("Jvm") ||
					src.class.simpleName.startsWith("MutableJvm"))) {

					val delegateSrc = ReflectUtils.getPrivateFieldValue(src, "delegate")
					val delegateDest = ReflectUtils.getPrivateFieldValue(dest, "delegate")

					// ensure that required lists have been created
					val delegateSrcMethod = ReflectUtils.getPrivateMethodCovariantMatch(delegateSrc.class,
						"getLocalClasses", null)
					val delegateDestMethod = ReflectUtils.getPrivateMethodCovariantMatch(delegateDest.class,
						"getLocalClasses", null)
					if (delegateSrcMethod !== null)
						ReflectUtils.callPrivateMethod(delegateSrc, delegateSrcMethod, null)
					if (delegateDestMethod !== null)
						ReflectUtils.callPrivateMethod(delegateDest, delegateDestMethod, null)

					// access lists
					val List<Object> localClassesSrc = ReflectUtils.getPrivateFieldValue(delegateSrc,
						"localClasses") as List<Object>
					val List<Object> localClassesDest = ReflectUtils.getPrivateFieldValue(delegateDest,
						"localClasses") as List<Object>

					// add all local classes to destination list (because of containment EMF will actually perform move operations)
					while (localClassesSrc.size > 0)
						localClassesDest.add(localClassesSrc.get(0))

				}

				// ensure that cache does not contain any data for destination method any more 
				cachedBodies.remove(dest)

				// ensure that source method's body is set to null (if mutable)
				if (src instanceof MutableMethodDeclaration)
					setBody(src, null, context)

			} else {

				setBody(dest, null, context)

			}

		}

	}

	/** 
	 * <p>
	 * When copying methods the type parameters of the clone will still point to the original method.
	 * This method fixes this issue, i.e., the type references will be updated.
	 * </p> 
	 */
	private static def <T extends AnnotationReferenceProvider & TypeReferenceProvider> void fixTypeParameters(
		MutableExecutableDeclaration executable, extension T context) {

		if (executable instanceof MutableMethodDeclaration) {
			val newReturnType = getFixedTypeParameter(executable, executable.returnType, context)

			if (newReturnType !== null)
				executable.returnType = newReturnType

		}

		val newTypes = new ArrayList<TypeReference>
		for (parameter : executable.parameters)
			newTypes.add(getFixedTypeParameter(executable, parameter.type, context))

		for (index : 0 ..< executable.parameters.size) {

			if (newTypes.get(index) !== null)
				retypeParameter(executable, index, newTypes.get(index), context)

		}

	}

	/**
	 * <p>Returns a fixed type parameter.</p>
	 * 
	 * @see #fixTypeParameters
	 */
	static private def <T extends TypeReferenceProvider> TypeReference getFixedTypeParameter(
		MutableExecutableDeclaration executable, TypeReference typeReference, T context) {

		val type = typeReference.type

		if (type instanceof TypeParameterDeclaration) {

			val typeParameterDeclarator = type.typeParameterDeclarator

			if (typeParameterDeclarator instanceof ExecutableDeclaration) {

				if (typeParameterDeclarator !== executable) {

					// determine position of type declaration
					val pos = typeParameterDeclarator.typeParameters.indexed.findFirst[it.value === type].key

					// return type based on provided executable
					return context.newTypeReference(executable.typeParameters.get(pos))

				}

			}

		}

		var boolean change = false

		// go through type arguments as well
		val newActualTypeArguments = new ArrayList<TypeReference>

		for (actualTypeArgument : typeReference.actualTypeArguments) {

			val newTypeArgument = getFixedTypeParameter(executable, actualTypeArgument, context)

			if (newTypeArgument !== null) {
				newActualTypeArguments.add(newTypeArgument)
				change = true
			} else {
				newActualTypeArguments.add(actualTypeArgument)
			}

		}

		// just create a new type reference if there is any change...
		if (change)
			return context.newTypeReference(typeReference.type, newActualTypeArguments)

		// ... otherwise return null
		return null

	}

	/**
	 * <p>Write all cached method bodies to methods.</p>
	 */
	def <T extends AnnotationReferenceProvider & TypeReferenceProvider> void flush(T context) {

		for (bodyInfo : cachedBodies.entrySet) {

			if (bodyInfo.value.flushed == false) {

				var String typeAssertionBody = ""
				for (newMethodParameter : bodyInfo.key.parameters)
					if (newMethodParameter.hasAnnotation(AssertParameterType)) {
						val requiredParamterType = newMethodParameter.getAnnotation(AssertParameterType).
							getClassValue("value")
						typeAssertionBody +=
							'''assert «newMethodParameter.simpleName» == null || «newMethodParameter.simpleName» instanceof «requiredParamterType.getTypeReferenceAsString(true, TypeErasureMethod.REMOVE_CONCRETE_TYPE_PARAMTERS, false, false, bodyInfo.value.context)» : String.format(org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRuleProcessor.TYPE_ADAPTION_PARAMETER_TYPE_ERROR, "«bodyInfo.key.simpleName»", "«newMethodParameter.simpleName»", "«requiredParamterType.getTypeReferenceAsString(true, TypeErasureMethod.NONE, false, false, bodyInfo.value.context)»");
							'''
						typeAssertionBody += "\n";
					}

				bodyInfo.value.flushed = true
				val typeAssertionBodyFinal = typeAssertionBody
				bodyInfo.key.mutate [

					bodyInfo.key.body = '''«typeAssertionBodyFinal + bodyInfo.value.methodBody»'''

				]

				// fix type parameters of methods (can still be incorrectly connected after cloning methods)
				fixTypeParameters(bodyInfo.key, context)

			}

		}

	}

}
