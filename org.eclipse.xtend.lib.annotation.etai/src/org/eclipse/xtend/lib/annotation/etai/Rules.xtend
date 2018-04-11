package org.eclipse.xtend.lib.annotation.etai

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.ValidationParticipant
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.ConstructorDeclaration
import org.eclipse.xtend.lib.macro.declaration.Declaration
import org.eclipse.xtend.lib.macro.declaration.ExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.ParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.file.FileLocations
import org.eclipse.xtend.lib.macro.services.TypeLookup
import org.eclipse.xtend.lib.macro.services.TypeReferenceProvider

import static extension org.eclipse.xtend.lib.annotation.etai.ExtendedByProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.TraitClassProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.FactoryMethodRuleProcessor.*
import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*

/**
 * This annotation can be used in order to generate a factory method for constructing an
 * object of the annotated class. It must be used in order to generate an
 * object. All public (or default) constructors of the class will become protected.
 * The factory method will be generated for all subclasses
 * annotated by {@link ApplyRules}.
 * 
 * The annotation can only be used once in the type hierarchy, i.e. also specified names cannot
 * be changed then.
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
	 * @see SetAdaptionVariable
	 */
	String factoryInstance = ""

	/**
	 * If a factory is used, which is determined by the setting of <code>factoryInstance</code>,
	 * this setting specifies, if the generated factory class shall implement the given interface.
	 * 
	 * @see GeneratedFactoryClass
	 * @see GeneratedFactoryInstance
	 * @see FactoryMethodRule#factoryInstance
	 */
	Class<?> factoryInterface = Object

	/**
	 * <p>This attribute has the same purpose as <code>factoryInterface</code>. However, it
	 * supports the usage of an adaption variable, which is resolved during the generation
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
 * <p>The list can only be used, if also a factory method is generated, i.e.
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
 * all classes, which are extending the currently annotated class, are chosen for being created
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
 * implies that only trait classes can be specified, which have also been specified by an
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
 * <p>Methods in a supertype which are annotated with {@link TypeAdaptionRule},
 * will be generated and adapted automatically in a derived class,
 * if the derived class is annotated with {@link ApplyRules}.
 * The same applies to constructors, which are annotated by {@link CopyConstructorRule}.</p>
 * 
 * <p>This generation process will also be triggered,
 * if any parameter of the method/constructor, i.e. not the method/constructor itself,
 * is annotated with {@link TypeAdaptionRule}. In case of a constructor annotated
 * parameter, the constructor is adapted as if annotated by {@link CopyConstructorRule}.</p>
 * 
 * <p>The generated method/constructor will simply call the method/constructor
 * of the supertype. In case of a method, if there is no type change at all, the method
 * will not be generated.</p>
 * 
 * <p>An adaption rule of a superclass can be "deactivated" for a method in context of further
 * subclasses, if the method is overridden, and the {@link AdaptedMethod}
 * annotation is NOT used.</p>
 * 
 * <p>An adaption rule of a superclass can be "deactivated" for a constructor in context of 
 * further subclasses, if any constructor is implemented.</p>
 * 
 * <p>In order to control the type adaption a string for {@link TypeAdaptionRule} must be specified.
 * This string must contain one or multiple type adaption function calls separated by ";". The
 * purpose of such functions is to adapt the original type when generating the method in a
 * subclass. If {@link TypeAdaptionRule} annotates a method, the return type will
 * be adapted. If {@link TypeAdaptionRule} annotates a parameter, the corresponding
 * type will be adapted.</p>
 * 		
 * <p>Each type adaption function will modify the previously assumed type name to use. Originally,
 * exactly the type of the annotated type is assumed. If the type adaption function leads to a string
 * of a type, which cannot be found, the type of the super class's executable will
 * be applied.</p>
 * 
 * <p>The parameters of a type adaption function is usually interpreted as a string (without the necessity
 * of using <code>"</code>), but functions in context of type
 * parameters or for the search of type alternatives can also be nested.</p>
 * 
 * <p>Supported (type) adaption functions:</p>
 * <ul>
 * <li>apply(x):						"x" will replace the previously assumed type (as string)
 * <li>append(x):						"x" will be appended to the previously assumed type (as string)
 * <li>prepend(x):						"x" will be prepended to the previously assumed type (as string)
 * <li>applyVariable(x):				variable "x" will replace the previously assumed type (as string)
 * <li>appendVariable(x):				variable "x" will be appended to the previously assumed type (as string)
 * <li>prependVariable(x):				variable "x" will be prepended to the previously assumed type (as string)
 * <li>replace(x,y):					in the previously assumed type (as string) all occurrences of "x" will be replaced by "y"
 * <li>replaceAll(x,y):					in the previously assumed type (as string) all occurrences of "x" will be replaced by "y" (support of regular expressions)
 * <li>replaceFirst(x,y):				in the previously assumed type (as string) the first occurrence of "x" will be replaced by "y" (support of regular expressions)
 * <li>addTypeParam(x):					if not empty, the result of type adaption rule "x" (nested rules) are added as type parameter to previously assumed type
 * <li>addTypeParamWildcardExtends(x):	if not empty, the result of type adaption rule "x" (nested rules) are added as type parameter to previously assumed type using the format "? extends resultOfX"
 * <li>addTypeParamWildcardSuper(x):	if not empty, the result of type adaption rule "x" (nested rules) are added as type parameter to previously assumed type using the format "? super resultOfX"
 * <li>alternative(x):					with this function another function call list can be nested; if the type resulting from the commands until <code>alternative</code> cannot be found, the search for a type will continue after applying the commands within the <code>alternative</code> command as well; <code>alternative</code> is applicable only on top-level and together with other <code>alternative</code> calls at the end the function call list
 * </ul>
 * 
 * <p>The following variables are predefined and set automatically for the
 * current context:</p>
 * <ul>
 * <li>var.package:					the package name
 * <li>var.class.simple:			the fully simple class name
 * <li>var.class.qualified:			the fully qualified class name
 * <li>var.class.abstract:			if the class is abstract "true", otherwise "false"
 * <li>var.class.typeparameter.1:	the name of type parameter #1 (if available)
 * <li>var.class.typeparameter.2:	the name of type parameter #2 (if available)
 * <li>...
 * <li>var.class.typeparameter.x:	the name of type parameter #x (if available)
 * <li>const.bracket.round.open:	round bracket, open,    "("
 * <li>const.bracket.round.close:	round bracket, closed,  ")"
 * </ul>
 * 
 * @see ApplyRules
 * @see AdaptedMethod
 * @see AdaptedConstructor
 * @see CopyConstructorRule
 * @see SetAdaptionVariable
 * @see ImplAdaptionRule
 */
