package org.eclipse.xtend.lib.annotation.etai.utils

import java.util.ArrayList
import java.util.HashMap
import java.util.IdentityHashMap
import java.util.List
import java.util.Map
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.ExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableAnnotationTarget
import org.eclipse.xtend.lib.macro.declaration.MutableTypeParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableTypeParameterDeclarator
import org.eclipse.xtend.lib.macro.declaration.Type
import org.eclipse.xtend.lib.macro.declaration.TypeParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeParameterDeclarator
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.services.TypeReferenceProvider

import static extension org.eclipse.xtend.lib.annotation.etai.ExtendedByProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.TraitClassProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.ExtractInterfaceProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*

class TypeMap {

	// mapping data for type map
	private Map<String, TypeReference> hierarchyMapping = new HashMap<String, TypeReference>
	private Map<Type, TypeReference> cloneMapping = new HashMap<Type, TypeReference>

	/**
	 * Retrieves a unique name for a given type (which might be a type parameter declaration).
	 */
	static private def String getUniqueTypeName(Type type) {

		if (type === null)
			return ""

		if (type instanceof TypeParameterDeclaration) {

			val x = type.typeParameterDeclarator
			if (x instanceof ExecutableDeclaration) {
				return x.declaringType.qualifiedName + "::" + x.simpleName + "::" + type.simpleName
			} else if (x instanceof ClassDeclaration) {
				return x.qualifiedName + "::" + type.simpleName
			} else if (x instanceof InterfaceDeclaration) {
				return x.qualifiedName + "::" + type.simpleName
			}

		}

		return type.getQualifiedName()

	}

	/**
	 * <p>Adds mapping information, if a type of a supertype shall be replaced by an actual type reference of the subclass.</p>
	 */
	def void putHierarchyRelation(Type parameterTypeOfSuperType, TypeReference actualTypeReferenceOfSubType) {

		hierarchyMapping.put(parameterTypeOfSuperType.uniqueTypeName, actualTypeReferenceOfSubType)

	}

	/**
	 * <p>Adds mapping information, if a structure has been cloned and also a related type (parameter) has been cloned as well.</p>
	 */
	def void putClone(Type originalType, TypeReference newTypeReference, extension TypeReferenceProvider context) {

		cloneMapping.put(originalType, newTypeReference)

	}

	/**
	 * <p>Returns another reference to the given type, if it has been cloned before.</p>
	 * 
	 * @see #putClone
	 */
	def TypeReference getClone(Type originalType) {

		return cloneMapping.get(originalType)

	}

	/**
	 * <p>Resolves type reference from given type map. The method considers all types of mapping information</p>
	 * 
	 * @see #putHierarchyRelation
	 * @see #putClone
	 */
	static def TypeReference resolve(TypeMap typeMap, TypeReference typeReference) {

		var TypeReference result = typeReference

		if (typeMap !== null) {

			// follow hierarchy mapping completely
			var TypeReference currentTypeReference = result
			{
				val cycleProtectionTypeReference = new IdentityHashMap<TypeReference, Object>
				while (currentTypeReference !== null) {

					currentTypeReference = typeMap.hierarchyMapping.get(currentTypeReference.type.uniqueTypeName)

					// protect from cycles
					if (cycleProtectionTypeReference.containsKey(currentTypeReference))
						throw new IllegalStateException("Internal error: cycle within type map detected (hierarchy)")

					if (currentTypeReference !== null) {
						result = currentTypeReference
						cycleProtectionTypeReference.put(currentTypeReference, null)
					}

				}

			}

			// follow cloned paths
			currentTypeReference = result
			{

				val cycleProtectionTypeReference = new IdentityHashMap<TypeReference, Object>
				cycleProtectionTypeReference.put(currentTypeReference, null)
				while (currentTypeReference !== null) {

					currentTypeReference = typeMap.cloneMapping.get(currentTypeReference.type)

					// protect from cycles
					if (cycleProtectionTypeReference.containsKey(currentTypeReference))
						throw new IllegalStateException("Internal error: cycle within type map detected (cloning)")

					if (currentTypeReference !== null) {
						result = currentTypeReference
						cycleProtectionTypeReference.put(currentTypeReference, null)
					}

				}

			}

		}

		return result

	}

	/**
	 * <p>This method clones the type map.</p>
	 */
	override TypeMap clone() {

		val newTypeMap = new TypeMap
		newTypeMap.hierarchyMapping = new HashMap<String, TypeReference>(hierarchyMapping)
		newTypeMap.cloneMapping = new HashMap<Type, TypeReference>(cloneMapping)
		return newTypeMap

	}

