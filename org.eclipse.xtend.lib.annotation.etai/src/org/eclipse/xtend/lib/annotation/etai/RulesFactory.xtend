package org.eclipse.xtend.lib.annotation.etai

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.NamedElement
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.file.FileLocations
import org.eclipse.xtend.lib.macro.services.TypeLookup
import org.eclipse.xtend.lib.macro.services.TypeReferenceProvider

import static extension org.eclipse.xtend.lib.annotation.etai.ExtendedByProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.FactoryMethodRuleProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.TraitClassProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*

/**
 * <p>This annotation can be used in order to generate a factory method for constructing an
 * object of the annotated class. It must be used in order to generate an
 * object. All public (or default) constructors of the class will become protected.
 * The factory method will be generated for all subclasses
 * annotated by {@link ApplyRules}.</p>
 * 
 * <p>The annotation can only be used once in the type hierarchy, i.e., also specified names cannot
 * be changed then.</p>
 * 
 * @see ApplyRules
 * @see GeneratedFactoryMethod
 * @see GeneratedFactoryClass
 */
@Target(ElementType.TYPE)
@Active(FactoryMethodRuleProcessor)
annotation FactoryMethodRule {

	/**
	 * <p>The (static) factory method will get the name of this value.</p>
	 * 
	 * <p>If the factory method name contains a <code>%</code> symbol, this symbol will be replaced
	 * by the currently adapted class name.</p>
	 */
	String factoryMethod = "create%"

	/**
	 * <p>This value can be set in order to execute an initialization method after the whole object has
	 * been constructed (via factory method).</p>
	 * 
	 * <p>The init method must be a non-static method without parameters and <code>void</code> return type.</p>
	 * 
	 * <p>The value will be also applied for all derived classes. It cannot be
	 * changed by a derived class.</p>
	 */
	String initMethod = ""

	/**
	 * <p>If a value is set, the factory method is put into a static inner class called
	 * <code>Factory</code>, which is generated for each adapted class (it cannot be
	 * generated on demand). The factory will be instantiated automatically an provided
	 * via a generated static field available in the adapted class. The name of this
	 * field is given by this value.</p>
	 * 
	 * @see GeneratedFactoryClass
	 * @see GeneratedFactoryInstance
	 * @see FactoryMethodRule#factoryInterface
	 * @see FactoryMethodRule#factoryInstanceFinal
	 * @see SetAdaptionVariable
	 */
	String factoryInstance = ""

	/**
	 * <p>Determines if the <code>static</code> factory instance variable will be declared
	 * <code>final</code>.</p>
	 * 
	 * @see FactoryMethodRule#factoryInstance
	 */
	boolean factoryInstanceFinal = true

	/**
	 * <p>Determines if the generated factory class shall extend the potentially
	 * generated factory class of a parent class.</p>
	 * 
	 * @see FactoryMethodRule#factoryInstance
	 */
	boolean factoryClassDerived = false

	/**
	 * <p>If a factory is used, which is determined by the setting of <code>factoryInstance</code>,
	 * this setting specifies if the generated factory class shall implement the given interface.</p>
	 * 
	 * @see GeneratedFactoryClass
	 * @see GeneratedFactoryInstance
	 * @see FactoryMethodRule#factoryInstance
	 */
	Class<?> factoryInterface = Object

	/**
	 * <p>This attribute has the same purpose as <code>factoryInterface</code>. However, it
	 * supports the usage of an adaption variable that is resolved during the generation
	 * of the factory class. The variable can be set via {@link SetAdaptionVariable}.</p>
	 * 
	 * <p>If the variable is not set, no interface will be used.</p>
	 * 
	 * @see GeneratedFactoryClass
	 * @see GeneratedFactoryInstance
	 * @see FactoryMethodRule#factoryInterface
	 * @see SetAdaptionVariable
	 */
	String factoryInterfaceVariable = ""

	/**
	 * <p>The return type of the generated factory method matches the class for which the
	 * factory method is generated. However, with this attribute an adaption rule can be specified. If the
	 * specified string is not empty, the rule will be applied in order to
	 * determine the return type of the factory method.</p>
	 */
	String returnTypeAdaptionRule = ""

}