@Target(ElementType.METHOD, ElementType.PARAMETER)
@Active(TypeAdaptionRuleProcessor)
annotation TypeAdaptionRule {
	String value = ""
}

/**
 * <p>Methods and constructors in a supertype which are annotated with {@link ImplAdaptionRule},
 * will be generated and adapted automatically in a derived class,
 * if the derived class is annotated with {@link ApplyRules}.</p>
 * 
 * <p>The generated method/constructor will have a body which can be specified by
 * the value of this annotation, which is evaluated when the code is generated.
 * The annotation's value (a string) must contain implementation adaption
 * function calls, which are the same as type adaption function calls
 * (see {@link TypeAdaptionRule}).</p>
 * 
 * <p>The annotation also supports another list of adaption function calls in attribute
 * <code>typeExistenceCheck</code>. If specified, these calls are also evaluated during
 * code generation. If the evaluation result is not an existing type, then the
 * annotated method/constructor will not be adapted. In case of a constructor, it will
 * be implemented, however, and call the supertype's constructor.</p>
 * 
 * <p>An adaption rule of a superclass can be "deactivated" for a method in context of further
 * subclasses, if the method is overridden, and the {@link AdaptedMethod}
 * annotation is NOT used.</p>
 * 
 * <p>An adaption rule of a superclass can be "deactivated" for a constructor in context of 
 * further subclasses, if any constructor is implemented.</p>
 * 
 * @see ApplyRules
 * @see AdaptedMethod
 * @see AdaptedConstructor
 * @see TypeAdaptionRule
 * @see CopyConstructorRule
 * @see SetAdaptionVariable
 */
@Target(ElementType.METHOD, ElementType.CONSTRUCTOR)
@Active(ImplAdaptionRuleProcessor)
annotation ImplAdaptionRule {
	String value
	String typeExistenceCheck = ""
}

/**
 * <p>This annotation can be applied to constructors and ensures that
 * the constructor in also implemented in sub classes. Basically, the semantics of this annotation
 * is explained in the documentation for {@link TypeAdaptionRule}, but with this annotation no
 * (return) type is adapted.</p>
 * 
 * @see TypeAdaptionRule
 */