	/**
	 * <p>Creates type map for class hierarchy considering the type arguments for supertypes.</p>
	 */
	static def void fillTypeMapFromTypeHierarchy(Type type, TypeMap typeMap, extension TransformationContext context) {

		fillTypeMapFromTypeHierarchy(type, null, typeMap, context)

	}

	static private def void fillTypeMapFromTypeHierarchy(Type type, List<Type> processedTypes, TypeMap typeMap,
		extension TransformationContext context) {

		var processedTypesVar = if (processedTypes === null)
				new ArrayList<Type>
			else
				processedTypes

		if (type instanceof ClassDeclaration) {

			// go through extended classes
			if (type.isExtendedClass) {
				val traitClassRefs = type.getTraitClassesAppliedToExtended(null, context)
				if (traitClassRefs !== null)
					for (traitClassRef : traitClassRefs) {
						fillTypeMapFromTypeHierarchy(typeMap, traitClassRef.type, processedTypesVar,
							(traitClassRef.type as ClassDeclaration).typeParameters,
							traitClassRef.actualTypeArguments, context)
					}
			}

			// go through used trait classes
			if (type.isTraitClass) {
				val traitClassRefs = type.getTraitClassesDirectlyUsedByTraitClass(null, context)
				if (traitClassRefs !== null)
					for (traitClassRef : traitClassRefs) {
						fillTypeMapFromTypeHierarchy(typeMap, traitClassRef.type, processedTypesVar,
							(traitClassRef.type as ClassDeclaration).typeParameters,
							traitClassRef.actualTypeArguments, context)
					}
			}

			val classDeclaration = type as ClassDeclaration
			if (classDeclaration.extendedClass !== null && classDeclaration.extendedClass.type !== null) {
				val superType = classDeclaration.extendedClass.type as ClassDeclaration
				if (superType !== null)
					fillTypeMapFromTypeHierarchy(typeMap, superType, processedTypesVar, superType.typeParameters,
						classDeclaration.extendedClass.actualTypeArguments, context)
			}

			for (interfaceReference : classDeclaration.implementedInterfaces) {
				val superType = interfaceReference.type as InterfaceDeclaration
				if (superType !== null)
					fillTypeMapFromTypeHierarchy(typeMap, superType, processedTypesVar, superType.typeParameters,
						interfaceReference.actualTypeArguments, context)
			}

			// process interface, which is not extracted, yet
			if (classDeclaration.qualifiedName.isUnprocessedClassExtraction) {

				val mirrorInterface = findTypeGlobally(classDeclaration.getMirrorInterfaceName)
				if (mirrorInterface instanceof InterfaceDeclaration) {

					val interfaceTypeArguments = new ArrayList<TypeReference>
					for (typeParameter : classDeclaration.typeParameters)
						interfaceTypeArguments.add(typeParameter.newSelfTypeReference)

					fillTypeMapFromTypeHierarchy(typeMap, mirrorInterface, processedTypesVar,
						mirrorInterface.typeParameters, interfaceTypeArguments, context)
				}

			}

		} else if (type instanceof InterfaceDeclaration) {

			val interfaceDeclaration = type as InterfaceDeclaration

			for (interfaceReference : interfaceDeclaration.extendedInterfaces) {
				val superType = interfaceReference.type as InterfaceDeclaration
				if (superType !== null)
					fillTypeMapFromTypeHierarchy(typeMap, superType, processedTypesVar, superType.typeParameters,
						interfaceReference.actualTypeArguments, context)
			}

		}

	}

	static private def void fillTypeMapFromTypeHierarchy(
		TypeMap typeMap,
		Type type,
		List<Type> processedTypes,
		Iterable<? extends TypeParameterDeclaration> typeParamDecls,
		Iterable<? extends TypeReference> typeArgs,
		extension TransformationContext context
	) {

		// recursion protection
		if (processedTypes.contains(type))
			return;
		processedTypes.add(type)

		// create available map
		var int typeArgumentCount = 0
		val typeParameterIterator = typeParamDecls.iterator
		for (typeArgument : typeArgs) {
			val typeParameter = typeParameterIterator.next
			typeMap.putHierarchyRelation(typeParameter, typeArgument)
			typeArgumentCount++
		}

		// fill left-over map, where no type argument is given explicitly
		while (typeArgumentCount < typeParamDecls.size) {
			if (typeParamDecls.get(typeArgumentCount).upperBounds.size > 0)
				typeMap.putHierarchyRelation(typeParamDecls.get(typeArgumentCount),
					typeParamDecls.get(typeArgumentCount).upperBounds.get(0))
			else
				typeMap.putHierarchyRelation(typeParamDecls.get(typeArgumentCount), object)
			typeArgumentCount++
		}

		// recursively follow type hierarchy
		fillTypeMapFromTypeHierarchy(type, processedTypes, typeMap, context)

	}

