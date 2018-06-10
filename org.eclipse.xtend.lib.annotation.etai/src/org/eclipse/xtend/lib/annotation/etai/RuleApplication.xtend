package org.eclipse.xtend.lib.annotation.etai

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target
import java.util.ArrayList
import java.util.HashMap
import java.util.HashSet
import java.util.LinkedHashMap
import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.IConstructorParamDummyCheckApplyRules
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.IConstructorParamDummyCheckInit
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.TypeMatchingStrategy
import org.eclipse.xtend.lib.annotation.etai.utils.TypeMap
import org.eclipse.xtend.lib.annotation.etai.utils.TypeUtils
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.ConstructorDeclaration
import org.eclipse.xtend.lib.macro.declaration.Declaration
import org.eclipse.xtend.lib.macro.declaration.ExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableAnnotationTarget
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableConstructorDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.ParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension org.eclipse.xtend.lib.annotation.etai.ConstructRuleDisableProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ConstructorMethodProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.FactoryMethodRuleProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.TraitClassProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.AbstractTraitMethodAnnotationProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ExtendedByProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.CollectionUtils.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.StringUtils.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.TypeMap.*
import org.eclipse.xtend.lib.macro.declaration.TypeParameterDeclarator

/**
 * <p>Classes can be annotated by this element in order to adapt them concerning
 * the settings in their class hierarchy. The hierarchy and included constructors, methods and
 * parameters will be scanned for the following annotations in order to finalize the
 * current class.</p>
 * 
 * <p>Further features:</p>
 * <ul>
 * <li>{@link TypeAdaptionRule}
 * <li>{@link CopyConstructorRule}
 * <li>{@link FactoryMethodRule}
 * <li>{@link ConstructRule}
 * <li>{@link ConstructRuleAuto}
 * <li>{@link ConstructRuleDisable}
 * <li>{@link ImplAdaptionRule}
 * </ul>
 * 
 * <p>If used once for a class, all derived classes must also use this annotations.</p>
 * 
 * @see TypeAdaptionRule
 * @see CopyConstructorRule
 * @see FactoryMethodRule
 * @see ConstructRule
 * @see ConstructRuleAuto
 * @see ConstructRuleDisable
 * @see ImplAdaptionRule
 */
@Target(ElementType.TYPE)
@Active(ApplyRulesProcessor)
@Retention(RetentionPolicy.RUNTIME)
annotation ApplyRules {
}

/**
 * <p>Annotation for an adapted method, i.e., a method which has been included because of
 * auto adaption of types ({@link TypeAdaptionRule}) or implementation ({@link ImplAdaptionRule}).</p>
 * 
 * <p>This annotation can also be used explicitly, if overriding a method that shall not
 * deactivate the adaption rule of a superclass.</p>
 * 
 * @see ApplyRules
 * @see TypeAdaptionRule
 * @see ImplAdaptionRule
 */
@Target(ElementType.METHOD)
annotation AdaptedMethod {
}

/**
 * Annotation for an adapted constructor, i.e., a constructor which has been included because of
 * type auto adaption ({@link TypeAdaptionRule}) or the explicit request for copying the
 * constructor ({@link CopyConstructorRule}).
 * 
 * @see ApplyRules
 * @see TypeAdaptionRule
 * @see CopyConstructorRule
 */
@Target(ElementType.CONSTRUCTOR)
annotation AdaptedConstructor {
}

/**
 * Annotation for an adapted constructor, which has been hidden because of the automatic
 * implementation of a factory method.
 * 
 * @see ApplyRules
 * @see FactoryMethodRule
 */
@Target(ElementType.CONSTRUCTOR)
annotation ConstructorHiddenForFactoryMethod {
}

/**
 * Annotation for a factory method, which has been generated to create an adapted class.
 * 
 * @see ApplyRules
 * @see FactoryMethodRule#factoryMethod
 */
@Target(ElementType.METHOD)
annotation GeneratedFactoryMethod {
}

/**
 * Annotation for the factory class, which has been generated to hold a factory method.
 * 
 * @see ApplyRules
 * @see GeneratedFactoryInstance
 * @see FactoryMethodRule#factoryInstance
 */
@Target(ElementType.TYPE)
annotation GeneratedFactoryClass {
}

/**
 * Annotation for the instance of the generated factory class.
 * 
 * @see ApplyRules
 * @see GeneratedFactoryClass
 * @see FactoryMethodRule#factoryInstance
 */
@Target(ElementType.FIELD)
annotation GeneratedFactoryInstance {
}

/**
 * This annotation is attached to classes, which do have a (xtend) source class with at
 * least one explicit constructor.
 */
@Target(ElementType.TYPE)
annotation HasExplicitConstructors {
}

/**
 * This annotation is put onto constructors within adapted classes,
 * which have been generated for delegation purpose. Thereby, the main purpose
 * of delegation is to include a check procedure.
 * 
 * @see ApplyRules
 */
@Target(ElementType.CONSTRUCTOR)
annotation ApplyRulesCheckerDelegationConstructor {
}

/**
 * Active Annotation Processor for {@link ApplyRules}
 * 
 * @see ApplyRules
 */
class ApplyRulesProcessor extends AbstractClassProcessor implements QueuedTransformationParticipant<MutableClassDeclaration> {

	final static public String AUTO_RULE_ADAPTION_MISSING_ERROR = "Class \"%s\" must be annotated by @ApplyRules, because a base class is marked for automatic adaption"

	final static public String INJECTED_PARAMETER_NAME_SEPARATOR = "______$injectedParam$"
	final static public String FACTORY_CLASS_NAME = "Factory"

	final static public String CLASS_PARAM_NAME_PREFIX = "$_type_"

	protected override Class<?> getProcessedAnnotationType() {
		ApplyRules
	}

	/**
	 * Retrieves all constructors in hierarchy, which declared type adaption rules (in parameters) or
	 * the copy constructor rule for constructor itself.
	 */
	static protected def getConstructorsToAdapt(ClassDeclaration classDeclaration, Class<?> annotationType,
		extension TransformationContext context) {

		for (superType : classDeclaration.getSuperClasses(false)) {

			val constructorsToAdapt = superType.declaredConstructors.filter [
				it.visibility != Visibility.PRIVATE && (
				it.getAnnotation(annotationType) !== null || it.parameters.exists [
					it.getAnnotation(annotationType) !== null
				])
			]

			// do not continue with parent's constructors, if already found adaption rules
			if (constructorsToAdapt.size > 0) {

				return constructorsToAdapt

			} else {

				// no adaption, if there is a explicitly declared constructor
				if (superType.hasAnnotation(HasExplicitConstructors))
					return new ArrayList<ConstructorDeclaration>

			}

		}

		return new ArrayList<ConstructorDeclaration>

	}

	/**
	 * <p>Retrieves all methods in the type hierarchy, which have an adaption rule declared
	 * (in parameters or return type).</p>
	 * 
	 * <p>The result is a map of methods, together with the first superclass
	 * of the given class or the trait class in whose type hierarchy the adaption rule
	 * has been found.</p>
	 * 
	 * <p>A (manually declared) method in the type hierarchy without adaption rule will stop adaption,
	 * even if a method in a super type has type adaption rules declared. In order to avoid this,
	 * a (manually declared) method can be annotated by {@link AdaptedMethod}. Then it will be ignored
	 * and the search type adaption rules continues.</p>
	 */
	static protected def Map<MethodDeclaration, ClassDeclaration> getMethodsToAdapt(
		ClassDeclaration annotatedClass,
		TypeMap typeMap,
		Class<?> annotationType,
		(MethodDeclaration)=>Boolean annotationCheckExistenceOnMethod,
		extension TransformationContext context
	) {

		val methodsToAdapt = new LinkedHashMap<MethodDeclaration, ClassDeclaration>
		val methodsNotToAdapt = new HashSet<String>

		// all methods in current class shall not be adapted (based on the method name) 
		methodsNotToAdapt.addAll(annotatedClass.getDeclaredMethodsResolved(context).map[simpleName])

		// start recursion with current class
		getMethodsToAdaptInternal(annotatedClass, annotatedClass, true, null, methodsToAdapt, methodsNotToAdapt,
			!annotatedClass.getDeclaredMethodsResolved(context).exists [
				it.isConstructorMethod
			], typeMap, annotationType, annotationCheckExistenceOnMethod, context)

		return methodsToAdapt

	}

