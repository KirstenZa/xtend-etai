package org.eclipse.xtend.lib.annotation.etai

import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.IConstructorParamDummyCheckInit
import org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.TypeMatchingStrategy
import org.eclipse.xtend.lib.annotation.etai.utils.StringUtils
import org.eclipse.xtend.lib.annotation.etai.utils.TypeMap
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.ArrayList
import java.util.HashMap
import java.util.HashSet
import java.util.List
import java.util.Set
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.Type
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.file.FileLocations
import org.eclipse.xtend.lib.macro.services.TypeLookup
import org.eclipse.xtend.lib.macro.services.TypeReferenceProvider

import static org.eclipse.xtend.lib.annotation.etai.utils.TypeMap.*

import static extension org.eclipse.xtend.lib.annotation.etai.ApplyRulesProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ConstructRuleDisableProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ConstructRuleProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.EnvelopeMethodProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ExclusiveMethodProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.TraitClassProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.TraitMethodRedirectionProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ExtractInterfaceProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ProcessedMethodProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.RequiredMethodProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*

/**
 * <p>Extends class by the specified trait classes ({@link TraitClass}).</p>
 * 
 * <p>In this context extending a class means that trait methods from the trait class
 * are automatically implemented in the extended class (for example, in case of an
 * {@link ExclusiveMethod}).</p>
 * 
 * <p>In addition to trait classes explicitly specified by this annotation, also other
 * trait classes, which are "used" by applied trait classes, will extend the 
 * annotated class.</p>
 * 
 * <p>If a trait method already exists in the extended class, it is even
 * possible that the trait method extends the existing functionality depending
 * on the type of the trait method.</p>
 * 
 * <p>The specified trait classes must use the {@link TraitClass} annotation.</p>
 * 
 * @see ExtendedByAuto
 * @see TraitClass
 * @see ExclusiveMethod
 * @see ProcessedMethod
 * @see EnvelopeMethod
 * @see RequiredMethod
 * @see ConstructorMethod
 */
@Target(ElementType.TYPE)
@Active(ExtendedByProcessor)
annotation ExtendedBy {

	/**
	 * <p>The list of trait classes ({@link TraitClass}), which shall be applied.</p>
	 * 
	 * <p>The (extracted) mirror interfaces of the trait classes specified here must also
	 * be added to the list of implemented interfaces of the annotated class.</p>
	 * 
	 * <p>The order of extension is exactly how the trait classes are listed in the list of corresponding
	 * interfaces (implements). This might be important, if multiple trait classes contain the same trait
	 * methods ({@link ProcessedMethod}).</p>
	 * 
	 * @see TraitClass
	 */
	Class<?> [] value = #[]

}

/**
 * <p>This annotation works like {@link ExtendedBy}.</p>
 * 
 * <p>However, trait classes {@link TraitClass} which shall be applied are found automatically by
 * analyzing the list of implemented interfaces. If a given interface
 * is the (extracted) mirror interface of a trait class,
 * this trait class will be applied.</p> 
 * 
 * <p>The order of extension is exactly how the list of interfaces is declared. This might be
 * important, if multiple trait classes contain the same trait methods
 * ({@link ProcessedMethod}).</p>
 * 
 * @see ExtendedBy
 */
@Target(ElementType.TYPE)
@Active(ExtendedByAutoProcessor)
annotation ExtendedByAuto {
}

/**
 * Annotation for an extended method, which is specified within the
 * trait class and therefore is renamed. It will get the body
 * of any previous method before applying a trait class.
 */
@Target(ElementType.METHOD)
annotation ExtendedMethodImpl {
}

/**
 * This annotation is put onto methods within extended classes,
 * which have been generated for delegation purpose.
 */
@Target(ElementType.METHOD)
annotation ExtendedDelegationMethod {
}

/**
 * This annotation is put onto methods within extended classes,
 * which have been generated for constructing a trait class
 * object (with constructor method). Usually, when implementing
 * an constructor, a call to this method is expected.
 * 
 * @see ConstructorMethod
 */
@Target(ElementType.METHOD)
annotation ExtendedConstructionHelperMethod {
}

/**
 * This annotation is put onto constructors within extended classes,
 * which have been generated for delegation purpose. Thereby, the main purpose
 * of delegation is to include a check procedure.
 */
@Target(ElementType.CONSTRUCTOR)
annotation ExtendedCheckerMethodDelegationConstructor {
}

/**
 * Active Annotation Processor for {@link ExtendedBy} and {@link ExtendedByAuto}
 * 
 * @see ExtendedBy
 */
class ExtendedByProcessor extends AbstractClassProcessor implements QueuedTransformationParticipant<MutableClassDeclaration> {

	// this flag can be set in order to avoid processing of EPDefault and EPOverride (optimization)
	final static public boolean ENABLE_PROCESSOR_SHORTCUT = true

	final static public String TRAIT_OBJECT_NOT_CONSTRUCTED_ERROR = "Trait object of type \"%s\" has not been constructed via construction helper call"
	final static public String TRAIT_OBJECT_ALREADY_CONSTRUCTED_ERROR = "Trait object of type \"%s\" has already been constructed"

	final static public String DELEGATION_OBJECT_NAME_PREFIX = "delegate$"
	final static public String TRAIT_CLASS_CONSTRUCTOR_CALL_NAME_AUTO_PREFIX = "auto$new$"
	final static public String TRAIT_CLASS_CONSTRUCTOR_CALL_NAME_PREFIX = "new$"
	final static public String EXTENDED_METHOD_IMPL_NAME_SEPARATOR = "__$beforeExtended$__"

	final static public Set<ClassDeclaration> EXTENDED_CLASS_TO_BE_PROCESSED = new HashSet<ClassDeclaration>

	/**
	 * Predicate for a flexible type comparison, which considers two types as equal, if they have a common super type (trait class).
	 */
	static public (TypeLookup, Type, Type)=>Boolean flexibleTypeComparisonCommonSupertype = [
		getFirstCommonSuperClass($1 as ClassDeclaration, $2 as ClassDeclaration).isTraitClass
	]

	/** 
	 * This helper class considers another (simple) name for an existing method declaration 
	 */
	static class MethodDeclarationRenamed implements MethodDeclaration {

		MethodDeclaration originalMethodDeclaration
		String newSimpleName
		Visibility newVisibility

		new(MethodDeclaration originalMethodDeclaration, String newSimpleName, Visibility newVisibility) {
			this.originalMethodDeclaration = originalMethodDeclaration
			this.newSimpleName = newSimpleName
			this.newVisibility = newVisibility
		}

		override getReturnType() { return originalMethodDeclaration.returnType }

		override isAbstract() { return originalMethodDeclaration.abstract }

		override isDefault() { return originalMethodDeclaration.isDefault }

		override isFinal() { return originalMethodDeclaration.isFinal }

		override isNative() { return originalMethodDeclaration.isNative }

		override isStatic() { return originalMethodDeclaration.isStatic }

		override isStrictFloatingPoint() { return originalMethodDeclaration.isStrictFloatingPoint }

		override isSynchronized() { return originalMethodDeclaration.isSynchronized }

		override getBody() { return originalMethodDeclaration.getBody }

		override getExceptions() { return originalMethodDeclaration.getExceptions }

		override getParameters() { return originalMethodDeclaration.getParameters }

		override isVarArgs() { return originalMethodDeclaration.isVarArgs }