	/**
	 * <p>Adds the annotation for suppressing "unused" warnings to the given target.</p>
	 */
	static def void addSuppressWarningUnused(MutableAnnotationTarget target, extension TransformationContext context) {

		if (!target.hasAnnotation(SuppressWarnings)) {

			// create new annotation
			target.addAnnotation(SuppressWarnings.newAnnotationReference [
				setStringValue("value", "unused")
			])

		} else {

			// retrieve info from existing annotation and re-create
			val suppressWarningsAnnotation = target.getAnnotation(SuppressWarnings)
			val suppressedWarnings = suppressWarningsAnnotation.getStringArrayValue("value")
			if (!suppressedWarnings.contains("unused")) {

				target.removeAnnotation(suppressWarningsAnnotation)
				suppressedWarnings.add("unused")
				target.addAnnotation(SuppressWarnings.newAnnotationReference [
					setStringValue("value", suppressedWarnings)
				])

			}

		}

	}

	/**
	 * <p>Retrieves type arguments for given class or interface declaration considering type map.</p>
	 */
	static def List<TypeReference> getActualTypeArgumentsUsingTypeMap(TypeParameterDeclarator typeParameterDeclaration,
		TypeMap typeMap, extension TypeReferenceProvider context) {

		val typeArgs = new ArrayList<TypeReference>

		for (typeParameter : typeParameterDeclaration.typeParameters) {

			var TypeReference typeReferenceResolved = typeMap.resolve(typeParameter.newTypeReference)
			typeArgs.add(typeReferenceResolved)

		}

		return typeArgs

	}

	/**
	 * <p>Clones type parameters from source object to destination object and also updates given type map
	 * by mappings to newly created type parameters.</p>
	 */
	static def cloneTypeParameters(TypeParameterDeclarator src, MutableTypeParameterDeclarator dest, TypeMap typeMap,
		extension TypeReferenceProvider context) {

		cloneTypeParametersWithoutUpperBounds(src, dest, typeMap, context)
		cloneTypeParametersRefineUpperBounds(src, dest, typeMap, context)

	}

	/**
	 * <p>Clones type parameters from source object to destination object and also updates given type map
	 * by mappings to newly created type parameters.</p>
	 * 
	 * <p>This method does not consider upper bounds.</p>
	 */
	static def cloneTypeParametersWithoutUpperBounds(TypeParameterDeclarator src, MutableTypeParameterDeclarator dest,
		TypeMap typeMap, extension TypeReferenceProvider context) {

		// copy type parameters (without type references)
		for (typeParameter : src.typeParameters) {
			val newTypeParameter = dest.addTypeParameter(typeParameter.simpleName)
			if (typeMap !== null)
				typeMap.putClone(typeParameter, newTypeParameter.newTypeReference, context)
		}

	}

	/**
	 * <p>Clones type parameters from source object to destination object and also updates the given type map
	 * by mappings to newly created type parameters.</p>
	 * 
	 * <p>This method just refines upper bounds, i.e. it considers that the type parameters have already
	 * been cloned before {@link #cloneTypeParametersWithoutUpperBounds}.</p>
	 */
	static def cloneTypeParametersRefineUpperBounds(TypeParameterDeclarator src, MutableTypeParameterDeclarator dest,
		TypeMap typeMap, extension TypeReferenceProvider context) {

		// set upper bound afterwards (type map must be complete and "copyTypeReference"
		// method must be used
		for (typeParameter : src.typeParameters) {

			if (typeParameter.upperBounds.size > 0) {

				val newTypeParameter = typeMap.getClone(typeParameter).type as MutableTypeParameterDeclaration
				val newUpperBounds = new ArrayList<TypeReference>
				for (upperBound : typeParameter.upperBounds)
					newUpperBounds.add(copyTypeReference(upperBound, typeMap, context))
				newTypeParameter.upperBounds = newUpperBounds

			}

		}

	}

}