	/**
	 * Internal method for searching adaption methods.
	 */
	static private def void getMethodsToAdaptInternal(
		ClassDeclaration original,
		ClassDeclaration currentClass,
		boolean isRoot,
		ClassDeclaration superClass,
		Map<MethodDeclaration, ClassDeclaration> methodsToAdapt,
		Set<String> methodsNotToAdapt,
		boolean addConstructorMethods,
		TypeMap typeMap,
		Class<?> annotationType,
		(MethodDeclaration)=>Boolean annotationCheckExistenceOnMethod,
		extension TransformationContext context
	) {

		var continueAddConstructorMethods = addConstructorMethods

		// process current class
		if (!isRoot) {

			// ignore adapted methods
			var relevantMethods = currentClass.getDeclaredMethodsResolved(context).filter [
				!it.hasAnnotation(AdaptedMethod)
			]

			// check for constructor methods, if not processed yet
			if (continueAddConstructorMethods) {

				val relevantConstructorMethods = relevantMethods.filter[it.isConstructorMethod]
				if (relevantConstructorMethods.size > 0) {

					continueAddConstructorMethods = false
					val constructorMethodsWithAdaptionRule = relevantConstructorMethods.filter [
						it.visibility != Visibility.PRIVATE && it.hasAnnotation(annotationType) || it.parameters.exists [
							it.hasAnnotation(annotationType)
						]
					]

					// add found constructor methods
					for (method : constructorMethodsWithAdaptionRule)
						methodsToAdapt.put(method, superClass)

				}

			}

			// do not consider constructor methods any more (they will also not be blacklisted)
			relevantMethods = relevantMethods.filter [
				!it.isConstructorMethod
			]

			// do not consider methods in blacklist (based on method name)
			relevantMethods = relevantMethods.filter [
				!methodsNotToAdapt.contains(it.simpleName)
			]

			// search for methods with adaption rules and add
			val methodsWithAdaptionRule = relevantMethods.filter [
				it.visibility != Visibility.PRIVATE && annotationCheckExistenceOnMethod.apply(it)
			]

			// add found methods
			for (method : methodsWithAdaptionRule)
				methodsToAdapt.put(method, superClass)

			// all found (relevant) methods shall not be considered in further processing of current hierarchy any more
			methodsNotToAdapt.addAll(relevantMethods.map[simpleName])

		}

		// recurse into super type
		if (currentClass.extendedClass?.type instanceof ClassDeclaration) {

			getMethodsToAdaptInternal(original, currentClass.extendedClass.type as ClassDeclaration, false, if (isRoot)
				currentClass.extendedClass.type as ClassDeclaration
			else
				superClass, methodsToAdapt, new HashSet<String>(methodsNotToAdapt), continueAddConstructorMethods,
				typeMap, annotationType, annotationCheckExistenceOnMethod, context)

		}

		// track methods to adapt based on trait classes separately
		val methodsToAdaptTemp = if (isRoot)
				new LinkedHashMap<MethodDeclaration, ClassDeclaration>
			else
				methodsToAdapt

		// recurse into trait classes
		val traitClassRefs = currentClass.getTraitClassesAppliedToExtended(null, context)

		for (traitClassRef : traitClassRefs) {

			// iterate over trait class hierarchy
			if (traitClassRef?.type instanceof ClassDeclaration) {

				getMethodsToAdaptInternal(original, traitClassRef.type as ClassDeclaration, false, if (isRoot)
					traitClassRef.type as ClassDeclaration
				else
					superClass, methodsToAdaptTemp, new HashSet<String>(methodsNotToAdapt), false, typeMap,
					annotationType, annotationCheckExistenceOnMethod, context)

				if (isRoot) {

					val methodsNamesAdapted = methodsToAdapt.keySet.map[simpleName]

					// check for ambiguous type adaption rules
					for (methodToAdaptTemp : methodsToAdaptTemp.keySet)
						if (methodsNamesAdapted.findFirst[it == methodToAdaptTemp.simpleName] !== null)
							currentClass.
								addError('''Trait class "«traitClassRef?.type.simpleName»" contains method "«methodToAdaptTemp.simpleName»", which specifies another type adaption rule''')

					// copy entries of temporary structures to main structures
					methodsToAdapt.putAll(methodsToAdaptTemp)
					methodsToAdaptTemp.clear

				}

			}

		}

	}

	/**
	 * Retrieves the type for a specific parameter (or return type, if "paramPos" is -1) from the method of 
	 * the given class. It will search through superclasses until method is found.
	 */
	static protected def getSuperClassesMethodParamType(ClassDeclaration classDeclaration,
		MethodDeclaration methodDeclaration, TypeMap typeMap, int paramPos, extension TransformationContext context) {

		for (currentClass : classDeclaration.getSuperClasses(true)) {

			val methodsFound = currentClass.getDeclaredMethodsResolved(context).filter [
				it.simpleName == methodDeclaration.simpleName &&
					it.parameters.parameterListsSimilar(methodDeclaration.parameters)
			]

			if (methodsFound.size > 0) {
				if (paramPos == -1)
					return copyTypeReference(methodsFound.get(0).returnType, typeMap, context)
				return copyTypeReference(methodsFound.get(0).parameters.get(paramPos).type, typeMap, context)
			}

		}

		return null

	}

	/**
	 * Retrieves the type for a specific parameter from the constructor of 
	 * the given class. It will search through superclasses until constructor is found.
	 */
	static protected def getSuperClassesConstructorParamType(
		ClassDeclaration classDeclaration,
		ConstructorDeclaration constructorDeclaration,
		TypeMap typeMap,
		int paramPos,
		extension TransformationContext context
	) {

		for (currentClass : classDeclaration.getSuperClasses(true)) {

			val constructorsFound = currentClass.declaredConstructors.filter [
				it.parameters.parameterListsSimilar(constructorDeclaration.parameters)
			]

			if (constructorsFound.size > 0)
				return copyTypeReference(constructorsFound.get(0).parameters.get(paramPos).type, typeMap, context)

		}

	}

	/** 
	 * <p>Returns true, if two parameter lists shall be considered as "similar".</p>
	 * 
	 * <p>They are considered as equal, if they have the same size and primitive types
	 * match.</p>
	 */
	static def boolean parameterListsSimilar(Iterable<? extends ParameterDeclaration> parameterList1,
		Iterable<? extends ParameterDeclaration> parameterList2) {

		if (parameterList1.size != parameterList2.size)
			return false

		val iteratorParam1 = parameterList1.iterator
		val iteratorParam2 = parameterList2.iterator

		while (iteratorParam1.hasNext) {

			val param1 = iteratorParam1.next
			val param2 = iteratorParam2.next

			if (param1.type.isPrimitive != param2.type.isPrimitive)
				return false
			if (param1.type.isPrimitive == true) {
				if (param1.type != param2.type)
					return false
			}
		}

		return true

	}

	/**
	 * Returns the position of the parameter in its executable
	 */
	static protected def int getParameterPosition(ParameterDeclaration parameter) {

		var int number = 0
		for (currentParameter : parameter.declaringExecutable.parameters) {
			if (currentParameter === parameter)
				return number
			number++
		}
		return -1

	}