/**
 * <p>For each trait class listed in this annotation, the construction will be handled automatically
 * in the factory method after the main construction and before executing the initialization method
 * ({@link FactoryMethodRule#initMethod}). This also means that the constructors of the extended class must not
 * call the methods for constructing the trait class object.</p>
 * 
 * <p>The automated construction is not only applied to the annotated class, but also to sub classes. This 
 * behavior can be stopped via {@link ConstructRuleDisable}. 
 * 
 * <p>Potential construction parameters ({@link ConstructorMethod}) of according
 * trait classes will be injected into the factory method (in specified order).
 * If multiple constructor methods are given by a trait class, the algorithm injecting the
 * parameters will build cartesian products. If any parameter is
 * contained multiple times, which is determined by its simple name, it will only be injected once and
 * used internally multiple times for each construction.</p>
 * 
 * <p>The list can only be used if also a factory method is generated, i.e.,
 * {@link FactoryMethodRule} is used. In addition to that, only trait classes which extend the
 * annotated class can be specified.</p>
 * 
 * @see ConstructRuleAuto
 * @see ConstructRuleDisable
 * @see FactoryMethodRule
 * @see ExtendedBy
 * @see ConstructorMethod
 */
@Target(ElementType.TYPE)
@Active(ConstructRuleProcessor)
annotation ConstructRule {
	Class<?> [] value = #[]
}

/**
 * <p>Works like {@link ConstructRule}. However, if this annotation is used,
 * all classes that are extending the currently annotated class are chosen for being created
 * automatically.</p>
 * 
 * @see ConstructRule
 */
@Target(ElementType.TYPE)
@Active(ConstructRuleAutoProcessor)
annotation ConstructRuleAuto {
}

/**
 * <p>With this annotation the automatic construction setting specified by {@link ConstructRule}
 * or {@link ConstructRuleAuto} can be disabled for the annotated class and all subclasses. This
 * implies that only trait classes can be specified that have also been specified by an
 * according auto construction rule ({@link ConstructRule}) in a superclass before.</p>
 * 
 * <p>If the automatic construction has been disabled for a trait class, it is necessary to
 * manually construct the trait class during the construction of the annotated class. This
 * can be done as described for {@link ConstructorMethod}. However, instead of calling 
 * <code>new$A(intParam)</code> for constructing trait class <code>A</code> the
 * following call must be used: <code>auto$new$A(intParam)</code>.</p>
 * 
 * @see ConstructRule
 * @see ConstructRuleAuto
 */
@Target(ElementType.TYPE)
@Active(ConstructRuleDisableProcessor)
annotation ConstructRuleDisable {
	Class<?> [] value = #[]
}

/**
 * <p>Active Annotation Processor for {@link FactoryMethodRule}.</p>
 * 
 * @see FactoryMethodRule
 */
class FactoryMethodRuleProcessor extends RuleProcessor<ClassDeclaration, MutableClassDeclaration> {

	final static public String REGISTER_OBJECT_CONSTRUCTION_ERROR = "Internal error: registering object construction via factory method"
	final static public String UNREGISTER_OBJECT_CONSTRUCTION_ERROR = "Internal error: unregistering object construction via factory method"
	final static public String CHECK_OBJECT_CONSTRUCTION_ERROR = "Internal error: the construction of an object without factory method has been detected"

	/**
	 * <p>This structure shall store at runtime if factory method are used for the construction of objects.</p>
	 */
	static final protected Map<Thread, List<Object>> MAP_OBJECT_CONSTRUCTION_VIA_FACTORY_METHOD_REGISTRY = new HashMap<Thread, List<Object>>

	/**
	 * <p>This method must be called by a factory method in order to be allowed to construct
	 * the next object that would requires a factory method in order to be constructed.</p>
	 */
	static synchronized def boolean registerObjectConstructionViaFactory() {

		val thread = Thread.currentThread

		var List<Object> registeredForThread = MAP_OBJECT_CONSTRUCTION_VIA_FACTORY_METHOD_REGISTRY.get(thread)
		if (registeredForThread === null) {
			registeredForThread = new ArrayList<Object>
			MAP_OBJECT_CONSTRUCTION_VIA_FACTORY_METHOD_REGISTRY.put(thread, registeredForThread)
		}

		// add null to the end (object has not been created, yet)
		registeredForThread.add(null)

	}