		override getTypeParameters() { return originalMethodDeclaration.getTypeParameters }

		override getDeclaringType() { return originalMethodDeclaration.getDeclaringType }

		override getDocComment() { return originalMethodDeclaration.getDocComment }

		override getModifiers() { return originalMethodDeclaration.getModifiers }

		override getVisibility() { return newVisibility }

		override isDeprecated() { return originalMethodDeclaration.isDeprecated }

		override findAnnotation(Type annotationType) { return originalMethodDeclaration.findAnnotation(annotationType) }

		override getAnnotations() { return originalMethodDeclaration.getAnnotations }

		override getCompilationUnit() { return originalMethodDeclaration.getCompilationUnit }

		override getSimpleName() { return newSimpleName }

		override toString() { return originalMethodDeclaration.toString }

	}

	protected override Class<?> getProcessedAnnotationType() {
		ExtendedBy
	}

	/**
	 * Returns name of the delegate for the given trait class.
	 */
	static def String getDelegateObjectName(ClassDeclaration traitClass) {
		DELEGATION_OBJECT_NAME_PREFIX + traitClass.simpleName
	}

	/**
	 * Returns name of the construction helper method for the given trait class.
	 */
	static def String getConstructorMethodCallName(ClassDeclaration traitClass, boolean autoConstruct) {
		(if(autoConstruct) TRAIT_CLASS_CONSTRUCTOR_CALL_NAME_AUTO_PREFIX else TRAIT_CLASS_CONSTRUCTOR_CALL_NAME_PREFIX) +
			traitClass.simpleName
	}

	/**
	 * Returns the alternative method name for traits mechanisms.
	 * 
	 * Thereby, the trait class which causes the move to this function must be provided in addition
	 * as its name will become part of the method name.
	 */
	static def getExtendedMethodImplName(MethodDeclaration methodDeclaration, ClassDeclaration traitClass) {
		methodDeclaration.simpleName + EXTENDED_METHOD_IMPL_NAME_SEPARATOR + traitClass.simpleName
	}

	/**
	 * Check if class is an extended class (i.e. it directly applies traits).
	 */
	static def boolean isExtendedClass(ClassDeclaration annotatedClass) {
		annotatedClass.hasAnnotation(ExtendedBy) || annotatedClass.isExtendedClassAuto
	}

	/**
	 * Returns true, if the class is annotated by {@link ExtendedByAuto}.
	 * 
	 * @see ExtendedByAuto
	 */
	static def boolean isExtendedClassAuto(ClassDeclaration annotatedClass) {
		return annotatedClass.hasAnnotation(ExtendedByAuto)
	}

	/**
	 * Returns <code>true</code>, if the extended class is still unprocessed.
	 * If it returns <code>true</code>, the type hierarchy is not complete, so type checks must be
	 * processed specifically. 
	 */
	static def boolean isUnprocessedExtendedClass(String annotatedClass) {

		if (EXTENDED_CLASS_TO_BE_PROCESSED.contains(annotatedClass))
			return true

		return false

	}

