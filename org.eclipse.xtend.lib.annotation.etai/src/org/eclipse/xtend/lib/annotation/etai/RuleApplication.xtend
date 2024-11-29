package org.eclipse.xtend.lib.annotation.etai

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target
import java.util.ArrayList
import java.util.Collection
import java.util.HashMap
import java.util.HashSet
import java.util.LinkedHashMap
import java.util.List
import java.util.Map
import java.util.Set
import java.util.SortedMap
import java.util.SortedSet
import java.util.TreeMap
import org.eclipse.xtend.lib.annotation.etai.AdderRuleProcessor.MethodDeclarationFromAdder_AddAllTo
import org.eclipse.xtend.lib.annotation.etai.AdderRuleProcessor.MethodDeclarationFromAdder_AddAllToIndexed
import org.eclipse.xtend.lib.annotation.etai.AdderRuleProcessor.MethodDeclarationFromAdder_AddTo
import org.eclipse.xtend.lib.annotation.etai.AdderRuleProcessor.MethodDeclarationFromAdder_AddToIndexed
import org.eclipse.xtend.lib.annotation.etai.AdderRuleProcessor.MethodDeclarationFromAdder_PutAllTo
import org.eclipse.xtend.lib.annotation.etai.AdderRuleProcessor.MethodDeclarationFromAdder_PutTo
import org.eclipse.xtend.lib.annotation.etai.GetterRuleProcessor.MethodDeclarationFromGetter
import org.eclipse.xtend.lib.annotation.etai.RemoverRuleProcessor.MethodDeclarationFromRemover_Clear
import org.eclipse.xtend.lib.annotation.etai.RemoverRuleProcessor.MethodDeclarationFromRemover_RemoveAllFrom
import org.eclipse.xtend.lib.annotation.etai.RemoverRuleProcessor.MethodDeclarationFromRemover_RemoveFrom
import org.eclipse.xtend.lib.annotation.etai.RemoverRuleProcessor.MethodDeclarationFromRemover_RemoveFromIndexed
import org.eclipse.xtend.lib.annotation.etai.SetterRuleProcessor.MethodDeclarationFromSetter
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.IConstructorParamDummy
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.IConstructorParamDummyCheckApplyRules
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.IConstructorParamDummyCheckFactoryCall
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.TypeErasureMethod
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.TypeMatchingStrategy
import org.eclipse.xtend.lib.annotation.etai.utils.TypeMap
import org.eclipse.xtend.lib.annotation.etai.utils.TypeUtils
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationTarget
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
import org.eclipse.xtend.lib.macro.declaration.MutableParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.ParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeParameterDeclarator
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension org.eclipse.xtend.lib.annotation.etai.AbstractTraitMethodAnnotationProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ConstructRuleDisableProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ConstructorMethodProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ExtendedByProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.FactoryMethodRuleProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.PriorityEnvelopeMethodProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.TraitClassProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.TraitMethodRedirectionProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.CollectionUtils.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.StringUtils.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.TypeMap.*

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
 * <p>Annotation for an adapted method, i.e. a method which has been included because of
 * auto adaption of types ({@link TypeAdaptionRule}) or implementation ({@link ImplAdaptionRule}).</p>
 * 
 * <p>This annotation can also be used explicitly if overriding a method that shall not
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
 * <p>This annotation marks a parameter and gives information about the expected type. Thereby, the expected type
 * does not match the declared paramter type. However, the declared type cannot be changed due to language
 * restrictions (e.g. no covariance for method parameter types allowed).</p>
 * 
 * <p>During runtime the type of the passed argument will be checked for the expected type via assertion.</p>
 */
@Target(ElementType.PARAMETER)
annotation AssertParameterType {
	Class<?> value
}

/**
 * <p>Annotation for an adapted constructor, i.e., a constructor that has been included because of
 * type auto adaption ({@link TypeAdaptionRule}) or the explicit request for copying the
 * constructor ({@link CopyConstructorRule}).</p>
 * 
 * @see ApplyRules
 * @see TypeAdaptionRule
 * @see CopyConstructorRule
 */
@Target(ElementType.CONSTRUCTOR)
annotation AdaptedConstructor {
}

/**
 * <p>Annotation for an adapted constructor that has been hidden because of the automatic
 * implementation of a factory method.</p>
 * 
 * @see ApplyRules
 * @see FactoryMethodRule
 */
@Target(ElementType.CONSTRUCTOR)
annotation ConstructorHiddenForFactoryMethod {
}

/**
 * <p>Annotation for a factory method that has been generated to create an adapted class.</p>
 * 
 * @see ApplyRules
 * @see FactoryMethodRule#factoryMethod
 */
@Target(ElementType.METHOD)
annotation GeneratedFactoryMethod {
}

/**
 * <p>Annotation for the factory class that has been generated to hold a factory method.</p>
 * 
 * @see ApplyRules
 * @see GeneratedFactoryInstance
 * @see FactoryMethodRule#factoryInstance
 */
@Target(ElementType.TYPE)
annotation GeneratedFactoryClass {
}

/**
 * <p>Annotation for a getter method that has been generated retrieving a field's value.</p>
 * 
 * @see GetterRule
 */
@Target(ElementType.METHOD)
annotation GeneratedGetterMethod {
}

/**
 * <p>Annotation for a setter method that has been generated setting a field's value.</p>
 * 
 * @see SetterRule
 */
@Target(ElementType.METHOD)
annotation GeneratedSetterMethod {
}

/**
 * <p>Annotation for a method that has been generated for adding a elements to a collection/map.</p>
 * 
 * @see AdderRule
 */
@Target(ElementType.METHOD)
annotation GeneratedAdderMethod {
}

/**
 * <p>Annotation for a method that has been generated for removing a elements from a collection/map.</p>
 * 
 * @see RemoverRule
 */
@Target(ElementType.METHOD)
annotation GeneratedRemoverMethod {
}

/**
 * <p>This annotation is put onto methods which have been generated for
 * calling the method in the super class.</p>
 */
@Target(ElementType.METHOD)
annotation GeneratedSuperCallMethod {
}

/**
 * <p>Annotation for the instance of the generated factory class.</p>
 * 
 * @see ApplyRules
 * @see GeneratedFactoryClass
 * @see FactoryMethodRule#factoryInstance
 */
@Target(ElementType.FIELD)
annotation GeneratedFactoryInstance {
}

/**
 * <p>This annotation is attached to classes that do have a (xtend) source class with at
 * least one explicit constructor.</p>
 */
@Target(ElementType.TYPE)
annotation HasExplicitConstructors {
}

/**
 * <p>This annotation is put onto constructors within adapted classes,
 * which have been generated for delegation purpose. Thereby, the main purpose
 * of delegation is to include a check procedure. In constructors annotated
 * by this annotation, it is checked if the {@link ApplyRules} annotation
 * is used consistently.</p>
 * 
 * @see ApplyRules
 */
@Target(ElementType.CONSTRUCTOR)
annotation ApplyRulesCheckerDelegationConstructor {
}

/**
 * <p>This annotation is put onto constructors within adapted classes,
 * which have been generated for delegation purpose. Thereby, the main purpose
 * of delegation is to include a check procedure. In constructors annotated
 * by this annotation, it is checked if the constructor has been called by
 * an associated factory method.</p>
 * 
 * @see ApplyRules
 */
@Target(ElementType.CONSTRUCTOR)
annotation FactoryCallCheckerDelegationConstructor {
}

/**
 * <p>Active Annotation Processor for {@link ApplyRules}.</p>
 * 
 * @see ApplyRules
 */
class ApplyRulesProcessor extends AbstractClassProcessor implements QueuedTransformationParticipant<MutableClassDeclaration> {

	final static public String AUTO_RULE_ADAPTION_MISSING_ERROR = "Class \"%s\" must be annotated by @ApplyRules because a base class is marked for automatic adaption"
	final static public String SUPER_CALL_NOT_AVAILABLE_ERROR = "Super call of method \"%s\" detected, but method is not available in class \"%s\""

	final static public String INJECTED_PARAMETER_NAME_SEPARATOR = "______$injectedParam$"
	final static public String FACTORY_CLASS_NAME = "Factory"

	final static public String CLASS_PARAM_NAME_PREFIX = "$_type_"

	protected override Class<?> getProcessedAnnotationType() {
		ApplyRules
	}

	/**
	 * <p>Retrieves all constructors in the hierarchy that declare type adaption rules (in parameters) or
	 * the copy constructor rule.</p>
	 */
	static protected def getConstructorsToAdapt(ClassDeclaration classDeclaration, Class<?> annotationType,
		extension TransformationContext context) {

		for (superType : classDeclaration.getSuperClasses(false)) {

			val constructorsToAdapt = superType.declaredConstructors.filter [
				it.visibility != Visibility::PRIVATE && (
				it.getAnnotation(annotationType) !== null || it.parameters.exists [
					it.getAnnotation(annotationType) !== null
				])
			]

			// do not continue with parent's constructors if already found adaption rules
			if (constructorsToAdapt.size > 0) {

				return constructorsToAdapt

			} else {

				// no adaption if there is a explicitly declared constructor
				if (superType.hasAnnotation(HasExplicitConstructors))
					return new ArrayList<ConstructorDeclaration>

			}

		}

		return new ArrayList<ConstructorDeclaration>

	}

	/**
	 * <p>Retrieves all methods in the type hierarchy that have an adaption rule declared
	 * (in parameters or return type).</p>
	 * 
	 * <p>The result is a map of methods, together with the "super classes" (in order) leading to the class 
	 * where the adaption rule has been found. Thereby, a "super class" is not necessarily the extended class,
	 * but it can also be a trait class.</p>
	 * 
	 * <p>A (manually declared) method in the type hierarchy without adaption rule will stop adaption,
	 * even if a method in a super type has type adaption rules declared. In order to avoid this,
	 * a (manually declared) method can be annotated by {@link AdaptedMethod}. Then it will be ignored
	 * and the search type adaption rules continues.</p>
	 */
	static protected def Map<MethodDeclaration, List<ClassDeclaration>> getMethodsToAdapt(
		ClassDeclaration annotatedClass,
		TypeMap typeMap,
		Class<?> annotationType,
		(MethodDeclaration)=>Boolean annotationCheckExistenceOnMethod,
		List<String> errors,
		extension TransformationContext context
	) {

		val methodsToAdapt = new LinkedHashMap<MethodDeclaration, List<ClassDeclaration>>
		val methodsNotToAdapt = new HashSet<String>

		// all methods in current class shall not be adapted (based on the method name) 
		methodsNotToAdapt.addAll(annotatedClass.getDeclaredMethodsResolved(true, false, false, context).map[simpleName])

		// start recursion with current class
		getMethodsToAdaptInternal(annotatedClass, annotatedClass, true, new ArrayList<ClassDeclaration>, methodsToAdapt,
			methodsNotToAdapt, !annotatedClass.getDeclaredMethodsResolved(true, false, false, context).exists [
				it.isConstructorMethod
			], typeMap, annotationType, annotationCheckExistenceOnMethod, errors, context)

		return methodsToAdapt

	}