	/**
	 * <p>This method can be called by constructor in order to check if it has been called from
	 * within a factory method.</p>
	 * 
	 * <p>The method checks if any registration has been request before
	 * via {@link #registerObjectConstructionViaFactory}. This method then requires either a <code>null</code>
	 * in the list of the current thread or the currently constructed object (which will be put to
	 * the end of the list in case of <code>null</code>).</p>
	 * 
	 * <p>Please note, that a sophisticated check is not possible with the applied schema.
	 * If there are internal calls of other constructors, the detection will
	 * trigger an error. However, it might be detected for the outside construction because all
	 * construction checks will be performed after calling the regular constructor.</p>
	 */
	static synchronized def boolean checkObjectConstructionViaFactory(Object checkObject) {

		val registeredForThread = MAP_OBJECT_CONSTRUCTION_VIA_FACTORY_METHOD_REGISTRY.get(Thread.currentThread)
		if (registeredForThread === null)
			return false

		// current object must override null in list
		if (registeredForThread.get(registeredForThread.size - 1) === null) {

			registeredForThread.set(registeredForThread.size - 1, checkObject)
			return true

		}

		// return true if last object within list is current object
		return registeredForThread.get(registeredForThread.size - 1) === checkObject

	}

	/**
	 * <p>This method must be called by a factory method after an object has been constructed.</p>
	 */
	static synchronized def boolean unregisterObjectConstructionViaFactory() {

		val thread = Thread.currentThread

		val registeredForThread = MAP_OBJECT_CONSTRUCTION_VIA_FACTORY_METHOD_REGISTRY.get(thread)
		if (registeredForThread === null)
			return false

		// remove latest object
		registeredForThread.remove(registeredForThread.size - 1)
		if (registeredForThread.size === 0)
			MAP_OBJECT_CONSTRUCTION_VIA_FACTORY_METHOD_REGISTRY.remove(thread)

		return true

	}

	/** 
	 * <p>Helper class for storing information about auto adaption.</p>
	 */
	static class FactoryMethodRuleInfo {

		public String factoryMethod = null
		public String initMethod = null
		public String factoryInstance = null
		public boolean factoryInstanceFinal = true
		public boolean factoryClassDerived = true
		public TypeDeclaration factoryInterface = null
		public String factoryInterfaceVariable = null
		public String returnTypeAdaptionRule = null

	}