	/** 
	 * Adds type references (of trait classes) to list, if corresponding mirror interfaces are found for
	 * the annotated class specification.
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> void addTraitClassesOfMirrorInterfaces(
		ClassDeclaration annotatedClass, List<String> errors, List<TypeReference> typeReferences,
		List<String> specifiedTraitClassesNames, extension T context) {

		try {
			// add type references based on used interfaces
			for (implementedInterface : annotatedClass.implementedInterfaces) {

				val traitClass = (implementedInterface.type as InterfaceDeclaration).getTraitClassForMirrorInterface()
				if (traitClass !== null) {

					// do not include self
					if (traitClass.qualifiedName != annotatedClass.qualifiedName) {

						// check that class is not already contained
						if (!typeReferences.typeReferenceListContains(traitClass)) {

							// do not add, if not in list of explicitly specified trait classes
							if (specifiedTraitClassesNames === null ||
								specifiedTraitClassesNames.contains(traitClass.qualifiedName)) {

								// add type reference (to trait class)
								typeReferences.add(
									traitClass.newTypeReference(implementedInterface.actualTypeArguments))

								// ensure that name is removed from list of specified trait classes
								if (specifiedTraitClassesNames !== null) {

									// put error, if the ordering is inconsistent
									if (specifiedTraitClassesNames.indexOf(traitClass.qualifiedName) != 0)
										errors?.
											add('''Specification of trait classes is not in the same order as in the list of implemented interfaces''')

									specifiedTraitClassesNames.remove(traitClass.qualifiedName)

								}

							}

						}

					}

				}

			}

		} catch (Exception ex) {

			errors?.add('''Cannot add trait classes to mirror interface because of exception:
			    «StringUtils.getStackTrace(ex)»''')

		}

	}

	/** 
	 * <p>Retrieves the trait classes specified for the given (extended) class.</p>
	 * 
	 * <p>A trait classes is specified by putting its interface to the list of implemented
	 * interfaces (<code>implements</code>).</p>
	 * 
	 * <p>If the <code>includeIndirect</code> flag is <code>true</code>, all trait classes which are applied
	 * to these trait classes will also be included (recursively), i.e. all indirectly applied trait classes.
	 * If an (empty) array is passed as <code>infoIndirect</code>, it will be filled with <code>true</code> or
	 * <code>false</code> according to whether the trait class is applied directly or indirectly.</p>
	 * 
	 * <p>If duplicates shall be removed, {@link ProcessUtils#unifyTypeReferences} must be called afterwards.</p>
	 * 
	 * @see TraitClassProcessor#getTraitClassesUsedByTraitClassClosure
	 * @see ProcessUtils#unifyTypeReferences
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> List<TypeReference> getTraitClassesSpecifiedForExtended(
		ClassDeclaration annotatedClass,
		List<String> errors,
		boolean includeIndirect,
		List<Boolean> infoIndirect,
		extension T context
	) {

		if (annotatedClass === null || !annotatedClass.isExtendedClass)
			return new ArrayList<TypeReference>

		val List<TypeReference> typeReferences = new ArrayList<TypeReference>()

		// retrieve explicitly specified trait classes
		var List<String> specifiedTraitClassesNames = null
		if (!annotatedClass.isExtendedClassAuto) {

			specifiedTraitClassesNames = new ArrayList<String>

			val specifiedTraitClasses = annotatedClass.getAnnotation(ExtendedBy).getClassArrayValue("value")

			if (specifiedTraitClasses !== null) {

				// add names of trait classes
				for (specifiedTraitClass : specifiedTraitClasses) {

					if (specifiedTraitClass.type instanceof ClassDeclaration &&
						(specifiedTraitClass.type as ClassDeclaration).isTraitClass)
						specifiedTraitClassesNames.add(specifiedTraitClass.name)
					else
						errors?.
							add('''Type "«specifiedTraitClass.name»" is not a trait class, i.e. it does not use @TraitClass or @TraitClassAutoUsing''')

				}

			}

		}

		// add type references based on used interfaces
		addTraitClassesOfMirrorInterfaces(annotatedClass, errors, typeReferences, specifiedTraitClassesNames, context)

		// report error, if there are specified trait classes, which are not specified as implemented interface
		if (errors !== null && specifiedTraitClassesNames !== null)
			if (specifiedTraitClassesNames.size > 0)
				errors?.
					add('''Trait class "«specifiedTraitClassesNames.get(0)»" specified, but not found in list of implemented interfaces''')

		// add indirectly applied trait classes (i.e. trait classes, which are implemented by directly applied trait classes)
		if (includeIndirect) {

			// add missing use info
			if (infoIndirect !== null)
				for (typeReference : typeReferences)
					infoIndirect.add(false)

			// add type references to result (including use info)
			val typeReferencesLength = typeReferences.length
			for (typeReferenceIndex : 0 ..< typeReferencesLength) {

				val typeReference = typeReferences.get(typeReferenceIndex)

				if (typeReference.type instanceof ClassDeclaration) {

					val indirectTraitClasses = (typeReference.type as ClassDeclaration).
						getTraitClassesUsedByTraitClassClosure(errors, context)
					for (indirectTraitClass : indirectTraitClasses) {
						typeReferences.add(indirectTraitClass)
						if (infoIndirect !== null)
							infoIndirect.add(true)
					}

				}

			}

		}

		return typeReferences

	}

	/** 
	 * <p>Retrieves the trait classes specified for the given (extended) class and parent classes.</p>
	 * 
	 * <p>If duplicates shall be removed, {@link ProcessUtils#unifyTypeReferences} must be called afterwards.</p>
	 * 
	 * @see #getTraitClassesSpecifiedForExtended
	 * @see ProcessUtils#unifyTypeReferences
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> List<TypeReference> getTraitClassesSpecifiedForExtendedClosure(
		ClassDeclaration annotatedClass,
		List<String> errors,
		extension T context
	) {

		val result = new ArrayList<TypeReference>
		for (currentClass : annotatedClass.getSuperClasses(true))
			result += currentClass.getTraitClassesSpecifiedForExtended(errors, true, null, context)
		return result

	}

	/** 
	 * <p>Retrieves the trait classes which must be applied to the given class, including all directly or
	 * indirectly specified trait classes, but without the trait classes, which have already been applied
	 * to the parent.</p>
	 * 
	 * <p>The result is unified, so duplicates are removed.</p>
	 * 
	 * @see #getTraitClassesSpecifiedForExtended
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> List<TypeReference> getTraitClassesAppliedToExtended(
		ClassDeclaration annotatedClass, List<String> errors, extension T context) {

		val result = new ArrayList<TypeReference>
		val resultIsAppliedDirectly = new ArrayList<Boolean>

		// retrieve type references
		val traitClassRefsInfoIndirect = new ArrayList<Boolean>
		val traitClassRefs = annotatedClass.getTraitClassesSpecifiedForExtended(errors, true,
			traitClassRefsInfoIndirect, context)

		if (traitClassRefs === null)
			return result

		// compute relevant extensions, i.e., trait classes which have not been applied, yet
		val alreadyAppliedTraitClasses = (annotatedClass.extendedClass?.type as ClassDeclaration)?.
			getTraitClassesSpecifiedForExtendedClosure(null, context)

		// go through trait classes and check validity
		val traitClassRefLength = traitClassRefs.length
		for (traitClassRefIndex : 0 ..< traitClassRefLength) {

			val traitClassRef = traitClassRefs.get(traitClassRefIndex)
			val traitClassRefIsAppliedDirectly = traitClassRefsInfoIndirect.get(traitClassRefIndex) == false

			// check if type reference has already been applied to parent
			val indexOfTypeReferenceInAlreadyAppliedList = if (alreadyAppliedTraitClasses === null)
					-1
				else
					alreadyAppliedTraitClasses.indexOfTypeReference(traitClassRef,
						flexibleTypeComparisonCommonSupertype.curry(context), false, null)

			// it is not necessary to check type arguments
			// this is covered by Java interface restrictions
			if (indexOfTypeReferenceInAlreadyAppliedList != -1) {

				if (errors !== null) {

					val typeReferenceAlreadyApplied = alreadyAppliedTraitClasses.get(
						indexOfTypeReferenceInAlreadyAppliedList)
					val classAlreadyApplied = typeReferenceAlreadyApplied.type as ClassDeclaration

					// it is an error, if trait class shall be applied directly
					if (traitClassRefIsAppliedDirectly)
						errors?.
							add('''Cannot apply the trait class "«traitClassRef.type.qualifiedName»", because a type related to this trait class ("«classAlreadyApplied.qualifiedName»") has already been applied to a super type''')
					// otherwise (indirect trait class shall be applied) it is an error, if it is not a super type of an already applied trait class (so it is a more concrete or otherwise related type)
					else if (!traitClassRef.type.isAssignableFromConsiderUnprocessed(typeReferenceAlreadyApplied.type,
						context))
						errors?.
							add('''Cannot apply the (indirectly applied) trait class "«traitClassRef.type.qualifiedName»", because a type related to this trait class ("«classAlreadyApplied.qualifiedName»"), which is not a derived from it, has already been applied to a super type of this class''')

				}

			} else {

				// check if type reference is already in result list
				val indexOfTypeReferenceInResult = result.indexOfTypeReference(traitClassRef,
					flexibleTypeComparisonCommonSupertype.curry(context), false, null)

				if (indexOfTypeReferenceInResult == -1) {

					// add new trait classes to result list 
					result += traitClassRef
					resultIsAppliedDirectly += traitClassRefIsAppliedDirectly

				} else {

					val foundTypeReference = result.get(indexOfTypeReferenceInResult)
					val foundTypeReferenceIsAppliedDirectly = resultIsAppliedDirectly.get(indexOfTypeReferenceInResult)

					if (traitClassRefIsAppliedDirectly) {

						if (foundTypeReferenceIsAppliedDirectly) {

							// it is an error, if two inconsistent trait classes shall be applied directly
							errors?.
								add('''Cannot apply the trait class "«traitClassRef.type.qualifiedName»", because a type related to this trait class ("«foundTypeReference.type.qualifiedName»") has already been applied''')

						} else {

							// it is not an error, if indirectly applied trait classes are more abstract than directly applied trait classes...
							if (foundTypeReference.type.
								isAssignableFromConsiderUnprocessed(traitClassRef.type, context)) {

								// the more concrete type shall be used then
								result.remove(indexOfTypeReferenceInResult)
								resultIsAppliedDirectly.remove(indexOfTypeReferenceInResult)
								result.add(indexOfTypeReferenceInResult, traitClassRef)
								resultIsAppliedDirectly.add(indexOfTypeReferenceInResult,
									traitClassRefIsAppliedDirectly)

							} else {

								// otherwise, it is an error
								errors?.
									add('''Cannot apply the trait class "«traitClassRef.type.qualifiedName»", because a type related to this trait class ("«foundTypeReference.type.qualifiedName»") has already been applied indirectly''')

							}
						}

					} else {

						if (foundTypeReferenceIsAppliedDirectly) {

							// it is an error, if the indirectly applied trait class is not equal or more abstract than the directly applied trait class
							if (!traitClassRef.type.
								isAssignableFromConsiderUnprocessed(foundTypeReference.type, context))
								errors?.
									add('''Cannot apply the (indirectly applied) trait class "«traitClassRef.type.qualifiedName»", because a type related to this trait class ("«foundTypeReference.type.qualifiedName»") has already been applied''')

						} else {

							// only further checking, if newly found, directly applied type is more abstract than indirectly applied type
							if (!traitClassRef.type.
								isAssignableFromConsiderUnprocessed(foundTypeReference.type, context)) {

								// it is an error, if it is also not a more concrete type
								if (!foundTypeReference.type.isAssignableFromConsiderUnprocessed(traitClassRef.type,
									context))
									errors?.
										add('''Cannot apply the (indirectly applied) trait class "«traitClassRef.type.qualifiedName»", because a type related to this trait class ("«foundTypeReference.type.qualifiedName»") has already been applied indirectly''')
								else {

									// otherwise, the more concrete type shall be used
									result.remove(indexOfTypeReferenceInResult)
									resultIsAppliedDirectly.remove(indexOfTypeReferenceInResult)
									result.add(indexOfTypeReferenceInResult, traitClassRef)
									resultIsAppliedDirectly.add(indexOfTypeReferenceInResult,
										traitClassRefIsAppliedDirectly)

								}

							}

						}

					}

				}

			}

		}

		return result

	}

	/**
	 * Retrieves the trait classes which shall be be constructed automatically (and for which this
	 * feature is not disabled) inside the factory method of the given class.
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> Iterable<ClassDeclaration> getTraitClassesAutoConstructEnabled(
		ClassDeclaration annotatedClass, extension T context) {

		val traitClassesAutoConstruct = annotatedClass.getTraitClassesAutoConstruct(true, context)
		val traitClassesAutoConstructDisabled = annotatedClass.getTraitClassesAutoConstructDisabled(true, context)
		return traitClassesAutoConstruct.filter[!traitClassesAutoConstructDisabled.contains(it)]

	}

	/** 
	 * <p>Search and return existing method in annotated class, which shall be extended.</p>
	 * 
	 * <p>If no method has been found, the return value is null.</p>
	 * 
	 * <p>The method from the trait class must be passed via list (which has exactly the
	 * method as element). The passed method might be altered (a name wrapper could be applied)
	 * because of trait method redirection. Therefore, the calling method must analyze the
	 * list after the call and use the method inside later on as trait method.</p>
	 */
	static private def MethodDeclaration getExistingMethodForExtension(List<MethodDeclaration> methodClosureCache,
		MutableClassDeclaration annotatedClass, List<MethodDeclaration> traitClassMethodInList,
		boolean enableRedirection, TypeMap typeMap, extension TransformationContext context) {

		var MethodDeclaration methodDeclarationToAnalyze = traitClassMethodInList.get(0)
		var MethodDeclaration foundMethod

		val recursionProtection = new HashSet<String>

		do {

			foundMethod = methodClosureCache.getMatchingMethod(
				methodDeclarationToAnalyze,
				TypeMatchingStrategy.MATCH_COVARIANT,
				typeMap,
				context
			)

			if (foundMethod !== null) {

				// retrieve name of method redirecting to
				val extensionRedirectionInfo = foundMethod.getTraitMethodRedirectionInfo(context)

				// do not follow redirection in case of cycles
				if (!recursionProtection.add(extensionRedirectionInfo.redirectedMethodName)) {

					annotatedClass.
						addError('''Trait method redirection cycle detected (method: "«extensionRedirectionInfo.redirectedMethodName»")''')

					return foundMethod

				}

				// return method, if either not redirected or found in annotated class already (will not follow encapsulation then, i.e. extension is directly applied)
				if (!enableRedirection || extensionRedirectionInfo.redirectedMethodName.nullOrEmpty) {

					// method found (not redirected from any method)
					return foundMethod

				} else {

					// continue search for method with another name (redirection)
					methodDeclarationToAnalyze = new MethodDeclarationRenamed(methodDeclarationToAnalyze,
						extensionRedirectionInfo.redirectedMethodName, extensionRedirectionInfo.redirectedVisibility)

					// always return last analyzed method
					traitClassMethodInList.set(0, methodDeclarationToAnalyze)

				}

			}

		} while (foundMethod !== null)

		return null

	}

