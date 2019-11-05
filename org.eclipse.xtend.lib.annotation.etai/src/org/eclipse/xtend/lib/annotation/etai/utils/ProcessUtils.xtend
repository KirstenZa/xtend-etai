package org.eclipse.xtend.lib.annotation.etai.utils

import java.util.ArrayList
import java.util.Collection
import java.util.Comparator
import java.util.HashSet
import java.util.List
import java.util.Set
import org.eclipse.xtend.lib.annotation.etai.AbstractTraitMethodAnnotationProcessor
import org.eclipse.xtend.lib.annotation.etai.AdaptedMethod
import org.eclipse.xtend.lib.annotation.etai.AdderRule
import org.eclipse.xtend.lib.annotation.etai.AssertParameterType
import org.eclipse.xtend.lib.annotation.etai.EnvelopeMethod
import org.eclipse.xtend.lib.annotation.etai.ExclusiveMethod
import org.eclipse.xtend.lib.annotation.etai.GetterRule
import org.eclipse.xtend.lib.annotation.etai.ImplAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.NoInterfaceExtract
import org.eclipse.xtend.lib.annotation.etai.ProcessedMethod
import org.eclipse.xtend.lib.annotation.etai.RemoverRule
import org.eclipse.xtend.lib.annotation.etai.RequiredMethod
import org.eclipse.xtend.lib.annotation.etai.SetterRule
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRule
import org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRuleProcessor
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.AnnotationTarget
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.ConstructorDeclaration
import org.eclipse.xtend.lib.macro.declaration.Element
import org.eclipse.xtend.lib.macro.declaration.ExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableAnnotationTarget
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableConstructorDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.NamedElement
import org.eclipse.xtend.lib.macro.declaration.ParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.Type
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeParameterDeclarator
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.file.FileLocations
import org.eclipse.xtend.lib.macro.services.AnnotationReferenceProvider
import org.eclipse.xtend.lib.macro.services.ProblemSupport
import org.eclipse.xtend.lib.macro.services.TypeLookup
import org.eclipse.xtend.lib.macro.services.TypeReferenceProvider

import static extension org.eclipse.xtend.lib.annotation.etai.AbstractTraitMethodAnnotationProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ConstructorMethodProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ExtendedByProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ExtractInterfaceProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ImplAdaptionRuleProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.TraitClassProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.TypeAdaptionRuleProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.StringUtils.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.TypeMap.*

/**
 * <p>Utility class for processing Xtend's active annotations.</p>
 */
class ProcessUtils {

	static interface IConstructorParamDummy {
		final static public String DUMMY_VARIABLE_NAME_PREFIX = "$dummy"
	}

	static interface IConstructorParamDummyCheckFactoryCall extends IConstructorParamDummy {
		final static public String DUMMY_VARIABLE_NAME = DUMMY_VARIABLE_NAME_PREFIX + "$checkFactoryCall"
	}

	static interface IConstructorParamDummyCheckApplyRules extends IConstructorParamDummy {
		final static public String DUMMY_VARIABLE_NAME = DUMMY_VARIABLE_NAME_PREFIX + "$checkApplyRules"
	}

	static interface IConstructorParamDummyCheckInit extends IConstructorParamDummy {
		final static public String DUMMY_VARIABLE_NAME = DUMMY_VARIABLE_NAME_PREFIX + "$checkInit"
	}

	static interface IConstructorParamDummySetExtendedThis extends IConstructorParamDummy {
		final static public String DUMMY_VARIABLE_NAME = DUMMY_VARIABLE_NAME_PREFIX + "$setExtendedThis"
	}

	final static public String WARNING_PREFIX = "Warning: "

	/**
	 * <p>Enumeration which allows for choosing different matching strategies for return types.</p>
	 */
	static enum TypeMatchingStrategy {

		MATCH_INVARIANT,
		MATCH_COVARIANT,
		MATCH_COVARIANT_CONSTRUCTOR_METHOD,
		MATCH_CONTRAVARIANT,
		MATCH_CONTRAVARIANT_CONSTRUCTOR_METHOD,
		MATCH_INHERITED,
		MATCH_INHERITED_CONSTRUCTOR_METHOD,
		MATCH_ALL,
		MATCH_ALL_CONSTRUCTOR_METHOD

	}

	/**
	 * <p>Different settings for type erasure.</p>
	 */
	static enum TypeErasureMethod {

		NONE,
		REMOVE_GENERICS,
		REMOVE_CONCRETE_TYPE_PARAMTERS

	}

	/**
	 * <p>Predicate for a flexible type comparison, which considers two types as equal if
	 * one is the supertype of the other type (whereas the first one must be the super class).</p>
	 */
	static public (TypeLookup, Type, Type)=>Boolean flexibleTypeComparisonCovariance = [
		$1.isAssignableFromConsiderUnprocessed($2, $0)
	]

	/**
	 * <p>Predicate for a flexible type comparison, which considers two types as equal if
	 * one is the supertype of the other type (whereas the second one must be the super class).</p>
	 */
	static public (TypeLookup, Type, Type)=>Boolean flexibleTypeComparisonContravariance = [
		$2.isAssignableFromConsiderUnprocessed($1, $0)
	]

	/**
	 * <p>Predicate for a flexible type comparison, which considers two types as equal if
	 * one is the supertype of the other type (no matter which one is the super class).</p>
	 */
	static public (TypeLookup, Type, Type)=>Boolean flexibleTypeComparisonInheritance = [
		$1.isAssignableFromConsiderUnprocessed($2, $0) || $2.isAssignableFromConsiderUnprocessed($1, $0)
	]

	/**
	 * <p>Predicate for choosing one of two matching methods with the return type, which is the subtype
	 * of the other return type. If this does not apply (e.g. the types are equal or not related),
	 * the first method in order will be returned.</p>
	 */
	static public (TypeLookup, TypeMap, MethodDeclaration, MethodDeclaration)=>MethodDeclaration covariantReturnType = [
		var plainType1 = $2.returnType
		var plainType2 = $3.returnType
		while (plainType1.array || plainType2.array) {
			if (!plainType1.array || !plainType2.array)
				return $2
			plainType1 = plainType1.arrayComponentType
			plainType2 = plainType2.arrayComponentType
		}
		if (!typeReferenceEquals(plainType1, plainType2, null, false, $1) &&
			plainType1.type.isAssignableFromConsiderUnprocessed(plainType2.type, $0)) {
			return $3
		} else {
			return $2
		}
	]

	/**
	 * <p>A comparator which be be used to sort integer value is a descendant order.</p>
	 */
	static class IntegerDescendantComparator implements Comparator<Integer> {

		static public IntegerDescendantComparator INTEGER_DESCENDANT_COMPARATOR = new IntegerDescendantComparator

		override int compare(Integer x0, Integer x1) {

			if (x0 > x1)
				return -1
			if (x0 < x1)
				return 1
			return 0

		}

	}

	/**
	 * <p>Determines if the type represented by <code>type1</code> is either the same as,
	 * or is a supertype of, the type specified by <code>type2</code>.</p>
	 * 
	 * <p>If <code>type1</code> represents a primitive type, this method returns <code>true</code>
	 * if <code>type2</code> parameter is exactly the same; otherwise it returns
	 * <code>false</code>.</p>
	 * 
	 * <p>In addition to this, the method is able to resolve type hierarchies, which
	 * are not fully processed by the active annotations, yet.</p>
	 */
	static def boolean isAssignableFromConsiderUnprocessed(Type type1, Type type2, extension TypeLookup context) {

		return isAssignableFromConsiderUnprocessedInternal(type1, type2, new HashSet<Type>, context)

	}

	/**
	 * <p>Internal method for checking if assignable.</p>
	 */
	static def boolean isAssignableFromConsiderUnprocessedInternal(Type type1, Type type2, Set<Type> processedTypes,
		extension TypeLookup context) {

		if (type1 !== null && type1.isAssignableFrom(type2))
			return true

		// process extended interfaces on the fly and continue recursively 
		if (type2 instanceof InterfaceDeclaration && type2.qualifiedName.isUnprocessedMirrorInterface) {

			val mirrorInterfaceExtends = if (context instanceof TransformationContext)
					getClassOfUnprocessedMirrorInterface(type2.qualifiedName).getMirrorInterfaceExtends(null, context)

			for (extendedInterface : mirrorInterfaceExtends) {

				val extendedInterfaceType = extendedInterface.type
				if (extendedInterfaceType !== null) {

					// protect from cycles
					if (processedTypes.contains(extendedInterfaceType))
						throw new IllegalStateException("Internal error: cycle within type assignment check detected")

					processedTypes.add(extendedInterfaceType)
					try {

						if (isAssignableFromConsiderUnprocessedInternal(type1, extendedInterfaceType, processedTypes,
							context))
							return true

					} finally {
						processedTypes.remove(extendedInterfaceType)
					}

				}

			}

		}

		// process extended interfaces on the fly and continue recursively 
		if (type2 instanceof ClassDeclaration && type2.qualifiedName.isUnprocessedClassExtraction) {

			val interfaceName = (type2 as ClassDeclaration).getMirrorInterfaceName

			val extractedInterfaceType = findTypeGlobally(interfaceName)
			if (isAssignableFromConsiderUnprocessedInternal(type1, extractedInterfaceType, processedTypes, context))
				return true

		}

		return false

	}

	/**
	 * <p>The method internally uses {@link #isAssignableFromConsiderUnprocessed}. It passes the types of the
	 * passed type references. In addition, arrays are considered.</p>
	 * 
	 * @see #isAssignableFromConsiderUnprocessed
	 */
	static def boolean isAssignableFromStripRefConsiderUnprocessed(TypeReference typeRef1, TypeReference typeRef2,
		extension TypeLookup context) {

		var plainType1 = typeRef1
		var plainType2 = typeRef2
		while (plainType1.array || plainType2.array) {
			if (!plainType1.array || !plainType2.array)
				return false
			plainType1 = plainType1.arrayComponentType
			plainType2 = plainType2.arrayComponentType
		}

		return plainType1.type.isAssignableFromConsiderUnprocessed(plainType2.type, context)

	}