@Target(ElementType.CONSTRUCTOR)
@Active(CopyConstructorRuleProcessor)
annotation CopyConstructorRule {
}

/**
 * <p>This annotation can be used in context of a type in order to
 * set a variable in its context. The variable can be changed by subclassing.
 * However, if also inherited via interfaces or trait classes, it must
 * be ensured that variables are not set ambiguously.</p>
 * 
 * <p>There are also some variables, which are set automatically for the current
 * context and should not be set manually (see {@link TypeAdaptionRule}).</p>
 * 
 * <p>The variable can be accessed by {@link TypeAdaptionRule}. In its context,
 * there are also some predefined variables, which are set automatically and
 * should not be set manually.</p>
 * 
 * @see TypeAdaptionRule
 */
@Target(ElementType.TYPE)
annotation SetAdaptionVariable {
	String value
}

/**
 * Active Annotation Processor for {@link CopyConstructorRule}
 * 
 * @see CopyConstructorRule
 */
class CopyConstructorRuleProcessor implements ValidationParticipant<ConstructorDeclaration> {

	override doValidate(List<? extends ConstructorDeclaration> annotatedConstructors,
		extension ValidationContext context) {

		for (annotatedConstructor : annotatedConstructors)
			doValidate(annotatedConstructor, context)

	}

	def doValidate(ConstructorDeclaration annotatedConstructor, extension ValidationContext context) {

		var ConstructorDeclaration xtendConstructor = annotatedConstructor.
			primarySourceElement as ConstructorDeclaration

		// check if in context of ApplyRules
		val classWithConstructor = annotatedConstructor.declaringType as ClassDeclaration
		if (!classWithConstructor.hasAnnotation(ApplyRules))
			xtendConstructor.
				addError('''Annotation @CopyConstructorRule must be used in context of a class with annotation @ApplyRules''')

	}

}

/**
 * Active Annotation Processor for {@link TypeAdaptionRule}
 * 
 * @see TypeAdaptionRule
 */
class TypeAdaptionRuleProcessor implements ValidationParticipant<Declaration> {

	/**
	 * Returns true if method has any specific adaption rule.
	 */
	static def hasTypeAdaptionRule(MethodDeclaration methodDeclaration) {
		return methodDeclaration.hasAnnotation(TypeAdaptionRule) || methodDeclaration.parameters.exists [
			it.hasAnnotation(TypeAdaptionRule)
		]
	}

	override doValidate(List<? extends Declaration> annotatedDeclarations, extension ValidationContext context) {

		for (annotatedDeclaration : annotatedDeclarations)
			doValidate(annotatedDeclaration, context)

	}

	def doValidate(Declaration annotatedDeclaration, extension ValidationContext context) {

		// retrieve executable which is in context of annotation
		var ExecutableDeclaration executableInContext = null
		if (annotatedDeclaration instanceof MethodDeclaration)
			executableInContext = annotatedDeclaration
		else if (annotatedDeclaration instanceof ParameterDeclaration)
			executableInContext = annotatedDeclaration.declaringExecutable
		else
			annotatedDeclaration.addError('''Annotation @TypeAdaptionRule can not be applied to this element type''')

		if (executableInContext !== null) {

			val xtendExecutableDeclaration = executableInContext.primarySourceElement as ExecutableDeclaration

			// must not be used on static method, if it does not use implementation adaption as well
			if (executableInContext instanceof MethodDeclaration)
				if (executableInContext.static && !executableInContext.hasAnnotation(ImplAdaptionRule))
					xtendExecutableDeclaration.
						addError('''Annotation @TypeAdaptionRule wihtout @ImplAdaptionRule cannot be used with static methods''')

			// check if in context of ApplyRules 
			val classInContext = executableInContext.declaringType as ClassDeclaration
			if (!classInContext.hasAnnotation(ApplyRules))
				xtendExecutableDeclaration.
					addError('''Annotation @TypeAdaptionRule must be used in context of a class with annotation @ApplyRules''')

			// parse and check for errors
			val errors = new ArrayList<String>
			val ruleParam = annotatedDeclaration.getAnnotation(TypeAdaptionRule)?.getStringValue("value")
			AdaptionFunctions.createFunctions(ruleParam, errors)
			xtendExecutableDeclaration.reportErrors(errors, context)

		}

	}

}