	override doRegisterGlobals(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {

		super.doRegisterGlobals(annotatedClass, context)

		// track if class has already been processed, i.e. the type hierarchy has been set correctly
		EXTENDED_CLASS_TO_BE_PROCESSED.add(annotatedClass)

		// start processing of this element
		ProcessQueue.startTrack(ProcessQueue.PHASE_EXTENDED_BY, annotatedClass, annotatedClass.qualifiedName)

	}

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {

		super.doTransform(annotatedClass, context)

		// queue processing
		ProcessQueue.processTransformation(ProcessQueue.PHASE_EXTENDED_BY, this, annotatedClass,
			annotatedClass.qualifiedName, context)

	}

	override boolean doTransformQueued(int phase, MutableClassDeclaration annotatedClass, BodySetter bodySetter,
		extension TransformationContext context) {

		// postpone transformation, if supertype must still be processed
		for (superType : annotatedClass.getSuperClasses(false)) {

			if (superType.hasAnnotation(ApplyRules) &&
				ProcessQueue.isTrackedTransformation(ProcessQueue.PHASE_EXTENDED_BY, annotatedClass.compilationUnit,
					superType.qualifiedName))
				return false

		}

		try {

			doTransformQueuedExtended(phase, annotatedClass, bodySetter, context)

		} finally {

			// stop tracking (hierarchy is complete now)
			EXTENDED_CLASS_TO_BE_PROCESSED.remove(annotatedClass)

		}

		return true

	}

	def void doTransformQueuedExtended(int phase, MutableClassDeclaration annotatedClass, BodySetter bodySetter,
		extension TransformationContext context) {

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// retrieve type references (errors will be reported during the validation step)
		val traitClassRefs = annotatedClass.getTraitClassesAppliedToExtended(null, context)

		// create type map from type hierarchy
		val typeMap = new TypeMap
		fillTypeMapFromTypeHierarchy(annotatedClass, typeMap, context)

		// process basics for trait classes
		val traitClasses = new ArrayList<ClassDeclaration>
		for (traitClassRef : traitClassRefs) {

			// add trait class for processing
			val traitClass = (traitClassRef?.type as ClassDeclaration)
			traitClasses.add(traitClass)

			// create field for delegation object
			annotatedClass.addField(traitClass.delegateObjectName) [

				static = false
				visibility = Visibility.PRIVATE
				type = traitClassRef.type.newTypeReference(traitClassRef.actualTypeArguments.map [
					copyTypeReference(it, typeMap, context)
				])

				if (traitClass.hasNonEmptyConstructorMethod(context)) {
					initializer = '''null'''
				} else {
					initializer = '''new «traitClass.qualifiedName»(this«IF !traitClass.hasConstructorMethod(context)», (org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.IConstructorParamDummySetExtendedThis) null«ENDIF»)'''

					final = true
				}

				docComment = '''This is the delegation object for the functionality of trait class «traitClass.getJavaDocLinkTo(context)»'''

			]

			// cache method closure (of non-abstract and implemented methods)
			val methodClosureCache = annotatedClass.getMethodClosure(null, [
				false
			], true, context).unifyMethodDeclarations(TypeMatchingStrategy.MATCH_COVARIANT, null, typeMap, context)

			// do specific transformations for each relevant trait method
			val traitClassMethods = traitClass.getTraitMethodsToApply(typeMap, context)
			for (traitClassMethod : traitClassMethods)
				doTransformForTraitClassMethod(annotatedClass, traitClass, traitClassMethod, methodClosureCache,
					typeMap, bodySetter, context)

		}

		// retrieve trait classes, which need construction in general
		val currentTraitClassesNeedingConstruction = traitClasses.filter [
			it.hasNonEmptyConstructorMethod(context)
		]

		// retrieve trait classes, which shall be constructed manually (locally) and automatically (all)
		val allTraitClassesWithAutoConstruction = annotatedClass.getTraitClassesAutoConstruct(true, context)
		val currentTraitClassesManualConstruction = currentTraitClassesNeedingConstruction.filter [
			!allTraitClassesWithAutoConstruction.contains(it)
		]

		// create construction helper methods for all trait classes, which need construction
		for (traitClass : currentTraitClassesNeedingConstruction) {

			// go through all constructor methods of trait class
			for (constructorMethod : traitClass.getConstructorMethods(context)) {

				val isAutoConstructed = allTraitClassesWithAutoConstruction.contains(traitClass)

				// create method for creating delegate object
				val methodName = traitClass.getConstructorMethodCallName(isAutoConstructed)
				val constructionHelperMethod = annotatedClass.addMethod(methodName) [
					visibility = Visibility.PROTECTED

					abstract = false
					returnType = primitiveVoid
				]

				// documentation
				constructionHelperMethod.docComment = '''<p>Method for constructing the delegation object for trait class «traitClass.getJavaDocLinkTo(context)».</p>
							«IF isAutoConstructed»<p>If auto construction is not disabled in a subclass, it will be called automatically during construction via factory method.«ELSE»It must be called in the constructor of the extended class.</p>«ENDIF»'''

				// specify annotation
				constructionHelperMethod.addAnnotation(ExtendedConstructionHelperMethod.newAnnotationReference)

				// add parameters
				val paramNameList = constructorMethod.parametersNames
				constructorMethod.copyParameters(constructionHelperMethod, 0, typeMap, context)

				// call constructor and set delegation object of extended object
				bodySetter.setBody(
					constructionHelperMethod, '''assert «traitClass.delegateObjectName» == null : String.format(org.eclipse.xtend.lib.annotation.etai.ExtendedByProcessor.TRAIT_OBJECT_ALREADY_CONSTRUCTED_ERROR, "«traitClass.qualifiedName»");
							this.«traitClass.delegateObjectName» = new «traitClass.qualifiedName»(this«IF (paramNameList.size > 0)», «ENDIF»«paramNameList.join(", ")»);''')

			}

		}

		// collect trait classes for which (manual) construction of trait class delegation object must be checked.
		val currentTraitClassesCheckConstruction = new ArrayList<ClassDeclaration>
		currentTraitClassesCheckConstruction.addAll(currentTraitClassesManualConstruction)
		currentTraitClassesCheckConstruction.addAll(annotatedClass.getTraitClassesAutoConstructDisabled(false, context))

		// wrap constructors and check if trait class delegation object have been created manually
		// (this doesn't work for disabled auto-construction, i.e., according construction must be checked in factory method)
		if (!currentTraitClassesManualConstruction.empty) {

			if ((annotatedClass.primarySourceElement as ClassDeclaration).declaredConstructors.size == 0) {
				xtendClass.addError(
					'''This class must create constructors in order to construct delegation objects for trait classes: «currentTraitClassesManualConstruction.map[it.simpleName].join(", ")»''')
				return
			}

			// wrap constructors in order to check for construction
			for (constructor : annotatedClass.declaredConstructors) {

				// create the code which is needed to check for the construction of the trait classes delegation objects
				var String constructorCheckBody = ""
				for (traitClass : currentTraitClassesManualConstruction)
					constructorCheckBody +=
						'''assert «traitClass.delegateObjectName» != null : String.format(org.eclipse.xtend.lib.annotation.etai.ExtendedByProcessor.TRAIT_OBJECT_NOT_CONSTRUCTED_ERROR, "«traitClass.qualifiedName»");
						'''

				// add body to constructor
				constructor.addAdditionalBodyToConstructor(constructorCheckBody,
					ExtendedCheckerMethodDelegationConstructor, IConstructorParamDummyCheckInit,
					IConstructorParamDummyCheckInit.DUMMY_VARIABLE_NAME, bodySetter, typeMap, context)

			}

		}

	}

	def doTransformForTraitClassMethod(MutableClassDeclaration annotatedClass, ClassDeclaration traitClass,
		MethodDeclaration traitClassMethod, List<MethodDeclaration> methodClosureCache, TypeMap typeMap,
		BodySetter bodySetter, extension TransformationContext context) {

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// retrieve information from annotation
		var TypeDeclaration processor = null
		var boolean isRequired = false
		var boolean setFinal = false
		var boolean disableRedirection = false
		if (traitClassMethod.isExclusiveMethod) {
			val info = traitClassMethod.getExclusiveMethodInfo(context)
			setFinal = info.setFinal
			disableRedirection = info.disableRedirection
		} else if (traitClassMethod.isProcessedMethod) {
			val info = traitClassMethod.getProcessedMethodInfo(context)
			processor = info.processor
			isRequired = info.required
			setFinal = info.setFinal
			disableRedirection = info.disableRedirection
		} else if (traitClassMethod.isEnvelopeMethod) {
			val info = traitClassMethod.getEnvelopeMethodInfo(context)
			isRequired = info.required
			setFinal = info.setFinal
			disableRedirection = info.disableRedirection
		}

		// retrieve method, which already exists
		val traitClassMethodInList = new ArrayList<MethodDeclaration>
		traitClassMethodInList.add(traitClassMethod)
		var MethodDeclaration existingMethod = methodClosureCache.getExistingMethodForExtension(annotatedClass,
			traitClassMethodInList, !disableRedirection, typeMap, context)
		var traitClassMethodRedirected = traitClassMethodInList.get(0)
		val methodRedirected = (traitClassMethod.simpleName != traitClassMethodRedirected.simpleName)
		val autoImplementation = annotatedClass.hasAnnotation(ImplementDefault)

		// determine if this is a void method
		val isVoid = traitClassMethodRedirected.returnType === null || traitClassMethodRedirected.returnType.isVoid()

		// check if existing method is in this class
		var existingMethodInCurrentClass = existingMethod !== null && !existingMethod.abstract &&
			existingMethod.declaringType == annotatedClass
		var existingMethodOnlyInSuperClass = existingMethod !== null && !existingMethod.abstract &&
			!existingMethodInCurrentClass
		var existingAbstractMethodInCurrentClass = existingMethod !== null && existingMethod.abstract &&
			existingMethod.declaringType == annotatedClass

		// private method, which is not in current class is not considered
		if (existingMethod !== null && existingMethod.visibility == Visibility.PRIVATE && !existingMethodInCurrentClass)
			existingMethod = null

		// error if found method has incompatible modifiers or type arguments
		if (existingMethod !== null) {

			// types in existing methods must not be inferred
			if (existingMethod.returnType.inferred) {
				xtendClass.
					addError('''Cannot extend method "«traitClassMethod.getMethodAsString(false, context)»"«IF (methodRedirected)» (redirected to "«traitClassMethodRedirected.simpleName»")«ENDIF» as it has an inferred return type''')
				return
			}

			// error if found method is final, i.e. no modification is allowed
			if (existingMethod.final && !traitClassMethod.isRequiredMethod) {
				if (!existingMethodInCurrentClass) {
					xtendClass.
						addError('''Cannot extend method "«traitClassMethod.getMethodAsString(false, context)»"«IF (methodRedirected)» (redirected to "«traitClassMethodRedirected.simpleName»")«ENDIF» as it has been declared final in a superclass''')
					return
				} else if (existingMethod.hasAnnotation(ExtendedDelegationMethod)) {
					xtendClass.
						addError('''Cannot extend method "«traitClassMethod.getMethodAsString(false, context)»"«IF (methodRedirected)» (redirected to "«traitClassMethodRedirected.simpleName»")«ENDIF» by the functionality in trait class "«traitClass.simpleName»" because it has been set to final by another trait class''')
					return
				}
			}

			// error if static
			if (existingMethod.static == true) {
				if (traitClassMethod.isRequiredMethod)
					xtendClass.
						addError('''Method "«traitClassMethod.getMethodAsString(false, context)»"«IF (methodRedirected)» (redirected to "«traitClassMethodRedirected.simpleName»")«ENDIF» is required by trait class "«traitClass.simpleName»", but it is declared static''')
				else
					xtendClass.
						addError('''Cannot extend method "«traitClassMethod.getMethodAsString(false, context)»"«IF (methodRedirected)» (redirected to "«traitClassMethodRedirected.simpleName»")«ENDIF» as it is declared static''')
				return
			}

			// error if private
			if (existingMethod.visibility == Visibility.PRIVATE && existingMethodInCurrentClass) {
				if (traitClassMethod.isRequiredMethod)
					xtendClass.
						addError('''Method "«traitClassMethod.getMethodAsString(false, context)»"«IF (methodRedirected)» (redirected to "«traitClassMethodRedirected.simpleName»")«ENDIF» is required by trait class "«traitClass.simpleName»", but it is declared private''')
				else
					xtendClass.
						addError('''Cannot extend method "«traitClassMethod.getMethodAsString(false, context)»"«IF (methodRedirected)» (redirected to "«traitClassMethodRedirected.simpleName»")«ENDIF» as it is declared private''')
				return
			}

		}

		// check if method has already been implemented and no further implementation is allowed
		if (existingMethod !== null && !existingMethod.abstract) {

			// if claimed it might be an error that method exists in extended class
			if (traitClassMethodRedirected.isExclusiveMethod) {
				xtendClass.
					addError('''Trait class "«traitClass.qualifiedName»" declares method "«traitClassMethod.getMethodAsString(false, context)»"«IF (methodRedirected)» (redirected to "«traitClassMethodRedirected.simpleName»")«ENDIF» as exclusive trait method, so it must not exist in the extended class ("«annotatedClass.qualifiedName»")''')
				return
			}

		} else {

			// error if the implementation of this method inside of extended class is required
			if (isRequired && !autoImplementation)
				xtendClass.
					addError('''Trait class "«traitClass.qualifiedName»" requires method "«traitClassMethod.getMethodAsString(false, context)»"«IF (methodRedirected)» (redirected to "«traitClassMethodRedirected.simpleName»")«ENDIF» to be implemented in the extended class''')

		}

		// report error, if method is required, but not in current non-abstract class
		// (interface mechanism is not sufficient, because required methods might be declared protected)
		if (existingMethod === null && traitClassMethod.isRequiredMethod && !annotatedClass.abstract) {

			// if methods will be implemented via annotation, no further processor or error
			if (!autoImplementation) {

				xtendClass.
					addError('''Trait class "«traitClass.qualifiedName»" requires method "«traitClassMethod.getMethodAsString(false, context)»"«IF (methodRedirected)» (redirected to "«traitClassMethodRedirected.simpleName»")«ENDIF» to be implemented in the non-abstract, extended class''')

				return

			}

		}

		// if method is required and public in trait class,
		// no need to specify anything (method is part of mirror interface),
		// at least if there is no method is base class with lower visibility
		if (traitClassMethod.isRequiredMethod && traitClassMethod.visibility == Visibility.PUBLIC &&
			(existingMethod === null || existingMethod.visibility == Visibility.PUBLIC))
			return

		// determine if trait method must be called from existing method
		val existingMethodNoExtensionCall = existingMethod !== null && !existingMethod.abstract &&
			(traitClassMethod.isRequiredMethod ||
				(processor !== null && ENABLE_PROCESSOR_SHORTCUT && processor.qualifiedName == EPDefault.canonicalName)
				)

		// store meta information which must be considered as original
		val originalOverride = existingMethod !== null && existingMethod.hasAnnotation(Override)
		val originalFinal = existingMethod !== null && existingMethod.final
		val originalVisibility = existingMethod?.visibility
		val originalReturnType = existingMethod?.returnType

		// calculate final state
		val targetFinal = originalFinal || setFinal

		// calculate visibility
		var targetVisibility = if (originalVisibility === null)
				traitClassMethodRedirected.visibility
			else
				getMaximalVisibility(traitClassMethodRedirected.visibility, originalVisibility)

		// create parameter name list
		val paramNameList = traitClassMethodRedirected.parametersNames
		val paramTypeNameListJavadoc = traitClassMethodRedirected.getParametersTypeNames(true, true, context)

		if (!methodRedirected) {

			// calculate visibility: adjust to public, if found within an interface
			if (targetVisibility != Visibility.PUBLIC) {
				if (annotatedClass.getMethodClosure(null, null, false, context).filter [
					it.declaringType instanceof InterfaceDeclaration
				].getMatchingMethod(traitClassMethodRedirected, TypeMatchingStrategy.MATCH_COVARIANT, typeMap,
					context) !== null)
					targetVisibility = Visibility.PUBLIC
			}

		} else {

			// calculate visibility: adjust to public, if found within an interface
			//
			// special implementation in case of redirection, because the original method is usually not considered 
			val traitClassMethodInListTemp = new ArrayList<MethodDeclaration>
			traitClassMethodInListTemp.add(traitClassMethod)
			var MethodDeclaration existingMethodOriginal = methodClosureCache.
				getExistingMethodForExtension(annotatedClass, traitClassMethodInListTemp, false, typeMap, context)
			if (existingMethodOriginal.visibility != Visibility.PUBLIC)
				if (annotatedClass.getMethodClosure(null, null, false, context).filter [
					it.declaringType instanceof InterfaceDeclaration
				].getMatchingMethod(existingMethodOriginal, TypeMatchingStrategy.MATCH_COVARIANT, typeMap, context) !==
					null) {

					// copy original method (without redirection
					val originalMethodWrapper = annotatedClass.copyMethod(existingMethodOriginal, true, false, true,
						typeMap, context)
					originalMethodWrapper.visibility = Visibility.PUBLIC

					// just call functionality of superclass
					bodySetter.setBody(
						originalMethodWrapper, '''«IF !isVoid»return «ENDIF»«annotatedClass.qualifiedName».super.«traitClassMethod.simpleName»(«paramNameList.join(", ")»);''')

				}

		}

		// calculate target return type (covariance is considered and applied, programmer must take care)
		val targetReturnType = if (existingMethod === null) {
				traitClassMethodRedirected.returnType
			} else {
				if (traitClassMethodRedirected.returnType.
					isAssignableFromStripRefConsiderUnprocessed(existingMethod.returnType, context))
					existingMethod.returnType
				else
					traitClassMethodRedirected.returnType
			}

		// clone type map as it becomes modified locally
		val typeMapLocal = typeMap.clone

		// create new method (copy signature of trait method completely), re-use abstract method declaration or decide to exit
		var MutableMethodDeclaration delegationMethod = if (existingAbstractMethodInCurrentClass ||
				(existingMethodNoExtensionCall && existingMethodInCurrentClass))
				existingMethod as MutableMethodDeclaration
			else if (existingMethodNoExtensionCall && targetVisibility == originalVisibility &&
				targetFinal == originalFinal &&
				targetReturnType.typeReferenceEquals(originalReturnType, null, false, typeMapLocal, null))
				null
			else
				annotatedClass.copyMethod(traitClassMethodRedirected, true, true, true, typeMapLocal, context)

		if (delegationMethod === null)
			return;

		// determine, if method must be abstract or not
		if (traitClassMethodRedirected.isRequiredMethod)
			delegationMethod.abstract = if (existingMethod !== null)
				existingMethod.abstract
			else
				true
		else
			delegationMethod.abstract = false

		// set return type of delegation method as calculated
		delegationMethod.returnType = targetReturnType.copyTypeReference(typeMapLocal, context)

		// if method exists in current class, or method is in supertype (and an envelope method is needed), create implementation method
		if (!existingMethodNoExtensionCall && (existingMethodInCurrentClass ||
			(existingMethodOnlyInSuperClass && traitClassMethodRedirected.isEnvelopeMethod))) {

			// name for implementation method
			val newName = traitClassMethod.getExtendedMethodImplName(traitClass)

			// check if new name is valid
			if (methodClosureCache.exists[it.simpleName == newName]) {
				xtendClass.
					addError('''Trait method "«existingMethod.getMethodAsString(false, context)»" cannot be renamed to "«newName»" because method already exists''')
				return;
			}

			var MutableMethodDeclaration implMethod
			if (existingMethodInCurrentClass) {

				// use delegation method (which is a new method copied from the trait class or which is the abstract method existing before)
				implMethod = delegationMethod

				// documentation
				implMethod.docComment = existingMethod.docComment

				// move body from previously existing method
				bodySetter.moveBody(implMethod, existingMethod)

			} else {

				// create another method, which can then call the method in the supertype
				implMethod = annotatedClass.copyMethod(traitClassMethodRedirected, true, false, true, typeMapLocal,
					context)
				implMethod.abstract = false

				// documentation
				implMethod.docComment = '''This is a generated method for calling the supertype method {@link «(annotatedClass.extendedClass.type as ClassDeclaration).qualifiedName»#«existingMethod.simpleName»(«paramTypeNameListJavadoc.join(", ")»)}.'''

				// just call functionality of superclass
				bodySetter.setBody(
					implMethod, '''«IF !isVoid»return «ENDIF»«annotatedClass.qualifiedName».super.«existingMethod.simpleName»(«paramNameList.join(", ")»);''')

			}

			// do rename implementation method and make it private
			implMethod.simpleName = newName
			implMethod.visibility = Visibility.PRIVATE

			// specific annotations for new method
			implMethod.addAnnotation(ExtendedMethodImpl.newAnnotationReference)

			// ensure that return type from current class is used (covariance)
			val typeMapWithMethodTypeParameters = typeMapLocal.clone
			val typeParameterIteratorExisting = existingMethod.typeParameters.iterator
			val typeParameterIteratorImpl = implMethod.typeParameters.iterator
			while (typeParameterIteratorExisting.hasNext) {
				val typeParameterExisting = typeParameterIteratorExisting.next
				val typeParameterImpl = typeParameterIteratorImpl.next
				typeMapWithMethodTypeParameters.putHierarchyRelation(typeParameterExisting,
					typeParameterImpl.newTypeReference)
			}

			implMethod.returnType = existingMethod.returnType.copyTypeReference(typeMapWithMethodTypeParameters,
				context)

			// use previously existing method as "newly created method" in the following algorithm and the other way around;
			// this avoids some problems with "override" and warnings
			if (existingMethodInCurrentClass)
				delegationMethod = existingMethod as MutableMethodDeclaration

			// implemented method contains previous functionality and is now considered the existing method
			existingMethod = implMethod

		} else if (existingMethodNoExtensionCall) {

			if (existingMethodOnlyInSuperClass) {

				delegationMethod.docComment = '''This is a generated method for calling the supertype method {@link «(annotatedClass.extendedClass.type as ClassDeclaration).qualifiedName»#«existingMethod.simpleName»(«paramTypeNameListJavadoc.join(", ")»)}.'''

				bodySetter.setBody(
					delegationMethod, '''«IF !isVoid»return «ENDIF»«annotatedClass.qualifiedName».super.«existingMethod.simpleName»(«paramNameList.join(", ")»);''')

			}

		}

		// set previously calculated modifiers
		delegationMethod.visibility = targetVisibility
		delegationMethod.final = targetFinal

		// add annotations (in case of having a delegation method)
		if (!delegationMethod.abstract) {

			if (!delegationMethod.hasAnnotation(Override)) {
				if (existingMethodOnlyInSuperClass || (existingMethodInCurrentClass && originalOverride))
					delegationMethod.addAnnotation(Override.newAnnotationReference)
				else {
					if (annotatedClass.getMethodClosure(null, null, false, context).getMatchingMethod(delegationMethod,
						TypeMatchingStrategy.MATCH_COVARIANT, typeMapLocal, context) !== null)
						delegationMethod.addAnnotation(Override.newAnnotationReference)
				}

			}
			if (!delegationMethod.hasAnnotation(ExtendedDelegationMethod))
				delegationMethod.addAnnotation(ExtendedDelegationMethod.newAnnotationReference)

		}

		// stop if there is no extension to call
		if (existingMethodNoExtensionCall)
			return

		// determine generation mode
		var boolean useProcessor = processor !== null
		val boolean processorMustCallExtendedMethod = ((existingMethodInCurrentClass ||
			existingMethodOnlyInSuperClass) || (isRequired && autoImplementation))

		// short-circuit (performance): if method exists in trait class, only use this method and skip the rest
		var boolean enableProcessorShortcut = ENABLE_PROCESSOR_SHORTCUT
		if (enableProcessorShortcut && useProcessor && processor.qualifiedName == EPOverride.canonicalName)
			useProcessor = false

		// use functionality of trait class only in according cases
		if (!useProcessor) {

			// documentation
			delegationMethod.docComment = traitClassMethod.docComment

			// set body (simply call trait class functionality)
			val delegationMethodFinal = delegationMethod
			bodySetter.setBody(
				delegationMethod, '''«IF !isVoid»return («delegationMethodFinal.returnType.getTypeReferenceAsString(true, false, false, context)») «ENDIF»«traitClass.delegateObjectName».«traitClassMethod.getTraitMethodImplName»(«paramNameList.join(", ")»);''')

			return;

		}

		// lazy evaluation of functionality in trait class
		var String methodBody = '''org.eclipse.xtend.lib.annotation.etai.LazyEvaluation lazyValueExtension = new org.eclipse.xtend.lib.annotation.etai.LazyEvaluation() {
					public Object eval() {
						«IF !isVoid»return «ENDIF»«traitClass.delegateObjectName».«traitClassMethod.getTraitMethodImplName»(«paramNameList.join(", ")»);
						«IF isVoid»return null;«ENDIF»
					}
				};'''

		// call super method, if implementation is not in this class
		var String existingMethodCall
		if (existingMethodInCurrentClass) {

			existingMethodCall = existingMethod.simpleName

		} else {

			if (existingMethodOnlyInSuperClass)
				existingMethodCall = annotatedClass.qualifiedName + ".super." + existingMethod.simpleName
			else
				existingMethodCall = delegationMethod.getExtendedMethodImplName(traitClass)

		}

		// lazy evaluation of functionality in extended class
		if (processorMustCallExtendedMethod)
			methodBody += "\n" + '''org.eclipse.xtend.lib.annotation.etai.LazyEvaluation lazyValueExtended = new org.eclipse.xtend.lib.annotation.etai.LazyEvaluation() {
					public Object eval() {
						«IF !isVoid»return «ENDIF»«existingMethodCall»(«paramNameList.join(", ")»);
						«IF isVoid»return null;«ENDIF»
					}
				};'''

		// trait method processor call
		val processorCall = '''resultTraitMethodProcessor.call(lazyValueExtension, «IF processorMustCallExtendedMethod»lazyValueExtended«ELSE»null«ENDIF»)'''

		// compute result via trait method processor
		methodBody += "\n" +
			'''org.eclipse.xtend.lib.annotation.etai.TraitMethodProcessor resultTraitMethodProcessor = new «processor.qualifiedName»();'''

		// check if return conversion (in case of arrays) is required
		var boolean returnArrayConversionRequired = false
		if (!isVoid && delegationMethod.returnType.array && traitClassMethod.typeParameters.size ==
			delegationMethod.typeParameters.size) {

			// map locally specified type parameter declarations
			val localMethodTypeDeclarationMatch = new HashMap<TypeParameterDeclaration, TypeParameterDeclaration>
			val typeParam2Iterator = traitClassMethod.typeParameters.iterator
			for (typeParam1 : delegationMethod.typeParameters) {
				val typeParam2 = typeParam2Iterator.next
				localMethodTypeDeclarationMatch.put(typeParam1, typeParam2)
			}

			if (!traitClassMethod.returnType.typeReferenceEquals(delegationMethod.returnType, null, false, typeMapLocal,
				localMethodTypeDeclarationMatch))
				returnArrayConversionRequired = true

		}

		// add return to method body
		if (returnArrayConversionRequired) {

			val traitClassMethodReturnType = traitClassMethod.returnType.getTypeReferenceAsString(true, false, false,
				context)

			// specific handling of array types (cannot be simply casted in case of covariance)
			methodBody += "\n" +
				'''«traitClassMethodReturnType» resultArray = («traitClassMethodReturnType») «processorCall»;'''
			methodBody += "\n" +
				'''return java.util.Arrays.copyOf(resultArray, resultArray.length, «delegationMethod.returnType.getTypeReferenceAsString(true, false, false, context)».class);'''

		} else {
			methodBody += "\n" +
				'''«IF !isVoid»return («delegationMethod.returnType.getTypeReferenceAsString(true, false, false, context)») «ENDIF»«processorCall»;'''

		}

		// documentation
		delegationMethod.docComment = '''<p>This method combines the call of:</p>
			<ul><li>{@link «IF existingMethodInCurrentClass»#«existingMethod.simpleName»«ELSE»«(annotatedClass.extendedClass.type as ClassDeclaration).qualifiedName»#«traitClassMethod.simpleName»«ENDIF»(«paramTypeNameListJavadoc.join(", ")»)}</ul>
			<p>and</p>
			<ul><li>{@link «traitClass.qualifiedName»#«delegationMethod.simpleName»(«paramTypeNameListJavadoc.join(", ")»)}</ul>
			<p>via processor «processor.getJavaDocLinkTo(context)»</p>'''

		// apply method body
		bodySetter.setBody(delegationMethod, methodBody)

	}

	override doValidate(ClassDeclaration annotatedClass, extension ValidationContext context) {

		super.doValidate(annotatedClass, context)

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// check that trait classes are not extended
		if (annotatedClass.isTraitClass) {
			xtendClass.addError('''Trait classes cannot be extended''')
			return
		}

		// check that only one annotation of the same class is applied
		if (getProcessedAnnotationType() === ExtendedByAuto && annotatedClass.hasAnnotation(ExtendedBy))
			xtendClass.addError('''Cannot apply both @ExtendedBy and @ExtendedByAuto''')

		// retrieve applied trait classes
		val errors = new ArrayList<String>
		val traitClassRefsToApply = annotatedClass.getTraitClassesAppliedToExtended(errors, context)
		if (xtendClass.reportErrors(errors, context))
			return;

		// check that at least one trait class is annotated
		if (!annotatedClass.isExtendedClassAuto) {

			val specifiedTraitClasses = annotatedClass.getAnnotation(ExtendedBy).getClassArrayValue("value")
			if (specifiedTraitClasses !== null && specifiedTraitClasses.size <= 0)
				xtendClass.addError('''Must specify at least one trait class''')

		} else {

			if (traitClassRefsToApply.size <= 0)
				xtendClass.addError('''Must specify at least one trait class''')

		}

		// search through constructors for prohibited names
		for (xtendConstructor : xtendClass.declaredConstructors) {

			// some variable names must not be used
			for (parameter : xtendConstructor.parameters)
				if (parameter.simpleName.startsWith(ProcessUtils.IConstructorParamDummy.DUMMY_VARIABLE_NAME_PREFIX))
					xtendConstructor.addError('''Parameter name "«parameter.simpleName»" is not allowed''')

		}

		// go through all trait classes and check for simple name ambiguity		
		val alreadyAppliedTraitClasses = (annotatedClass.extendedClass?.type as ClassDeclaration)?.
			getTraitClassesSpecifiedForExtendedClosure(null, context)

		val Set<String> alreadyAppliedTraitClassesSimpleName = new HashSet<String>
		if (alreadyAppliedTraitClasses !== null)
			alreadyAppliedTraitClassesSimpleName.addAll(alreadyAppliedTraitClasses.map [
				it.simpleName
			])

		for (traitClassRefToApply : traitClassRefsToApply) {

			if (traitClassRefToApply === null || traitClassRefToApply.type === null) {
				xtendClass.addError(
					'''Could not find one of the given trait classes specified in @ExtendedBy or @ExtendedByAuto''')
				return
			}

			// check for type
			if (!(traitClassRefToApply.type instanceof ClassDeclaration)) {

				xtendClass.addError('''Type "«traitClassRefToApply.type.qualifiedName»" is not class''')
				return

			}

			val traitClass = (traitClassRefToApply.type as ClassDeclaration)

			// check for annotation
			if (traitClass.isTraitBaseClass) {

				xtendClass.
					addError('''Type "«traitClass.qualifiedName»" is a trait base class, i.e. it cannot be used as trait in @ExtendedBy or @ExtendedByAuto''')

			}

			// must be auto adapted, if any trait class is
			if (traitClass.hasAnnotation(ApplyRules) && !xtendClass.hasAnnotation(ApplyRules)) {

				xtendClass.
					addError('''Trait class "«traitClass.qualifiedName»" is auto adapted, so also this class must apply @ApplyRules''')

			}

			// check that no simple name is used multiple times (important for naming conventions)
			if (alreadyAppliedTraitClassesSimpleName.contains(traitClassRefToApply.simpleName))
				xtendClass.
					addError('''Name of trait class "«traitClassRefToApply.simpleName»" (non-qualified) is used multiple times in context of this class, which is not allowed because of naming conventions in automatically generated methods''')
			else
				alreadyAppliedTraitClassesSimpleName.add(traitClassRefToApply.simpleName)

		}

	}

}

/**
 * Active Annotation Processor for {@link ExtendedByAuto}
 * 
 * @see ExtendedByAuto
 */
class ExtendedByAutoProcessor extends ExtendedByProcessor {

	protected override getProcessedAnnotationType() {
		ExtendedByAuto
	}

}