	/**
	 * <p>Returns the declared methods of the given type. This method automatically considers additional
	 * mechanics like trait methods, method extraction, etc., even if the class/interface has not been 
	 * processed, yet.</p>
	 * 
	 * <p>The flags <code>resolveUnprocessedMirrorInterfaces</code>, <code>resolveUnprocessedTraitClasses</code> and
	 * <code>resolveUnprocessedExtendedClasses</code> determine if methods of the according unresolved class/interface
	 * shall also be considered.</p>
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> Iterable<? extends MethodDeclaration> getDeclaredMethodsResolved(
		TypeDeclaration typeDeclaration,
		boolean resolveUnprocessedMirrorInterfaces,
		boolean resolveUnprocessedTraitClasses,
		boolean resolveUnprocessedExtendedClasses,
		extension T context
	) {

		if (resolveUnprocessedMirrorInterfaces && typeDeclaration instanceof InterfaceDeclaration &&
			typeDeclaration.qualifiedName.isUnprocessedMirrorInterface) {

			return typeDeclaration.qualifiedName.classOfUnprocessedMirrorInterface.
				getMethodExtractionCandidates(true, null, context)

		} else {

			if (resolveUnprocessedTraitClasses && typeDeclaration instanceof ClassDeclaration &&
				typeDeclaration.qualifiedName.isUnprocessedTraitClass) {

				val result = new ArrayList<MethodDeclaration>(typeDeclaration.declaredMethods.toList)

				for (traitClass : (typeDeclaration as ClassDeclaration).
					getTraitClassesUsedByTraitClassClosure(null, context))
					for (traitMethod : (traitClass.type as ClassDeclaration).getTraitMethodClosure(null, context))
						result.add(traitMethod)

				return result

			} else {

				if (resolveUnprocessedExtendedClasses && typeDeclaration instanceof ClassDeclaration &&
					typeDeclaration.qualifiedName.isUnprocessedExtendedClass) {

					val result = new ArrayList<MethodDeclaration>(typeDeclaration.declaredMethods.toList)

					// add trait methods
					// hint: method redirection is performed as a first transformation step, so these methods should
					// have been added to extended classes already 
					for (traitClass : (typeDeclaration as ClassDeclaration).
						getTraitClassesAppliedToExtended(null, context))
						for (traitMethod : (traitClass.type as ClassDeclaration).getTraitMethodClosure(null, context))
							result.add(traitMethod)

					return result

				} else {

					return typeDeclaration.declaredMethods

				}

			}

		}

	}

	/**
	 * <p>Returns all methods of a class (directly or indirectly).</p>
	 * 
	 * <p>The predicate can be used in order to determine if the algorithm shall
	 * consider the given interface declaration (and also follow recursively).</p>
	 * 
	 * <p>The flags <code>resolveUnprocessedMirrorInterfaces</code>, <code>resolveUnprocessedTraitClasses</code> and
	 * <code>resolveUnprocessedExtendedClasses</code> determine if methods of the according unresolved class/interface
	 * shall also be considered.</p>
	 * 
	 * <p>The flag <code>includeSelf</code> determines if methods of the passed interface declaration shall be included.</p>
	 * 
	 * <p>If duplicates shall be removed, {@link #unifyMethodDeclarations} must be called afterwards.</p>
	 * 
	 * @see #unifyMethodDeclarations
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> List<MethodDeclaration> getMethodClosure(
		InterfaceDeclaration interfaceDeclaration,
		(InterfaceDeclaration)=>Boolean interfacePredicate,
		boolean resolveUnprocessedMirrorInterfaces,
		boolean resolveUnprocessedTraitClasses,
		boolean resolveUnprocessedExtendedClasses,
		boolean includeSelf,
		extension T context
	) {

		// create type closure
		val listTypes = getSuperTypeClosure(interfaceDeclaration, interfacePredicate, includeSelf, context)

		// go through all types and add methods
		val methodList = new ArrayList<MethodDeclaration>
		for (type : listTypes)
			methodList.addAll(
				type.getDeclaredMethodsResolved(resolveUnprocessedMirrorInterfaces, resolveUnprocessedTraitClasses,
					resolveUnprocessedExtendedClasses, context))

		return methodList

	}

	/**
	 * <p>Returns all methods of a class (directly or indirectly).</p>
	 * 
	 * <p>The predicates can be used in order to determine if the algorithm shall
	 * consider the given class/interface declaration (and also follow recursively).</p>
	 * 
	 * <p>The flags <code>resolveUnprocessedMirrorInterfaces</code>, <code>resolveUnprocessedTraitClasses</code> and
	 * <code>resolveUnprocessedExtendedClasses</code> determine if methods of the according unresolved class/interface
	 * shall also be considered.</p>
	 * 
	 * <p>The flag <code>includeSelf</code> determines if methods of the passed class declaration shall be included.</p>
	 * 
	 * <p>If duplicates shall be removed, {@link #unifyMethodDeclarations} must be called afterwards.</p>
	 * 
	 * @see #unifyMethodDeclarations
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> List<MethodDeclaration> getMethodClosure(
		ClassDeclaration classDeclaration,
		(ClassDeclaration)=>Boolean classPredicate,
		(InterfaceDeclaration)=>Boolean interfacePredicate,
		boolean resolveUnprocessedMirrorInterfaces,
		boolean resolveUnprocessedTraitClasses,
		boolean resolveUnprocessedExtendedClasses,
		boolean includeSelf,
		boolean considerPrivateInSuperType,
		extension T context
	) {

		// create type closure
		val listTypes = getSuperTypeClosure(
			classDeclaration,
			classPredicate,
			interfacePredicate,
			includeSelf,
			context
		)

		// go through all types and add methods
		val methodList = new ArrayList<MethodDeclaration>
		for (type : listTypes)
			methodList.addAll(
				type.getDeclaredMethodsResolved(resolveUnprocessedMirrorInterfaces, resolveUnprocessedTraitClasses,
				resolveUnprocessedExtendedClasses, context).filter [

				// if flag is not set to true,
				// the method must be either in original class or not private (will not be visible in derived classes)
				considerPrivateInSuperType || (classDeclaration === type || it.visibility != Visibility::PRIVATE)

			])

		return methodList

	}

	/**
	 * <p>Returns all supertypes of an interface including
	 * the actual type parameters, which are resolved while going through the tree.</p>
	 * 
	 * <p>The predicate can be used in order to determine if the algorithm shall
	 * consider the currently processed interface declaration (and also follow recursively).
	 * If <code>null</code> is passed for a predicate, no filter is applied.</p>
	 * 
	 * <p>The flag <code>includeSelf</code> determines if the passed interface declaration shall be included.</p>
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> List<InterfaceDeclaration> getSuperTypeClosure(
		InterfaceDeclaration interfaceDeclaration,
		(InterfaceDeclaration)=>Boolean interfacePredicate,
		boolean includeSelf,
		extension T context
	) {

		val result = new ArrayList<InterfaceDeclaration>
		getSuperTypeClosureInternal(interfaceDeclaration, interfacePredicate, includeSelf, result, context)
		return result

	}

	/**
	 * <p>Internal method for calculating supertype closure.</p>
	 */
	@SuppressWarnings("rawtypes")
	private static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> void getSuperTypeClosureInternal(
		InterfaceDeclaration interfaceDeclaration,
		(InterfaceDeclaration)=>Boolean interfacePredicate,
		boolean includeSelf,
		List<? super InterfaceDeclaration> interfaceList,
		extension T context
	) {

		// evaluate predicate
		if (interfacePredicate !== null && !interfacePredicate.curry(interfaceDeclaration).apply.booleanValue)
			return;

		// add current type
		if (includeSelf) {

			// recursion protection
			if (interfaceList.contains(interfaceDeclaration))
				return;

			interfaceList.add(interfaceDeclaration)

		}

		// find extended interfaces (consider unprocessed type information)
		val extendedInterfaces = if (interfaceDeclaration.qualifiedName.isUnprocessedMirrorInterface) {
				getClassOfUnprocessedMirrorInterface(interfaceDeclaration.qualifiedName).
					getMirrorInterfaceExtends(null, context)
			} else {
				interfaceDeclaration.extendedInterfaces
			}

		// iterate through all extended interfaces (do not process current interface any more, may be circular)
		for (superInterface : extendedInterfaces)
			(superInterface.type as InterfaceDeclaration).getSuperTypeClosureInternal([
				it !== interfaceDeclaration &&
					(interfacePredicate === null || interfacePredicate.curry(it).apply.booleanValue)
			], true, interfaceList, context)

	}

	/**
	 * <p>Returns all supertypes of a class (including the class itself) including
	 * the actual type parameters, which are resolved while going through the tree.</p>
	 * 
	 * <p>The predicates can be used in order to determine if the algorithm shall
	 * consider the currently processed class/interface declaration (and also follow recursively).
	 * If <code>null</code> is passed for a predicate, no filter is applied.</p>
	 * 
	 * <p>The flag <code>includeSelf</code> determines if the passed class declaration shall be included.</p>
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> List<TypeDeclaration> getSuperTypeClosure(
		ClassDeclaration classDeclaration,
		(ClassDeclaration)=>Boolean classPredicate,
		(InterfaceDeclaration)=>Boolean interfacePredicate,
		boolean includeSelf,
		extension T context
	) {

		val result = new ArrayList<TypeDeclaration>
		getSuperTypeClosureInternal(classDeclaration, classPredicate, interfacePredicate, includeSelf, result, context)
		return result

	}

	/**
	 * <p>Internal method for calculating supertype closure.</p>
	 */
	@SuppressWarnings("rawtypes")
	private static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> void getSuperTypeClosureInternal(
		ClassDeclaration classDeclaration,
		(ClassDeclaration)=>Boolean classPredicate,
		(InterfaceDeclaration)=>Boolean interfacePredicate,
		boolean includeSelf,
		List<? super TypeDeclaration> typeList,
		extension T context
	) {

		// evaluate predicate
		if (classPredicate !== null && !classPredicate.curry(classDeclaration).apply.booleanValue)
			return;

		// add current type
		if (includeSelf) {

			// recursion protection
			if (typeList.contains(classDeclaration))
				return;

			typeList.add(classDeclaration)

		}

		// iterate through all superclasses
		if (classDeclaration.extendedClass !== null)
			getSuperTypeClosureInternal(classDeclaration.extendedClass.type as ClassDeclaration, classPredicate,
				interfacePredicate, true, typeList, context)

		// find implemented interfaces (consider unprocessed type information)
		val implementedInterfaces = new ArrayList<InterfaceDeclaration>
		implementedInterfaces.addAll(classDeclaration.implementedInterfaces.map[type as InterfaceDeclaration])

		if (classDeclaration.qualifiedName.isUnprocessedClassExtraction) {
			val mirrorInterface = findTypeGlobally(classDeclaration.getMirrorInterfaceName)
			if (mirrorInterface instanceof InterfaceDeclaration)
				implementedInterfaces.add(mirrorInterface)
		}

		// iterate through all interfaces
		for (superInterface : implementedInterfaces)
			superInterface.getSuperTypeClosureInternal(interfacePredicate, true, typeList, context)

	}