/**
 * Active Annotation Processor for {@link ImplAdaptionRule}
 * 
 * @see ImplAdaptionRule
 */
class ImplAdaptionRuleProcessor implements ValidationParticipant<ExecutableDeclaration> {

	/**
	 * Returns true if method has any specific adaption rule.
	 */
	static def hasImplAdaptionRule(MethodDeclaration methodDeclaration) {
		return methodDeclaration.hasAnnotation(ImplAdaptionRule)
	}

	override doValidate(List<? extends ExecutableDeclaration> annotatedMethods, extension ValidationContext context) {

		for (annotatedMethod : annotatedMethods)
			doValidate(annotatedMethod, context)

	}

	def doValidate(ExecutableDeclaration annotatedExecutable, extension ValidationContext context) {

		val xtendExecutableDeclaration = annotatedExecutable.primarySourceElement as ExecutableDeclaration

		// check if in context of ApplyRules 
		val classInContext = xtendExecutableDeclaration.declaringType as ClassDeclaration
		if (!classInContext.hasAnnotation(ApplyRules))
			xtendExecutableDeclaration.
				addError('''Annotation @ImplAdaptionRule must be used in context of a class with annotation @ApplyRules''')

		// parse and check for errors
		val errors = new ArrayList<String>

		val typeCheckParam = xtendExecutableDeclaration.getAnnotation(ImplAdaptionRule)?.getStringValue(
			"typeExistenceCheck")
		AdaptionFunctions.createFunctions(typeCheckParam, errors)
		
		val ruleParam = xtendExecutableDeclaration.getAnnotation(ImplAdaptionRule)?.getStringValue("value")
		AdaptionFunctions.createFunctions(ruleParam, errors)
		
		xtendExecutableDeclaration.reportErrors(errors, context)

	}

}

/**
 * Base class for activate annotation class processors (for auto adaption rules annotated on classes).
 */
abstract class AutoAdaptionRuleClassProcessor extends AbstractClassProcessor {

	override doValidate(ClassDeclaration annotatedClass, extension ValidationContext context) {

		super.doValidate(annotatedClass, context)

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// check if in context of ApplyRules
		if (!annotatedClass.hasAnnotation(ApplyRules))
			xtendClass.
				addError('''Annotation @«processedAnnotationType.simpleName» must be used in context of a class with annotation @ApplyRules''')

	}

}

/**
 * Active Annotation Processor for {@link FactoryMethodRule}
 * 
 * @see FactoryMethodRule
 */
class FactoryMethodRuleProcessor extends AutoAdaptionRuleClassProcessor {

	/** 
	 * Helper class for storing information about auto adaption.
	 */
	static class FactoryMethodRuleInfo {

		public String factoryMethod = null
		public String initMethod = null
		public String factoryInstance = null
		public TypeDeclaration factoryInterface = null
		public String factoryInterfaceVariable = null

	}

	protected override getProcessedAnnotationType() {
		FactoryMethodRule
	}

	/**
	 * The method will return the annotation's information from the current class.
	 */
	static private def FactoryMethodRuleInfo createFactoryMethodRuleInfo(ClassDeclaration classDeclaration) {

		val annotationFactoryMethodRule = classDeclaration.getAnnotation(FactoryMethodRule)

		if (annotationFactoryMethodRule !== null) {

			val result = new FactoryMethodRuleInfo()

			val factoryMethod = annotationFactoryMethodRule.getStringValue("factoryMethod")
			val initMethod = annotationFactoryMethodRule.getStringValue("initMethod")
			val factoryInstance = annotationFactoryMethodRule.getStringValue("factoryInstance")
			val factoryInterface = annotationFactoryMethodRule.getClassValue("factoryInterface")
			val factoryInterfaceVariable = annotationFactoryMethodRule.getStringValue("factoryInterfaceVariable")

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

			return result

		}

		return null

	}

	/**
	 * Returns the information about specified factory method settings for the current class. 
	 * The method will search recursively through supertypes and gather information, if applicable.
	 * If no specification is found, null is returned.
	 */
	static public def <T extends TypeLookup & TypeReferenceProvider> FactoryMethodRuleInfo getFactoryMethodRuleInfo(
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

			val TraitClassResult = getFactoryMethodRuleInfoInternal(traitClassRef?.type as ClassDeclaration,
				rootClass, errors, context)

			if (TraitClassResult !== null)
				result.add(TraitClassResult)

		}