	/**
	 * <p>Internal method for searching adaption methods.</p>
	 */
	static private def void getMethodsToAdaptInternal(
		ClassDeclaration original,
		ClassDeclaration currentClass,
		boolean isRoot,
		List<ClassDeclaration> currentlyProcessingSuperClasses,
		Map<MethodDeclaration, List<ClassDeclaration>> methodsToAdapt,
		Set<String> methodsNotToAdapt,
		boolean addConstructorMethods,
		TypeMap typeMap,
		Class<?> annotationType,
		(MethodDeclaration)=>Boolean annotationCheckExistenceOnMethod,
		List<String> errors,
		extension TransformationContext context
	) {

		var continueAddConstructorMethods = addConstructorMethods

		// process current class
		if (!isRoot) {

			// ignore adapted methods
			var relevantMethods = currentClass.getDeclaredMethodsResolved(true, false, false, context).filter [
				!it.hasAnnotation(AdaptedMethod)
			]

			// check for constructor methods if not processed yet
			if (continueAddConstructorMethods) {

				val relevantConstructorMethods = relevantMethods.filter[it.isConstructorMethod]
				if (relevantConstructorMethods.size > 0) {

					continueAddConstructorMethods = false
					val constructorMethodsWithAdaptionRule = relevantConstructorMethods.filter [
						it.visibility != Visibility::PRIVATE && it.hasAnnotation(annotationType) || it.parameters.exists [
							it.hasAnnotation(annotationType)
						]
					]

					// add found constructor methods
					for (method : constructorMethodsWithAdaptionRule) {
						methodsToAdapt.put(
							method,
							new ArrayList<ClassDeclaration>(currentlyProcessingSuperClasses)
						)
					}

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
				it.visibility != Visibility::PRIVATE && annotationCheckExistenceOnMethod.apply(it)
			]

			// add found methods
			for (method : methodsWithAdaptionRule)
				methodsToAdapt.put(method, new ArrayList<ClassDeclaration>(currentlyProcessingSuperClasses))

			// all found (relevant) methods shall not be considered in further processing of current hierarchy any more
			methodsNotToAdapt.addAll(relevantMethods.map[simpleName])

		}

		// recurse into super type (regular extended class)
		if (currentClass.extendedClass?.type instanceof ClassDeclaration) {

			currentlyProcessingSuperClasses.add(currentClass.extendedClass.type as ClassDeclaration)
			try {

				getMethodsToAdaptInternal(original, currentClass.extendedClass.type as ClassDeclaration, false,
					currentlyProcessingSuperClasses, methodsToAdapt, new HashSet<String>(methodsNotToAdapt),
					continueAddConstructorMethods, typeMap, annotationType, annotationCheckExistenceOnMethod, errors,
					context)

			} finally {
				currentlyProcessingSuperClasses.remove(currentlyProcessingSuperClasses.size - 1)
			}

		}

		// track methods to adapt based on trait classes separately
		val methodsToAdaptTemp = if (isRoot)
				new LinkedHashMap<MethodDeclaration, List<ClassDeclaration>>
			else
				methodsToAdapt

		// recurse into trait classes
		val traitClassRefs = currentClass.getTraitClassesAppliedToExtended(null, context)

		for (traitClassRef : traitClassRefs) {

			// iterate over trait class hierarchy
			if (traitClassRef?.type instanceof ClassDeclaration) {

				// recurse into super type (trait class)
				currentlyProcessingSuperClasses.add(traitClassRef.type as ClassDeclaration)
				try {

					getMethodsToAdaptInternal(original, traitClassRef.type as ClassDeclaration, false,
						currentlyProcessingSuperClasses, methodsToAdaptTemp, new HashSet<String>(methodsNotToAdapt),
						false, typeMap, annotationType, annotationCheckExistenceOnMethod, errors, context)

				} finally {
					currentlyProcessingSuperClasses.remove(currentlyProcessingSuperClasses.size - 1)
				}

				if (isRoot) {

					val methodsNamesAdapted = methodsToAdapt.keySet.map[simpleName]

					// check for ambiguous type adaption rules
					for (methodToAdaptTemp : methodsToAdaptTemp.keySet)
						if (methodsNamesAdapted.findFirst[it == methodToAdaptTemp.simpleName] !== null) {
							errors?.
								add('''Trait class "«traitClassRef?.type.simpleName»" contains method "«methodToAdaptTemp.simpleName»", which specifies another adaption rule''')
						}

					// copy entries of temporary structures to main structures
					methodsToAdapt.putAll(methodsToAdaptTemp)
					methodsToAdaptTemp.clear

				}

			}

		}

	}

	/**
	 * <p>Retrieves the fallback type for a specific parameter (or return type if <code>paramPos</code>
	 * is <code>-1</code>) from the method of the given class. It will search through superclasses
	 * until method is found.</p>
	 */
	static protected def TypeReference getSuperClassesMethodFallbackParamType(
		ClassDeclaration classDeclaration,
		MethodDeclaration methodDeclaration,
		TypeMap typeMap,
		int paramPos,
		List<String> errors,
		extension TransformationContext context
	) {

		for (currentClass : classDeclaration.getSuperClasses(true)) {

			// step 1: search exact type match
			var methodsFound = currentClass.getDeclaredMethodsResolved(true, false, false, context).filter [
				it.simpleName == methodDeclaration.simpleName &&
					methodDeclaration.parameters.parametersEquals(it.parameters, TypeMatchingStrategy.MATCH_INVARIANT,
						true, typeMap, context)

			]

			if (methodsFound.size == 0) {

				// step 2: search covariant type match
				methodsFound = currentClass.getDeclaredMethodsResolved(true, false, false, context).filter [
					it.simpleName == methodDeclaration.simpleName &&
						methodDeclaration.parameters.parametersEquals(it.parameters,
							TypeMatchingStrategy.MATCH_COVARIANT, true, typeMap, context)

				]

			}

			if (methodsFound.size == 0) {

				// step 3: search similar type match
				methodsFound = currentClass.getDeclaredMethodsResolved(true, false, false, context).filter [
					it.simpleName == methodDeclaration.simpleName &&
						methodDeclaration.parameters.parametersSimilar(it.parameters)
				]

			}

			// error if still more than one method (ambiguity)
			if (methodsFound.size > 1 && paramPos == -1) {

				errors?.
					add('''Retrieving fallback return type of method "«methodDeclaration.simpleName»" not possible because of ambiguity''')

			}

			if (methodsFound.size > 0) {

				var methodFound = if (methodsFound.size > 1) {

						// if there is ambiguity, try to find correct method via parameter name
						val methodsFoundReduced = methodsFound.filter [
							it.parameters.get(paramPos).simpleName ==
								methodDeclaration.parameters.get(paramPos).simpleName
						]

						// error if still more than one method (ambiguity)
						if (methodsFoundReduced.size > 1)
							errors?.
								add('''Retrieving fallback type of parameter #«paramPos» of method "«methodDeclaration.simpleName»" not possible because of ambiguity (try to use different names for parameters)''')

						methodsFoundReduced.get(0)

					} else {

						methodsFound.get(0)

					}

				if (methodFound !== null) {

					// method found, now copy type reference
					if (paramPos == -1)
						return copyTypeReference(methodFound.returnType, typeMap, context)

					val parameter = methodFound.parameters.get(paramPos)
					val parameterType = if (parameter.hasAnnotation(AssertParameterType))
							parameter.getAnnotation(AssertParameterType).getClassValue("value")
						else
							parameter.type

					return copyTypeReference(parameterType, typeMap, context)

				}

			}

		}

		return null

	}

	/**
	 * <p>Retrieves the fallback type for a specific parameter from the constructor of 
	 * the given class. It will search through superclasses until constructor is found.</p>
	 */
	static protected def TypeReference getSuperClassesConstructorFallbackParamType(
		ClassDeclaration classDeclaration,
		ConstructorDeclaration constructorDeclaration,
		TypeMap typeMap,
		int paramPos,
		List<String> errors,
		extension TransformationContext context
	) {

		for (currentClass : classDeclaration.getSuperClasses(true)) {

			// step 1: search exact type match
			var constructorsFound = currentClass.declaredConstructors.filter [
				constructorDeclaration.parameters.parametersEquals(it.parameters, TypeMatchingStrategy.MATCH_INVARIANT,
					true, typeMap, context)
			]

			if (constructorsFound.size == 0) {

				// step 2: search covariant type match
				constructorsFound = currentClass.declaredConstructors.filter [
					constructorDeclaration.parameters.parametersEquals(it.parameters,
						TypeMatchingStrategy.MATCH_INHERITED, true, typeMap, context)
				]

			}

			if (constructorsFound.size == 0) {

				// step 3: search similar type match
				constructorsFound = currentClass.declaredConstructors.filter [
					constructorDeclaration.parameters.parametersSimilar(it.parameters)
				]

			}

			if (constructorsFound.size > 0) {

				var constructorFound = if (constructorsFound.size > 1) {

						// if there is ambiguity, try to find correct constructor via parameter name
						val constructorsFoundReduced = constructorsFound.filter [
							it.parameters.get(paramPos).simpleName ==
								constructorDeclaration.parameters.get(paramPos).simpleName
						]

						// error if still more than one constructor (ambiguity)
						if (constructorsFoundReduced.size > 1)
							errors?.
								add('''Retrieving fallback type of parameter #«paramPos» of constructor not possible because of ambiguity (try to use different names for parameters)''')

						constructorsFoundReduced.get(0)

					} else {

						constructorsFound.get(0)

					}

				if (constructorFound !== null)
					return copyTypeReference(constructorFound.parameters.get(paramPos).type, typeMap, context)

			}

		}

	}

	/**
	 * <p>This method returns the declared method in the given class that are extended by the
	 * given priority envelope method, e.g., there is a method which must be considered when calling
	 * via priority queue.</p>
	 */
	static def MethodDeclaration getDeclaredPriorityEnvelopeMethod(ClassDeclaration annotatedClass,
		MethodDeclaration priorityEnvelopeMethod, TypeMap typeMap, extension TransformationContext context) {

		val declaredPriorityEnvelopeMethod = annotatedClass.declaredMethods.filter [
			it.visibility != Visibility::PRIVATE
		].getMatchingMethod(priorityEnvelopeMethod, TypeMatchingStrategy.MATCH_INHERITED_CONSTRUCTOR_METHOD,
			TypeMatchingStrategy.MATCH_INHERITED, false, typeMap, context)

		if (declaredPriorityEnvelopeMethod !== null) {

			// do not consider method if it is an delegation method implemented for a priority envelope method
			// if it is, search for original method
			if (declaredPriorityEnvelopeMethod.hasAnnotation(DelegationPriorityEnvelopeCaller)) {

				return annotatedClass.declaredMethods.getMatchingMethod(
					new MethodDeclarationRenamed(priorityEnvelopeMethod,
						priorityEnvelopeMethod.getExtendedMethodImplNameAfterExtendedByPriorityEnvelope),
					TypeMatchingStrategy.MATCH_INHERITED_CONSTRUCTOR_METHOD, TypeMatchingStrategy.MATCH_INHERITED,
					false, typeMap, context)

			}

			return declaredPriorityEnvelopeMethod

		}

		return null

	}

	/**
	 * <p>This method returns the first (non-abstract) declared priority envelope method in the list of parents of the
	 * given class that are extended by the given priority envelope method, e.g., there is a method which
	 * must be considered when calling via priority queue.</p>
	 */
	static def MethodDeclaration getParentDeclaredPriorityEnvelopeMethod(ClassDeclaration annotatedClass,
		MethodDeclaration priorityEnvelopeMethod, TypeMap typeMap, extension TransformationContext context) {

		for (parentClass : annotatedClass.getSuperClasses(false)) {

			val implementedPriorityEnvelopeMethod = parentClass.
				getDeclaredPriorityEnvelopeMethod(priorityEnvelopeMethod, typeMap, context)

			if (implementedPriorityEnvelopeMethod !== null) {
				if (implementedPriorityEnvelopeMethod.abstract && !parentClass.hasAnnotation(ImplementDefault))
					return null
				else
					return implementedPriorityEnvelopeMethod

			}

		}

		return null

	}

	/**
	 * <p>Retrieves the class requiring an implementation for the given priority envelope method in
	 * the extended class.</p>
	 * 
	 * <p>If it is not required, the method return <code>null</code>.</p>
	 */
	static def ClassDeclaration getRequiringTraitClassForPriorityEnvelopeMethod(
		MethodDeclaration priorityEnvelopeMethod,
		Map<MethodDeclaration, Map<Integer, MethodDeclaration>> priorityEnvelopeMethodsMapAll,
		extension TransformationContext context) {

		// check if an implementation in extended class is required
		if (!priorityEnvelopeMethodsMapAll.get(priorityEnvelopeMethod).values.lastOrNull.
			getPriorityEnvelopeMethodInfo(context).required)
			return null

		// return class in which the "required" is set
		return priorityEnvelopeMethodsMapAll.get(priorityEnvelopeMethod).values.lastOrNull.declaringType as ClassDeclaration

	}

	/**
	 * <p>This method returns if "priority envelope method caller" for the given priority envelope method has been or
	 * must be implemented in the given class.</p>
	 */
	static def boolean hasImplementedPriorityEnvelopeCaller(ClassDeclaration annotatedClass,
		MethodDeclaration priorityEnvelopeMethod,
		Map<MethodDeclaration, Map<Integer, MethodDeclaration>> priorityEnvelopeMethodsMapAll, TypeMap typeMap,
		extension TransformationContext context) {

		val declaredPriorityEnvelopeMethod = annotatedClass.
			getDeclaredPriorityEnvelopeMethod(priorityEnvelopeMethod, typeMap, context)
		val parentDeclaredPriorityEnvelopeMethod = annotatedClass.
			getParentDeclaredPriorityEnvelopeMethod(priorityEnvelopeMethod, typeMap, context)

		var hasImplementation = ((((declaredPriorityEnvelopeMethod !== null &&
			(!declaredPriorityEnvelopeMethod.abstract || annotatedClass.hasAnnotation(ImplementDefault))) ||
			( annotatedClass.hasAnnotation(ImplementDefault) &&
				getRequiringTraitClassForPriorityEnvelopeMethod(priorityEnvelopeMethod, priorityEnvelopeMethodsMapAll,
					context) !== null)) &&
			(parentDeclaredPriorityEnvelopeMethod === null || parentDeclaredPriorityEnvelopeMethod.abstract) &&
			hasImplementedPriorityEnvelopeCallerInAnyParent(annotatedClass, priorityEnvelopeMethod,
				priorityEnvelopeMethodsMapAll, typeMap, context)) ||
			annotatedClass.getAppliedPriorityEnvelopeMethods(typeMap, context).getMatchingMethod(priorityEnvelopeMethod,
				TypeMatchingStrategy.MATCH_INVARIANT, TypeMatchingStrategy.MATCH_INHERITED, false, typeMap, context) !==
				null)

		// check if implementation might be automatic
		if (!hasImplementation) {

			annotatedClass.hasAnnotation(ImplementDefault)

		}

		return hasImplementation

	}

	/**
	 * <p>This method returns if a "priority envelope method caller" for the given priority envelope method
	 * has been or must be implemented in any parent of the given class.</p>
	 */
	static def boolean hasImplementedPriorityEnvelopeCallerInAnyParent(ClassDeclaration annotatedClass,
		MethodDeclaration priorityEnvelopeMethod,
		Map<MethodDeclaration, Map<Integer, MethodDeclaration>> priorityEnvelopeMethodsMapAll, TypeMap typeMap,
		extension TransformationContext context) {

		for (parentClass : annotatedClass.getSuperClasses(false))
			if (parentClass.hasImplementedPriorityEnvelopeCaller(priorityEnvelopeMethod, priorityEnvelopeMethodsMapAll,
				typeMap, context))
				return true;
		return false;

	}

	/**
	 * <p>Returns the adaption rule (string) for the specified parameter.</p>
	 * 
	 * <p>If the method of the source parameter has been adapted, the method will search for adaption
	 * rules in superclasses. However, this method does not search for type adaptions coming from trait
	 * classes that extend the current type hierarchy.</p>
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

		} else {

			val executable = parameterDeclaration.declaringExecutable

			if (executable.hasAnnotation(AdaptedMethod) || executable.hasAnnotation(AdaptedConstructor)) {

				val superMethod = getMatchingExecutableInClass(
					(executable.declaringType as ClassDeclaration).extendedClass?.type as ClassDeclaration, executable,
					TypeMatchingStrategy.MATCH_INHERITED_CONSTRUCTOR_METHOD, TypeMatchingStrategy.MATCH_INHERITED,
					false, false, true, false, false, typeMap, context)
				if (superMethod !== null)
					return getTypeAdaptionRuleWithinTypeHierarchy(
						superMethod.parameters.get(parameterDeclaration.parameterPosition), typeMap, context)

			}

		}

		return null

	}

	/**
	 * <p>Apply type adaption rule (given by string) to a declared element (can be method or parameter), 
	 * i.e., the type of the according element is changed by applying the rule.</p>
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
		List<String> errors,
		extension TransformationContext context
	) {

		// return with same type if no rule is defined
		if (completeRule === null || completeRule.trim().empty) {

			if (element instanceof MethodDeclaration)
				return copyTypeReference((element).returnType, typeMap, context)
			else if (element instanceof ParameterDeclaration)
				return copyTypeReference((element).type, typeMap, context)
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

		// return null if type within supertype's element shall not be searched
		if (!useSuperType)
			return null;

		// use type within supertype's element if new type not found
		val paramPos = if (element instanceof ParameterDeclaration)
				element.parameterPosition
			else
				-1

		if (source instanceof MethodDeclaration)
			return getSuperClassesMethodFallbackParamType(relevantSuperClass, source, typeMap, paramPos, errors,
				context)
		else if (element instanceof ParameterDeclaration)
			return getSuperClassesConstructorFallbackParamType(relevantSuperClass, source as ConstructorDeclaration,
				typeMap, paramPos, errors, context)
		else
			throw new IllegalArgumentException('''Cannot apply adaption rule to given element: ''' + element.toString)

	}

	/**
	 * <p>Apply implementation adaption rule (given by string) to a declared method and
	 * return resulting implementation (as string).</p>
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
	 * <p>The method returns if there is any change for the given executable declaration.</p>
	 */
	static protected def boolean checkAdaptionChange(ClassDeclaration annotatedClass,
		List<ClassDeclaration> relevantSuperClasses, MethodDeclaration ruleMethod,
		MethodDeclaration methodInExtendedClass, Map<String, String> variableMap, TypeMap typeMap, List<String> errors,
		extension TransformationContext context) {

		// check each parameter for type change
		val parameterIteratorRuleMethod = ruleMethod.parameters.iterator
		val parameterIteratorMethodInExtendedClass = methodInExtendedClass.parameters.iterator

		while (parameterIteratorRuleMethod.hasNext) {

			val parameterRuleMethod = parameterIteratorRuleMethod.next
			val parameterMethodInExtendedClass = parameterIteratorMethodInExtendedClass.next

			val ruleParam = parameterRuleMethod.getAnnotation(TypeAdaptionRule)?.getStringValue("value")
			val adaptedTypeAnnotatedClass = parameterMethodInExtendedClass.applyTypeAdaptionRule(#[annotatedClass],
				relevantSuperClasses.get(0), ruleParam, ruleMethod, variableMap, typeMap, true, errors, context)

			// use type in AssertParameterType annotation if available (parameter has been adapted already)
			var parameterTypeMethodInExtendedClass = parameterMethodInExtendedClass.type
			if (parameterMethodInExtendedClass.hasAnnotation(AssertParameterType))
				parameterTypeMethodInExtendedClass = parameterMethodInExtendedClass.getAnnotation(AssertParameterType).
					getClassValue("value")

			if (!adaptedTypeAnnotatedClass.typeReferenceEquals(
				parameterTypeMethodInExtendedClass,
				null,
				true,
				typeMap
			))
				return true

		}

		// check return type for change
		val ruleReturnType = ruleMethod.getAnnotation(TypeAdaptionRule)?.getStringValue("value")
		val adaptedReturnType = methodInExtendedClass.applyTypeAdaptionRule(#[annotatedClass],
			relevantSuperClasses.get(0), ruleReturnType, ruleMethod, variableMap, typeMap, true, errors, context)

		if (!adaptedReturnType.typeReferenceEquals(methodInExtendedClass.returnType, null, true, typeMap))
			return true

		return false

	}

	/**
	 * <p>Copy parameters and apply adaption rules.</p>
	 * 
	 * <p>The method supports copying parameters from multiple sources.</p>
	 * 
	 * <p>The parameter <code>createParameterAssertions</code> determines if the parameter types shall
	 * really be adapted/changed, or if a <code>AssertParameterType</code> annotation shall be added,
	 * which will cause the generation of runtime type assertions.</p>
	 */
	static protected def void copyParametersAndAdapt(MutableClassDeclaration annotatedClass,
		ClassDeclaration relevantSuperClass, ExecutableDeclaration source, MutableExecutableDeclaration target,
		boolean createParameterAssertions, Map<String, String> variableMap, TypeMap typeMap, List<String> errors,
		extension TransformationContext context) {

		// copy parameters and create name list
		for (parameter : source.parameters) {

			// apply adaption rule (for parameter type)
			val ruleParam = parameter.getAnnotation(TypeAdaptionRule)?.getStringValue("value")
			val adaptedType = parameter.applyTypeAdaptionRule(#[annotatedClass], relevantSuperClass, ruleParam, source,
				variableMap, typeMap, true, errors, context)

			// construct new parameter name and check
			val newParameterName = parameter.simpleName

			// create new parameter (with regular or adapted type depending on mode)
			val newParam = if (createParameterAssertions)
					target.addParameter(newParameterName, parameter.type.copyTypeReference(typeMap, context))
				else
					target.addParameter(newParameterName, adaptedType)

			// add information about adapted type
			if (createParameterAssertions) {

				if (!adaptedType.typeReferenceEquals(parameter.type, null, true, typeMap)) {

					// error if adaption to a type parameter (a check cannot be performed)
					if (adaptedType?.type instanceof TypeParameterDeclaration) {

						errors?.
							add('''Parameter "«parameter.simpleName»" of method "«source.simpleName»" cannot be adapted to type parameter "«adaptedType.type.simpleName»" because it cannot be checked (type erasure)''')

					}

					// warning if adapted type has type arguments (they will not be checked)
					if (adaptedType.actualTypeArguments.length > 0) {

						errors?.
							add('''«WARNING_PREFIX»Parameter "«parameter.simpleName»" of method "«source.simpleName»" should not be adapted to another type with type arguments because they cannot be checked (type erasure)''')

					}

					// add adapted type via annotation
					newParam.addAnnotation(AssertParameterType.newAnnotationReference [
						setClassValue("value", adaptedType)
					])

				}

			}

		}

		// also set variable argument option correctly
		target.varArgs = source.isVarArgsFixed

	}

	/**
	 * <p>Transfers an annotation for an adaption rule (in a bigger context, e.g., if annotated to a collection field) to a parameter
	 * of a generated method (e.g. adder for this field).</p>
	 */
	static def void transferTypeAdaptionRuleToParameter(MutableParameterDeclaration parameterDeclaration,
		AnnotationTarget annotationTarget, int expectedTypeParameterRules, (String[])=>String ruleModifier,
		extension TransformationContext context) {

		if (!annotationTarget.hasAnnotation(TypeAdaptionRule))
			return

		// copy and transform annotation
		val transferredAnnotation = TypeAdaptionRuleProcessor.copyAnnotationAndTransform(annotationTarget,
			expectedTypeParameterRules, ruleModifier, context)

		// add annotation if available
		if (transferredAnnotation !== null)
			parameterDeclaration.addAnnotation(transferredAnnotation)

	}

	/**
	 * <p>Returns <code>true</code> if given class is root class for auto adaption, i.e. a class which does not have
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
	 * <p>Returns the (qualified) factory class name for the annotated class.</p>
	 */
	static def String getFactoryClassName(ClassDeclaration annotatedClass) {

		return annotatedClass.qualifiedName + "." + FACTORY_CLASS_NAME

	}

	/**
	 * <p>Returns all adaption variables in the context of the given class.</p>
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
	 * <p>Internal method for retrieving adaption variables.</p>
	 */
	@SuppressWarnings("unchecked")
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
	 * <p>Moves the {@link GeneratedFactoryMethod} annotation from one element to another.</p>
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
		var paramNameList = originalConstructor.parameterNames
		if (!isDefaultConstructor)
			paramNameList = paramNameList.subList(1, paramNameList.size)
		originalConstructor.copyParameters(newConstructor, if(!isDefaultConstructor) 1 else 0, false, typeMap, context)

		// hide original constructor
		originalConstructor.visibility = Visibility::PRIVATE

		// move documentation
		if (!isDefaultConstructor) {

			if (originalConstructor.hasAnnotation(FactoryCallCheckerDelegationConstructor) ||
				originalConstructor.hasAnnotation(ApplyRulesCheckerDelegationConstructor) ||
				originalConstructor.hasAnnotation(ExtendedCheckerMethodDelegationConstructor)) {

				newConstructor.docComment = originalConstructor.docComment
				originalConstructor.docComment = '''This is a wrapper of constructor «newConstructor.getJavaDocLinkTo(context)» that is performing some additional checks.'''

			} else {

				newConstructor.docComment = originalConstructor.docComment
				originalConstructor.docComment = '''This is the implementation of constructor «newConstructor.getJavaDocLinkTo(context)».'''

			}

		}

		// add body to new constructor
		bodySetter.setBody(
			newConstructor, '''«IF !isDefaultConstructor»this((«dummyVariableType.canonicalName») null«IF (paramNameList.size > 0)», «ENDIF»«paramNameList.join(", ")»);«ENDIF»
						«additionalBody»''', context)

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

	override void doRegisterGlobals(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {

		super.doRegisterGlobals(annotatedClass, context)

		// generate factory (inner class)
		//
		// currently, with xtend it is not possible to generate the factory class based
		// on the annotation specifications of a parent class because those are not
		// accessible in the current context.
		context.registerClass(annotatedClass.getFactoryClassName())

		// start processing of this element
		ProcessQueue.startTrack(ProcessQueue.PHASE_AUTO_ADAPT, annotatedClass, annotatedClass.qualifiedName)
		ProcessQueue.startTrack(ProcessQueue.PHASE_AUTO_ADAPT_PRIORITY_ENVELOPE_METHODS, annotatedClass,
			annotatedClass.qualifiedName)
		ProcessQueue.startTrack(ProcessQueue.PHASE_AUTO_ADAPT_CHECK, annotatedClass, annotatedClass.qualifiedName)

	}

	override void doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {

		super.doTransform(annotatedClass, context)

		// queue processing
		ProcessQueue.processTransformation(ProcessQueue.PHASE_AUTO_ADAPT, this, annotatedClass,
			annotatedClass.qualifiedName, context)
		ProcessQueue.processTransformation(ProcessQueue.PHASE_AUTO_ADAPT_PRIORITY_ENVELOPE_METHODS, this,
			annotatedClass, annotatedClass.qualifiedName, context)
		ProcessQueue.processTransformation(ProcessQueue.PHASE_AUTO_ADAPT_CHECK, this, annotatedClass,
			annotatedClass.qualifiedName, context)

	}

	override boolean doTransformQueued(int phase, MutableClassDeclaration annotatedClass, BodySetter bodySetter,
		extension TransformationContext context) {

		// postpone transformation if supertype must still be processed
		if (phase === ProcessQueue.PHASE_AUTO_ADAPT ||
			phase === ProcessQueue.PHASE_AUTO_ADAPT_PRIORITY_ENVELOPE_METHODS) {

			for (traitType : annotatedClass.getTraitClassesAppliedToExtended(null, context)) {

				if ((traitType.type as ClassDeclaration).hasAnnotation(ApplyRules) &&
					ProcessQueue.isTrackedTransformation(phase, annotatedClass.compilationUnit,
						(traitType.type as ClassDeclaration).qualifiedName))
					return false

			}

			for (superType : annotatedClass.getSuperClasses(false)) {

				if (superType.hasAnnotation(ApplyRules) &&
					ProcessQueue.isTrackedTransformation(phase, annotatedClass.compilationUnit,
						superType.qualifiedName))
					return false

			}

		}

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// do not process if priority envelope methods have already been processed during previous step
		if (phase === ProcessQueue.PHASE_AUTO_ADAPT_PRIORITY_ENVELOPE_METHODS && annotatedClass.isExtendedClass)
			return true

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
			doTransformGetterSetterAdderRemover(annotatedClass, variableMap, typeMap, bodySetter, context)

		} else if (phase === ProcessQueue.PHASE_AUTO_ADAPT_PRIORITY_ENVELOPE_METHODS) {

			doTransformPriorityEnvelopeMethods(annotatedClass, typeMap, bodySetter, context)

		} else if (phase === ProcessQueue.PHASE_AUTO_ADAPT_CHECK) {

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

		// retrieve methods that must be type/implementation adapted
		val errorsTypeAdaption = new ArrayList<String>
		val methodsTypeAdaption = getMethodsToAdapt(annotatedClass, typeMap, TypeAdaptionRule, [
			TypeAdaptionRuleProcessor.hasTypeAdaptionRule(it)
		], errorsTypeAdaption, context)
		if (xtendClass.reportErrors(errorsTypeAdaption, context))
			return;

		val errorsImplAdaption = new ArrayList<String>
		val methodsImplAdaption = getMethodsToAdapt(annotatedClass, typeMap, ImplAdaptionRule, [
			ImplAdaptionRuleProcessor.hasImplAdaptionRule(it)
		], errorsImplAdaption, context)
		if (xtendClass.reportErrors(errorsImplAdaption, context))
			return;

		val methodsAdaption = new HashSet<MethodDeclaration>
		methodsAdaption.addAll(methodsTypeAdaption.keySet)
		methodsAdaption.addAll(methodsImplAdaption.keySet)

		// adapt methods
		for (method : methodsAdaption.getMethodsSorted(context)) {

			val errorsMethod = new ArrayList<String>
			val extendedClass = annotatedClass.extendedClass.type as ClassDeclaration

			// retrieve and calculate data
			var doTypeAdaption = methodsTypeAdaption.containsKey(method)
			var doImplAdaption = methodsImplAdaption.containsKey(method)

			var relevantSuperClasses = methodsTypeAdaption.get(method)

			// check if type adaption is needed due to type change
			val executableInExtendedClass = extendedClass.getMatchingExecutableInClass(method,
				TypeMatchingStrategy.MATCH_INHERITED, TypeMatchingStrategy.MATCH_INHERITED, true, true, true, false,
				false, typeMap, context) as MethodDeclaration
			if (doTypeAdaption && !doImplAdaption) {

				// perform type adaption if constructor method
				if (!method.isConstructorMethod)
					if (executableInExtendedClass !== null &&
						!checkAdaptionChange(annotatedClass, relevantSuperClasses, method, executableInExtendedClass,
							variableMap, typeMap, errorsMethod, context)) {

						// perform type adaption if the extended class has multiple matching methods
						val matchingMethodsInSuperClass = extendedClass.getDeclaredMethodsResolved(true, false, false,
							context).getMatchingMethods(method, TypeMatchingStrategy.MATCH_INHERITED,
							TypeMatchingStrategy.MATCH_INHERITED, true, typeMap, context)

						if (matchingMethodsInSuperClass.size > 1)
							doTypeAdaption = true
						else
							doTypeAdaption = false

					}

			}

			// check if implementation adaption is needed due to type check
			if (doImplAdaption && errorsMethod.size == 0) {

				val ruleImplTypeExistenceCheck = method.getAnnotation(ImplAdaptionRule)?.getStringValue(
					"typeExistenceCheck")
				if (!ruleImplTypeExistenceCheck.isNullOrEmpty) {
					val existingType = method.applyTypeAdaptionRule(#[annotatedClass], null,
						ruleImplTypeExistenceCheck, null, variableMap, typeMap, false, null, context)
					if (existingType === null)
						doImplAdaption = false
				}

			}

			if ((doTypeAdaption || doImplAdaption) && errorsMethod.size == 0) {

				// method must not exist yet in current class
				if (annotatedClass.getDeclaredMethodsResolved(true, false, false, context).exists [
					it.simpleName == method.simpleName &&
						it.methodEquals(method, TypeMatchingStrategy.MATCH_INHERITED_CONSTRUCTOR_METHOD,
							TypeMatchingStrategy.MATCH_INHERITED, true, typeMap, context)
				]) {
					xtendClass.
						addError('''Adaption of method "«method.simpleName»(«method.getParametersTypeNames(TypeErasureMethod.REMOVE_CONCRETE_TYPE_PARAMTERS, false, context).join(", ")»)" cannot be applied to current class because the method has already been declared.''')
					return
				}

				// clone type map as it becomes modified locally
				val typeMapLocal = typeMap.clone

				// create new method if not declared
				val newMethod = annotatedClass.copyMethod(method, false, true, false, false, false, false, typeMapLocal,
					context)

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

				val performTypeAssertions = doTypeAdaption && !method.isStatic && !method.isConstructorMethod

				if (doTypeAdaption) {

					// copy parameters and apply type adaption rules
					copyParametersAndAdapt(annotatedClass, relevantSuperClasses.get(0), method, newMethod,
						performTypeAssertions, variableMap, typeMapLocal, errorsMethod, context)

					// apply adaption rule (for method return type)
					val ruleMethod = method.getAnnotation(TypeAdaptionRule)?.getStringValue("value")
					newMethod.returnType = method.applyTypeAdaptionRule(#[annotatedClass], relevantSuperClasses.get(0),
						ruleMethod, method, variableMap, typeMapLocal, true, errorsMethod, context)

				} else {

					// copy parameters and return type
					method.copyParameters(newMethod, 0, false, typeMapLocal, context)
					newMethod.returnType = copyTypeReference(method.returnType, typeMap, context)

				}

				// create name list of parameters
				val paramNameList = newMethod.parameterNames

				// set new method to abstract if the implementation will not be adapted,
				// but also search for a reason to implement, which means calling the method of the superclass
				newMethod.abstract = !(doImplAdaption ||
					(executableInExtendedClass !== null && !executableInExtendedClass.abstract))

				if (newMethod.abstract == true && executableInExtendedClass !== null) {

					// if method in superclass is abstract, it could be that it is an adapted method,
					// which has not been processed by the traits mechanism, yet.
					// the following algorithm checks if the abstract method will get implemented
					// by the traits mechanism, i.e., there is a trait class extending the method
					val superClassWithExecutable = executableInExtendedClass.declaringType as ClassDeclaration

					if (!superClassWithExecutable.isTraitClass && method.isTraitMethod) {

						val traitClasses = superClassWithExecutable.getTraitClassesAppliedToExtended(null, context)
						for (traitClassRef : traitClasses) {

							// iterate over trait class hierarchy
							if (traitClassRef?.type instanceof ClassDeclaration) {

								val traitClass = traitClassRef.type as ClassDeclaration

								val executableInTraitClass = traitClass.getMatchingExecutableInClass(
									newMethod,
									TypeMatchingStrategy.MATCH_INHERITED_CONSTRUCTOR_METHOD,
									TypeMatchingStrategy.MATCH_INHERITED,
									true,
									true,
									true,
									false,
									false,
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

					if (doImplAdaption) {

						// apply implementation adaption
						val ruleImpl = method.getAnnotation(ImplAdaptionRule)?.getStringValue("value")
						bodySetter.setBody(newMethod, method.applyImplAdaptionRule(ruleImpl, variableMap, context),
							context)

					} else {

						// generate method body that is a super call
						val isVoid = newMethod.returnType === null || newMethod.returnType.isVoid()
						val returnTypeReferenceString = newMethod.returnType.getTypeReferenceAsString(true,
							TypeErasureMethod.NONE, false, false, context)
						bodySetter.setBody(newMethod, '''«IF !isVoid»return («returnTypeReferenceString») «ENDIF»
			 			super.«if (newMethod.isTraitMethod) newMethod.getTraitMethodImplName else newMethod.simpleName»(«paramNameList.join(", ")»);''',
							context)

					}

				}

			}

			// report errors
			xtendClass.reportErrors(errorsMethod, context)

		}

	}

	private def void doTransformConstructorsAdaptions(
		MutableClassDeclaration annotatedClass,
		Map<String, String> variableMap,
		TypeMap typeMap,
		BodySetter bodySetter,
		extension TransformationContext context
	) {

		// adapt constructors if there is no declared constructor
		if ((annotatedClass.primarySourceElement as ClassDeclaration).declaredConstructors.size == 0) {

			val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

			// retrieve methods that must be copied or type/implementation adapted
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
				var doTypeAdaption = constructorsTypeAdaption.filter[it === constructor].size > 0
				var doImplAdaption = constructorsImplAdaption.filter[it === constructor].size > 0

				// check if implementation adaption is needed due to type check
				if (doImplAdaption) {

					val ruleImplTypeExistenceCheck = constructor.getAnnotation(ImplAdaptionRule)?.getStringValue(
						"typeExistenceCheck")
					if (!ruleImplTypeExistenceCheck.isNullOrEmpty) {
						val existingType = constructor.applyTypeAdaptionRule(#[annotatedClass], null,
							ruleImplTypeExistenceCheck, null, variableMap, typeMap, false, null, context)
						if (existingType === null)
							doImplAdaption = false
					}

				}

				// create new constructor if no other constructor with same amount of parameters
				val newConstructor = annotatedClass.addConstructor() [

					it.docComment = constructor.docComment
					it.deprecated = constructor.deprecated
					it.exceptions = constructor.exceptions

					// use originally used visibility
					if (constructor.hasAnnotation(ConstructorHiddenForFactoryMethod)) {

						it.visibility = Visibility::PUBLIC

					} else {

						it.visibility = constructor.visibility

					}

				]

				val errors = new ArrayList<String>

				if (doTypeAdaption) {

					// copy parameters and apply type adaption rules
					copyParametersAndAdapt(annotatedClass, annotatedClass.extendedClass?.type as ClassDeclaration,
						constructor, newConstructor, false, variableMap, typeMap, errors, context)

				} else {

					// copy parameters
					constructor.copyParameters(newConstructor, 0, false, typeMap, context)

				}

				// create name list of parameters
				val paramNameList = newConstructor.parameterNames

				// mark as "adapted constructor"
				newConstructor.addAnnotation(AdaptedConstructor.newAnnotationReference)

				if (doImplAdaption) {

					// apply implementation adaption
					val ruleImpl = constructor.getAnnotation(ImplAdaptionRule)?.getStringValue("value")
					bodySetter.setBody(newConstructor,
						constructor.applyImplAdaptionRule(ruleImpl, variableMap, context), context)

				} else {

					// generate constructor body, that is a super call
					bodySetter.setBody(newConstructor, '''super(«paramNameList.join(", ")»);''', context)

				}

				// report errors
				xtendClass.reportErrors(errors, context)

			}

		} else {

			// add information to class that there is an explicit constructor
			// (this is necessary because it is not possible to access primarySourceElement when processing
			// another activate annotation from another file in order to determine explicit constructors)
			if ((annotatedClass.primarySourceElement as ClassDeclaration).declaredConstructors.size > 0)
				annotatedClass.addAnnotation(HasExplicitConstructors.newAnnotationReference)

		}

	}

	private def void doTransformGetterSetterAdderRemover(MutableClassDeclaration annotatedClass,
		Map<String, String> variableMap, TypeMap typeMap, BodySetter bodySetter,
		extension TransformationContext context) {

		// go through all fields (do not consider fields with inferred types)
		for (field : annotatedClass.declaredFields.filter[!type.inferred]) {

			if (field.hasAnnotation(GetterRule)) {

				val getterRuleInfo = GetterRuleProcessor.getGetterInfo(field, context)

				// create virtual method (getter) and copy/create
				val virtualGetterMethod = new MethodDeclarationFromGetter(field, getterRuleInfo.visibility,
					getterRuleInfo.collectionPolicy, context)
				val newGetterMethod = copyMethod(annotatedClass, virtualGetterMethod, true, false, true, true, true,
					true, typeMap, context)

				// adjust return type for collections and make returned value unmodifiable
				if (getterRuleInfo.collectionPolicy != CollectionGetterPolicy.DIRECT) {

					if (context.newTypeReference(Collection).isAssignableFrom(field.type) ||
						context.newTypeReference(Map).isAssignableFrom(field.type)) {

						if (context.newTypeReference(SortedMap).isAssignableFrom(field.type)) {
							if (newGetterMethod.returnType.actualTypeArguments !== null &&
								newGetterMethod.returnType.actualTypeArguments.size == 2)
								newGetterMethod.returnType = SortedMap.newTypeReference(
									newGetterMethod.returnType.actualTypeArguments.get(0),
									newGetterMethod.returnType.actualTypeArguments.get(1))
							else
								newGetterMethod.returnType = SortedMap.newTypeReference(newWildcardTypeReference)
						} else if (context.newTypeReference(Map).isAssignableFrom(field.type)) {
							if (newGetterMethod.returnType.actualTypeArguments !== null &&
								newGetterMethod.returnType.actualTypeArguments.size == 2)
								newGetterMethod.returnType = Map.newTypeReference(
									newGetterMethod.returnType.actualTypeArguments.get(0),
									newGetterMethod.returnType.actualTypeArguments.get(1))
							else
								newGetterMethod.returnType = Map.newTypeReference(newWildcardTypeReference)
						} else if (context.newTypeReference(SortedSet).isAssignableFrom(field.type)) {
							if (newGetterMethod.returnType.actualTypeArguments !== null &&
								newGetterMethod.returnType.actualTypeArguments.size == 1)
								newGetterMethod.returnType = SortedSet.newTypeReference(
									newGetterMethod.returnType.actualTypeArguments.get(0))
							else
								newGetterMethod.returnType = SortedSet.newTypeReference(newWildcardTypeReference)
						} else if (context.newTypeReference(Set).isAssignableFrom(field.type)) {
							if (newGetterMethod.returnType.actualTypeArguments !== null &&
								newGetterMethod.returnType.actualTypeArguments.size == 1)
								newGetterMethod.returnType = Set.newTypeReference(
									newGetterMethod.returnType.actualTypeArguments.get(0))
							else
								newGetterMethod.returnType = Set.newTypeReference(newWildcardTypeReference)
						} else if (context.newTypeReference(List).isAssignableFrom(field.type)) {
							if (newGetterMethod.returnType.actualTypeArguments !== null &&
								newGetterMethod.returnType.actualTypeArguments.size == 1)
								newGetterMethod.returnType = List.newTypeReference(
									newGetterMethod.returnType.actualTypeArguments.get(0))
							else
								newGetterMethod.returnType = List.newTypeReference(newWildcardTypeReference)
						} else {
							if (newGetterMethod.returnType.actualTypeArguments !== null &&
								newGetterMethod.returnType.actualTypeArguments.size == 1)
								newGetterMethod.returnType = Collection.newTypeReference(
									newGetterMethod.returnType.actualTypeArguments.get(0))
							else
								newGetterMethod.returnType = Collection.newTypeReference(newWildcardTypeReference)
						}

					}

				}

				// apply body
				bodySetter.setBody(newGetterMethod, virtualGetterMethod.basicImplementation, context)

				// add generation annotation
				newGetterMethod.addAnnotation(GeneratedGetterMethod.newAnnotationReference)

			}

			if (field.hasAnnotation(SetterRule)) {

				val setterRuleInfo = SetterRuleProcessor.getSetterInfo(field, context)

				// create virtual method (setter) and copy/create
				val virtualSetterMethod = new MethodDeclarationFromSetter(field, setterRuleInfo.visibility, context)
				val newSetterMethod = copyMethod(annotatedClass, virtualSetterMethod, true, false, true, true, true,
					false, typeMap, context)

				// transfer type adaption rule in a specific way
				if (virtualSetterMethod.hasAnnotation(TypeAdaptionRule))
					newSetterMethod.parameters.get(0).addAnnotation(
						TypeAdaptionRuleProcessor.copyAnnotation(virtualSetterMethod, context))

				// apply body
				bodySetter.setBody(newSetterMethod, virtualSetterMethod.basicImplementation, context)

				// add generation annotation
				newSetterMethod.addAnnotation(GeneratedSetterMethod.newAnnotationReference)

			}

			if (field.hasAnnotation(AdderRule)) {

				val adderRuleInfo = AdderRuleProcessor.getAdderInfo(field, context)

				if (context.newTypeReference(Collection).isAssignableFrom(field.type)) {

					if (adderRuleInfo.single) {

						// create virtual method (add) and copy/create
						val virtualAddMethod = new MethodDeclarationFromAdder_AddTo(field, adderRuleInfo.visibility,
							context)
						val newAddMethod = copyMethod(annotatedClass, virtualAddMethod, true, false, true, true, true,
							false, typeMap, context)

						// apply body
						bodySetter.setBody(newAddMethod, virtualAddMethod.basicImplementation, context)

						// transfer type adaption rule in a specific way
						transferTypeAdaptionRuleToParameter(newAddMethod.parameters.get(0), virtualAddMethod,
							1, [ rules |
								'''«rules.get(0)»'''
							], context)

						// add generation annotation
						newAddMethod.addAnnotation(GeneratedAdderMethod.newAnnotationReference)

						// another version of this method for adding with index
						if (context.newTypeReference(List).isAssignableFrom(field.type)) {

							// create virtual method (add, indexed) and copy/create
							val virtualAddIndexedMethod = new MethodDeclarationFromAdder_AddToIndexed(field,
								adderRuleInfo.visibility, context)
							val newAddIndexedMethod = copyMethod(annotatedClass, virtualAddIndexedMethod, true, false,
								true, true, true, false, typeMap, context)

							// apply body
							bodySetter.setBody(newAddIndexedMethod, virtualAddIndexedMethod.basicImplementation,
								context)

							// transfer type adaption rule in a specific way
							transferTypeAdaptionRuleToParameter(newAddIndexedMethod.parameters.get(1), virtualAddMethod,
								1, [ rules |
									'''«rules.get(0)»'''
								], context)

							// add generation annotation
							newAddIndexedMethod.addAnnotation(GeneratedAdderMethod.newAnnotationReference)

						}

					}

					if (adderRuleInfo.multiple) {

						// create virtual method (addAll) and copy/create
						val virtualAddAllMethod = new MethodDeclarationFromAdder_AddAllTo(field,
							adderRuleInfo.visibility, context)
						val newAddAllMethod = copyMethod(annotatedClass, virtualAddAllMethod, true, false, true, true,
							true, false, typeMap, context)

						// apply body
						bodySetter.setBody(newAddAllMethod, virtualAddAllMethod.basicImplementation, context)

						// transfer type adaption rule in a specific way
						transferTypeAdaptionRuleToParameter(
							newAddAllMethod.parameters.get(0),
							virtualAddAllMethod,
							1,
							[ rules |
								'''«AdaptionFunctions.RULE_FUNC_APPLY»(java.util.Collection);«AdaptionFunctions.RULE_FUNC_ADD_TYPE_PARAMS_EXTENDS»(«rules.get(0)»)'''
							],
							context
						)

						// add generation annotation
						newAddAllMethod.addAnnotation(GeneratedAdderMethod.newAnnotationReference)

						// another version of this method for adding with index
						if (context.newTypeReference(List).isAssignableFrom(field.type)) {

							// create virtual method (addAll, indexed) and copy/create
							val virtualAddAllIndexedMethod = new MethodDeclarationFromAdder_AddAllToIndexed(field,
								adderRuleInfo.visibility, context)
							val newAddAllIndexedMethod = copyMethod(annotatedClass, virtualAddAllIndexedMethod, true,
								false, true, true, true, false, typeMap, context)

							// apply body
							bodySetter.setBody(newAddAllIndexedMethod, virtualAddAllIndexedMethod.basicImplementation,
								context)

							// transfer type adaption rule in a specific way
							transferTypeAdaptionRuleToParameter(newAddAllIndexedMethod.parameters.get(1),
								virtualAddAllIndexedMethod, 1, [ rules |
									'''«AdaptionFunctions.RULE_FUNC_APPLY»(java.util.Collection);«AdaptionFunctions.RULE_FUNC_ADD_TYPE_PARAMS_EXTENDS»(«rules.get(0)»)'''
								], context)

							// add generation annotation
							newAddAllIndexedMethod.addAnnotation(GeneratedAdderMethod.newAnnotationReference)

						}

					}

				} else if (context.newTypeReference(Map).isAssignableFrom(field.type)) {

					if (adderRuleInfo.single) {

						// create virtual method (add) and copy/create
						val virtualPutMethod = new MethodDeclarationFromAdder_PutTo(field, adderRuleInfo.visibility,
							context)
						val newPutMethod = copyMethod(annotatedClass, virtualPutMethod, true, false, true, true, true,
							false, typeMap, context)

						// apply body
						bodySetter.setBody(newPutMethod, virtualPutMethod.basicImplementation, context)

						// transfer type adaption rule in a specific way
						transferTypeAdaptionRuleToParameter(newPutMethod.parameters.get(0),
							virtualPutMethod, 2, [ rules |
								'''«rules.get(0)»'''
							], context)
						transferTypeAdaptionRuleToParameter(newPutMethod.parameters.get(1),
							virtualPutMethod, 2, [ rules |
								'''«rules.get(1)»'''
							], context)

						// add generation annotation
						newPutMethod.addAnnotation(GeneratedAdderMethod.newAnnotationReference)

					}

					if (adderRuleInfo.multiple) {

						// create virtual method (add) and copy/create
						val virtualPutAllMethod = new MethodDeclarationFromAdder_PutAllTo(field,
							adderRuleInfo.visibility, context)
						val newPutAllMethod = copyMethod(annotatedClass, virtualPutAllMethod, true, false, true, true,
							true, false, typeMap, context)

						// apply body
						bodySetter.setBody(newPutAllMethod, virtualPutAllMethod.basicImplementation, context)

						// transfer type adaption rule in a specific way
						transferTypeAdaptionRuleToParameter(
							newPutAllMethod.parameters.get(0),
							virtualPutAllMethod,
							2,
							[ rules |
								'''«AdaptionFunctions.RULE_FUNC_APPLY»(java.util.Map);«AdaptionFunctions.RULE_FUNC_ADD_TYPE_PARAMS_EXTENDS»(«rules.get(0)»);«AdaptionFunctions.RULE_FUNC_ADD_TYPE_PARAMS_EXTENDS»(«rules.get(1)»)'''
							],
							context
						)

						// add generation annotation
						newPutAllMethod.addAnnotation(GeneratedAdderMethod.newAnnotationReference)

					}

				}

			}

			if (field.hasAnnotation(RemoverRule)) {

				val removerRuleInfo = RemoverRuleProcessor.getRemoverInfo(field, context)

				if (removerRuleInfo.single) {

					// create virtual method (remove) and copy/create
					val virtualRemoveMethod = new MethodDeclarationFromRemover_RemoveFrom(field,
						removerRuleInfo.visibility, context)
					val newRemoveMethod = copyMethod(annotatedClass, virtualRemoveMethod, true, false, true, true, true,
						false, typeMap, context)

					// apply body
					bodySetter.setBody(newRemoveMethod, '''«virtualRemoveMethod.basicImplementation»''', context)

					// transfer type adaption rule in a specific way
					transferTypeAdaptionRuleToParameter(
						newRemoveMethod.parameters.get(0),
						virtualRemoveMethod,
						if (context.newTypeReference(Collection).isAssignableFrom(field.type))
							1
						else
							2,
						[ rules |
							'''«rules.get(0)»'''
						],
						context
					)

					// add generation annotation
					newRemoveMethod.addAnnotation(GeneratedRemoverMethod.newAnnotationReference)

					// another version of this method for removing with index
					if (context.newTypeReference(List).isAssignableFrom(field.type)) {

						// create virtual method (remove, indexed) and copy/create
						val virtualRemoveIndexedMethod = new MethodDeclarationFromRemover_RemoveFromIndexed(field,
							removerRuleInfo.visibility, context)
						val newRemoveIndexedMethod = copyMethod(annotatedClass, virtualRemoveIndexedMethod, true,
							false, true, true, true, false, typeMap, context)

						// apply body
						bodySetter.setBody(
							newRemoveIndexedMethod, '''«virtualRemoveIndexedMethod.basicImplementation»''', context)

						// add generation annotation
						newRemoveIndexedMethod.addAnnotation(GeneratedRemoverMethod.newAnnotationReference)

					}

				}

				if (removerRuleInfo.multiple) {

					if (context.newTypeReference(Collection).type.
						isAssignableFromConsiderUnprocessed(field.type?.type, context)) {

						// create virtual method (removeAll) and copy/create
						val virtualRemoveAllMethod = new MethodDeclarationFromRemover_RemoveAllFrom(field,
							removerRuleInfo.visibility, context)
						val newRemoveAllMethod = copyMethod(annotatedClass, virtualRemoveAllMethod, true, false, true,
							true, true, false, typeMap, context)

						// apply body
						bodySetter.setBody(newRemoveAllMethod, '''«virtualRemoveAllMethod.basicImplementation»''',
							context)

						// transfer type adaption rule in a specific way
						transferTypeAdaptionRuleToParameter(
							newRemoveAllMethod.parameters.get(0),
							virtualRemoveAllMethod,
							1,
							[ rules |
								'''«AdaptionFunctions.RULE_FUNC_APPLY»(java.util.Collection);«AdaptionFunctions.RULE_FUNC_ADD_TYPE_PARAMS_EXTENDS»(«rules.get(0)»)'''
							],
							context
						)

						// add generation annotation
						newRemoveAllMethod.addAnnotation(GeneratedRemoverMethod.newAnnotationReference)

					}

					// create virtual method (clear) and copy/create
					val virtualClearMethod = new MethodDeclarationFromRemover_Clear(field, removerRuleInfo.visibility,
						context)
					val newClearMethod = copyMethod(annotatedClass, virtualClearMethod, true, false, true, true, true,
						false, typeMap, context)

					// apply body
					bodySetter.setBody(newClearMethod, '''«virtualClearMethod.basicImplementation»''', context)

					// add generation annotation
					newClearMethod.addAnnotation(GeneratedRemoverMethod.newAnnotationReference)

				}

			}

		}

	}

	static protected def void doTransformPriorityEnvelopeMethods(MutableClassDeclaration annotatedClass,
		TypeMap typeMap, BodySetter bodySetter, extension TransformationContext context) {

		// do not apply rules in trait classes
		if (annotatedClass.isTraitClass)
			return;

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// check if class has auto implementation activated
		val autoImplementation = annotatedClass.hasAnnotation(ImplementDefault)
		var willGetAutoImplementation = false

		// collect priority envelope methods that must be considered in this class
		val priorityEnvelopeMethodsAll = annotatedClass.getAppliedPriorityEnvelopeMethodsClosure(true, typeMap, context)

		// ... and unify results
		val priorityEnvelopeMethodsAllUnique = priorityEnvelopeMethodsAll.unifyMethodDeclarations(
			TypeMatchingStrategy.MATCH_INHERITED_CONSTRUCTOR_METHOD, TypeMatchingStrategy.MATCH_INHERITED,
			covariantReturnType.curry(context).curry(typeMap), false, typeMap, context)

		// create map of priority and a (sorted) priority envelope method list for each priority envelope method
		val priorityEnvelopeMethodsMapAll = new HashMap<MethodDeclaration, Map<Integer, MethodDeclaration>>

		for (priorityEnvelopeMethodAllUnique : priorityEnvelopeMethodsAllUnique) {

			val priorityEnvelopeMethodSortedList = new TreeMap<Integer, MethodDeclaration>(
				ProcessUtils.IntegerDescendantComparator::INTEGER_DESCENDANT_COMPARATOR)
			priorityEnvelopeMethodsMapAll.put(priorityEnvelopeMethodAllUnique, priorityEnvelopeMethodSortedList)
			for (priorityEnvelopeMethodAll : priorityEnvelopeMethodsAll) {

				if (priorityEnvelopeMethodAllUnique.methodEquals(priorityEnvelopeMethodAll,
					TypeMatchingStrategy.MATCH_INHERITED_CONSTRUCTOR_METHOD, TypeMatchingStrategy.MATCH_INHERITED,
					false, typeMap, context)) {

					// retrieve priority and add to priority-sorted list
					val priority = priorityEnvelopeMethodAll.getPriorityEnvelopeMethodInfo(context).priority

					// error if priority already used
					if (priorityEnvelopeMethodSortedList.get(priority) !== null)
						xtendClass.
							addError('''Method with priority «priority» is already contained in priority method call list (added from trait classes "«priorityEnvelopeMethodSortedList.get(priority).declaringType.simpleName»" and "«annotatedClass.simpleName»")''')

					// retrieve priority and add to priority-sorted list
					priorityEnvelopeMethodSortedList.put(priority, priorityEnvelopeMethodAll)

				}

			}

		}

		// go through all priority envelope methods and generate code
		for (currentPriorityEnvelopeMethodSignature : priorityEnvelopeMethodsAllUnique) {

			// retrieve some signature data from priority envelope method
			val isVoid = currentPriorityEnvelopeMethodSignature.returnType === null ||
				currentPriorityEnvelopeMethodSignature.returnType.isVoid()

			// retrieve implementation from current class and (first in) parent classes if there are any
			val declaredPriorityEnvelopMethod = annotatedClass.getDeclaredPriorityEnvelopeMethod(
				currentPriorityEnvelopeMethodSignature, typeMap, context) as MutableMethodDeclaration
			val firstNonAbstractDeclaredPriorityEnvelopMethodInParent = annotatedClass.
				getParentDeclaredPriorityEnvelopeMethod(currentPriorityEnvelopeMethodSignature, typeMap, context)

			// check if there is any implementation in this class or any parent
			val hasAnyImplementation = if (declaredPriorityEnvelopMethod !== null)
					!declaredPriorityEnvelopMethod.abstract
				else if (firstNonAbstractDeclaredPriorityEnvelopMethodInParent !== null)
					true
				else
					false

			// check if there is a redirection directive
			val firstMatchingExecutable = annotatedClass.getMatchingExecutableInClass(
				currentPriorityEnvelopeMethodSignature,
				TypeMatchingStrategy.MATCH_INHERITED_CONSTRUCTOR_METHOD,
				TypeMatchingStrategy.MATCH_INHERITED,
				true,
				false,
				true,
				true,
				true,
				typeMap,
				context
			) as MethodDeclaration
			val hasRedirectionDirective = firstMatchingExecutable !== null &&
				!firstMatchingExecutable.getTraitMethodRedirectionInfo(context).redirectedMethodName.nullOrEmpty

			if (hasRedirectionDirective)
				xtendClass.
					addError('''Priority envelope methods do not allow trait method redirection (priority envelope method: "«currentPriorityEnvelopeMethodSignature.simpleName»")''')

			// track of super call wrapper has been generated
			var boolean superCallWrapperGenerated = false

			// generate a method for performing the original functionality,
			// if functionality is implemented in this class
			if (declaredPriorityEnvelopMethod !== null) {

				if (!declaredPriorityEnvelopMethod.abstract) {

					// moving the body to a new method instead of renaming the original method avoids
					// some problems with "override" and warnings
					// (original method will be reused by delegation mechanism)
					val implMethod = annotatedClass.copyMethod(declaredPriorityEnvelopMethod, true, false, false, false,
						false, false, typeMap, context)

					// rename old method
					implMethod.simpleName = declaredPriorityEnvelopMethod.
						getExtendedMethodImplNameAfterExtendedByPriorityEnvelope

					// set visibility
					implMethod.visibility = Visibility::PROTECTED

					// move body
					bodySetter.moveBody(implMethod, declaredPriorityEnvelopMethod, context)

					// annotation for original functionality
					implMethod.addAnnotation(ExtendedMethodImpl.newAnnotationReference)

				}

			} else {

				// otherwise, generate a method calling functionality in super class if this is necessary
				if (hasAnyImplementation) {

					// not necessary if there already is an priority envelope caller in the parent
					if (!annotatedClass.
						hasImplementedPriorityEnvelopeCallerInAnyParent(currentPriorityEnvelopeMethodSignature,
							priorityEnvelopeMethodsMapAll, typeMap, context)) {

						superCallWrapperGenerated = true

						// create new method via copy
						val superCallWrapperMethod = copyMethod(annotatedClass,
							firstNonAbstractDeclaredPriorityEnvelopMethodInParent, true, false, true, true, false, true,
							typeMap, context)

						// rename method
						superCallWrapperMethod.simpleName = currentPriorityEnvelopeMethodSignature.
							getExtendedMethodImplNameAfterExtendedByPriorityEnvelope

						// set visibility
						superCallWrapperMethod.visibility = Visibility::PROTECTED

						// apply body
						bodySetter.setBody(
							superCallWrapperMethod, '''«IF !isVoid»return «ENDIF»super.«currentPriorityEnvelopeMethodSignature.simpleName»(«superCallWrapperMethod.parameterNames.join(", ")»);''',
							context)

						// put corresponding annotation on generated method
						superCallWrapperMethod.addAnnotation(GeneratedSuperCallMethod.newAnnotationReference)

					}

				} else {

					val requiringTraitClass = currentPriorityEnvelopeMethodSignature.
						getRequiringTraitClassForPriorityEnvelopeMethod(priorityEnvelopeMethodsMapAll, context)

					if (requiringTraitClass !== null) {

						// method is not available in class, but required...
						if (autoImplementation) {

							willGetAutoImplementation = true

							// ensure that abstract method exists (with suffix) in order to demand implementation in derived class
							var MutableMethodDeclaration implMethodAbstract = annotatedClass.copyMethod(
								currentPriorityEnvelopeMethodSignature, true, false, false, false, false, false,
								typeMap, context)
							implMethodAbstract.abstract = true

							// rename method
							implMethodAbstract.simpleName = currentPriorityEnvelopeMethodSignature.
								getExtendedMethodImplNameAfterExtendedByPriorityEnvelope

							// set visibility
							implMethodAbstract.visibility = Visibility::PROTECTED

							// annotation for original functionality
							implMethodAbstract.addAnnotation(ExtendedMethodImpl.newAnnotationReference)

						} else if (!annotatedClass.abstract) {

							xtendClass.
								addError('''Trait class "«requiringTraitClass.qualifiedName»" requires method "«currentPriorityEnvelopeMethodSignature.getMethodAsString(false, context)»" to be implemented with a lower priority''')

						}

					}

				}

			}

			// generate delegation method to "priority envelope caller" method
			var MutableMethodDeclaration priorityEnvelopeCallerDelegationMethod

			{

				// copy method
				priorityEnvelopeCallerDelegationMethod = if (declaredPriorityEnvelopMethod !== null)
					declaredPriorityEnvelopMethod
				else
					copyMethod(annotatedClass, currentPriorityEnvelopeMethodSignature, true, false, true, true,
						false, true, typeMap, context)

				// method must not be abstract
				priorityEnvelopeCallerDelegationMethod.abstract = false

				// calculate visibility
				val visibilities = new ArrayList<Visibility>
				visibilities.add(declaredPriorityEnvelopMethod?.visibility)
				visibilities.add(firstNonAbstractDeclaredPriorityEnvelopMethodInParent?.visibility)

				for (priorityEnvelopeMethodSignature : priorityEnvelopeMethodsMapAll.get(
					currentPriorityEnvelopeMethodSignature).values)
					visibilities.add(priorityEnvelopeMethodSignature.visibility)

				priorityEnvelopeCallerDelegationMethod.visibility = getMaximalVisibility(visibilities)

				// calculate return type ...
				val returnTypeReferences = new ArrayList<TypeReference>
				returnTypeReferences.add(declaredPriorityEnvelopMethod?.returnType)
				returnTypeReferences.add(firstNonAbstractDeclaredPriorityEnvelopMethodInParent?.returnType)

				// ... also consider possible concrete type in parent even if not implemented explicitly (important for type adaption)
				returnTypeReferences.add(
					(getMatchingExecutableInClass(
						(annotatedClass.primaryGeneratedJavaElement as ClassDeclaration).extendedClass?.
							type as ClassDeclaration,
						priorityEnvelopeCallerDelegationMethod,
						TypeMatchingStrategy.MATCH_INHERITED_CONSTRUCTOR_METHOD,
						TypeMatchingStrategy.MATCH_INHERITED,
						false,
						false,
						true,
						true,
						true,
						typeMap,
						context
					) as MethodDeclaration)?.returnType
				)

				for (priorityEnvelopeMethodSignature : priorityEnvelopeMethodsMapAll.get(
					currentPriorityEnvelopeMethodSignature).values)
					returnTypeReferences.add(priorityEnvelopeMethodSignature.returnType)

				val errors = new ArrayList<String>
				val targetReturnType = getMostConcreteType(returnTypeReferences, errors, typeMap, context)
				if (xtendClass.reportErrors(errors, context))
					return;

				priorityEnvelopeCallerDelegationMethod.returnType = targetReturnType.copyTypeReference(typeMap, context)

				// do not delegate, but call original target if called via "super"
				val callSuperTargetCode = if (hasAnyImplementation)
						TraitClassProcessor.generateSuperCallRedirectionCode(annotatedClass,
							priorityEnvelopeCallerDelegationMethod, if (superCallWrapperGenerated)
								null
							else
								priorityEnvelopeCallerDelegationMethod.
									getExtendedMethodImplNameAfterExtendedByPriorityEnvelope, context)
					else
						'''assert this.getClass() == «annotatedClass.qualifiedName».class : String.format(org.eclipse.xtend.lib.annotation.etai.ApplyRulesProcessor.SUPER_CALL_NOT_AVAILABLE_ERROR, "«currentPriorityEnvelopeMethodSignature.getMethodAsString(false, context)»", "«annotatedClass.qualifiedName»");'''

				// implement call
				bodySetter.setBody(priorityEnvelopeCallerDelegationMethod, '''«callSuperTargetCode»
						«IF !isVoid»return («priorityEnvelopeCallerDelegationMethod.returnType.getTypeReferenceAsString(true, TypeErasureMethod.NONE, false, false, context)») «ENDIF»«priorityEnvelopeCallerDelegationMethod.simpleName + ExtendedByProcessor.EXTENDED_METHOD_PRIORITY_ENVELOPE_CALLER_SUFFIX»(«priorityEnvelopeCallerDelegationMethod.parameterNames.join(", ")»«IF priorityEnvelopeCallerDelegationMethod.parameters.size > 0», «ENDIF»java.lang.Integer.MAX_VALUE«IF !isVoid», null«ENDIF»);''',
					context)

				// consider the created method as delegation method caused by extension
				if (!priorityEnvelopeCallerDelegationMethod.hasAnnotation(DelegationMethodForTraitMethod))
					priorityEnvelopeCallerDelegationMethod.addAnnotation(
						DelegationMethodForTraitMethod.newAnnotationReference)
				priorityEnvelopeCallerDelegationMethod.addAnnotation(
					DelegationPriorityEnvelopeCaller.newAnnotationReference)

			}

			// generate "priority envelope caller" method
			if (annotatedClass.hasImplementedPriorityEnvelopeCaller(currentPriorityEnvelopeMethodSignature,
				priorityEnvelopeMethodsMapAll, typeMap, context)) {

				// copy and rename method
				val priorityEnvelopeCallerMethod = copyMethod(annotatedClass,
					priorityEnvelopeCallerDelegationMethod, true, false, true, true, false, true, typeMap, context)

				// rename method
				priorityEnvelopeCallerMethod.simpleName = priorityEnvelopeCallerMethod.
					getExtendedMethodPriorityQueueCallName

				// adjust visibility
				priorityEnvelopeCallerMethod.visibility = Visibility::PROTECTED

				// put corresponding annotation on generated method
				priorityEnvelopeCallerMethod.addAnnotation(ExtendedPriorityEnvelopeCallerMethod.newAnnotationReference)

				// add parameter for retrieving priority
				priorityEnvelopeCallerMethod.addParameter("$currentPriority", newTypeReference(Integer))

				// add parameter passing default value				
				if (!isVoid)
					priorityEnvelopeCallerMethod.addParameter("$defaultValueProvider",
						newTypeReference(Class,
							newWildcardTypeReference(newTypeReference(DefaultValueProvider, newWildcardTypeReference))))

				var String methodBody = ""

				// sort list of envelope methods
				for (priorityEnvelopeMethodToIncludeEntry : priorityEnvelopeMethodsMapAll.get(
					currentPriorityEnvelopeMethodSignature).entrySet) {

					methodBody += '''if ($currentPriority > «priorityEnvelopeMethodToIncludeEntry.key») {
							«IF !isVoid»return («priorityEnvelopeCallerMethod.returnType.getTypeReferenceAsString(true, TypeErasureMethod.NONE, false, false, context)») «ENDIF»«priorityEnvelopeMethodToIncludeEntry.value.getTraitClassDeclaringTraitMethod(annotatedClass, typeMap, context).delegateObjectName».«currentPriorityEnvelopeMethodSignature.getTraitMethodImplName»(«priorityEnvelopeCallerDelegationMethod.parameterNames.join(", ")»);
							«IF isVoid»return;«ENDIF»
						}
						'''

				}

				if (hasAnyImplementation || willGetAutoImplementation) {

					// call existing method in current class if existing or required...
					methodBody +=
						'''«IF !isVoid»return («priorityEnvelopeCallerMethod.returnType.getTypeReferenceAsString(true, TypeErasureMethod.NONE, false, false, context)») «ENDIF»«currentPriorityEnvelopeMethodSignature.getExtendedMethodImplNameAfterExtendedByPriorityEnvelope»(«priorityEnvelopeCallerDelegationMethod.parameterNames.join(", ")»);
						'''

				} else if (!isVoid) {

					// ... otherwise use default value provider if return value is needed
					methodBody += '''try {
							return («priorityEnvelopeCallerMethod.returnType.getTypeReferenceAsString(true, TypeErasureMethod.NONE, false, true, context)») $defaultValueProvider.getConstructor().newInstance().getDefaultValue();
						} catch (java.lang.InstantiationException | java.lang.IllegalAccessException | java.lang.IllegalArgumentException | java.lang.reflect.InvocationTargetException | java.lang.NoSuchMethodException | java.lang.SecurityException $exception) {
							throw org.eclipse.xtext.xbase.lib.Exceptions.sneakyThrow($exception);
						}
						'''

				}

				// apply body
				bodySetter.setBody(priorityEnvelopeCallerMethod, methodBody, context)

			}

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
		val factoryClass = context.findClass(annotatedClass.getFactoryClassName())
		factoryClass.addAnnotation(GeneratedFactoryClass.newAnnotationReference)

		// hide factory class by default
		factoryClass.visibility = Visibility::PRIVATE

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// retrieve factory rules
		val errors = new ArrayList<String>
		val factoryMethodRuleInfo = annotatedClass.getFactoryMethodRuleInfo(errors, context)
		if (xtendClass.reportErrors(errors, context))
			return;

		// check if factory class shall be generated (including content) 
		val useFactoryClass = factoryMethodRuleInfo !== null && !factoryMethodRuleInfo.factoryInstance.nullOrEmpty
		val useFactoryClassInheritance = useFactoryClass && factoryMethodRuleInfo.factoryClassDerived

		// do not generate factory methods if class is abstract
		if (annotatedClass.abstract && !useFactoryClassInheritance)
			return;

		// construct factory method if method name has been set
		if (factoryMethodRuleInfo !== null && !factoryMethodRuleInfo.factoryMethod.nullOrEmpty) {

			// prepare factory class (inner class)
			var MutableClassDeclaration classToAddFactoryMethods
			if (useFactoryClass) {

				// factory class is used
				factoryClass.visibility = Visibility::PUBLIC
				factoryClass.static = true
				factoryClass.abstract = annotatedClass.abstract

				// extend factory from first parent class that has a factory (if applicable)
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

				// use interface for factory if specified
				if (factoryMethodRuleInfo.factoryInterface !== null &&
					factoryMethodRuleInfo.factoryInterface.qualifiedName != Object.canonicalName) {

					// only add interface if there is no parent (factory) class
					if (factoryClassParent === null)
						factoryClass.implementedInterfaces = factoryClass.implementedInterfaces +
							#[factoryMethodRuleInfo.factoryInterface.newTypeReference]

				}

				// use interface for factory (set via variable) if specified
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

							// only add interface if there is a change
							if (firstImplementedInterfaceParent === null ||
								!typeReferenceEquals(firstImplementedInterfaceParent, factoryInterfaceReference, null,
									false, typeMap))
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
						it.visibility = Visibility::PUBLIC
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

			// track all constructor parameters for each trait class that shall be constructed automatically
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

				// only add constructor parameters if any have been found
				if (!constructorsAndParams.isEmpty)
					constructorParamsPerTraitClass.add(constructorsAndParams)

			}

			// create injection combinations (add empty list if no combination)
			val injectConstructorParameters = constructorParamsPerTraitClass.cartesianProduct
			if (injectConstructorParameters.size == 0)
				injectConstructorParameters.add(new ArrayList<ParameterDeclaration>)

			// create factory method for each public constructor and ...
			for (constructor : annotatedClass.declaredConstructors.filter [
				it.visibility == Visibility::PUBLIC
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

					// additional refactoring of factory method if class provides type parameters
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
							usedTypeMap.putTypeClone(typeParameter, newTypeArgument)

						}

					} else {

						usedTypeMap = typeMap

					}

					// set return type (consider type arguments)
					newFactoryMethod.returnType = annotatedClass.newTypeReference(newMethodTypeArguments)

					// apply return type adaption rule if available
					if (!factoryMethodRuleInfo.returnTypeAdaptionRule.nullOrEmpty) {

						val adaptedTypeReference = newFactoryMethod.applyTypeAdaptionRule(#[newFactoryMethod], null,
							factoryMethodRuleInfo.returnTypeAdaptionRule, null, variableMap, typeMap, false, null,
							context)

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
								parameter.type.getTypeReferenceAsString(true, TypeErasureMethod.NONE, true, false,
									context))

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
									adaptionRule, declaringExecutable, currentVariableMap, usedTypeMap, false, null,
									context)

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
							if (!originalType.typeReferenceEquals(newType, null, true, usedTypeMap)) {
								xtendClass.
									addError('''Injection of constructor parameters from trait class «traitClass.simpleName» cannot be performed because of a type mismatch of parameter "«parameter.simpleName»" («newType» != «originalType»)''')
								return
							}

						}

					}

					// add parameters that have been processed so far
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
										parameter.type.getTypeReferenceAsString(true, TypeErasureMethod.NONE, true,
											false, context))
								}

							}

							bodyDelegationObjectCreation +=
								'''internal$newObject.«traitClassToConstruct.getConstructorMethodCallName(true)»(«parameterNames.join(", ")»);
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
								'''assert org.eclipse.xtend.lib.annotation.etai.utils.ReflectUtils.getPrivateFieldValue(internal$newObject, "«traitClassToCheck.delegateObjectName»") != null : String.format(org.eclipse.xtend.lib.annotation.etai.ExtendedByProcessor.TRAIT_OBJECT_NOT_CONSTRUCTED_ERROR, "«traitClassToCheck.qualifiedName»");
								'''

						}

					}

					// check if there is an ambiguous combination
					if (newFactoryMethodList.methodListContains(newFactoryMethod, TypeMatchingStrategy.MATCH_INVARIANT,
						TypeMatchingStrategy.MATCH_INVARIANT, false, typeMap, context)) {
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
					val paramNameList = constructor.parameterNames

					// store type argument string
					val typeArgumentString = '''«IF (annotatedClass.typeParameters.size > 0)»<«newFactoryMethod.typeParameters.map[it.simpleName].join(", ")»>«ENDIF»'''

					// add body to factory method (if not abstract)
					if (!newFactoryMethod.abstract) {

						bodySetter.setBody(newFactoryMethod, '''assert org.eclipse.xtend.lib.annotation.etai.FactoryMethodRuleProcessor.registerObjectConstructionViaFactory() : org.eclipse.xtend.lib.annotation.etai.FactoryMethodRuleProcessor.REGISTER_OBJECT_CONSTRUCTION_ERROR;
							try {
								«annotatedClass.qualifiedName»«typeArgumentString» internal$newObject = new «annotatedClass.qualifiedName»«typeArgumentString»(«paramNameList.join(", ")»);
								«bodyDelegationObjectCreation»
								«bodyCheckObjectCreation»
								«IF !factoryMethodRuleInfo.initMethod.nullOrEmpty»internal$newObject.«factoryMethodRuleInfo.initMethod»();«ENDIF»
								return internal$newObject;
							} finally {
								assert org.eclipse.xtend.lib.annotation.etai.FactoryMethodRuleProcessor.unregisterObjectConstructionViaFactory() : org.eclipse.xtend.lib.annotation.etai.FactoryMethodRuleProcessor.UNREGISTER_OBJECT_CONSTRUCTION_ERROR;
							}''', context)

					}

				}

				// ensure that constructor is not synthetic
				if (!bodySetter.hasBody(constructor))
					bodySetter.setBody(constructor, "", context)

				// hide constructor
				constructor.addAnnotation(ConstructorHiddenForFactoryMethod.newAnnotationReference)
				constructor.visibility = Visibility::PROTECTED

			}

		}

	}

	private def void doTransformConstructorsConsistencyChecks(MutableClassDeclaration annotatedClass, TypeMap typeMap,
		BodySetter bodySetter, extension TransformationContext context) {

		// check that factory method is called for object construction
		if (!annotatedClass.isTraitClass && annotatedClass.getFactoryMethodRuleInfo(null, context) !== null) {

			// only need once in root class for factory method rule, so parent must not have factory method rule declared
			if ((annotatedClass.extendedClass?.type as ClassDeclaration)?.getFactoryMethodRuleInfo(null, context) ===
				null) {

				// process existing constructors (do not extend constructors that already start with a dummy parameter)
				for (constructor : annotatedClass.declaredConstructors.filter [
					it.parameters.size() == 0 ||
						!it.parameters.get(0).simpleName.startsWith(IConstructorParamDummy.DUMMY_VARIABLE_NAME_PREFIX)
				])
					constructor.addAdditionalBodyToConstructor(
				    	'''assert org.eclipse.xtend.lib.annotation.etai.FactoryMethodRuleProcessor.checkObjectConstructionViaFactory(this) : org.eclipse.xtend.lib.annotation.etai.FactoryMethodRuleProcessor.CHECK_OBJECT_CONSTRUCTION_ERROR;
					''', FactoryCallCheckerDelegationConstructor, IConstructorParamDummyCheckFactoryCall,
						IConstructorParamDummyCheckFactoryCall.DUMMY_VARIABLE_NAME, bodySetter, typeMap, context)

			}

		}

		// check that annotation is used consistently (only necessary in root)
		if (annotatedClass.isApplyRulesRoot) {

			// process existing constructors (do not extend constructors that already start with a dummy parameter)
			for (constructor : annotatedClass.declaredConstructors.filter [
				it.parameters.size() == 0 ||
					!it.parameters.get(0).simpleName.startsWith(IConstructorParamDummy.DUMMY_VARIABLE_NAME_PREFIX)
			])
				constructor.addAdditionalBodyToConstructor(
					'''assert this.getClass().getAnnotation(org.eclipse.xtend.lib.annotation.etai.ApplyRules.class) != null : String.format(org.eclipse.xtend.lib.annotation.etai.ApplyRulesProcessor.AUTO_RULE_ADAPTION_MISSING_ERROR, this.getClass().getCanonicalName());
				''', ApplyRulesCheckerDelegationConstructor, IConstructorParamDummyCheckApplyRules,
					IConstructorParamDummyCheckApplyRules.DUMMY_VARIABLE_NAME, bodySetter, typeMap, context)

		}

	}

	override void doValidate(ClassDeclaration annotatedClass, extension ValidationContext context) {

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