	/**
	 * <p>Retrieves all supertypes of given class. If the flag is set to true, the result will also contain
	 * the passed given class itself (at the first position).</p>
	 */
	static def List<ClassDeclaration> getSuperClasses(ClassDeclaration classDeclaration, boolean includingSelf) {

		val result = new ArrayList<ClassDeclaration>

		if (includingSelf === true)
			result.add(classDeclaration)

		var currentClass = classDeclaration.extendedClass?.type as ClassDeclaration
		while (currentClass !== null) {

			// recursion protection
			if (result.contains(currentClass))
				throw new IllegalStateException("Inconsistent type hierarchy detected")

			result.add(currentClass)
			currentClass = currentClass.extendedClass?.type as ClassDeclaration

		}

		return result

	}

	/**
	 * <p>This method retrieves the first common base class of two class declarations.</p>
	 */
	static def ClassDeclaration getFirstCommonSuperClass(ClassDeclaration classDeclaration1,
		ClassDeclaration classDeclaration2) {

		val superClasses1 = classDeclaration1.getSuperClasses(true)
		val superClasses2 = classDeclaration2.getSuperClasses(true)

		for (currentSuperClass1 : superClasses1)
			if (superClasses2.contains(currentSuperClass1))
				return currentSuperClass1

		return null

	}

	/**
	 * <p>Returns the position of the parameter in its executable.</p>
	 */
	static def int getParameterPosition(ParameterDeclaration parameter) {

		var int number = 0
		for (currentParameter : parameter.declaringExecutable.parameters) {
			if (currentParameter === parameter)
				return number
			number++
		}
		return -1

	}