	protected override getProcessedAnnotationType() {
		FactoryMethodRule
	}

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof ClassDeclaration
	}

	/**
	 * <p>The method will return the annotation's information from the current class.</p>
	 */
	static private def FactoryMethodRuleInfo createFactoryMethodRuleInfo(ClassDeclaration classDeclaration) {

		val annotationFactoryMethodRule = classDeclaration.getAnnotation(FactoryMethodRule)

		if (annotationFactoryMethodRule !== null) {

			val result = new FactoryMethodRuleInfo()

			val factoryMethod = annotationFactoryMethodRule.getStringValue("factoryMethod")
			val initMethod = annotationFactoryMethodRule.getStringValue("initMethod")
			val factoryInstance = annotationFactoryMethodRule.getStringValue("factoryInstance")
			val factoryInstanceFinal = annotationFactoryMethodRule.getBooleanValue("factoryInstanceFinal")
			val factoryClassDerived = annotationFactoryMethodRule.getBooleanValue("factoryClassDerived")
			val factoryInterface = annotationFactoryMethodRule.getClassValue("factoryInterface")
			val factoryInterfaceVariable = annotationFactoryMethodRule.getStringValue("factoryInterfaceVariable")
			val returnTypeAdaptionRule = annotationFactoryMethodRule.getStringValue("returnTypeAdaptionRule")

			if (factoryMethod !== null)
				result.factoryMethod = factoryMethod
			if (initMethod !== null)
				result.initMethod = initMethod
			if (factoryInstance !== null)
				result.factoryInstance = factoryInstance
			if (factoryInterface !== null)
				result.factoryInterface = factoryInterface.type as TypeDeclaration
			if (factoryInterfaceVariable !== null)
				result.factoryInterfaceVariable = factoryInterfaceVariable
			if (returnTypeAdaptionRule !== null)
				result.returnTypeAdaptionRule = returnTypeAdaptionRule
			result.factoryInstanceFinal = factoryInstanceFinal
			result.factoryClassDerived = factoryClassDerived

			return result

		}

		return null

	}

	/**
	 * <p>Returns the information about specified factory method settings for the current class. 
	 * The method will search recursively through supertypes and gather information if applicable.
	 * If no specification is found, null is returned.</p>
	 */
	static def <T extends TypeLookup & TypeReferenceProvider> FactoryMethodRuleInfo getFactoryMethodRuleInfo(
		ClassDeclaration classDeclaration, List<String> errors, extension T context) {

		return getFactoryMethodRuleInfoInternal(classDeclaration, classDeclaration, errors, context)

	}

	static private def <T extends TypeLookup & TypeReferenceProvider> FactoryMethodRuleInfo getFactoryMethodRuleInfoInternal(
		ClassDeclaration currentClass, ClassDeclaration rootClass, List<String> errors, extension T context) {

		val result = new ArrayList<FactoryMethodRuleInfo>

		// retrieve info from super class
		if (currentClass.extendedClass?.type !== null) {

			val superTypeResult = getFactoryMethodRuleInfoInternal(currentClass.extendedClass?.type as ClassDeclaration,
				rootClass, errors, context)

			if (superTypeResult !== null)
				result.add(superTypeResult)

		}

		// retrieve info from trait classes
		for (traitClassRef : currentClass.getTraitClassesAppliedToExtended(null, context)) {

			val TraitClassResult = getFactoryMethodRuleInfoInternal(traitClassRef?.type as ClassDeclaration, rootClass,
				errors, context)

			if (TraitClassResult !== null)
				result.add(TraitClassResult)

		}

		// retrieve info from current class
		val currentResult = createFactoryMethodRuleInfo(currentClass)
		if (currentResult !== null)
			result.add(currentResult)

		// check for ambiguity
		if (currentClass === rootClass && result.size > 1)
			errors?.add('''Ambiguous factory method rules have been found in supertypes and/or trait classes''')

		// return one result
		if (result.size == 0)
			return null
		return result.get(0)

	}

	override void doValidate(ClassDeclaration annotatedClass, extension ValidationContext context) {

		super.doValidate(annotatedClass, context)

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// retrieve factory method rule data
		val factoryMethodRuleInfo = annotatedClass.createFactoryMethodRuleInfo()

		// factory method name must not be null
		if (factoryMethodRuleInfo.factoryMethod.nullOrEmpty)
			xtendClass.addError('''An empty factory method name is not allowed''')

		if (factoryMethodRuleInfo.factoryInterface !== null &&
			factoryMethodRuleInfo.factoryInterface.qualifiedName != Object.canonicalName) {

			// only one specification for the factory interface is allowed
			if (!factoryMethodRuleInfo.factoryInterfaceVariable.nullOrEmpty)
				xtendClass.addError('''Cannot specify both "factoryInterface" and "factoryInterfaceVariable"''')

			// factory interface must be an interface
			if (factoryMethodRuleInfo.factoryInterface.qualifiedName != Object.canonicalName &&
				!(factoryMethodRuleInfo.factoryInterface instanceof InterfaceDeclaration))
				xtendClass.addError('''The specified factory interface must be an interface''')

		}

		if ((factoryMethodRuleInfo.factoryInterface !== null &&
			factoryMethodRuleInfo.factoryInterface.qualifiedName != Object.canonicalName) ||
			!factoryMethodRuleInfo.factoryInterfaceVariable.nullOrEmpty) {

			// factory interface must only be set if also instance is specified
			if (factoryMethodRuleInfo.factoryInstance.nullOrEmpty)
				xtendClass.
					addError('''If a factory interface is specified, also the factory instance name must be specified''')

		}

		if (!factoryMethodRuleInfo.initMethod.nullOrEmpty) {

			// factory interface must only be set if also instance is specified
			if (!annotatedClass.getMethodClosure(null, null, true, false, false, true, false, context).exists [
				it.simpleName == factoryMethodRuleInfo.initMethod && it.parameters.size == 0 && it.returnType.isVoid &&
					(it.visibility == Visibility::PUBLIC || it.visibility == Visibility::PROTECTED)
			])
				xtendClass.
					addError('''A non-static init method named "«factoryMethodRuleInfo.initMethod»" without parameters and void return type must be declared and visible within this class.''')

		}

	}

}

/**
 * <p>Active Annotation Processor for {@link ConstructRule}.</p>
 * 
 * @see ConstructRule
 */
class ConstructRuleProcessor extends RuleProcessor<ClassDeclaration, MutableClassDeclaration> {

