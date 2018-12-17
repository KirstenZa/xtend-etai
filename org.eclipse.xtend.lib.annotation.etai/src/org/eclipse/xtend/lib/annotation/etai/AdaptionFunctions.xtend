package org.eclipse.xtend.lib.annotation.etai

import java.util.ArrayList
import java.util.List
import java.util.Map
import org.eclipse.xtend.lib.macro.declaration.Declaration

import static extension org.eclipse.xtend.lib.annotation.etai.utils.StringUtils.*

package class AdaptionFunctions {

	final static public String RULE_FUNC_APPLY = "apply"
	final static public String RULE_FUNC_APPEND = "append"
	final static public String RULE_FUNC_PREPEND = "prepend"
	final static public String RULE_FUNC_APPLY_VARIABLE = "applyVariable"
	final static public String RULE_FUNC_APPEND_VARIABLE = "appendVariable"
	final static public String RULE_FUNC_PREPEND_VARIABLE = "prependVariable"
	final static public String RULE_FUNC_REPLACE = "replace"
	final static public String RULE_FUNC_REPLACE_ALL = "replaceAll"
	final static public String RULE_FUNC_REPLACE_FIRST = "replaceFirst"
	final static public String RULE_FUNC_ADD_TYPE_PARAMS = "addTypeParam"
	final static public String RULE_FUNC_ADD_TYPE_PARAMS_EXTENDS = "addTypeParamWildcardExtends"
	final static public String RULE_FUNC_ADD_TYPE_PARAMS_SUPER = "addTypeParamWildcardSuper"
	final static public String RULE_FUNC_ALTERNATIVE = "alternative"

	/**
	 * Interface for classes which implement type adaption functions
	 */
	static protected interface IAdaptionFunction {

		/**
		 * This method is called in order to apply the type adaption function to the type in
		 * <code>baseString</code> (a string). The application can be supported by the application
		 * context and a variable mapping.
		 */
		def String apply(String baseString, Declaration typeContext, Map<String, String> variableMap)

		/**
		 * Prints the function as string (serialization).
		 * 
		 * If <code>onlyParameters</code> is set to <code>true</code>, only the parameters of the
		 * function are printed.
		 */
		def String print(boolean onlyParameters)

	}

	/**
	 * Class implementing type adaption function: apply
	 */
	static class Apply implements IAdaptionFunction {

		String parameter

		/**
		 * This is the constructor method for this type adaption function.
		 */
		static protected def Apply create(String parameter) {
			val newInstance = new Apply
			newInstance.parameter = parameter
			return newInstance
		}

		override String apply(String baseString, Declaration typeContext, Map<String, String> variableMap) {
			return parameter
		}

		override String print(boolean onlyParameters) {
			return '''«IF !onlyParameters»«RULE_FUNC_APPLY»(«ENDIF»«parameter»«IF !onlyParameters»)«ENDIF»'''
		}

	}

	/**
	 * Class implementing type adaption function: append
	 */
	static class Append implements IAdaptionFunction {

		String parameter

		/**
		 * This is the constructor method for this type adaption function.
		 */
		static protected def Append create(String parameter) {
			val newInstance = new Append
			newInstance.parameter = parameter
			return newInstance
		}

		override String apply(String baseString, Declaration typeContext, Map<String, String> variableMap) {
			return baseString + parameter
		}

		override String print(boolean onlyParameters) {
			return '''«IF !onlyParameters»«RULE_FUNC_APPEND»(«ENDIF»«parameter»«IF !onlyParameters»)«ENDIF»'''
		}

	}

	/**
	 * Class implementing type adaption function: prepend
	 */
	static class Prepend implements IAdaptionFunction {

		String parameter

		/**
		 * This is the constructor method for this type adaption function.
		 */
		static protected def Prepend create(String parameter) {
			val newInstance = new Prepend
			newInstance.parameter = parameter
			return newInstance
		}

		override String apply(String baseString, Declaration typeContext, Map<String, String> variableMap) {
			return parameter + baseString
		}

		override String print(boolean onlyParameters) {
			return '''«IF !onlyParameters»«RULE_FUNC_PREPEND»(«ENDIF»«parameter»«IF !onlyParameters»)«ENDIF»'''
		}

	}

	/**
	 * Class implementing type adaption function: applyVariable
	 */
	static class ApplyVariable implements IAdaptionFunction {

		String parameter

		/**
		 * This is the constructor method for this type adaption function.
		 */
		static protected def ApplyVariable create(String parameter) {
			val newInstance = new ApplyVariable
			newInstance.parameter = parameter
			return newInstance
		}

		override String apply(String baseString, Declaration typeContext, Map<String, String> variableMap) {
			return if (variableMap.get(parameter) === null)
				""
			else
				variableMap.get(parameter)
		}

		override String print(boolean onlyParameters) {
			return '''«IF !onlyParameters»«RULE_FUNC_APPLY_VARIABLE»(«ENDIF»«parameter»«IF !onlyParameters»)«ENDIF»'''
		}

	}

	/**
	 * Class implementing type adaption function: appendVariable
	 */
	static class AppendVariable implements IAdaptionFunction {

		String parameter

		/**
		 * This is the constructor method for this type adaption function.
		 */
		static protected def AppendVariable create(String parameter) {
			val newInstance = new AppendVariable
			newInstance.parameter = parameter
			return newInstance
		}

		override String apply(String baseString, Declaration typeContext, Map<String, String> variableMap) {
			return baseString + if (variableMap.get(parameter) === null)
				""
			else
				variableMap.get(parameter)
		}

		override String print(boolean onlyParameters) {
			return '''«IF !onlyParameters»«RULE_FUNC_APPEND_VARIABLE»(«ENDIF»«parameter»«IF !onlyParameters»)«ENDIF»'''
		}

	}

	/**
	 * Class implementing type adaption function: prependVariable
	 */
	static class PrependVariable implements IAdaptionFunction {

		String parameter

		/**
		 * This is the constructor method for this type adaption function.
		 */
		static protected def PrependVariable create(String parameter) {
			val newInstance = new PrependVariable
			newInstance.parameter = parameter
			return newInstance
		}

		override String apply(String baseString, Declaration typeContext, Map<String, String> variableMap) {
			return if (variableMap.get(parameter) === null)
				""
			else
				variableMap.get(parameter) + baseString
		}

		override String print(boolean onlyParameters) {
			return '''«IF !onlyParameters»«RULE_FUNC_PREPEND_VARIABLE»(«ENDIF»«parameter»«IF !onlyParameters»)«ENDIF»'''
		}

	}

	/**
	 * Class implementing type adaption function: addTypeParam
	 */
	static abstract protected class AdaptionFunctionWithNesting implements IAdaptionFunction {

		protected List<IAdaptionFunction> nestedAdaptionFunctions

		/**
		 * Apply the nested type adaption functions
		 */
		protected def String applyNestedAdaptionFunctions(String baseString, Declaration typeContext,
			Map<String, String> variableMap) {

			val appliedTypeAdaptionList = applyAdaptionFunctions(nestedAdaptionFunctions, baseString, typeContext,
				variableMap)
			if (appliedTypeAdaptionList.size != 1)
				throw new IllegalArgumentException('''Type adaption rules must not nest the function "alternative"''')

			return appliedTypeAdaptionList.get(0)

		}

		override String print(boolean onlyParameters) {
			return '''«IF !onlyParameters»«adaptionFunctionName»(«ENDIF»«AdaptionFunctions.printFunctions(nestedAdaptionFunctions)»«IF !onlyParameters»)«ENDIF»'''
		}

		/**
		 * Returns the name of the adaption function
		 */
		abstract def String getAdaptionFunctionName()

	}

	/**
	 * Class implementing type adaption function: addTypeParam
	 */
	static class AddTypeParam extends AdaptionFunctionWithNesting {

		/**
		 * This is the constructor method for this type adaption function.
		 */
		static protected def AddTypeParam create(List<IAdaptionFunction> nestedAdaptionFunctions) {
			val newInstance = new AddTypeParam
			newInstance.nestedAdaptionFunctions = nestedAdaptionFunctions
			return newInstance
		}

		/**
		 * This internal function returns the type calculated inside of the "addTypeParamX" rule.
		 */
		protected def String getTypeString(String baseString, Declaration typeContext,
			Map<String, String> variableMap) {

			return applyNestedAdaptionFunctions(baseString, typeContext, variableMap)

		}

		final override String apply(String baseString, Declaration typeContext, Map<String, String> variableMap) {

			var baseStringTrimmed = baseString.trim

			// ensure that brackets "<>" are inside type string
			if (!baseStringTrimmed.endsWith(">"))
				baseStringTrimmed += "<>"

			// retrieve type
			val newTypeParam = getTypeString(baseString, typeContext, variableMap)

			// continue, if type could be retrieved
			if (!newTypeParam.nullOrEmpty) {

				// ensure that comma is used to separate types
				var typeInsideBrackets = false
				var currentIndex = baseStringTrimmed.indexOf("<") + 1
				val char charEndBracket = '>'
				while (!typeInsideBrackets && baseStringTrimmed.charAt(currentIndex) != charEndBracket)
					if (!Character.isWhitespace(baseStringTrimmed.charAt(currentIndex++)))
						typeInsideBrackets = true
				if (typeInsideBrackets)
					baseStringTrimmed = baseStringTrimmed.substring(0, baseStringTrimmed.length - 1) + ", " +
						baseStringTrimmed.substring(baseStringTrimmed.length - 1, baseStringTrimmed.length);

				// insert type
				baseStringTrimmed = baseStringTrimmed.substring(0, baseStringTrimmed.length - 1) + newTypeParam +
					baseStringTrimmed.substring(baseStringTrimmed.length - 1, baseStringTrimmed.length);

			}

			return baseStringTrimmed

		}

		override String getAdaptionFunctionName() {
			return RULE_FUNC_ADD_TYPE_PARAMS
		}

	}

	/**
	 * Class implementing type adaption function: addTypeParamWildcardExtends
	 */
	static class AddTypeParamWildcardExtends extends AddTypeParam {

		/**
		 * This is the constructor method for this type adaption function.
		 */
		static protected def AddTypeParamWildcardExtends create(List<IAdaptionFunction> nestedAdaptionFunctions) {
			val newInstance = new AddTypeParamWildcardExtends
			newInstance.nestedAdaptionFunctions = nestedAdaptionFunctions
			return newInstance
		}

		override String getTypeString(String baseString, Declaration typeContext, Map<String, String> variableMap) {
			return "? extends " + super.getTypeString(baseString, typeContext, variableMap)
		}

		override String getAdaptionFunctionName() {
			return RULE_FUNC_ADD_TYPE_PARAMS_EXTENDS
		}

	}

	/**
	 * Class implementing type adaption function: addTypeParamWildcardSuper
	 */
	static class AddTypeParamWildcardSuper extends AddTypeParam {

		/**
		 * This is the constructor method for this type adaption function.
		 */
		static protected def AddTypeParamWildcardSuper create(List<IAdaptionFunction> nestedAdaptionFunctions) {
			val newInstance = new AddTypeParamWildcardSuper
			newInstance.nestedAdaptionFunctions = nestedAdaptionFunctions
			return newInstance
		}

		override String getTypeString(String baseString, Declaration typeContext, Map<String, String> variableMap) {
			return "? super " + super.getTypeString(baseString, typeContext, variableMap)
		}

		override String getAdaptionFunctionName() {
			return RULE_FUNC_ADD_TYPE_PARAMS_SUPER
		}

	}

	/**
	 * Class implementing type adaption function: replace
	 */
	static class Replace implements IAdaptionFunction {

		String target
		String replacement

		/**
		 * This is the constructor method for this type adaption function.
		 */
		static protected def Replace create(String target, String replacement) {
			val newInstance = new Replace
			newInstance.target = target
			newInstance.replacement = replacement
			return newInstance
		}

		override String apply(String baseString, Declaration typeContext, Map<String, String> variableMap) {
			return baseString.replace(target, replacement)
		}

		override String print(boolean onlyParameters) {
			return '''«IF !onlyParameters»«RULE_FUNC_REPLACE»(«ENDIF»«target»,«replacement»«IF !onlyParameters»)«ENDIF»'''
		}

	}

	/**
	 * Class implementing type adaption function: replaceAll
	 */
	static class ReplaceAll implements IAdaptionFunction {

		String target
		String replacement

		/**
		 * This is the constructor method for this type adaption function.
		 */
		static protected def ReplaceAll create(String target, String replacement) {
			val newInstance = new ReplaceAll
			newInstance.target = target
			newInstance.replacement = replacement
			return newInstance
		}

		override String apply(String baseString, Declaration typeContext, Map<String, String> variableMap) {
			return baseString.replaceAll(target, replacement)
		}

		override String print(boolean onlyParameters) {
			return '''«IF !onlyParameters»«RULE_FUNC_REPLACE_ALL»(«ENDIF»«target»,«replacement»«IF !onlyParameters»)«ENDIF»'''
		}

	}

	/**
	 * Class implementing type adaption function: replaceFirst
	 */
	static class ReplaceFirst implements IAdaptionFunction {

		String target
		String replacement

		/**
		 * This is the constructor method for this type adaption function.
		 */
		static protected def ReplaceFirst create(String target, String replacement) {
			val newInstance = new ReplaceFirst
			newInstance.target = target
			newInstance.replacement = replacement
			return newInstance
		}

		override String apply(String baseString, Declaration typeContext, Map<String, String> variableMap) {
			return baseString.replaceFirst(target, replacement)
		}

		override String print(boolean onlyParameters) {
			return '''«IF !onlyParameters»«RULE_FUNC_REPLACE_FIRST»(«ENDIF»«target»,«replacement»«IF !onlyParameters»)«ENDIF»'''
		}

	}

	/**
	 * Class implementing type adaption function: alternative
	 */
	static class Alternative extends AdaptionFunctionWithNesting {

		/**
		 * This is the constructor method for this type adaption function.
		 */
		static protected def Alternative create(List<IAdaptionFunction> nestedAdaptionFunctions) {
			val newInstance = new Alternative
			newInstance.nestedAdaptionFunctions = nestedAdaptionFunctions
			return newInstance
		}

		override String apply(String baseString, Declaration typeContext, Map<String, String> variableMap) {

			return this.applyNestedAdaptionFunctions(baseString, typeContext, variableMap)

		}

		override String getAdaptionFunctionName() {
			return RULE_FUNC_ALTERNATIVE
		}

	}

	/**
	 * Created the type adaption function with the given name and arguments. If there is an error,
	 * the (optionally) passed error list will be extended.
	 */
	static protected def IAdaptionFunction createFunction(String functionName, List<String> parameters,
		List<String> errors) {

		if (parameters.size == 1) {
			if (functionName == RULE_FUNC_APPLY) {
				return Apply.create(parameters.get(0))
			} else if (functionName == RULE_FUNC_APPEND) {
				return Append.create(parameters.get(0))
			} else if (functionName == RULE_FUNC_PREPEND) {
				return Prepend.create(parameters.get(0))
			} else if (functionName == RULE_FUNC_APPLY_VARIABLE) {
				return ApplyVariable.create(parameters.get(0))
			} else if (functionName == RULE_FUNC_APPEND_VARIABLE) {
				return AppendVariable.create(parameters.get(0))
			} else if (functionName == RULE_FUNC_PREPEND_VARIABLE) {
				return PrependVariable.create(parameters.get(0))
			} else if (functionName == RULE_FUNC_ADD_TYPE_PARAMS) {
				return AddTypeParam.create(createFunctionsInternal(parameters.get(0), errors, false))
			} else if (functionName == RULE_FUNC_ADD_TYPE_PARAMS_EXTENDS) {
				return AddTypeParamWildcardExtends.create(createFunctionsInternal(parameters.get(0), errors, false))
			} else if (functionName == RULE_FUNC_ADD_TYPE_PARAMS_SUPER) {
				return AddTypeParamWildcardSuper.create(createFunctionsInternal(parameters.get(0), errors, false))
			} else if (functionName == RULE_FUNC_ALTERNATIVE) {
				return Alternative.create(createFunctionsInternal(parameters.get(0), errors, false))
			}
		} else if (parameters.size == 2) {
			if (functionName == RULE_FUNC_REPLACE) {
				return Replace.create(parameters.get(0), parameters.get(1))
			} else if (functionName == RULE_FUNC_REPLACE_ALL) {
				return ReplaceAll.create(parameters.get(0), parameters.get(1))
			} else if (functionName == RULE_FUNC_REPLACE_FIRST) {
				return ReplaceFirst.create(parameters.get(0), parameters.get(1))
			}
		}

		errors?.add('''Function "«functionName»" with «parameters.size» parameters not found''')

		return null

	}

	/**
	 * This method can be used in order to apply multiple type adaption functions. It returns multiple (alternative)
	 * type strings, which can be checked one after another for an existing type.
	 * 
	 * @see IAdaptionFunction#apply
	 */
	static def List<String> applyAdaptionFunctions(List<IAdaptionFunction> AdaptionFunctions, String baseString,
		Declaration typeContext, Map<String, String> variableMap) {

		val result = new ArrayList<String>
		result.add(baseString)

		for (AdaptionFunction : AdaptionFunctions) {

			// create new result as alternative
			if (AdaptionFunction instanceof Alternative)
				result.add(result.get(result.size - 1))

			// apply current function and store as result
			result.set(result.size - 1, AdaptionFunction.apply(result.get(result.size - 1), typeContext, variableMap))

		}

		return result

	}

	/**
	 * The method takes a complete type adaption rule (as string) and returns a list of created
	 * type adaption functions (deserialization). If there is an error, the (optionally) passed error
	 * list will be extended .
	 */
	static def List<IAdaptionFunction> createFunctions(String completeRule, List<String> errors) {

		return createFunctionsInternal(completeRule, errors, true)

	}

	/**
	 * The method prints the given functions again in rule string format (serialization).
	 */
	static def String printFunctions(List<IAdaptionFunction> functions) {

		return functions.map[print(false)].join(";")

	}

	/**
	 * Internal method for creating adaption function.
	 */
	private static def List<IAdaptionFunction> createFunctionsInternal(String completeRule, List<String> errors,
		boolean isTopLevel) {

		val result = new ArrayList<IAdaptionFunction>

		var boolean alternativeSequenceOn = false

		if (completeRule !== null && !completeRule.trim.empty) {

			val rules = completeRule.splitConsideringParenthesis(";", "(", ")").map[trim]
			for (rule : rules) {

				// check if function call is syntactically correct
				val indexOfParameterStart = rule.indexOf('(')
				if (rule.endsWith(")") && indexOfParameterStart != -1) {

					val functionName = rule.substring(0, indexOfParameterStart)
					val functionParameterString = rule.substring(indexOfParameterStart + 1, rule.length - 1)
					val functionParameters = if (functionParameterString.isNullOrEmpty)
							new ArrayList<String>
						else
							functionParameterString.splitConsideringParenthesis(",", "(", ")")

					val AdaptionFunction = createFunction(functionName, functionParameters, errors)

					// function "alternative" must not be nested
					if (AdaptionFunction instanceof Alternative && isTopLevel == false)
						errors?.
							add('''Function "«RULE_FUNC_ALTERNATIVE»" inside type adaption rule must not be nested''')
					else if (AdaptionFunction !== null) {

						// ensure that "alternative" is at the end of the function call list
						if (AdaptionFunction instanceof Alternative)
							alternativeSequenceOn = true
						else if (alternativeSequenceOn == true)
							errors?.
								add('''Calls of "«RULE_FUNC_ALTERNATIVE»" functions must be at the end of the function call list''')

						result.add(AdaptionFunction)

					}

				} else {

					errors?.add('''Incorrect syntax of type adaption rule (parenthesis)''')

				}

			}

		}

		return result

	}

}
