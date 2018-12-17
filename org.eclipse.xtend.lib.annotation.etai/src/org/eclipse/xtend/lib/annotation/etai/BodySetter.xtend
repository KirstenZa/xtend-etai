package org.eclipse.xtend.lib.annotation.etai

import java.util.HashMap

import org.eclipse.xtend.lib.macro.declaration.ExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.expression.Expression

import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*
import org.eclipse.xtend.lib.annotation.etai.utils.ReflectUtils
import java.util.List
import org.eclipse.xtend.lib.macro.services.TypeReferenceProvider

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
	 * Returns the body of the given executable.
	 */
	def String getBody(ExecutableDeclaration executable) {
		if (cachedBodies.containsKey(executable))
			return cachedBodies.get(executable).methodBody
		return executable.body.toString
	}

	/**
	 * Returns if a body has been set for given executable .
	 */
	def boolean hasBody(MutableExecutableDeclaration executable) {

		if (cachedBodies.containsKey(executable))
			return cachedBodies.get(executable) !== null
		return executable.body !== null

	}

	/**
	 * Sets method body via string by using the internal cache. Also
	 * null as body string is allowed.
	 */
	def setBody(MutableExecutableDeclaration executable, String bodyString, TypeReferenceProvider context) {

		cachedBodies.put(executable, new BodyInfo(false, bodyString, context))
		executable.body = null as Expression

	}

	/**
	 * Move body of specified source method to given destination method considering
	 * the internal cache.
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
					ReflectUtils.callExtendedMethod(delegateSrc, "getLocalClasses", null, false, null, null)
					ReflectUtils.callExtendedMethod(delegateDest, "getLocalClasses", null, false, null, null)

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
	 * Write all cached method bodies to methods.
	 */
	def void flush() {

		for (bodyInfo : cachedBodies.entrySet) {

			if (bodyInfo.value.flushed == false) {

				var String typeAssertionBody = ""
				for (newMethodParameter : bodyInfo.key.parameters)
					if (newMethodParameter.hasAnnotation(AssertParameterType)) {
						val requiredParamterType = newMethodParameter.getAnnotation(AssertParameterType).
							getClassValue("value")
						typeAssertionBody +=
							'''assert «newMethodParameter.simpleName» == null || «newMethodParameter.simpleName» instanceof «requiredParamterType.getTypeReferenceAsString(true, true, false, false, bodyInfo.value.context)» : String.format(org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRuleProcessor.TYPE_ADAPTION_PARAMETER_TYPE_ERROR, "«bodyInfo.key.simpleName»", "«newMethodParameter.simpleName»", "«requiredParamterType.getTypeReferenceAsString(true, false, false, false, bodyInfo.value.context)»");
							'''
						typeAssertionBody += "\n";
					}

				bodyInfo.value.flushed = true
				val typeAssertionBodyFinal = typeAssertionBody
				bodyInfo.key.mutate [

					bodyInfo.key.body = '''«typeAssertionBodyFinal + bodyInfo.value.methodBody»'''

				]

			}

		}

	}

}