	protected override getProcessedAnnotationType() {
		ConstructRule
	}

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof ClassDeclaration
	}

	/**
	 * <p>Retrieves the trait classes which shall be constructed automatically inside the factory method
	 * of the given and derived classes.</p>
	 * 
	 * <p>If the <code>recursive</code> flag is set, also settings from superclasses will be collected.</p> 
	 */
	static def <T extends TypeLookup & FileLocations & TypeReferenceProvider> List<ClassDeclaration> getTraitClassesAutoConstruct(
		ClassDeclaration annotatedClass,
		boolean recursive,
		extension T context
	) {

		// return valid trait classes
		val result = new ArrayList<ClassDeclaration>
		for (traitClassRef : getRefsTraitClassesAutoConstruct(annotatedClass, recursive, context)) {
			if (traitClassRef !== null && traitClassRef.type instanceof ClassDeclaration)
				result.add(traitClassRef.type as ClassDeclaration)
		}
		return result

	}

	static private def <T extends TypeLookup & FileLocations & TypeReferenceProvider> List<TypeReference> getRefsTraitClassesAutoConstruct(
		ClassDeclaration annotatedClass,
		boolean recursive,
		extension T context
	) {

		val result = new ArrayList<TypeReference>

		if (annotatedClass === null)
			return result

		val searchedClasses = if(recursive) annotatedClass.getSuperClasses(true).reverse else #[annotatedClass]

		for (currentClass : searchedClasses) {

			val annotationApplyRules = currentClass.getAnnotation(ConstructRule)

			if (annotationApplyRules !== null) {

				// use specified trait classes
				val currentTraitClassAutoConstruction = annotationApplyRules.getClassArrayValue("value")
				if (currentTraitClassAutoConstruction !== null)
					for (typeRef : currentTraitClassAutoConstruction)
						result.add(typeRef)

			} else if (currentClass.hasAnnotation(ConstructRuleAuto)) {

				// collect all relevant trait classes
				val currentTraitClassAutoConstruction = currentClass.getTraitClassesAppliedToExtended(null, context)
				if (currentTraitClassAutoConstruction !== null)
					for (typeRef : currentTraitClassAutoConstruction)
						if (typeRef !== null && typeRef.type instanceof ClassDeclaration &&
							(typeRef.type as ClassDeclaration).hasNonEmptyConstructorMethod(context))
							result.add(typeRef)

			}

		}

		return result

	}

	/**
	 * <p>Returns <code>true</code> if the class is annotated by {@link ConstructRuleAuto}.</p>
	 * 
	 * @see ConstructRuleAuto
	 */
	def boolean isConstructRuleAuto() {
		return false
	}

	override void doValidate(ClassDeclaration annotatedClass, extension ValidationContext context) {

		super.doValidate(annotatedClass, context)

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// there must not be another setting in type hierarchy
		if (annotatedClass.getFactoryMethodRuleInfo(null, context) === null)
			xtendClass.
				addError('''Trait class auto construction cannot be used without specifying a factory method rules for class hierarchy via @FactoryMethodRule''')

		// check that class shall be extended
		if (!annotatedClass.isExtendedClass)
			xtendClass.
				addError('''Trait class auto construction must only be used if class is extended via @ExtendedBy or @ExtendedByAuto''')

		// checks in context of used trait classes
		val traitClassAutoConstructRefs = annotatedClass.getRefsTraitClassesAutoConstruct(false, context)
		val traitClassCurrentClassRefs = annotatedClass.getTraitClassesAppliedToExtended(null, context)

		// check that only one annotation of the same class is applied
		if (isConstructRuleAuto && annotatedClass.hasAnnotation(ConstructRule))
			xtendClass.addError('''Cannot apply both @ConstructRule and @ConstructRuleAuto''')

		// require at least one specified class
		if (!isConstructRuleAuto && traitClassAutoConstructRefs.size <= 0)
			xtendClass.
				addError('''Annotation @«processedAnnotationType.simpleName» requires at least one specified trait class''')

		val traitClassCurrentClassTypes = new ArrayList<ClassDeclaration>
		for (traitClassCurrentClassRef : traitClassCurrentClassRefs)
			traitClassCurrentClassTypes.add(traitClassCurrentClassRef?.type as ClassDeclaration)

		for (traitClassAutoConstructRef : traitClassAutoConstructRefs) {

			// retrieve type
			if (traitClassAutoConstructRef === null || traitClassAutoConstructRef.type === null) {
				xtendClass.
					addError('''Could not find one of the given trait classes specified in @«processedAnnotationType.simpleName»''')
				return
			}

			val traitClassAutoConstruct = traitClassAutoConstructRef.type as ClassDeclaration

			// check that class is actually extended by the specified class
			if (!traitClassCurrentClassTypes.contains(traitClassAutoConstruct))
				xtendClass.
					addError('''Trait class "«traitClassAutoConstruct.simpleName»" is not extending this class via @ExtendedBy or @ExtendedByAuto''')

			// check constructor methods of trait class
			if (!traitClassAutoConstruct.hasNonEmptyConstructorMethod(context))
				xtendClass.
					addError('''Trait class "«traitClassAutoConstruct.simpleName»" does not contain constructor methods with parameters, so it is not applicable to auto construction''')

			for (constructorMethod : traitClassAutoConstruct.getConstructorMethods(context)) {

				// must not specify varargs
				if (constructorMethod.isVarArgsFixed)
					xtendClass.
						addError('''Constructor method "«constructorMethod.simpleName»" of trait class "«traitClassAutoConstruct.simpleName»" is not applicable to auto construction: variable argument lists are not supported''')

			}

		}

	}

}