	/**
	 * <p>Returns the adaption rule (string) for the specified parameter.</p>
	 * 
	 * <p>If the method of the source parameter has been adapted, the method will search for adaption
	 * rules in superclasses. However, this method does not search for type adaptions coming from trait
	 * classes, which extend the current type hierarchy.</p>
	 */
	static protected def String getTypeAdaptionRuleWithinTypeHierarchy(ParameterDeclaration parameterDeclaration,
		TypeMap typeMap, extension TransformationContext context) {

		// stop if element is null
		if (parameterDeclaration === null)
			return null

		// search for annotation reference
		if (parameterDeclaration.hasAnnotation(TypeAdaptionRule)) {

			val annotationTypeAdaptionRule = parameterDeclaration.getAnnotation(TypeAdaptionRule)
			return annotationTypeAdaptionRule.getStringValue("value")

		} else if (parameterDeclaration instanceof ParameterDeclaration) {

			val executable = parameterDeclaration.declaringExecutable

			if (executable.hasAnnotation(AdaptedMethod) || executable.hasAnnotation(AdaptedConstructor)) {

				val superMethod = getMatchingExecutableInSuperClass(executable as ExecutableDeclaration,
					TypeMatchingStrategy.MATCH_COVARIANT, false, typeMap, context)
				if (superMethod !== null)
					return getTypeAdaptionRuleWithinTypeHierarchy(
						superMethod.parameters.get(parameterDeclaration.parameterPosition), typeMap, context)

			}

		}

		return null

	}

	/**
	 * Apply type adaption rule (given by string) to a declared element (can be method or parameter), 
	 * i.e. the type of the according element is changed by applying the rule.
	 */
	static protected def TypeReference applyTypeAdaptionRule(
		Declaration element,
		List<TypeParameterDeclarator> typeParameterDeclarators,
		ClassDeclaration relevantSuperClass,
		String completeRule,
		ExecutableDeclaration source,
		Map<String, String> variableMap,
		TypeMap typeMap,
		boolean useSuperType,
		extension TransformationContext context
	) {

		// return with same type, if no rule is defined
		if (completeRule === null || completeRule.trim().empty) {

			if (element instanceof MethodDeclaration)
				return copyTypeReference((element as MethodDeclaration).returnType, typeMap, context)
			else if (element instanceof ParameterDeclaration)
				return copyTypeReference((element as ParameterDeclaration).type, typeMap, context)
			else
				throw new IllegalArgumentException('''Cannot apply empty adaption rule to given element: «element.toString»''')

		}

		// parse rule and apply
		val typeAdaptionFunctions = AdaptionFunctions.createFunctions(completeRule, null)
		val alternativeTypeStrings = AdaptionFunctions.applyAdaptionFunctions(typeAdaptionFunctions, "", element,
			variableMap)

		// search for a valid type string
		for (typeString : alternativeTypeStrings) {

			// create new type reference
			var TypeReference newType = typeString.createTypeReference(typeParameterDeclarators, null, context)

			if (newType !== null)
				return newType;

		}

		// return null, if type within supertype's element shall not be searched
		if (!useSuperType)
			return null;

		// use type within supertype's element, if new type not found
		val paramPos = if (element instanceof ParameterDeclaration)
				(element as ParameterDeclaration).parameterPosition
			else
				-1

		if (source instanceof MethodDeclaration)
			return getSuperClassesMethodParamType(relevantSuperClass, source as MethodDeclaration, typeMap, paramPos,
				context)
		else if (element instanceof ParameterDeclaration)
			return getSuperClassesConstructorParamType(relevantSuperClass, source as ConstructorDeclaration, typeMap,
				paramPos, context)
		else
			throw new IllegalArgumentException("Cannot apply adaption rule to given element: " + element.toString)

	}

	/**
	 * Apply implementation adaption rule (given by string) to a declared method and
	 * return resulting implementation (as string).
	 */
	static protected def String applyImplAdaptionRule(ExecutableDeclaration annotatedExecutable, String completeRule,
		Map<String, String> variableMap, extension TransformationContext context) {

		// parse rule and apply (start with empty string as context)
		val implAdaptionFunctions = AdaptionFunctions.createFunctions(completeRule, null)
		val implString = AdaptionFunctions.applyAdaptionFunctions(implAdaptionFunctions, "", annotatedExecutable,
			variableMap).get(0)

		return implString

	}

	/**
	 * <p>The method returns, if there is any change for the given executable declaration.</p>
	 */
	static protected def boolean checkAdaptionChange(MutableClassDeclaration annotatedClass,
		ClassDeclaration relevantSuperClass, ExecutableDeclaration ruleSource,
		ExecutableDeclaration executableToCompare, Map<String, String> variableMap, TypeMap typeMap,
		List<String> errors, extension TransformationContext context) {

		// check each parameter for type change
		val parameterIteratorRuleSource = ruleSource.parameters.iterator
		val parameterIteratorExecutableToCompare = executableToCompare.parameters.iterator

		while (parameterIteratorRuleSource.hasNext) {

			val parameterRuleSource = parameterIteratorRuleSource.next
			val parameterMethodToCompare = parameterIteratorExecutableToCompare.next

			val ruleParam = parameterRuleSource.getAnnotation(TypeAdaptionRule)?.getStringValue("value")
			val adaptedType = parameterMethodToCompare.applyTypeAdaptionRule(#[annotatedClass], relevantSuperClass,
				ruleParam, ruleSource, variableMap, typeMap, true, context)

			if (!adaptedType.typeReferenceEquals(parameterMethodToCompare.type, null, true, typeMap, null))
				return true

		}

		// check return type for change
		if (executableToCompare instanceof MethodDeclaration) {

			val ruleMethod = ruleSource.getAnnotation(TypeAdaptionRule)?.getStringValue("value")
			val adaptedReturnType = executableToCompare.applyTypeAdaptionRule(#[annotatedClass], relevantSuperClass,
				ruleMethod, ruleSource, variableMap, typeMap, true, context)

			if (!adaptedReturnType.typeReferenceEquals(executableToCompare.returnType, null, true, typeMap, null))
				return true

		}

		return false

	}

	/**
	 * <p>Copy parameters and apply adaption rules.</p>
	 * 
	 * <p>The method supports copying parameters from multiple sources.</p>
	 */
	static protected def void copyParametersAndAdapt(MutableClassDeclaration annotatedClass,
		ClassDeclaration relevantSuperClass, ExecutableDeclaration source, MutableExecutableDeclaration target,
		Map<String, String> variableMap, TypeMap typeMap, extension TransformationContext context) {

		// copy parameters and create name list
		for (parameter : source.parameters) {

			// apply adaption rule (for parameter type)
			val ruleParam = parameter.getAnnotation(TypeAdaptionRule)?.getStringValue("value")
			val adaptedType = parameter.applyTypeAdaptionRule(#[annotatedClass], relevantSuperClass, ruleParam, source,
				variableMap, typeMap, true, context)

			// construct new parameter name and check
			val newParameterName = parameter.simpleName

			// create new parameter (with adapting type)
			target.addParameter(newParameterName, adaptedType)

		}

		// also set variable argument option correctly
		target.varArgs = source.isVarArgsFixed

	}

	/**
	 * <p>Returns true if given class is root class for auto adaption, i.e. a class which does not have
	 * any other classes with according annotation as superclass.</p>
	 * 
	 * <p>Thereby, it is an important assumption that there are no gaps for using the annotation within the
	 * type hierarchy. This is also checked during validation.</p>
	 */
	static protected def boolean isApplyRulesRoot(ClassDeclaration annotatedClass) {

		return (annotatedClass.extendedClass === null || annotatedClass.extendedClass.type === null ||
			!(annotatedClass.extendedClass.type as ClassDeclaration).hasAnnotation(ApplyRules)
		)

	}

	/**
	 * Returns the (qualified) factory class name for the annotated class
	 */
	static def String getFactoryClassName(ClassDeclaration annotatedClass) {

		return annotatedClass.qualifiedName + "." + FACTORY_CLASS_NAME

	}

	/**
	 * Returns all adaption variables in the context of the given class
	 * 
	 * @see SetAdaptionVariable
	 */
	static def Map<String, String> getAdaptionVariables(ClassDeclaration annotatedClass, List<String> errors,
		extension TransformationContext context) {

		val result = new HashMap<String, String>

		// retrieve manually set variables from classes
		annotatedClass.getAdaptionVariablesInternal(result, errors, new ArrayList<TypeDeclaration>, context)

		// calculate package name
		var packageName = TypeUtils.removeSimpleNameFromQualifiedName(annotatedClass.qualifiedName)
		if (packageName.endsWith("."))
			packageName = packageName.substring(0, packageName.length - 1)