	/**
	 * <p>Returns <code>true</code> if two constructors shall be considered equal, i.e., the constructors have the
	 * same parameters.</p>
	 * 
	 * <p>The method internally uses {@link #parametersEquals}.</p>
	 * 
	 * @see #parametersEquals
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> boolean constructorEquals(
		ConstructorDeclaration constructor1,
		ConstructorDeclaration constructor2,
		TypeMatchingStrategy typeMatchingStrategy,
		boolean useAssertParameterType,
		TypeMap typeMap,
		T context
	) {

		if (constructor1 === constructor2)
			return true

		if (constructor1.typeParameters.size != constructor2.typeParameters.size)
			return false

		// create local type map, which considers that constructors have been copied
		if (!constructor1.parameters.parametersEquals(constructor2.parameters, typeMatchingStrategy,
			useAssertParameterType, typeMap, context))
			return false

		return true

	}

	/**
	 * <p>Returns <code>true</code> if two methods shall be considered equal, i.e., the methods have matching
	 * name, parameter types and return type.</p>
	 * 
	 * <p>The parameter <code>parameterTypeMatchingStrategy</code> determines, how the parameter types are matched.</p>
	 * 
	 * <p>The parameter <code>returnTypeMatchingStrategy</code> determines, how the return type is matched.</p>
	 * 
	 * <p>The method internally uses {@link #parametersEquals}.</p>
	 * 
	 * @see #parametersEquals
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> boolean methodEquals(
		MethodDeclaration method1,
		MethodDeclaration method2,
		TypeMatchingStrategy parameterTypeMatchingStrategy,
		TypeMatchingStrategy returnTypeMatchingStrategy,
		boolean useAssertParameterType,
		TypeMap typeMap,
		T context
	) {

		if (method1 === method2)
			return true

		if (method1.simpleName != method2.simpleName)
			return false

		if (method1.typeParameters.size != method2.typeParameters.size)
			return false

		// check equality of parameters
		if (!method1.parameters.parametersEquals(method2.parameters, parameterTypeMatchingStrategy,
			useAssertParameterType, typeMap, context))
			return false

		// if any return types is inferred, methods are considered equal
		if (method1.returnType.inferred || method2.returnType.inferred)
			return true

		if (returnTypeMatchingStrategy != TypeMatchingStrategy.MATCH_ALL || method1.returnType.primitive ||
			method2.returnType.primitive) {

			val (Type, Type)=>Boolean flexibleTypeComparison = if (returnTypeMatchingStrategy ==
					TypeMatchingStrategy.MATCH_INHERITED)
					flexibleTypeComparisonInheritance.curry(context)
				else if (returnTypeMatchingStrategy == TypeMatchingStrategy.MATCH_COVARIANT)
					flexibleTypeComparisonCovariance.curry(context)
				else if (returnTypeMatchingStrategy == TypeMatchingStrategy.MATCH_CONTRAVARIANT)
					flexibleTypeComparisonContravariance.curry(context)
				else
					null

			if (!typeReferenceEquals(method1.returnType, method2.returnType, flexibleTypeComparison, false, typeMap))
				return false

		}

		return true

	}

	/**
	 * <p>Returns <code>true</code> if two parameter collections shall be considered equal, i.e., the parameters
	 * have the same types in the same order.</p>
	 * 
	 * <p>The parameter <code>typeMatchingStrategy</code> determines, how the type is matched.</p>
	 * 
	 * <p>The method internally uses {@link #typeReferenceEquals}.</p>
	 * 
	 * @see #typeReferenceEquals
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> boolean parametersEquals(
		Iterable<? extends ParameterDeclaration> params1,
		Iterable<? extends ParameterDeclaration> params2,
		TypeMatchingStrategy typeMatchingStrategy,
		boolean useAssertParameterType,
		TypeMap typeMap,
		T context
	) {

		if (params1 === params2)
			return true

		if (params1.size != params2.size)
			return false

		if (params1.size == 0)
			return true

		val executable1 = params1.get(0).declaringExecutable
		val executable2 = params2.get(0).declaringExecutable

		val areConstructorMethods = executable1 instanceof MethodDeclaration &&
			executable2 instanceof MethodDeclaration && (executable1 as MethodDeclaration).isConstructorMethod &&
			(executable2 as MethodDeclaration).isConstructorMethod

		if (typeMatchingStrategy != TypeMatchingStrategy.MATCH_ALL &&
			(typeMatchingStrategy != TypeMatchingStrategy.MATCH_ALL_CONSTRUCTOR_METHOD || !areConstructorMethods)) {

			val (Type, Type)=>Boolean flexibleTypeComparison = if (typeMatchingStrategy ==
					TypeMatchingStrategy.MATCH_INHERITED) {
					flexibleTypeComparisonInheritance.curry(context)
				} else if (typeMatchingStrategy == TypeMatchingStrategy.MATCH_COVARIANT) {
					flexibleTypeComparisonCovariance.curry(context)
				} else if (typeMatchingStrategy == TypeMatchingStrategy.MATCH_CONTRAVARIANT) {
					flexibleTypeComparisonContravariance.curry(context)
				} else if (typeMatchingStrategy == TypeMatchingStrategy.MATCH_INHERITED_CONSTRUCTOR_METHOD) {
					if (areConstructorMethods)
						flexibleTypeComparisonInheritance.curry(context)
					else
						null
				} else if (typeMatchingStrategy == TypeMatchingStrategy.MATCH_COVARIANT_CONSTRUCTOR_METHOD) {
					if (areConstructorMethods)
						flexibleTypeComparisonCovariance.curry(context)
					else
						null
				} else if (typeMatchingStrategy == TypeMatchingStrategy.MATCH_CONTRAVARIANT_CONSTRUCTOR_METHOD) {
					if (areConstructorMethods)
						flexibleTypeComparisonContravariance.curry(context)
					else
						null
				} else {
					null
				}

			val iter2 = params2.iterator
			for (param1 : params1) {
				val param2 = iter2.next
				var type1 = param1.type
				var type2 = param2.type
				if (useAssertParameterType) {
					if (param1.hasAnnotation(AssertParameterType))
						type1 = param1.getAnnotation(AssertParameterType).getClassValue("value")
					if (param2.hasAnnotation(AssertParameterType))
						type2 = param2.getAnnotation(AssertParameterType).getClassValue("value")
				}

				if ((typeMatchingStrategy != TypeMatchingStrategy.MATCH_ALL &&
					(typeMatchingStrategy != TypeMatchingStrategy.MATCH_ALL_CONSTRUCTOR_METHOD ||
						!areConstructorMethods)) || type1.primitive || type2.primitive)
					if (!typeReferenceEquals(type1, type2, flexibleTypeComparison, false, typeMap))
						return false
			}

		}

		return true

	}

	/** 
	 * <p>Returns <code>true</code> if two parameter lists are considered as "similar".</p>
	 * 
	 * <p>They are considered as similar if they have the same size and primitive types
	 * match.</p>
	 */
	static def boolean parametersSimilar(Iterable<? extends ParameterDeclaration> parameterList1,
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
	 * <p>Returns <code>true</code> if two type references shall be considered equal.
	 * This method does consider type arguments specifically.</p>
	 * 
	 * <p>The method can consider a type map which links  
	 * from a type to a type reference in the current context, which is especially useful for
	 * type parameter declarations (TypeParameterDeclaration). This type reference shall then
	 * be used for the according given type.</p>
	 * 
	 * <p>The method can also consider additional type maps (specialized on type parameter declarations)
	 * which are created based on a method's locally specified type parameter declaration.</p>
	 * 
	 * <p>Via <code>flexibleTypeComparison</code> an additional condition can be passed that shall return
	 * <code>true</code> if two (resolved) types shall be considered. For example, hierarchical dependencies can be checked.
	 * If two types are not exactly the same and shall never be considered equal then, <code>null</code> or
	 * <code>[false]</code> must be passed.</p>
	 * 
	 * <p>With flag <code>considerTypeArguments</code> the consideration of type arguments can be turned on/off.</p>
	 */
	static def boolean typeReferenceEquals(
		TypeReference typeRef1,
		TypeReference typeRef2,
		(Type, Type)=>Boolean flexibleTypeComparison,
		boolean considerTypeArguments,
		TypeMap typeMap
	) {
		
		var performTypeArgumentCheck = considerTypeArguments

		// perform trivial checks
		if (typeRef1 === typeRef2)
			return true
		if ((typeRef1 === null) && (typeRef2 === null))
			return true
		if ((typeRef1 === null) !== (typeRef2 === null))
			return false

		if (typeRef1.isWildCard != typeRef2.isWildCard || typeRef1.isArray != typeRef2.isArray)
			return false

		if (typeRef1.isArray &&
			!typeReferenceEquals(typeRef1.arrayComponentType, typeRef2.arrayComponentType, flexibleTypeComparison,
				considerTypeArguments, typeMap)) {

			return false

		} else if (typeRef1.isWildCard) {

			if (!typeReferenceEquals(typeRef1.upperBound, typeRef2.upperBound, flexibleTypeComparison,
				considerTypeArguments, typeMap) ||
				!typeReferenceEquals(typeRef1.lowerBound, typeRef2.lowerBound, flexibleTypeComparison,
					considerTypeArguments, typeMap))
				return false

		} else {

			// apply type map
			var TypeReference typeRef1Resolved = typeMap.resolve(typeRef1)
			var TypeReference typeRef2Resolved = typeMap.resolve(typeRef2)

			// compare type
			if (typeRef1Resolved.type != typeRef2Resolved.type) {

				if (typeRef1Resolved.type === null || typeRef2Resolved.type === null)
					return false

				if ((typeRef1Resolved.type instanceof TypeParameterDeclaration) !==
					(typeRef2Resolved.type instanceof TypeParameterDeclaration))
					return false

				if (typeRef1Resolved.type instanceof TypeParameterDeclaration &&
					(typeRef1Resolved.type as TypeParameterDeclaration).
						typeParameterDeclarator instanceof MethodDeclaration !=
						(typeRef2Resolved.type as TypeParameterDeclaration).
							typeParameterDeclarator instanceof MethodDeclaration)
					return false

				if (typeRef1Resolved.type instanceof TypeParameterDeclaration &&
					(typeRef1Resolved.type as TypeParameterDeclaration).
						typeParameterDeclarator instanceof MethodDeclaration) {

					// in case of type parameters two type references might match (because the executables match),
					// if they have been specified in the same position
					val typeRef1ResolvedFinal = typeRef1Resolved
					val pos1 = ((typeRef1Resolved.type as TypeParameterDeclaration).
						typeParameterDeclarator as MethodDeclaration).typeParameters.indexed.findFirst [
						it.value === typeRef1ResolvedFinal.type
					].key
					val typeRef2ResolvedFinal = typeRef2Resolved
					val pos2 = ((typeRef2Resolved.type as TypeParameterDeclaration).
						typeParameterDeclarator as MethodDeclaration).typeParameters.indexed.findFirst [
						it.value === typeRef2ResolvedFinal.type
					].key

					if (pos1 != pos2)
						return false

					// still possible that the types do not match if upper bounds differ
					// note: upper bound is same as resolved type if there is not explicit declaration
					if ((!(typeRef1Resolved.upperBound.type instanceof TypeParameterDeclaration) ||
						!(typeRef2Resolved.upperBound.type instanceof TypeParameterDeclaration)) &&
						!typeReferenceEquals(typeRef1Resolved.upperBound, typeRef2Resolved.upperBound,
							flexibleTypeComparison, considerTypeArguments, typeMap))
						return false

				} // otherwise it was a regular type check 
				else {

					// types might have different qualified names, but they might still be equal (flexible type comparison)
					if (typeRef1Resolved.type.qualifiedName != typeRef2Resolved.type.qualifiedName) {

						// do not check type arguments any more if different types
						performTypeArgumentCheck = false

						if (flexibleTypeComparison === null)
							return false

						if (!flexibleTypeComparison.apply(typeRef1Resolved.type, typeRef2Resolved.type))
							return false

					}

				}

			}

		}

		// perform further checks...
		if (performTypeArgumentCheck) {

			if (typeRef1.actualTypeArguments.size != typeRef2.actualTypeArguments.size)
				return false

			for (i : 0 ..< typeRef1.actualTypeArguments.size) {
				if (typeReferenceEquals(typeRef1.actualTypeArguments.get(i), typeRef2.actualTypeArguments.get(i),
					flexibleTypeComparison, considerTypeArguments, typeMap) == false)
					return false
			}

		}

		return true

	}

	/**
	 * <p>Returns first method in collection that matches the given declaration.</p>
	 * 
	 * <p>The method internally uses {@link #methodEquals}.</p>
	 * 
	 * @see #methodEquals
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> MethodDeclaration getMatchingMethod(
		Iterable<? extends MethodDeclaration> methods,
		MethodDeclaration methodToFind,
		TypeMatchingStrategy parameterTypeMatchingStrategy,
		TypeMatchingStrategy returnTypeMatchingStrategy,
		boolean useAssertParameterType,
		TypeMap typeMap,
		T context
	) {

		for (method : methods)
			if (method.methodEquals(methodToFind, parameterTypeMatchingStrategy, returnTypeMatchingStrategy,
				useAssertParameterType, typeMap, context))
				return method
		return null

	}

	/**
	 * <p>Returns all methods in collection that match the given declaration.</p>
	 * 
	 * <p>The method internally uses {@link #methodEquals}.</p>
	 * 
	 * @see #methodEquals
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> List<MethodDeclaration> getMatchingMethods(
		Iterable<? extends MethodDeclaration> methods,
		MethodDeclaration methodToFind,
		TypeMatchingStrategy parameterTypeMatchingStrategy,
		TypeMatchingStrategy returnTypeMatchingStrategy,
		boolean useAssertParameterType,
		TypeMap typeMap,
		T context
	) {

		val result = new ArrayList<MethodDeclaration>

		for (method : methods)
			if (method.methodEquals(methodToFind, parameterTypeMatchingStrategy, returnTypeMatchingStrategy,
				useAssertParameterType, typeMap, context))
				result.add(method)

		return result

	}

	/**
	 * <p>Returns first constructor in collection that matches the given declaration.</p>
	 * 
	 * <p>The method internally uses {@link #constructorEquals}.</p>
	 * 
	 * @see #constructorEquals
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> ConstructorDeclaration getMatchingConstructor(
		Iterable<? extends ConstructorDeclaration> constructors,
		ConstructorDeclaration constructorToFind,
		TypeMatchingStrategy typeMatchingStrategy,
		boolean useAssertParameterType,
		TypeMap typeMap,
		T context
	) {

		for (constructor : constructors)
			if (constructor.constructorEquals(constructorToFind, typeMatchingStrategy, useAssertParameterType, typeMap,
				context))
				return constructor
		return null

	}

	/**
	 * <p>Returns all constructors in collection that match the given declaration.</p>
	 * 
	 * <p>The method internally uses {@link #constructorEquals}.</p>
	 * 
	 * @see #constructorEquals
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> List<ConstructorDeclaration> getMatchingConstructors(
		Iterable<? extends ConstructorDeclaration> constructors,
		ConstructorDeclaration constructorToFind,
		TypeMatchingStrategy typeMatchingStrategy,
		boolean useAssertParameterType,
		TypeMap typeMap,
		T context
	) {

		val result = new ArrayList<ConstructorDeclaration>

		for (constructor : constructors)
			if (constructor.constructorEquals(constructorToFind, typeMatchingStrategy, useAssertParameterType, typeMap,
				context))
				result.add(constructor)

		return result

	}

	/**
	 * <p>Returns the matching executable (method or constructor inside a class) in the given class or null,
	 * if it has not been found.</p>
	 * 
	 * <p>The method searches in the whole type hierarchy if the <code>recursive</code> flag is set.
	 * Otherwise, it will only search inside the given class.</p>
	 * 
	 * <p>The method internally uses {@link #getMatchingMethod} and {@link #getMatchingConstructor}.</p>
	 * 
	 * <p>The flags <code>resolveUnprocessedMirrorInterfaces</code>, <code>resolveUnprocessedTraitClasses</code> and
	 * <code>resolveUnprocessedExtendedClasses</code> determine if methods of the according unresolved class/interface
	 * shall also be considered.</p>
	 * 
	 * @see #getMatchingMethod
	 * @see #getMatchingConstructor
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> ExecutableDeclaration getMatchingExecutableInClass(
		ClassDeclaration classDeclaration,
		ExecutableDeclaration executable,
		TypeMatchingStrategy parameterTypeMatchingStrategy,
		TypeMatchingStrategy returnTypeMatchingStrategy,
		boolean recursive,
		boolean useAssertParameterType,
		boolean resolveUnprocessedMirrorInterfaces,
		boolean resolveUnprocessedTraitClasses,
		boolean resolveUnprocessedExtendedClasses,
		TypeMap typeMap,
		T context
	) {

		var currentClassDeclaration = classDeclaration

		while (currentClassDeclaration !== null) {

			var ExecutableDeclaration result = null

			// check for matching method or constructor
			if (executable instanceof MethodDeclaration) {
				result = currentClassDeclaration.getDeclaredMethodsResolved(resolveUnprocessedMirrorInterfaces,
					resolveUnprocessedTraitClasses, resolveUnprocessedExtendedClasses, context).getMatchingMethod(
					executable, parameterTypeMatchingStrategy, returnTypeMatchingStrategy, useAssertParameterType,
					typeMap, context)
			} else if (executable instanceof ConstructorDeclaration) {
				result = currentClassDeclaration.declaredConstructors.getMatchingConstructor(executable,
					parameterTypeMatchingStrategy, useAssertParameterType, typeMap, context)
			}

			if (recursive == false || result !== null)
				return result

			// continue recursively
			currentClassDeclaration = currentClassDeclaration.extendedClass?.type as ClassDeclaration

		}

		return null

	}

	/**
	 * <p>Retrieves (implemented) super methods of the given method in class hierarchy starting with the closest
	 * super method. Trait classes are not considered.</p>
	 * 
	 * <p>The flag <code>includeSelf</code> determines if the passed method (if implemented) will be added to
	 * the first position of the result.</p>
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> List<MethodDeclaration> getImplementedSuperMethods(
		MethodDeclaration method, boolean includeSelf, TypeMap typeMap, T context) {

		val result = new ArrayList<MethodDeclaration>

		if (includeSelf && !method.abstract)
			result.add(method)

		// go through super classes and add matching methods that which are declared there and are not abstract
		val superClasses = (method.declaringType as ClassDeclaration).getSuperClasses(false)
		for (superClass : superClasses) {

			val matchingMethodInSuperClass = superClass.getMatchingExecutableInClass(
				method,
				TypeMatchingStrategy.MATCH_INVARIANT,
				TypeMatchingStrategy.MATCH_COVARIANT,
				false,
				false,
				true,
				true,
				true,
				typeMap,
				context
			) as MethodDeclaration

			if (matchingMethodInSuperClass !== null && !matchingMethodInSuperClass.abstract)
				result.add(matchingMethodInSuperClass)

		}

		return result

	}

	/**
	 * <p>Checks if a type reference is already contained in a type reference collection.</p>
	 * 
	 * <p>The method internally uses {@link #typeReferenceEquals}.</p>
	 * 
	 * @see #typeReferenceEquals
	 */
	static def typeReferenceListContains(Iterable<? extends TypeReference> typeReferences,
		TypeReference typeReferenceToFind, ExecutableDeclaration executableContext1,
		ExecutableDeclaration executableContext2, (Type, Type)=>Boolean flexibleTypeComparison,
		boolean considerTypeArguments, TypeMap typeMap) {

		for (typeReference : typeReferences)
			if (typeReference.typeReferenceEquals(typeReferenceToFind, flexibleTypeComparison, considerTypeArguments,
				typeMap))
				return true
		return false

	}

	/**
	 * <p>Checks if a type is already contained in a type reference collection.</p>
	 * 
	 * @see #typeReferenceListContains
	 */
	static def typeReferenceListContains(Iterable<? extends TypeReference> typeReferences, Type typeToFind) {

		for (typeReference : typeReferences)
			if (typeReference.type.qualifiedName == typeToFind.qualifiedName)
				return true
		return false

	}

	/**
	 * <p>Checks if a list of type references equals another list.</p>
	 * 
	 * <p>The method internally uses {@link #typeReferenceEquals}.</p>
	 * 
	 * @see #typeReferenceEquals
	 */
	static def typeReferenceListEquals(List<? extends TypeReference> typeRefs1, List<? extends TypeReference> typeRefs2,
		(Type, Type)=>Boolean flexibleTypeComparison, boolean considerTypeArguments, TypeMap typeMap) {

		if (typeRefs1.size != typeRefs2.size)
			return false

		for (typeRefIndex : 0 ..< typeRefs1.size)
			if (!typeRefs1.get(0).typeReferenceEquals(typeRefs2.get(0), flexibleTypeComparison, considerTypeArguments,
				typeMap))
				return false

		return true

	}

	/**
	 * <p>Gets the index of a type reference within the given a collection.</p>
	 * 
	 * <p>The method returns <code>-1</code> if the collection does not contain the type reference.</p>
	 * 
	 * <p>The method internally uses {@link #typeReferenceEquals}.</p>
	 * 
	 * @see #typeReferenceEquals
	 */
	static def indexOfTypeReference(Iterable<? extends TypeReference> typeReferences, TypeReference typeReferenceToFind,
		(Type, Type)=>Boolean flexibleTypeComparison, boolean considerTypeArguments, TypeMap typeMap) {

		var int counter = 0
		for (typeReference : typeReferences) {
			if (typeReference.typeReferenceEquals(typeReferenceToFind, flexibleTypeComparison, considerTypeArguments,
				typeMap))
				return counter
			counter++
		}
		return -1

	}

	/**
	 * <p>Checks if a method is already contained in a collection.</p>
	 * 
	 * <p>The method internally uses {@link #getMatchingMethod}.</p>
	 * 
	 * @see #getMatchingMethod
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> methodListContains(
		Iterable<? extends MethodDeclaration> methods,
		MethodDeclaration methodToFind,
		TypeMatchingStrategy parameterTypeMatchingStrategy,
		TypeMatchingStrategy returnTypeMatchingStrategy,
		boolean useAssertParameterType,
		TypeMap typeMap,
		T context
	) {

		return getMatchingMethod(methods, methodToFind, parameterTypeMatchingStrategy, returnTypeMatchingStrategy,
			useAssertParameterType, typeMap, context) !== null

	}

	/**
	 * <p>Checks if a constructor is already contained in a collection.</p>
	 * 
	 * <p>The constructor internally uses {@link #getMatchingConstructor}.</p>
	 * 
	 * @see #getMatchingConstructor
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> constructorListContains(
		Iterable<? extends ConstructorDeclaration> constructors,
		ConstructorDeclaration constructorToFind,
		TypeMatchingStrategy typeMatchingStrategy,
		boolean useAssertParameterType,
		TypeMap typeMap,
		T context
	) {

		return getMatchingConstructor(constructors, constructorToFind, typeMatchingStrategy, useAssertParameterType,
			typeMap, context) !== null

	}

	/**
	 * <p>Returns unified list of type references, i.e., the list contains each type reference
	 * only once. Thereby, type references which come early in the given list will be kept.</p>
	 * 
	 * <p>The method internally uses {@link #typeReferenceEquals}.</p>
	 * 
	 * @see #typeReferenceEquals
	 */
	static def List<TypeReference> unifyTypeReferences(Iterable<? extends TypeReference> typeReferences,
		ExecutableDeclaration executableContext1, ExecutableDeclaration executableContext2,
		(Type, Type)=>Boolean flexibleTypeComparison, boolean considerTypeArguments, TypeMap typeMap) {

		val result = new ArrayList<TypeReference>

		// go through given methods
		if (typeReferences !== null)
			for (typeReference : typeReferences) {

				// add to result list if type reference is not already contained
				if (!result.typeReferenceListContains(typeReference, executableContext1, executableContext2,
					flexibleTypeComparison, considerTypeArguments, typeMap)) {
					result.add(typeReference)
				}

			}

		return result

	}

	/**
	 * <p>Returns unified list of methods, i.e., the list contains each method
	 * only once. Thereby, method declarations which come early in the given list will be kept.</p>
	 * 
	 * <p>If two matching method declaration are found, only one is kept in the result. Thereby, the
	 * expression <code>keepDecision</code> has to choose the method declaration. If <code>null</code>,
	 * the method declaration that comes earlier in the given list will be kept.
	 * 
	 * <p>The method internally uses {@link #methodEquals}.</p>
	 * 
	 * @see #methodEquals
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> List<MethodDeclaration> unifyMethodDeclarations(
		Iterable<? extends MethodDeclaration> methodDeclarations,
		TypeMatchingStrategy parameterTypeMatchingStrategy,
		TypeMatchingStrategy returnTypeMatchingStrategy,
		(MethodDeclaration, MethodDeclaration)=>MethodDeclaration keepDecision,
		boolean useAssertParameterType,
		TypeMap typeMap,
		T context
	) {

		// cache for already processed methods with given name (improve performance)
		val processedMethodNames = new HashSet<String>

		val result = new ArrayList<MethodDeclaration>

		// go through given methods
		for (methodDeclaration : methodDeclarations) {

			// add to result list if method (name) is not already contained (method names are cached)
			if (!processedMethodNames.contains(methodDeclaration.simpleName)) {

				processedMethodNames.add(methodDeclaration.simpleName)
				result.add(methodDeclaration)

			} else {

				// if matching method is contained, the given predicate must decide which method to keep
				val matchingMethod = result.getMatchingMethod(methodDeclaration, parameterTypeMatchingStrategy,
					returnTypeMatchingStrategy, useAssertParameterType, typeMap, context)
				if (matchingMethod !== null) {

					if (keepDecision !== null) {
						val methodToKeep = keepDecision.apply(matchingMethod, methodDeclaration)
						if (methodToKeep !== matchingMethod) {
							result.remove(matchingMethod)
							result.add(methodToKeep)
						}
					}

				} else {

					// add to result list if matching method is not already contained
					result.add(methodDeclaration)

				}

			}

		}

		return result

	}

	/**
	 * <p>Sorts the given methods and returns the sorted list.</p>
	 */
	static def List<MethodDeclaration> getMethodsSorted(Iterable<MethodDeclaration> methods,
		TypeReferenceProvider context) {

		return methods.sortWith([

			// compare names
			val nameCompare = $0.simpleName.compareTo($1.simpleName)
			if (nameCompare != 0)
				return nameCompare

			// compare parameter count
			val parameterCountCompare = if ($0.parameters.size < $1.parameters.size)
					-1
				else if ($0.parameters.size > $1.parameters.size)
					1
				else
					0

			if (parameterCountCompare != 0)
				return parameterCountCompare

			// compare return type
			val returnTypeCompare = $0.returnType.getTypeReferenceAsString(true, TypeErasureMethod.NONE, false, false,
				context).compareTo(
				$1.returnType.getTypeReferenceAsString(true, TypeErasureMethod.NONE, false, false, context))
			if (returnTypeCompare != 0)
				return returnTypeCompare

			// compare parameters
			val param0iterator = $0.parameters.iterator
			val param1iterator = $1.parameters.iterator
			while (param0iterator.hasNext) {

				val param0 = param0iterator.next
				val param1 = param1iterator.next
				val paramCompare = param0.simpleName.compareTo(param1.simpleName)
				if (paramCompare != 0)
					return paramCompare

				val paramTypeCompare = param0.type.getTypeReferenceAsString(true, TypeErasureMethod.NONE, false, false,
					context).compareTo(
					param1.type.getTypeReferenceAsString(true, TypeErasureMethod.NONE, false, false, context))
				if (paramTypeCompare != 0)
					return paramTypeCompare

			}

			return 0

		])

	}

	/**
	 * <p>Returns the annotation reference of the given annotation (passed via type).</p>
	 */
	static def AnnotationReference getAnnotation(AnnotationTarget annotationTarget, Class<?> clazz) {

		return annotationTarget.annotations.findFirst [
			it !== null && it.annotationTypeDeclaration !== null &&
				it.annotationTypeDeclaration.qualifiedName == clazz.canonicalName
		]

	}

	/**
	 * <p>Returns if an element has the given annotation (passed via type).</p>
	 */
	static def boolean hasAnnotation(AnnotationTarget annotationTarget, Class<?> clazz) {

		return annotationTarget.annotations.exists [
			it !== null && it.annotationTypeDeclaration !== null &&
				it.annotationTypeDeclaration.qualifiedName == clazz.canonicalName
		]

	}

	/**
	 * <p>Gives the parameter of an executable with the given index a new type.</p>
	 * 
	 * @bug This is currently not supported by xtend.
	 */
	static def <T extends AnnotationReferenceProvider & TypeReferenceProvider> retypeParameter(
		MutableExecutableDeclaration executable, int index, TypeReference newType, extension T context) {

		copyParameterInternal(executable.parameters.get(index), executable, newType, true, null, context)
		removeParameter(executable, index)
		moveParameter(executable, executable.parameters.size - 1, index)

	}

	/**
	 * <p>Moves the parameters of an executable from one position to the other.</p>
	 * 
	 * @bug This is currently not supported by xtend.
	 */
	@SuppressWarnings("unchecked")
	static def moveParameter(MutableExecutableDeclaration executable, int targetIndex, int sourceIndex) {

		val listParameter = ReflectUtils.getPrivateFieldValue(executable.parameters, "fromList") as List<Object>

		// move parameter by removing and adding
		val source = listParameter.get(sourceIndex)
		listParameter.remove(sourceIndex)
		listParameter.add(targetIndex, source)

	}

	/**
	 * <p>Removes the parameters of an executable.</p>
	 * 
	 * @bug This is currently not supported by xtend.
	 */
	@SuppressWarnings("unchecked")
	static def removeParameter(MutableExecutableDeclaration executable, int index) {

		val listParameter = ReflectUtils.getPrivateFieldValue(executable.parameters, "fromList") as List<Object>
		listParameter.remove(index)

	}

	/**
	 * <p>Removes the annotation of the given type from annotation target. This method is a workaround for
	 * the existing method that seems to fail on removing an annotation based on a new reference.</p>
	 * 
	 * <p>The method returns <code>true</code> if annotation has been found and removed.</p>
	 */
	static def removeAnnotation(MutableAnnotationTarget annotationTarget, Class<?> annotationType) {

		val availableAnnotations = annotationTarget.annotations.filter [
			it.annotationTypeDeclaration.qualifiedName == annotationType.canonicalName
		]
		if (availableAnnotations.size > 0) {
			annotationTarget.removeAnnotation(availableAnnotations.get(0))
			return true
		}
		return false

	}

	/**
	 * <p>Copies annotation of the given type from source to target.</p>
	 */
	static def copyAnnotation(AnnotationTarget src, MutableAnnotationTarget dest, Class<?> annotationType) {

		dest.addAnnotation(src.getAnnotation(annotationType))

	}

	/**
	 * <p>Moves annotation of the given type from source to target.</p>
	 * 
	 * @bug Moving annotations with multiple values leads to exceptions.
	 */
	static def moveAnnotation(MutableAnnotationTarget src, MutableAnnotationTarget dest, Class<?> annotationType) {

		val availableAnnotations = src.annotations.filter [
			it.annotationTypeDeclaration.qualifiedName == annotationType.canonicalName
		]

		if (availableAnnotations.size !== 1)
			throw new IllegalArgumentException(
				'''Cannot move annotation of type "«annotationType»" from "«src»" to "«dest»" because the annotation is not existing exactly once''')

		val _annotation = availableAnnotations.get(0)

		src.removeAnnotation(_annotation)
		dest.addAnnotation(_annotation)

	}

	/**
	 * <p>Copies the given type reference.</p>
	 * 
	 * <p>The method can consider a type map which links  
	 * from a type to a type reference in the current context, which is especially useful for
	 * type parameter declarations (TypeParameterDeclaration). This type reference shall then
	 * be used for the according given type.</p>
	 */
	static def TypeReference copyTypeReference(TypeReference typeReference, TypeMap typeMap,
		extension TypeReferenceProvider context) {

		if (typeReference.isArray) {

			return context.newArrayTypeReference(copyTypeReference(typeReference.arrayComponentType, typeMap, context))

		} else if (typeReference.isWildCard) {

			if (typeReference.lowerBound !== null && typeReference.lowerBound.type !== null)
				return context.newWildcardTypeReferenceWithLowerBound(
					copyTypeReference(typeReference.lowerBound, typeMap, context))
			else if (typeReference.upperBound !== null && typeReference.upperBound.type !== null &&
				typeReference.upperBound.type.qualifiedName != Object.canonicalName)
				return context.newWildcardTypeReference(copyTypeReference(typeReference.upperBound, typeMap, context))
			else
				return context.newWildcardTypeReference

		} else {

			val newTypeArgs = new ArrayList<TypeReference>()

			// use type map for resolving type
			val TypeReference typeReferenceResolved = typeMap.resolve(typeReference)

			// track if there are changes
			var changes = false
			if (typeReferenceResolved !== typeReference)
				changes = true

			// also copy type arguments
			for (typeArg : typeReferenceResolved.actualTypeArguments) {

				val copy = copyTypeReference(typeArg, typeMap, context)
				newTypeArgs.add(copy)

				// track if there are changes
				if (copy !== typeArg)
					changes = true

			}

			// only copy type reference if there is a change
			// this fixes some serious issues because it is not necessary to resolve type if not copied
			if (changes)
				return context.newTypeReference(typeReferenceResolved.type, newTypeArgs)
			else
				return typeReference

		}

	}

	/**
	 * <p>The method copies all type parameters of the given executable (method or constructor)
	 * to another one. In addition it fill the passed lists (if not null) with the names and type names
	 * of the copied parameters. If the target is not set, the method will only fill the lists.</p>
	 * 
	 * <p>It is also possible to specify an amount of parameters in the beginning of the parameters list,
	 * which will not be copied by the <code>skip</code> parameter.</p>
	 * 
	 * <p>If <code>keepAnnotationTypeAdaption</code> is set to <code>true</code>, the method will copy any annotations
	 * declaring type adaption.</p>
	 * 
	 */
	static def void copyParameters(ExecutableDeclaration source, MutableExecutableDeclaration target, int skip,
		boolean keepAnnotationTypeAdaption, TypeMap typeMap, extension TransformationContext context) {

		// copy parameters, but exclude skipped
		var int counter = 0
		for (parameter : source.parameters)
			if (counter++ >= skip)
				copyParameterInternal(parameter, target, null, keepAnnotationTypeAdaption, typeMap, context)

		target.varArgs = source.isVarArgsFixed

	}

	/**
	 * <p>Internal method for copying parameter.</p>
	 * 
	 * <p>If <code>newTypeReference</code> is set, the copied parameter will the according type.</p>
	 * 
	 * <p>If <code>keepAnnotationTypeAdaption</code> is set to <code>true</code>, the method will copy any annotations
	 * declaring type adaption.</p>
	 */
	private static def <T extends AnnotationReferenceProvider & TypeReferenceProvider> MutableParameterDeclaration copyParameterInternal(
		ParameterDeclaration param, MutableExecutableDeclaration target, TypeReference newTypeReference,
		boolean keepAnnotationTypeAdaption, TypeMap typeMap, extension T context) {

		val newParameter = target.addParameter(param.simpleName,
			if(newTypeReference !== null) newTypeReference else param.type.copyTypeReference(typeMap, context))

		// add annotation for type adaption
		if (keepAnnotationTypeAdaption)
			if (param.hasAnnotation(TypeAdaptionRule))
				newParameter.addAnnotation(TypeAdaptionRuleProcessor.copyAnnotation(param, context))

		return newParameter

	}

	/** 
	 * <p>This method returns if the given executable has a variable argument list.</p>
	 * 
	 * @bug This method fixes some problems with the original method that reports this.
	 */
	static def boolean isVarArgsFixed(ExecutableDeclaration source) {

		// seems that the internal implementation of "isVarArgs" is broken (is using "exists", which leads to StackOverflow exceptions in some rare cases)
		if (source.class.simpleName == "XtendMethodDeclarationImpl") {
			val delegate = source.class.getMethod("getDelegate").invoke(source)
			val parameters = delegate.class.getMethod("getParameters").invoke(delegate) as List<?>
			for (parameter : parameters)
				if (parameter.class.getMethod("isVarArg").invoke(parameter) as Boolean)
					return true
			return false

		}

		return source.varArgs

	}

	/**
	 * <p>Returns the (simple) names of all parameters as a list.</p>
	 */
	static def getParameterNames(ExecutableDeclaration executable) {

		executable.parameters.map [
			simpleName
		].toList

	}

	/**
	 * <p>Returns the (qualified) type names of all parameters as a list.</p>
	 */
	static def getParametersTypeNames(ExecutableDeclaration executable, TypeErasureMethod typeErasureMethod,
		boolean javadocHtml, extension TypeReferenceProvider context) {

		executable.parameters.map [
			type.getTypeReferenceAsString(true, typeErasureMethod, javadocHtml, false, context)
		].toList

	}

	/** 
	 * <p>Returns method as string containing information about return type and parameters.</p>
	 * 
	 * <p>The flag <code>qualified</code> determines if the parameter type shall be printed qualified.</p>
	 */
	static def String getMethodAsString(MethodDeclaration methodDeclaration, boolean qualified,
		extension TypeReferenceProvider context) {

		return methodDeclaration.returnType.getTypeReferenceAsString(qualified, TypeErasureMethod.NONE, false, false,
			context) + " " + methodDeclaration.simpleName + "(" + methodDeclaration.parameters.map [
			type.getTypeReferenceAsString(qualified, TypeErasureMethod.NONE, false, false, context)
		].join(", ") + ")"

	}

	/**
	 * <p>Returns the most concrete type of the given list of type references.</p>
	 * 
	 * <p>A type mismatch will be entered in the provided error list. The first found type will be returned then.</p>
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> TypeReference getMostConcreteType(
		List<? extends TypeReference> typeReferences, List<String> errors, TypeMap typeMap, T context) {

		var TypeReference result = null

		for (currentType : typeReferences) {

			if (currentType !== null) {

				if (result === null) {

					result = currentType

				} else if (result.typeReferenceEquals(currentType,
					flexibleTypeComparisonCovariance.curry(context), true, typeMap)) {

					// type is more concrete
					result = currentType

				} else if (!result.typeReferenceEquals(currentType,
					flexibleTypeComparisonInheritance.curry(context), true, typeMap)) {

					// type is incompatible
					errors?.
						add('''Error when searching for concrete type: type "«result.getTypeReferenceAsString(true, TypeErasureMethod.NONE, false, false, context)»" is incompatible with type "«currentType.getTypeReferenceAsString(true, TypeErasureMethod.NONE, false, false, context)»"''')
					return currentType

				}

			}

		}

		return result

	}

	/**
	 * <p>Returns type as string.</p>
	 * 
	 * <p>Flags can control the generation of the output, e.g., if the qualified name shall be used, the output format
	 * shall be HTML, type erasure shall be applied or primitive types shall be replaced by their wrapper classes.</p>
	 */
	static def String getTypeAsString(TypeDeclaration typeDeclaration, boolean qualified, boolean javadocHtml,
		extension TypeReferenceProvider context) {

		var String result

		if (qualified)
			result = typeDeclaration.qualifiedName
		else
			result = typeDeclaration.simpleName

		if (typeDeclaration instanceof ClassDeclaration)
			if (typeDeclaration.typeParameters !== null && typeDeclaration.typeParameters.size > 0) {

				val typeParamList = new ArrayList<String>
				for (typeParam : typeDeclaration.typeParameters)
					typeParamList.add(typeParam.qualifiedName)

				val symbolLt = if(javadocHtml) '&lt;' else '<'
				val symbolGt = if(javadocHtml) '&gt;' else '>'

				result = result + symbolLt + typeParamList.join(',') + symbolGt

			}

		return result

	}

	/**
	 * <p>Returns type reference as string.</p>
	 * 
	 * <p>Flags can control the generation of the output, e.g., if the qualified name shall be used, the output format
	 * shall be HTML, type erasure shall be applied or primitive types shall be replaced by their wrapper classes.</p>
	 */
	static def String getTypeReferenceAsString(TypeReference typeReference, boolean qualified,
		TypeErasureMethod typeErasureMethod, boolean javadocHtml, boolean useWrapperClasses,
		extension TypeReferenceProvider context) {

		var String result

		if (typeReference.isArray) {

			result = ProcessUtils.getTypeReferenceAsString(typeReference.arrayComponentType, qualified,
				typeErasureMethod, javadocHtml, useWrapperClasses, context) + '[]'

		} else if (typeReference.isWildCard) {

			result = '?'

			if (typeReference.upperBound !== null && typeReference.upperBound.type.qualifiedName !=
				Object.canonicalName) {

				val additionalBounds = typeReference.upperBound.getTypeReferenceAsString(qualified, typeErasureMethod,
					javadocHtml, useWrapperClasses, context)
				result = result + ' extends ' + additionalBounds

			} else if (typeReference.lowerBound !== null && typeReference.lowerBound.type !== null) {

				val additionalBounds = typeReference.lowerBound.getTypeReferenceAsString(qualified, typeErasureMethod,
					javadocHtml, useWrapperClasses, context)
				result = result + ' super ' + additionalBounds

			}

		} else {

			if (typeErasureMethod != TypeErasureMethod.NONE && typeReference.type instanceof TypeParameterDeclaration) {

				if ((typeReference.type as TypeParameterDeclaration).upperBounds.size == 1)
					result = (typeReference.type as TypeParameterDeclaration).upperBounds.get(0).
						getTypeReferenceAsString(qualified, typeErasureMethod, javadocHtml, useWrapperClasses, context)
				else {

					if (qualified)
						result = Object.canonicalName
					else
						result = Object.simpleName

				}

			} else {

				if (useWrapperClasses && typeReference == context.primitiveBoolean)
					result = if(qualified) "java.lang.Boolean" else "Boolean"
				else if (useWrapperClasses && typeReference == context.primitiveInt)
					result = if(qualified) "java.lang.Integer" else "Integer"
				else if (useWrapperClasses && typeReference == context.primitiveDouble)
					result = if(qualified) "java.lang.Double" else "Double"
				else if (useWrapperClasses && typeReference == context.primitiveFloat)
					result = if(qualified) "java.lang.Float" else "Float"
				else if (useWrapperClasses && typeReference == context.primitiveChar)
					result = if(qualified) "java.lang.Character" else "Character"
				else if (useWrapperClasses && typeReference == context.primitiveLong)
					result = if(qualified) "java.lang.Long" else "Long"
				else if (useWrapperClasses && typeReference == context.primitiveShort)
					result = if(qualified) "java.lang.Short" else "Short"
				else if (useWrapperClasses && typeReference == context.primitiveByte)
					result = if(qualified) "java.lang.Byte" else "Byte"
				else if (typeReference.type === null) {

					if (qualified)
						result = Object.canonicalName
					else
						result = Object.simpleName

				} else {

					if (qualified)
						result = typeReference.type.qualifiedName
					else
						result = typeReference.type.simpleName

				}

			}

			if (typeErasureMethod != TypeErasureMethod.REMOVE_GENERICS && typeReference.actualTypeArguments !== null &&
				typeReference.actualTypeArguments.size > 0) {

				val typeArgList = new ArrayList<String>
				for (typeArg : typeReference.actualTypeArguments) {
					if (typeErasureMethod == TypeErasureMethod.REMOVE_CONCRETE_TYPE_PARAMTERS)
						typeArgList.add("?")
					else
						typeArgList.add(
							typeArg.getTypeReferenceAsString(qualified, typeErasureMethod, javadocHtml,
								useWrapperClasses, context))
				}

				// in javadoc HTML this is not even needed as parameterized types are NOT part of the method's signature
				if (!javadocHtml)
					result += '<' + typeArgList.join(',') + '>'

			}

		}

		return result

	}

	/**
	 * <p>Returns a string containing the type arguments including angle brackets.</p>
	 * 
	 * <p>The method internally uses {@link #getTypeReferenceAsString}.</p>
	 * 
	 * @see #getTypeReferenceAsString
	 */
	static def getTypeArgumentsAsString(TypeParameterDeclarator typeParameterDeclarator, boolean qualified,
		TypeMap typeMap, extension TypeReferenceProvider context) {

		return if (typeParameterDeclarator.typeParameters.size == 0)
			""
		else {
			'''<«typeParameterDeclarator.getActualTypeArgumentsUsingTypeMap(typeMap, context).map [
							it.getTypeReferenceAsString(qualified, TypeErasureMethod.NONE, false, true, context)
						].join(
							", ")»>'''

		}

	}

	/** 
	 * <p>Returns maximal visibility value from the given visibilities.</p>
	 */
	static def Visibility getMaximalVisibility(Collection<Visibility> visibilities) {

		var Visibility highestFoundVisibility = Visibility::PRIVATE

		for (visibility : visibilities) {

			if (visibility !== null) {

				if (visibility == Visibility::PUBLIC)
					return Visibility::PUBLIC
				if (visibility == Visibility::PROTECTED)
					highestFoundVisibility = Visibility::PROTECTED
				else if (visibility == Visibility::DEFAULT && highestFoundVisibility != Visibility::PROTECTED)
					highestFoundVisibility = Visibility::DEFAULT

			}

		}

		return highestFoundVisibility

	}

	/**
	 * <p>Returns <code>true</code> if the given constructor is the default constructor.</p>
	 */
	static def isDefaultConstructor(MutableConstructorDeclaration constructorDeclaration,
		extension TransformationContext context) {

		val constructorClass = constructorDeclaration.declaringType as MutableClassDeclaration
		return constructorClass.declaredConstructors.size() == 1 &&
			constructorClass.declaredConstructors.get(0).annotations.size == 0 &&
			(constructorClass.primarySourceElement as ClassDeclaration).declaredConstructors.size == 0

	}

	/**
	 * <p>Creates a copy of the given method declaration (without body).</p>
	 * 
	 * <p>The method does not copy the annotations of the method.</p>
	 * 
	 * <p>The method will change the return type if <code>targetReturnType</code> is not <code>null</code>.</p>
	 * 
	 * <p>The type map will be extended by cloned method type parameters if the 
	 * <code>modifyTypeMapByClonedTypeParameters</code> flag is set to <code>true</code>.</p>
	 * 
	 * <p>If <code>keepAnnotationAdaptedMethod</code> is set to <code>true</code>, the method will copy
	 * the {@link AdaptedMethod} annotation.</p>
	 * 
	 * <p>If <code>keepAnnotationNoInterfaceExtraction</code> is set to <code>true</code>, the method will copy 
	 * the {@link NoInterfaceExtract} annotation.</p>
	 * 
	 * <p>If <code>keepAnnotationTraitMethod</code> is set to <code>true</code>, the method will copy any annotations
	 * declaring a trait method.</p>
	 * 
	 * <p>If <code>keepAnnotationTypeAdaption</code> is set to <code>true</code>, the method will copy any annotations
	 * declaring type adaption.</p>
	 * 
	 * @see ImplAdaptionRule
	 * @see TypeAdaptionRule
	 * @see NoInterfaceExtract
	 * @see ExclusiveMethod
	 * @see RequiredMethod
	 * @see ProcessedMethod
	 * @see EnvelopeMethod
	 * @see AdaptedMethod
	 */
	static def MutableMethodDeclaration copyMethod(
		MutableClassDeclaration clazz,
		MethodDeclaration source,
		boolean copyParameters,
		boolean modifyTypeMapByClonedTypeParameters,
		boolean keepAnnotationAdaptedMethod,
		boolean keepAnnotationNoInterfaceExtraction,
		boolean keepAnnotationTraitMethod,
		boolean keepAnnotationTypeAdaption,
		TypeMap typeMap,
		extension TransformationContext context
	) {

		if (copyParameters == false && modifyTypeMapByClonedTypeParameters == false)
			throw new IllegalArgumentException('''Unable to copy method "«source.simpleName»": either type map must be updated or copying of parameters must be handled by copy functionality''')

		if (source.returnType === null || source.returnType.inferred)
			throw new IllegalArgumentException('''Unable to copy method "«source.simpleName»" because the return type is inferred''')

		val newMethod = clazz.addMethod(source.simpleName) [
			it.abstract = source.abstract
			it.docComment = source.docComment
			it.visibility = source.visibility
			it.native = source.native
			it.synchronized = source.synchronized
			it.deprecated = source.deprecated
			it.static = source.static
			it.exceptions = source.exceptions
			it.strictFloatingPoint = source.strictFloatingPoint
		]

		// remember that executable has been cloned
		typeMap?.putExecutableClone(source, newMethod)

		// copy type parameter declarations and update type map
		val typeParameterDeclarationMapClone = if (modifyTypeMapByClonedTypeParameters)
				typeMap
			else
				typeMap.clone
		cloneTypeParameters(source, newMethod, typeParameterDeclarationMapClone, context)

		// copy return type
		newMethod.returnType = copyTypeReference(source.returnType, typeParameterDeclarationMapClone, context)

		// copy parameters
		if (copyParameters)
			source.copyParameters(newMethod, 0, keepAnnotationTypeAdaption, typeParameterDeclarationMapClone, context)

		// add annotation for type adaption (this method shall not stop type adaption)
		if (keepAnnotationAdaptedMethod)
			if (source.hasAnnotation(AdaptedMethod) || source.hasImplAdaptionRule ||
				(source.hasTypeAdaptionRule && !source.hasAnnotation(GetterRule) && !source.hasAnnotation(SetterRule) &&
					!source.hasAnnotation(AdderRule) && !source.hasAnnotation(RemoverRule)))
				newMethod.addAnnotation(AdaptedMethod.newAnnotationReference)

		// add annotation for interface extraction
		if (keepAnnotationNoInterfaceExtraction)
			if (source.hasAnnotation(NoInterfaceExtract))
				newMethod.addAnnotation(NoInterfaceExtract.newAnnotationReference)

		// add annotation for trait methods
		if (keepAnnotationTraitMethod)
			if (source.isTraitMethod)
				newMethod.addAnnotation(AbstractTraitMethodAnnotationProcessor.copyAnnotation(source, context))

		// add annotation for type adaption
		if (keepAnnotationTypeAdaption)
			if (source.hasAnnotation(TypeAdaptionRule))
				newMethod.addAnnotation(TypeAdaptionRuleProcessor.copyAnnotation(source, context))

		return newMethod

	}

	/**
	 * <p>Creates a type reference based on a string with qualified type names. Generics are supported.
	 * A class context can be provided in addition in order to allow it type parameters as supported
	 * types in the given string.</p>
	 */
	static def TypeReference createTypeReference(
		String typeDetailString,
		List<TypeParameterDeclarator> typeParameterDeclarators,
		List<String> errors,
		extension TransformationContext context
	) {

		return createTypeReferenceInternal(null, typeDetailString, typeParameterDeclarators, errors, context)

	}

	/**
	 * <p>Internal method for creating type reference.</p>
	 */
	static def private TypeReference createTypeReferenceInternal(
		String annotationName,
		String typeDetailString,
		List<TypeParameterDeclarator> typeParameterDeclarators,
		List<String> errors,
		extension TransformationContext context
	) {

		val indexOfTypeParamBracket = typeDetailString.indexOf('<')

		// type reference with upper bounds like "? extends Map<String, List<String>> & SomeOtherClass"
		val indexOfExtends = typeDetailString.indexOf(" extends ")
		if (indexOfExtends != -1 && (indexOfExtends < indexOfTypeParamBracket || indexOfTypeParamBracket == -1)) {

			val subTypeString = typeDetailString.substring(indexOfExtends + 9)

			val typeStringWithoutBounds = typeDetailString.substring(0, indexOfExtends).trim

			if (typeStringWithoutBounds != "?")
				errors?.add('''Incorrect type information: expected wildcard instead of "«typeStringWithoutBounds»"''' +
					if (annotationName !== null) ''' (found in type information details of @«annotationName»)''')

			return newWildcardTypeReference(
				createTypeReferenceInternal(annotationName, subTypeString, typeParameterDeclarators, errors, context))

		}

		// type reference with lower bounds like "? super Map<String, List<String>>"
		val indexOfSuper = typeDetailString.indexOf(" super ")
		if (indexOfSuper != -1 && (indexOfSuper < indexOfTypeParamBracket || indexOfTypeParamBracket == -1)) {

			val subTypeString = typeDetailString.substring(indexOfSuper + 7).trim
			val typeStringWithoutBounds = typeDetailString.substring(0, indexOfSuper).trim
			if (typeStringWithoutBounds != "?")
				errors?.add('''Incorrect type information: expected wildcard instead of "«typeStringWithoutBounds»"''' +
					if (annotationName !== null) ''' (found in type information details of @«annotationName»)''')

			return newWildcardTypeReferenceWithLowerBound(
				createTypeReferenceInternal(annotationName, subTypeString, typeParameterDeclarators, errors, context))

		}

		// if array type, go recursive
		if (typeDetailString.lastIndexOf('[') != -1) {

			var typeDetailStringArraySearch = typeDetailString.trim
			if (typeDetailStringArraySearch.lastIndexOf(']') == typeDetailStringArraySearch.length - 1) {
				typeDetailStringArraySearch = typeDetailStringArraySearch.substring(0,
					typeDetailStringArraySearch.length - 1).trim
				if (typeDetailStringArraySearch.lastIndexOf('[') == typeDetailStringArraySearch.length - 1) {
					typeDetailStringArraySearch = typeDetailStringArraySearch.substring(0,
						typeDetailStringArraySearch.length - 1).trim

					return newArrayTypeReference(
						createTypeReferenceInternal(annotationName, typeDetailStringArraySearch,
							typeParameterDeclarators, errors, context))

				}
			}

		}

		// just a wildcard
		if (typeDetailString.trim == "?")
			return newWildcardTypeReference

		// analyze and convert type arguments
		val typeArguments = new ArrayList<TypeReference>
		if (indexOfTypeParamBracket != -1) {
			val lastIndexOfTypeParamBracket = typeDetailString.lastIndexOf('>')
			val typeArgumentStrings = typeDetailString.substring(indexOfTypeParamBracket + 1,
				lastIndexOfTypeParamBracket).splitConsideringParenthesis(',', '<', '>')
			for (typeArgumentString : typeArgumentStrings)
				typeArguments.add(
					createTypeReferenceInternal(annotationName, typeArgumentString, typeParameterDeclarators, errors,
						context))
		}

		// type reference itself
		val typeNameWithoutTypeArguments = if (indexOfTypeParamBracket != -1)
				typeDetailString.substring(0, indexOfTypeParamBracket).trim
			else
				typeDetailString.trim

		// error if type name is empty
		if (typeNameWithoutTypeArguments.trim.length == 0) {

			errors?.add('''Incorrect type information: empty type is not valid''' +
				if (annotationName !== null) ''' (found in type information details of @«annotationName»)''')

			return null

		}

		// check if type exists
		val foundType = findTypeGlobally(typeNameWithoutTypeArguments)
		if (foundType !== null) {

			// check arguments as well
			for (typeArgument : typeArguments) {
				if (typeArgument === null)
					return foundType.newTypeReference
			}

			return foundType.newTypeReference(typeArguments)
		}

		// check if type is available in type parameter list of annotated class (if provided)
		if (typeParameterDeclarators !== null)
			for (typeParameterDeclarator : typeParameterDeclarators)
				for (givenTypeParameter : typeParameterDeclarator.typeParameters)
					if (givenTypeParameter.simpleName == typeNameWithoutTypeArguments)
						return givenTypeParameter.newTypeReference()

		errors?.add('''Incorrect type information: type "«typeNameWithoutTypeArguments»" not found''' +
			if (annotationName !== null) ''' (found in type information details of @«annotationName»)''')

		return null

	}

	/**
	 * <p>This method can be used to put multiple errors and warnings (indicated by keyword) on one element.</p>
	 * 
	 * <p>If there are errors the method will return true, otherwise false.</p>
	 */
	static def boolean reportErrors(Element element, List<String> errors, extension ProblemSupport context) {

		val hasErrors = !errors.isNullOrEmpty
		if (errors !== null) {
			for (error : errors) {
				if (error.startsWith(WARNING_PREFIX))
					element.addWarning(error.substring(WARNING_PREFIX.length, error.length))
				else
					element.addError(error)
			}
			errors.clear
		}
		return hasErrors

	}

	/**
	 * <p>Returns string which can be used to add a link to specified element within Javadoc comment.</p>
	 */
	static def String getJavaDocLinkTo(Element element, TypeReferenceProvider context) {

		var String result

		// resolve parameter type names
		val paramTypeNameList = if (element instanceof ExecutableDeclaration)
				getParametersTypeNames(element, TypeErasureMethod.NONE, true, context)
			else
				null

		if (element instanceof ConstructorDeclaration) {

			result = '''«element.declaringType.qualifiedName»#«element.declaringType.simpleName»(«paramTypeNameList.join(", ")»)'''

		} else if (element instanceof MethodDeclaration) {

			result = '''«element.declaringType.qualifiedName»#«element.simpleName»(«paramTypeNameList.join(", ")»)'''

		} else if (element instanceof TypeDeclaration) {

			result = '''«element.qualifiedName»'''

		} else {

			throw new IllegalArgumentException(
				'''Element type «element.class» it not provided''')

		}

		return String.format("{@link %s}", result)

	}

	/**
	 * <p>This method is able to execute a piece of code that mutates the given element
	 * even though xtend is not in the correct transformation state ("inferred").</p>
	 */
	static def mutate(NamedElement namedElement, Procedures.Procedure0 mutator) {

		val compilationUnit = namedElement.compilationUnit
		val lastPhaseField = compilationUnit.class.getDeclaredField("lastPhase")

		lastPhaseField.accessible = true
		val lastPhaseOldValue = lastPhaseField.get(compilationUnit)
		try {

			val newValue = lastPhaseOldValue.class.enumConstants.get(1) // AnnotationCallback.INFERENCE
			lastPhaseField.set(compilationUnit, newValue)

			mutator.apply

		} finally {

			lastPhaseField.set(compilationUnit, lastPhaseOldValue)
			lastPhaseField.accessible = false

		}

	}

}