/**
 * <p>Active Annotation Processor for {@link ConstructRule}.</p>
 * 
 * @see ConstructRuleAuto
 */
class ConstructRuleAutoProcessor extends ConstructRuleProcessor {

	protected override getProcessedAnnotationType() {
		ConstructRuleAuto
	}

	override boolean isConstructRuleAuto() {
		return true
	}

}

/**
 * <p>Active Annotation Processor for {@link ConstructRuleDisable}.</p>
 * 
 * @see ConstructRuleDisable
 */
class ConstructRuleDisableProcessor extends RuleProcessor<ClassDeclaration, MutableClassDeclaration> {

	protected override getProcessedAnnotationType() {
		ConstructRuleDisable
	}

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof ClassDeclaration
	}

	/**
	 * <p>Retrieves the trait classes which shall be not be constructed automatically even though a rule for
	 * automatic construction has been set for.</p>
	 * 
	 * <p>If the <code>recursive</code> flag is set, also settings from superclasses will be collected.</p>
	 * 
	 * @see ConstructRule
	 */
	static def List<ClassDeclaration> getTraitClassesAutoConstructDisabled(ClassDeclaration annotatedClass,
		boolean recursive, extension TypeLookup context) {

		// return valid trait classes
		val result = new ArrayList<ClassDeclaration>
		for (traitClassRef : getRefsTraitClassesAutoConstructDisabled(annotatedClass, recursive, context)) {
			if (traitClassRef !== null && traitClassRef.type instanceof ClassDeclaration)
				result.add(traitClassRef.type as ClassDeclaration)
		}
		return result

	}

	static private def List<TypeReference> getRefsTraitClassesAutoConstructDisabled(ClassDeclaration annotatedClass,
		boolean recursive, extension TypeLookup context) {

		val result = new ArrayList<TypeReference>

		if (annotatedClass === null)
			return result

		val searchedClasses = if(recursive) annotatedClass.getSuperClasses(true).reverse else #[annotatedClass]

		for (currentClass : searchedClasses) {

			val annotationConstructRuleDisable = currentClass.getAnnotation(ConstructRuleDisable)

			if (annotationConstructRuleDisable !== null) {

				// use specified trait classes
				val currentTraitClassAutoConstruction = annotationConstructRuleDisable.getClassArrayValue("value")
				if (currentTraitClassAutoConstruction !== null)
					for (typeRef : currentTraitClassAutoConstruction)
						result.add(typeRef)

			}

		}

		return result

	}

	override void doValidate(ClassDeclaration annotatedClass, extension ValidationContext context) {

		super.doValidate(annotatedClass, context)

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// checks in context of used trait classes
		val traitClassAutoConstructDisabledRefs = annotatedClass.
			getRefsTraitClassesAutoConstructDisabled(false, context)
		val traitClassAutoConstruct = ConstructRuleProcessor.getTraitClassesAutoConstruct(
			annotatedClass?.extendedClass?.type as ClassDeclaration, true, context)

		// require at least one specified class
		if (traitClassAutoConstructDisabledRefs.size <= 0)
			xtendClass.
				addError('''Annotation @«processedAnnotationType.simpleName» requires at least one specified trait class''')

		for (traitClassAutoConstructDisabledRef : traitClassAutoConstructDisabledRefs) {

			// retrieve type
			if (traitClassAutoConstructDisabledRef === null || traitClassAutoConstructDisabledRef.type === null) {
				xtendClass.
					addError('''Could not find one of the given trait classes specified in @«processedAnnotationType.simpleName»''')
				return
			}

			// disabling is only possible if supertype contains an auto construct rule for the according class
			if (!traitClassAutoConstruct.contains(traitClassAutoConstructDisabledRef.type)) {
				xtendClass.
					addError('''Auto construction for class "«traitClassAutoConstructDisabledRef.type.qualifiedName»" cannot be disabled because it is not found in list of automatically constructed trait classes (starting from the supertype of this class)''')
				return
			}

		}

	}

}