		// retrieve info from current class
		val currentResult = createFactoryMethodRuleInfo(currentClass)
		if (currentResult !== null)
			result.add(currentResult)

		// check for ambiguity
		if (currentClass === rootClass && result.size > 1)
			errors?.add('''Ambiguous factory method rules have found in supertypes and/or trait classes''')

		// return one result
		if (result.size == 0)
			return null
		return result.get(0)

	}

	override doValidate(ClassDeclaration annotatedClass, extension ValidationContext context) {

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

			// factory interface must only be set, if also instance is specified
			if (factoryMethodRuleInfo.factoryInstance.nullOrEmpty)
				xtendClass.
					addError('''If a factory interface is specified, also the factory instance name must be specified''')

		}

		if (!factoryMethodRuleInfo.initMethod.nullOrEmpty) {

			// factory interface must only be set, if also instance is specified
			if (!annotatedClass.getMethodClosure(null, null, true, context).exists [
				it.simpleName == factoryMethodRuleInfo.initMethod && it.parameters.size == 0 && it.returnType.isVoid &&
					(it.visibility == Visibility.PUBLIC || it.visibility == Visibility.PROTECTED)
			])
				xtendClass.
					addError('''A non-static init method named "«factoryMethodRuleInfo.initMethod»" without parameters and void return type must be declared and visible within this class.''')

		}

	}

}

/**
 * Active Annotation Processor for {@link ConstructRule}
 * 
 * @see ConstructRule
 */
class ConstructRuleProcessor extends AutoAdaptionRuleClassProcessor {

	protected override getProcessedAnnotationType() {
		ConstructRule
	}

	/**
	 * Retrieves the trait classes which shall be constructed automatically inside the factory method
	 * of the given and derived classes.
	 * 
	 * If the <code>recursive</code> flag is set, also settings from superclasses will be collected. 
	 */
	static public def <T extends TypeLookup & FileLocations & TypeReferenceProvider> List<ClassDeclaration> getTraitClassesAutoConstruct(
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
				val currentTraitClassAutoConstruction = currentClass.
					getTraitClassesAppliedToExtended(null, context)
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
	 * Returns true, if the class is annotated by {@link ConstructRuleAuto}.
	 * 
	 * @see ConstructRuleAuto
	 */
	def boolean isConstructRuleAuto() {
		return false
	}

	override doValidate(ClassDeclaration annotatedClass, extension ValidationContext context) {

		super.doValidate(annotatedClass, context)

		val xtendClass = annotatedClass.primarySourceElement as ClassDeclaration

		// there must not be another setting in type hierarchy
		if (annotatedClass.getFactoryMethodRuleInfo(null, context) === null)
			xtendClass.
				addError('''Trait class auto construction can not be used without specifying a factory method rules for class hierarchy via @FactoryMethodRule''')

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
			traitClassCurrentClassTypes += traitClassCurrentClassRef?.type as ClassDeclaration

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
 * Active Annotation Processor for {@link ConstructRule}
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
 * Active Annotation Processor for {@link ConstructRuleDisable}
 * 
 * @see ConstructRuleDisable
 */
class ConstructRuleDisableProcessor extends AutoAdaptionRuleClassProcessor {

	protected override getProcessedAnnotationType() {
		ConstructRuleDisable
	}

	/**
	 * Retrieves the trait classes which shall be not be constructed automatically even though a rule for
	 * automatic construction has been set for.
	 * 
	 * If the <code>recursive</code> flag is set, also settings from superclasses will be collected.
	 * 
	 * @see ConstructRule
	 */
	static public def List<ClassDeclaration> getTraitClassesAutoConstructDisabled(ClassDeclaration annotatedClass,
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

	override doValidate(ClassDeclaration annotatedClass, extension ValidationContext context) {

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
			if (traitClassAutoConstructDisabledRef === null ||
				traitClassAutoConstructDisabledRef.type === null) {
				xtendClass.
					addError('''Could not find one of the given trait classes specified in @«processedAnnotationType.simpleName»''')
				return
			}

			// disabling is only possible, if supertype contains an auto construct rule for the according class
			if (!traitClassAutoConstruct.contains(traitClassAutoConstructDisabledRef.type)) {
				xtendClass.
					addError('''Auto construction for class "«traitClassAutoConstructDisabledRef.type.qualifiedName»" cannot be disabled because it is not found in list of automatically constructed trait classes (starting from the supertype of this class)''')
				return
			}

		}

	}

}