		// set predefined variables
		result.put("const.bracket.round.open", "(")
		result.put("const.bracket.round.close", ")")

		result.put("var.package", packageName)
		result.put("var.class.simple", annotatedClass.simpleName)
		result.put("var.class.qualified", annotatedClass.qualifiedName)
		result.put("var.class.abstract", if(annotatedClass.abstract) "true" else "false")

		result.put("var.class.typeparameters", annotatedClass.typeParameters.map[simpleName].join(","))
		result.put("var.class.typeparameters.count", String::valueOf(annotatedClass.typeParameters.length))

		var typeParameterDeclarationCount = 1
		for (typeParameterDeclaration : annotatedClass.typeParameters)
			result.put("var.class.typeparameter." + typeParameterDeclarationCount++,
				typeParameterDeclaration.simpleName)

		return result

	}

	/**
	 * Internal method for retrieving adaption variables.
	 */
	static private def void getAdaptionVariablesInternal(
		TypeDeclaration typeDeclaration,
		Map<String, String> result,
		List<String> errors,
		List<? super TypeDeclaration> recursionProtectionList,
		extension TransformationContext context
	) {

		// recursion protection
		if (typeDeclaration === null || recursionProtectionList.contains(typeDeclaration))
			return;

		recursionProtectionList.add(typeDeclaration)

		// recursion: superclasses and (first) superinterface
		if (typeDeclaration instanceof ClassDeclaration) {

			// recursion: all super interfaces
			for (implementedInterface : typeDeclaration.implementedInterfaces)
				getAdaptionVariablesInternal(implementedInterface.type as TypeDeclaration, result, errors,
					recursionProtectionList, context)

			// recursion: all super class
			if (typeDeclaration.extendedClass !== null)
				getAdaptionVariablesInternal(typeDeclaration.extendedClass?.type as TypeDeclaration, result, errors,
					recursionProtectionList, context)

			// recursion: all trait classes
			val traitClassRefs = typeDeclaration.getTraitClassesAppliedToExtended(null, context)
			for (traitClassRef : traitClassRefs)
				getAdaptionVariablesInternal(traitClassRef.type as TypeDeclaration, result, errors,
					recursionProtectionList, context)

		} else if (typeDeclaration instanceof InterfaceDeclaration) {

			// recursion: all super interfaces			
			for (superInterface : typeDeclaration.extendedInterfaces.drop(1))
				getAdaptionVariablesInternal(superInterface.type as TypeDeclaration, result, errors,
					recursionProtectionList, context)

		}

		// add variables of current type
		if (typeDeclaration.hasAnnotation(SetAdaptionVariable)) {

			val variableString = typeDeclaration.getAnnotation(SetAdaptionVariable).getStringValue("value")
			if (variableString !== null) {
				val variableSettings = variableString.splitConsideringParenthesis(',', '(', ')')
				for (variableSetting : variableSettings) {
					val variableSettingSplit = variableSetting.split("=")
					if (variableSettingSplit.size == 2) {

						val variableName = variableSettingSplit.get(0).trim
						val variableValue = variableSettingSplit.get(1)
						result.put(variableName, variableValue)

					} else {

						errors?.add('''Error parsing adaption variable specification: "«variableSetting»"''')

					}
				}
			}

		}

	}

	/**
	 * <p>Removes all adaption rules and copy constructor rules from an element.</p>
	 */
	static def void removeTypeAdaptionAndCopyConstructorRules(MutableExecutableDeclaration executable) {

		if (executable === null)
			return;

		executable.removeAnnotation(CopyConstructorRule)
		executable.removeAnnotation(TypeAdaptionRule)

		for (parameter : executable.parameters)
			parameter.removeAnnotation(TypeAdaptionRule)

	}

	/**
	 * <p>Copies adaption rules from one element to another.</p>
	 * 
	 * <p>If the <code>skip</code> counter is set, the first number of parameters of the source will
	 * not be considered.</p>
	 */
	static def void copyTypeAdaptionAndCopyConstructorRules(
		ExecutableDeclaration src,
		MutableExecutableDeclaration trg,
		int skip,
		TypeMap typeMap,
		extension TransformationContext context
	) {

		if (src === null)
			return;

		// go through parameters and skip specified amount from source
		val srcParameterIterator = src.parameters.iterator
		val trgParameterIterator = trg.parameters.iterator

		var int counter = 0
		while (srcParameterIterator.hasNext) {

			val srcParameter = srcParameterIterator.next
			if (counter++ >= skip) {

				val trgParameter = trgParameterIterator.next

				// retrieve and set type adaption rule for parameter
				val annotationTypeAdaptionRule = srcParameter.getAnnotation(TypeAdaptionRule)
				val rule = annotationTypeAdaptionRule?.getStringValue("value")
				if (rule !== null) {

					trgParameter.addAnnotation(TypeAdaptionRule.newAnnotationReference [
						setStringValue("value", rule)
					])

				}

			}

		}

		// retrieve and set type adaption / copy constructor rule for executable
		val annotationTypeAdaptionRule = src.getAnnotation(TypeAdaptionRule)
		val ruleTypeAdaption = annotationTypeAdaptionRule?.getStringValue("value")
		if (ruleTypeAdaption !== null) {

			trg.addAnnotation(TypeAdaptionRule.newAnnotationReference [
				setStringValue("value", ruleTypeAdaption)
			])

		}

		val annotationCopyConstructorRule = src.getAnnotation(CopyConstructorRule)
		if (annotationCopyConstructorRule !== null)
			trg.addAnnotation(CopyConstructorRule.newAnnotationReference)

	}

	/**
	 * Moves the {@link GeneratedFactoryMethod} annotation from one element to another.
	 */
	static def void moveAnnotationConstructorHiddenForFactoryMethod(MutableAnnotationTarget trg,
		MutableAnnotationTarget src, extension TransformationContext context) {

		val adaptionConstructorHiddenForFactoryMethod = src.getAnnotation(ConstructorHiddenForFactoryMethod)
		if (adaptionConstructorHiddenForFactoryMethod !== null) {
			trg.addAnnotation(ConstructorHiddenForFactoryMethod.newAnnotationReference)
			src.removeAnnotation(adaptionConstructorHiddenForFactoryMethod)
		}

	}

	/**
	 * <p>This method will add instructions to the body of the given constructor.</p>
	 * 
	 * <p>Internally, this is achieved by moving the old body to a dummy constructor (with a dummy variable name)
	 * and delegating to it. The delegating constructor will also get an annotation,
	 * if a annotation class is given.</p>
	 */
	static def addAdditionalBodyToConstructor(MutableConstructorDeclaration originalConstructor, String additionalBody,
		Class<?> delegationAnnotation, Class<?> dummyVariableType, String dummyVariableName, BodySetter bodySetter,
		TypeMap typeMap, extension TransformationContext context) {

		val constructorClass = originalConstructor.declaringType as MutableClassDeclaration

		// check if constructor is not synthetic
		val isDefaultConstructor = originalConstructor.isDefaultConstructor(context)

		// add additional parameter to original constructor (at first position)
		if (!isDefaultConstructor) {
			val newDummyParameter = originalConstructor.addParameter(dummyVariableName,
				dummyVariableType.newTypeReference())
			newDummyParameter.addSuppressWarningUnused(context)
			moveParameter(originalConstructor, 0, originalConstructor.parameters.size - 1)
		}

		// create new constructor
		val newConstructor = constructorClass.addConstructor [
			it.visibility = originalConstructor.visibility
			it.deprecated = originalConstructor.deprecated
			it.exceptions = originalConstructor.exceptions
		]

		// specific annotation for new constructor
		if (delegationAnnotation !== null)
			newConstructor.addAnnotation(delegationAnnotation.newAnnotationReference)

		// copy parameters, create name and type list
		var paramNameList = originalConstructor.parametersNames
		if (!isDefaultConstructor)
			paramNameList = paramNameList.subList(1, paramNameList.size)
		originalConstructor.copyParameters(newConstructor, if(!isDefaultConstructor) 1 else 0, typeMap, context)

		// hide original constructor
		originalConstructor.visibility = Visibility.PRIVATE

		// move documentation
		if (!isDefaultConstructor) {

			newConstructor.docComment = originalConstructor.docComment
			originalConstructor.docComment = '''This is the implementation of constructor «newConstructor.getJavaDocLinkTo(context)».'''

		} else {

			originalConstructor.docComment = '''This is the implementation of the default constructor.'''

		}

		// add body to new constructor
		bodySetter.setBody(
			newConstructor, '''«IF !isDefaultConstructor»this((«dummyVariableType.canonicalName») null«IF (paramNameList.size > 0)», «ENDIF»«paramNameList.join(", ")»);«ENDIF»
						«additionalBody»''')

		// move annotations from original constructor to new constructor
		if (!isDefaultConstructor) {

			// copy adaption rules
			originalConstructor.copyTypeAdaptionAndCopyConstructorRules(newConstructor, 1, typeMap, context)

			// remove adaption rules from original constructor
			originalConstructor.removeTypeAdaptionAndCopyConstructorRules

			// move hidden constructor annotation
			moveAnnotationConstructorHiddenForFactoryMethod(newConstructor, originalConstructor, context)

		}

	}

	override doRegisterGlobals(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {

		super.doRegisterGlobals(annotatedClass, context)

		// generate factory (inner class)
		//
		// currently, with xtend it is not possible to generate the factory class based
		// on the annotation specifications of a parent class because those are not
		// accessible in the current context.
		context.registerClass(annotatedClass.getFactoryClassName())

		// start processing of this element
		ProcessQueue.startTrack(ProcessQueue.PHASE_AUTO_ADAPT, annotatedClass, annotatedClass.qualifiedName)
		ProcessQueue.startTrack(ProcessQueue.PHASE_AUTO_ADAPT_CHECK, annotatedClass, annotatedClass.qualifiedName)

	}

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {

		super.doTransform(annotatedClass, context)

		// queue processing
		ProcessQueue.processTransformation(ProcessQueue.PHASE_AUTO_ADAPT, this, annotatedClass,
			annotatedClass.qualifiedName, context)
		ProcessQueue.processTransformation(ProcessQueue.PHASE_AUTO_ADAPT_CHECK, this, annotatedClass,
			annotatedClass.qualifiedName, context)

	}

	override boolean doTransformQueued(int phase, MutableClassDeclaration annotatedClass, BodySetter bodySetter,
		extension TransformationContext context) {

		// postpone transformation, if supertype must still be processed
		if (phase === ProcessQueue.PHASE_AUTO_ADAPT)
			for (superType : annotatedClass.getSuperClasses(false)) {

				if (superType.hasAnnotation(ApplyRules) &&
					ProcessQueue.isTrackedTransformation(ProcessQueue.PHASE_AUTO_ADAPT, annotatedClass.compilationUnit,
						superType.qualifiedName))
					return false

			}

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// create type map from type hierarchy
		val typeMap = new TypeMap()
		fillTypeMapFromTypeHierarchy(annotatedClass, typeMap, context)

		if (phase === ProcessQueue.PHASE_AUTO_ADAPT) {

			// create variable map
			val errors = new ArrayList<String>
			val variableMap = getAdaptionVariables(annotatedClass, errors, context)
			xtendClass.reportErrors(errors, context)

			doTransformMethodsAdaptions(annotatedClass, variableMap, typeMap, bodySetter, context)
			doTransformConstructorsAdaptions(annotatedClass, variableMap, typeMap, bodySetter, context)
			doTransformConstructorsFactoryMethods(annotatedClass, variableMap, typeMap, bodySetter, context)

		} else {

			doTransformConstructorsConsistencyChecks(annotatedClass, typeMap, bodySetter, context)

		}

		return true

	}

	private def void doTransformMethodsAdaptions(
		MutableClassDeclaration annotatedClass,
		Map<String, String> variableMap,
		TypeMap typeMap,
		BodySetter bodySetter,
		extension TransformationContext context
	) {

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// retrieve methods, which must be type/implementation adapted
		val methodsTypeAdaption = getMethodsToAdapt(annotatedClass, typeMap, TypeAdaptionRule, [
			TypeAdaptionRuleProcessor.hasTypeAdaptionRule(it)
		], context)
		val methodsImplAdaption = getMethodsToAdapt(annotatedClass, typeMap, ImplAdaptionRule, [
			ImplAdaptionRuleProcessor.hasImplAdaptionRule(it)
		], context)
		val methodsAdaption = new HashSet<MethodDeclaration>
		methodsAdaption.addAll(methodsTypeAdaption.keySet)
		methodsAdaption.addAll(methodsImplAdaption.keySet)

		// adapt methods
		for (method : methodsAdaption) {

			val errors = new ArrayList<String>
			val extendedClass = annotatedClass.extendedClass.type as ClassDeclaration

			// retrieve and calculate data
			var isTypeAdaption = methodsTypeAdaption.containsKey(method)
			var isImplAdaption = methodsImplAdaption.containsKey(method)

			var relevantSuperClass = methodsTypeAdaption.get(method)

			// check if type adaption is needed due to type change
			val executableInSuperClass = extendedClass.getMatchingExecutableInClass(method,
				TypeMatchingStrategy.MATCH_COVARIANT, true, typeMap, context) as MethodDeclaration
			if (isTypeAdaption) {
				isTypeAdaption = method.isConstructorMethod || if (executableInSuperClass !== null)
					checkAdaptionChange(annotatedClass, relevantSuperClass, method, executableInSuperClass, variableMap,
						typeMap, errors, context)
				else
					true
			}

			// check if implementation adaption is needed due to type check
			if (isImplAdaption) {

				val ruleImplTypeExistenceCheck = method.getAnnotation(ImplAdaptionRule)?.getStringValue(
					"typeExistenceCheck")
				if (!ruleImplTypeExistenceCheck.isNullOrEmpty) {
					val existingType = method.applyTypeAdaptionRule(#[annotatedClass], null,
						ruleImplTypeExistenceCheck, null, variableMap, typeMap, false, context)
					if (existingType === null)
						isImplAdaption = false
				}

			}

			// report errors
			xtendClass.reportErrors(errors, context)

			if ((isTypeAdaption || isImplAdaption) && errors.size == 0) {

				// method must not exist yet in current class
				if (annotatedClass.getDeclaredMethodsResolved(context).exists [
					it.simpleName == method.simpleName &&
						it.methodEquals(method, TypeMatchingStrategy.MATCH_COVARIANT, typeMap, context)
				]) {
					xtendClass.
						addError('''Adaption of method "«method.simpleName»(«method.getParametersTypeNames(true, false, context).join(", ")»)" cannot be applied to current class, because the method has already been declared.''')
					return
				}

				// clone type map as it becomes modified locally
				val typeMapLocal = typeMap.clone

				// create new method, if not declared
				val newMethod = annotatedClass.copyMethod(method, false, true, false, typeMapLocal, context)

				// do NOT add override annotation in order to prevent covariance errors
				// (especially in case of class constructors)
				//
				// mark as "adapted method"
				newMethod.addAnnotation(AdaptedMethod.newAnnotationReference)

				// deal with trait class constructors, i.e. copy annotation
				if (method.isConstructorMethod)
					newMethod.addAnnotation(ConstructorMethodProcessor.copyAnnotation(method, context))

				// deal with trait methods, i.e. copy annotation
				if (method.isTraitMethod && annotatedClass.isTraitClass)
					newMethod.addAnnotation(AbstractTraitMethodAnnotationProcessor.copyAnnotation(method, context))

				// deal with "no interface" extract annotation
				if (method.hasAnnotation(NoInterfaceExtract) && annotatedClass.isTraitClass)
					newMethod.addAnnotation(NoInterfaceExtract.newAnnotationReference)

				if (isTypeAdaption) {

					// copy parameters and apply type adaption rules
					copyParametersAndAdapt(annotatedClass, relevantSuperClass, method, newMethod, variableMap,
						typeMapLocal, context)

					// apply adaption rule (for method return type)
					val ruleMethod = method.getAnnotation(TypeAdaptionRule)?.getStringValue("value")
					newMethod.returnType = method.applyTypeAdaptionRule(#[annotatedClass], relevantSuperClass,
						ruleMethod, method, variableMap, typeMapLocal, true, context)

				} else {

					// copy parameters and return type
					method.copyParameters(newMethod, 0, typeMapLocal, context)
					newMethod.returnType = copyTypeReference(method.returnType, typeMap, context)

				}

				// create name list of parameters
				val paramNameList = newMethod.parametersNames

				// set new method to abstract, if the implementation will not be adapted,
				// but also search for a reason to implement, which means calling the method of the superclass
				newMethod.abstract = !(isImplAdaption ||
					(executableInSuperClass !== null && !executableInSuperClass.abstract))

				if (newMethod.abstract == true && executableInSuperClass !== null) {

					// if method in superclass is abstract, it could be that it is an adapted method,
					// which has not been processed by the traits mechanism, yet.
					// the following algorithm checks, if the abstract method will get implemented
					// by the traits mechanism, i.e. there is a trait class extending the method
					val superClassWithExecutable = executableInSuperClass.declaringType as ClassDeclaration

					if (!superClassWithExecutable.isTraitClass && method.isTraitMethod) {

						val traitClasses = superClassWithExecutable.getTraitClassesAppliedToExtended(null, context)
						for (traitClassRef : traitClasses) {

							// iterate over trait class hierarchy
							if (traitClassRef?.type instanceof ClassDeclaration) {

								val traitClass = traitClassRef.type as ClassDeclaration

								val executableInTraitClass = traitClass.getMatchingExecutableInClass(
									newMethod,
									TypeMatchingStrategy.MATCH_COVARIANT,
									true,
									typeMapLocal,
									context
								) as MethodDeclaration

								if (executableInTraitClass !== null && !executableInTraitClass.abstract)
									newMethod.abstract = false

							}

						}

					}

				}

				// no need for setting body if abstract
				if (!newMethod.abstract) {

					if (isImplAdaption) {

						// apply implementation adaption
						val ruleImpl = method.getAnnotation(ImplAdaptionRule)?.getStringValue("value")
						bodySetter.setBody(newMethod, method.applyImplAdaptionRule(ruleImpl, variableMap, context))

					} else {

						// generate method body, which is a super call
						val isVoid = newMethod.returnType === null || newMethod.returnType.isVoid()
						val returnTypeReferenceString = newMethod.returnType.
							getTypeReferenceAsString(true, false, false, context)
						bodySetter.setBody(newMethod, '''«IF !isVoid»return («returnTypeReferenceString») «ENDIF»
			 			super.«if (newMethod.isTraitMethod) newMethod.getTraitMethodImplName else newMethod.simpleName»(«paramNameList.join(", ")»);''')

					}

				}

			}

		}

	}

	private def void doTransformConstructorsAdaptions(
		MutableClassDeclaration annotatedClass,
		Map<String, String> variableMap,
		TypeMap typeMap,
		BodySetter bodySetter,
		extension TransformationContext context
	) {

		// adapt constructors, if there is no declared constructor
		if ((annotatedClass.primarySourceElement as ClassDeclaration).declaredConstructors.size == 0) {

			// retrieve methods, which must be copied or type/implementation adapted
			val constructorsCopyRule = getConstructorsToAdapt(annotatedClass, CopyConstructorRule, context)
			val constructorsTypeAdaption = getConstructorsToAdapt(annotatedClass, TypeAdaptionRule, context)
			val constructorsImplAdaption = getConstructorsToAdapt(annotatedClass, ImplAdaptionRule, context)
			val constructorsAdaption = new HashSet<ConstructorDeclaration>

			constructorsAdaption.addAll(constructorsCopyRule)
			constructorsAdaption.addAll(constructorsTypeAdaption)
			constructorsAdaption.addAll(constructorsImplAdaption)

			// search for constructors to adapt
			for (constructor : constructorsAdaption) {

				// check type of adaption
				var isTypeAdaption = constructorsTypeAdaption.filter[it === constructor].size > 0
				var isImplAdaption = constructorsImplAdaption.filter[it === constructor].size > 0

				// check if implementation adaption is needed due to type check
				if (isImplAdaption) {

					val ruleImplTypeExistenceCheck = constructor.getAnnotation(ImplAdaptionRule)?.getStringValue(
						"typeExistenceCheck")
					if (!ruleImplTypeExistenceCheck.isNullOrEmpty) {
						val existingType = constructor.applyTypeAdaptionRule(#[annotatedClass], null,
							ruleImplTypeExistenceCheck, null, variableMap, typeMap, false, context)
						if (existingType === null)
							isImplAdaption = false
					}

				}

				// create new constructor, if no other constructor with same amount of parameters
				val newConstructor = annotatedClass.addConstructor() [

					it.docComment = constructor.docComment
					it.deprecated = constructor.deprecated
					it.exceptions = constructor.exceptions

					// use originally used visibility
					if (constructor.hasAnnotation(ConstructorHiddenForFactoryMethod)) {

						it.visibility = Visibility.PUBLIC

					} else {

						it.visibility = constructor.visibility

					}

				]

				if (isTypeAdaption) {

					// copy parameters and apply type adaption rules
					copyParametersAndAdapt(annotatedClass, annotatedClass.extendedClass?.type as ClassDeclaration,
						constructor, newConstructor, variableMap, typeMap, context)

				} else {

					// copy parameters
					constructor.copyParameters(newConstructor, 0, typeMap, context)

				}

				// create name list of parameters
				val paramNameList = newConstructor.parametersNames

				// mark as "adapted constructor"
				newConstructor.addAnnotation(AdaptedConstructor.newAnnotationReference)

				if (isImplAdaption) {

					// apply implementation adaption
					val ruleImpl = constructor.getAnnotation(ImplAdaptionRule)?.getStringValue("value")
					bodySetter.setBody(newConstructor,
						constructor.applyImplAdaptionRule(ruleImpl, variableMap, context))

				} else {

					// generate constructor body, which is a super call
					bodySetter.setBody(newConstructor, '''super(«paramNameList.join(", ")»);''')

				}

			}

		} else {

			// add information to class that there is an explicit constructor
			// (this is necessary, because it is not possible to access primarySourceElement when processing
			// another activate annotation from another file in order to determine explicit constructors)
			if ((annotatedClass.primarySourceElement as ClassDeclaration).declaredConstructors.size > 0)
				annotatedClass.addAnnotation(HasExplicitConstructors.newAnnotationReference)

		}

	}

	private def void doTransformConstructorsFactoryMethods(
		MutableClassDeclaration annotatedClass,
		Map<String, String> variableMap,
		TypeMap typeMap,
		BodySetter bodySetter,
		extension TransformationContext context
	) {

		// access factory class (inner class)
		val factoryClass = context.findClass(annotatedClass.getFactoryClassName()) as MutableClassDeclaration
		factoryClass.addAnnotation(GeneratedFactoryClass.newAnnotationReference)

		// hide factory class by default
		factoryClass.visibility = Visibility.PRIVATE

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// retrieve factory rules
		val errors = new ArrayList<String>
		val factoryMethodRuleInfo = annotatedClass.getFactoryMethodRuleInfo(errors, context)
		if (xtendClass.reportErrors(errors, context))
			return;

		// check if factory class shall be generated (including content) 
		val useFactoryClass = factoryMethodRuleInfo !== null && !factoryMethodRuleInfo.factoryInstance.nullOrEmpty
		val useFactoryClassInheritance = useFactoryClass && factoryMethodRuleInfo.factoryClassDerived

		// do not generate factory methods, if class is abstract
		if (annotatedClass.abstract && !useFactoryClassInheritance)
			return;

		// construct factory method, if method name has been set
		if (factoryMethodRuleInfo !== null && !factoryMethodRuleInfo.factoryMethod.nullOrEmpty) {

			// prepare factory class (inner class)
			var MutableClassDeclaration classToAddFactoryMethods
			if (useFactoryClass) {

				// factory class is used
				factoryClass.visibility = Visibility.PUBLIC
				factoryClass.static = true
				factoryClass.abstract = annotatedClass.abstract

				// extend factory from first parent class, which has a factory (if applicable)
				var ClassDeclaration factoryClassParent = null
				if (useFactoryClassInheritance) {

					val parentClassDeclarationWithFactoryRule = if ((annotatedClass.extendedClass.
							type as ClassDeclaration)?.getFactoryMethodRuleInfo(errors, context) !== null)
							annotatedClass.extendedClass.type as ClassDeclaration
					if (parentClassDeclarationWithFactoryRule !== null) {

						factoryClassParent = context.findClass(
							parentClassDeclarationWithFactoryRule.getFactoryClassName()) as ClassDeclaration
						factoryClass.extendedClass = factoryClassParent.newTypeReference
					}

				}

				// use interface for factory, if specified
				if (factoryMethodRuleInfo.factoryInterface !== null &&
					factoryMethodRuleInfo.factoryInterface.qualifiedName != Object.canonicalName) {

					// only add interface, if there is no parent (factory) class
					if (factoryClassParent === null)
						factoryClass.implementedInterfaces = factoryClass.implementedInterfaces +
							#[factoryMethodRuleInfo.factoryInterface.newTypeReference]

				}

				// use interface for factory (set via variable), if specified
				if (!factoryMethodRuleInfo.factoryInterfaceVariable.nullOrEmpty) {

					// resolve variable and create type reference
					val factoryInterfaceName = variableMap.get(factoryMethodRuleInfo.factoryInterfaceVariable)
					if (factoryInterfaceName !== null) {

						var TypeReference factoryInterfaceReference = factoryInterfaceName.
							createTypeReference(#[annotatedClass], null, context)

						// set factory interface if the type exists			
						if (factoryInterfaceReference !== null) {

							// check for already implemented interface
							var TypeReference firstImplementedInterfaceParent = null
							var ClassDeclaration currentParentFactoryClass = factoryClassParent
							while (currentParentFactoryClass !== null && firstImplementedInterfaceParent === null) {
								if (currentParentFactoryClass.implementedInterfaces.size != 0)
									firstImplementedInterfaceParent = currentParentFactoryClass.implementedInterfaces.
										get(0)
								currentParentFactoryClass = currentParentFactoryClass.extendedClass?.
									type as ClassDeclaration
							}

							// only add interface, if there is a change
							if (firstImplementedInterfaceParent === null ||
								firstImplementedInterfaceParent.type != factoryInterfaceReference.type)
								factoryClass.implementedInterfaces = factoryClass.implementedInterfaces +
									#[factoryInterfaceReference]

						}

					}

				}

				// add instance (if not abstract)
				if (!factoryClass.abstract) {

					val instanceField = annotatedClass.addField(factoryMethodRuleInfo.factoryInstance) [
						it.static = true
						it.final = factoryMethodRuleInfo.factoryInstanceFinal
						it.visibility = Visibility.PUBLIC
						it.type = factoryClass.newTypeReference
						it.initializer = '''new «factoryClass.qualifiedName»()'''
					]

					// specify annotation
					instanceField.addAnnotation(GeneratedFactoryInstance.newAnnotationReference)

				}

				// add factory method to factory class
				classToAddFactoryMethods = factoryClass

			} else {

				// add factory method to annotated class
				classToAddFactoryMethods = annotatedClass

			}

			// retrieve trait classes which shall be constructed automatically
			val traitClassesToConstructEnabled = annotatedClass.getTraitClassesAutoConstructEnabled(context)

			// retrieve trait classes for which automatic construction has been deactivated
			val traitClassesToConstructDisabled = annotatedClass.getTraitClassesAutoConstructDisabled(true, context)

			// track all factory methods
			val newFactoryMethodList = new ArrayList<MutableMethodDeclaration>

			// track all constructor parameters for each trait class, which shall be constructed automatically
			val constructorParamsPerTraitClass = new ArrayList<List<List<ParameterDeclaration>>>
			for (traitClassToConstruct : traitClassesToConstructEnabled) {

				// track all constructor parameters of current trait class
				val constructorsAndParams = new ArrayList<List<ParameterDeclaration>>

				// go through all constructor methods of trait class
				for (constructorMethod : traitClassToConstruct.getConstructorMethods(context)) {

					// create list of parameters for this constructor
					val currentParameters = new ArrayList<ParameterDeclaration>
					currentParameters.addAll(constructorMethod.parameters)
					constructorsAndParams.add(currentParameters)

				}

				// only add constructor parameters, if any have been found
				if (!constructorsAndParams.isEmpty)
					constructorParamsPerTraitClass.add(constructorsAndParams)

			}

			// create injection combinations (add empty list, if no combination)
			val injectConstructorParameters = constructorParamsPerTraitClass.cartesianProduct
			if (injectConstructorParameters.size == 0)
				injectConstructorParameters.add(new ArrayList<ParameterDeclaration>)

			// create factory method for each public constructor and ...
			for (constructor : annotatedClass.declaredConstructors.filter [
				it.visibility == Visibility.PUBLIC
			]) {

				// ... injected constructor parameter list 
				for (additionalContructorParameters : injectConstructorParameters) {

					// ensure that only processed once per disabled auto construct
					// create documentation
					var String calledConstructorsDocumentation = ""

					val newFactoryMethod = classToAddFactoryMethods.addMethod(
						factoryMethodRuleInfo.factoryMethod.replaceAll("\\%", annotatedClass.simpleName)) [

						it.static = !useFactoryClass
						it.deprecated = constructor.deprecated
						it.exceptions = constructor.exceptions
						it.abstract = annotatedClass.abstract

					]

					// additional refactoring of factory method, if class provides type parameters
					var TypeMap usedTypeMap

					val newMethodTypeArguments = new ArrayList<TypeReference>

					// consider used type map
					if (annotatedClass.typeParameters.size > 0) {

						// clone type map and adjust for type parameters of static method
						usedTypeMap = typeMap.clone

						for (typeParameter : annotatedClass.typeParameters) {

							val newTypeParamDeclaration = newFactoryMethod.addTypeParameter(typeParameter.simpleName,
								typeParameter.upperBounds)
							val newTypeArgument = newTypeParamDeclaration.newSelfTypeReference
							newMethodTypeArguments.add(newTypeArgument)
							usedTypeMap.putClone(typeParameter, newTypeArgument, context)

						}

					} else {

						usedTypeMap = typeMap

					}

					// set return type (consider type arguments)
					newFactoryMethod.returnType = annotatedClass.newTypeReference(newMethodTypeArguments)

					// apply return type adaption rule, if available
					if (!factoryMethodRuleInfo.returnTypeAdaptionRule.nullOrEmpty) {

						val adaptedTypeReference = newFactoryMethod.applyTypeAdaptionRule(#[newFactoryMethod], null,
							factoryMethodRuleInfo.returnTypeAdaptionRule, null, variableMap, typeMap, false, context)

						if (adaptedTypeReference !== null)
							newFactoryMethod.returnType = adaptedTypeReference

					}

					// track parameters to add
					var HashMap<String, TypeReference> newParameterList = null

					// copy parameters
					if (constructor !== null) {

						newParameterList = new LinkedHashMap<String, TypeReference>

						val regularParamTypeNameList = new ArrayList<String>
						for (parameter : constructor.parameters) {

							newParameterList.put(parameter.simpleName,
								parameter.type.copyTypeReference(usedTypeMap, context))
							regularParamTypeNameList.add(
								parameter.type.getTypeReferenceAsString(true, true, true, context))

						}

						calledConstructorsDocumentation +=
							'''<li>{@link «annotatedClass.qualifiedName»#«annotatedClass.simpleName»(«regularParamTypeNameList.join(", ")»)}<br>
							'''

					}

					// also set variable argument option correctly
					newFactoryMethod.varArgs = constructor.isVarArgsFixed

					// create and add new parameter declarations
					for (parameter : additionalContructorParameters) {

						// also adapt injected parameters
						val declaringExecutable = parameter.declaringExecutable
						val traitClass = declaringExecutable.declaringType as ClassDeclaration
						val adaptionRule = parameter.getTypeAdaptionRuleWithinTypeHierarchy(typeMap, context)

						// search for adapted parameter type (do consider supertype adaption even if no method is implemented)
						var TypeReference adaptedParameterType = null
						if (adaptionRule !== null && !adaptionRule.trim().empty) {

							var ClassDeclaration currectClass = annotatedClass
							var currentVariableMap = variableMap

							// search through superclasses as long as the same trait class is applied
							while (adaptedParameterType === null && currectClass !== null &&
								currectClass.getTraitClassesSpecifiedForExtendedClosure(null, context).map [
									type
								].contains(traitClass)) {

								// try to apply adaption rule
								adaptedParameterType = parameter.applyTypeAdaptionRule(#[annotatedClass], null,
									adaptionRule, declaringExecutable, currentVariableMap, usedTypeMap, false, context)

								// use variable map of parent, which maybe leads to an available type
								currectClass = currectClass.extendedClass.type as ClassDeclaration
								currentVariableMap = getAdaptionVariables(currectClass, null, context)
							}

						}

						// determine new type
						val newType = if (adaptedParameterType !== null) {
								adaptedParameterType
							} else {
								parameter.type.copyTypeReference(typeMap, context)
							}

						// add parameter (only if not already available)
						if (!newParameterList.containsKey(parameter.simpleName)) {

							newParameterList.put(parameter.simpleName, newType)

						} else {

							val originalType = newParameterList.get(parameter.simpleName)

							// ensure that parameter types match (in xtend type parameters for constructors are not allowed)
							if (!originalType.typeReferenceEquals(newType, null, true, usedTypeMap, null)) {
								xtendClass.
									addError('''Injection of constructor parameters from trait class «traitClass.simpleName» cannot be performed because of a type mismatch of parameter "«parameter.simpleName»" («newType» != «originalType»)''')
								return
							}

						}

					}

					// add parameters, which have been processed so far
					for (parameterEntry : newParameterList.entrySet)
						newFactoryMethod.addParameter(parameterEntry.key, parameterEntry.value)

					// edit body code for creating delegation objects (and continue documentation)
					var bodyDelegationObjectCreation = ""
					if (!newFactoryMethod.abstract) {

						for (traitClassToConstruct : traitClassesToConstructEnabled) {

							val parameterNames = new ArrayList<String>
							val parameterTypeNames = new ArrayList<String>
							for (parameter : additionalContructorParameters) {

								if (traitClassToConstruct == parameter.declaringExecutable.declaringType) {
									parameterNames.add(parameter.simpleName)
									parameterTypeNames.add(
										parameter.type.getTypeReferenceAsString(true, true, true, context))
								}

							}

							bodyDelegationObjectCreation +=
								'''newObject.«traitClassToConstruct.getConstructorMethodCallName(true)»(«parameterNames.join(", ")»);
								'''
							calledConstructorsDocumentation +=
								'''<li>{@link «traitClassToConstruct.qualifiedName»#«traitClassToConstruct.simpleName»(java.lang.Object«IF !parameterTypeNames.empty», «parameterTypeNames.join(", ")»«ENDIF»)}
								'''

						}

					}

					// edit body code for checking delegation objects (if not abstract)
					var bodyCheckObjectCreation = ""
					if (!newFactoryMethod.abstract) {

						for (traitClassToCheck : traitClassesToConstructDisabled) {

							bodyCheckObjectCreation +=
								'''assert org.eclipse.xtend.lib.annotation.etai.utils.ReflectUtils.getPrivateFieldValue(newObject, "«traitClassToCheck.delegateObjectName»") != null : String.format(org.eclipse.xtend.lib.annotation.etai.ExtendedByProcessor.TRAIT_OBJECT_NOT_CONSTRUCTED_ERROR, "«traitClassToCheck.qualifiedName»");
								'''

						}

					}

					// check if there is an ambiguous combination
					if (newFactoryMethodList.methodListContains(newFactoryMethod, TypeMatchingStrategy.MATCH_INVARIANT,
						typeMap, context)) {
						xtendClass.
							addError('''The generation of factory methods cannot be finished because the following type combination is ambiguous: «newFactoryMethod.parameters.map[it.type.toString].join(", ")» ''')
						return
					}
					newFactoryMethodList.add(newFactoryMethod)

					// documentation
					newFactoryMethod.docComment = '''<p>This is the factory method for creating «annotatedClass.getJavaDocLinkTo(context)» objects. It will call:</p>
						<ul>
							«calledConstructorsDocumentation»
							«IF !factoryMethodRuleInfo.initMethod.nullOrEmpty»{@link «annotatedClass.qualifiedName»#«factoryMethodRuleInfo.initMethod»()}«ENDIF»
						</ul>'''

					// specify annotation
					newFactoryMethod.addAnnotation(GeneratedFactoryMethod.newAnnotationReference)

					// retrieve parameter names
					val paramNameList = constructor.parametersNames

					// store type argument string
					val typeArgumentString = '''«IF (annotatedClass.typeParameters.size > 0)»<«newFactoryMethod.typeParameters.map[it.simpleName].join(", ")»>«ENDIF»'''

					// add body to factory method (if not abstract)
					if (!newFactoryMethod.abstract) {

						bodySetter.setBody(
							newFactoryMethod, '''«annotatedClass.qualifiedName»«typeArgumentString» newObject = new «annotatedClass.qualifiedName»«typeArgumentString»(«paramNameList.join(", ")»);
							«bodyDelegationObjectCreation»
							«bodyCheckObjectCreation»
							«IF !factoryMethodRuleInfo.initMethod.nullOrEmpty»newObject.«factoryMethodRuleInfo.initMethod»();«ENDIF»
							return newObject;''')

					}

				}

				// ensure that constructor is not synthetic
				if (!bodySetter.hasBody(constructor))
					bodySetter.setBody(constructor, "")

				// hide constructor
				constructor.addAnnotation(ConstructorHiddenForFactoryMethod.newAnnotationReference)
				constructor.visibility = Visibility.PROTECTED

			}

		}

	}

	private def void doTransformConstructorsConsistencyChecks(MutableClassDeclaration annotatedClass, TypeMap typeMap,
		BodySetter bodySetter, extension TransformationContext context) {

		// nothing to do, if class is not the root within the auto adaption type hierarchy
		if (!annotatedClass.isApplyRulesRoot)
			return;

		// process existing constructors (do not extend constructors, which already start with a dummy parameter)
		for (constructor : annotatedClass.declaredConstructors.filter [
			it.parameters.size() == 0 || it.parameters.get(0).simpleName !=
				IConstructorParamDummyCheckInit.DUMMY_VARIABLE_NAME
		])
			constructor.addAdditionalBodyToConstructor(
				'''assert this.getClass().getAnnotation(org.eclipse.xtend.lib.annotation.etai.ApplyRules.class) != null : String.format(org.eclipse.xtend.lib.annotation.etai.ApplyRulesProcessor.AUTO_RULE_ADAPTION_MISSING_ERROR, this.getClass().getCanonicalName());
			''', ApplyRulesCheckerDelegationConstructor, IConstructorParamDummyCheckApplyRules,
				IConstructorParamDummyCheckApplyRules.DUMMY_VARIABLE_NAME, bodySetter, typeMap, context)

	}

	override doValidate(ClassDeclaration annotatedClass, extension ValidationContext context) {

		super.doValidate(annotatedClass, context)

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// auto adaption must be used consistently for supertypes
		val notAutoAdaptedClassFound = new ArrayList<ClassDeclaration>
		notAutoAdaptedClassFound.add(null)
		annotatedClass.getSuperClasses(false).forEach [

			if (!it.hasAnnotation(ApplyRules))
				notAutoAdaptedClassFound.set(0, it)
			else if (notAutoAdaptedClassFound.get(0) !== null)
				xtendClass.
					addError('''Supertype "«annotatedClass.qualifiedName»" does specify @ApplyRules, but the closer supertype "«notAutoAdaptedClassFound.get(0).qualifiedName»" does not''')

		]

	}

}
