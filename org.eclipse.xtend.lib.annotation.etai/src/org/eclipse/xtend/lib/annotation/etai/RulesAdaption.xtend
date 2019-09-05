package org.eclipse.xtend.lib.annotation.etai

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.ArrayList
import org.eclipse.xtend.lib.annotation.etai.AdaptionFunctions.AddTypeParam
import org.eclipse.xtend.lib.annotation.etai.AdaptionFunctions.Alternative
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.AnnotationTarget
import org.eclipse.xtend.lib.macro.declaration.ConstructorDeclaration
import org.eclipse.xtend.lib.macro.declaration.Declaration
import org.eclipse.xtend.lib.macro.declaration.ExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableConstructorDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.NamedElement
import org.eclipse.xtend.lib.macro.declaration.ParameterDeclaration
import org.eclipse.xtend.lib.macro.services.AnnotationReferenceProvider

import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*

/**
 * <p>Methods which are annotated with {@link TypeAdaptionRule},
 * will be generated and adapted automatically in a derived class,
 * if the derived class is annotated with {@link ApplyRules}.
 * The same applies to constructors that are annotated by {@link CopyConstructorRule}.</p>
 * 
 * <p>This generation process will also be triggered,
 * if any parameter of the method/constructor, i.e., not the method/constructor itself,
 * is annotated with {@link TypeAdaptionRule}. In case of a constructor annotated
 * parameter, the constructor is adapted as if annotated by {@link CopyConstructorRule}.</p>
 * 
 * <p>The generated method/constructor will simply call the method/constructor
 * of the supertype. In case of a method if there is no type change at all, the method
 * will not be generated.</p>
 * 
 * <p>An adaption rule of a superclass can be "deactivated" for a method in context of further
 * subclasses if the method is overridden, and the {@link AdaptedMethod}
 * annotation is NOT used.</p>
 * 
 * <p>An adaption rule of a superclass can be "deactivated" for a constructor in context of 
 * further subclasses if any constructor is implemented.</p>
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
 * of a type that cannot be found, the type of the super class's executable will
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
@Target(ElementType.METHOD, ElementType.PARAMETER, ElementType.FIELD)
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
 * subclasses if the method is overridden, and the {@link AdaptedMethod}
 * annotation is NOT used.</p>
 * 
 * <p>An adaption rule of a superclass can be "deactivated" for a constructor in context of 
 * further subclasses if any constructor is implemented.</p>
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
 * <p>There are also some variables that are set automatically for the current
 * context and should not be set manually (see {@link TypeAdaptionRule}).</p>
 * 
 * <p>The variable can be accessed by {@link TypeAdaptionRule}. In its context,
 * there are also some predefined variables that are set automatically and
 * should not be set manually.</p>
 * 
 * @see TypeAdaptionRule
 */
@Target(ElementType.TYPE)
annotation SetAdaptionVariable {
	String value
}

/**
 * <p>Active Annotation Processor for {@link TypeAdaptionRule}.</p>
 * 
 * @see TypeAdaptionRule
 */
class TypeAdaptionRuleProcessor extends RuleProcessor<Declaration, MutableDeclaration> {

	final static public String TYPE_ADAPTION_PARAMETER_TYPE_ERROR = "Method \"%s\" has not been called with an object of type \"%s\" as Parameter \"%s\""

	protected override getProcessedAnnotationType() {
		TypeAdaptionRuleProcessor
	}

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof MethodDeclaration ||
			annotatedNamedElement instanceof FieldDeclaration || annotatedNamedElement instanceof ParameterDeclaration
	}

	/**
	 * <p>Returns <code>true</code> if method has any specific adaption rule.</p>
	 */
	static def hasTypeAdaptionRule(MethodDeclaration methodDeclaration) {
		return methodDeclaration.hasAnnotation(TypeAdaptionRule) || methodDeclaration.parameters.exists [
			it.hasAnnotation(TypeAdaptionRule)
		]
	}

	/**
	 * <p>Copies the type adaption annotation (if existent) from the given source including
	 * all attributes and returns a new annotation reference.</p>
	 */
	static def AnnotationReference copyAnnotation(AnnotationTarget annotationTarget,
		extension AnnotationReferenceProvider context) {

		val annotationTypeAdaptionRule = annotationTarget.getAnnotation(TypeAdaptionRule)

		if (annotationTypeAdaptionRule === null)
			return null

		return TypeAdaptionRule.newAnnotationReference [
			setStringValue("value", annotationTypeAdaptionRule.getStringValue("value"))
		]

	}

	/**
	 * <p>Copies the type adaption rule annotation (if existent) from the given source including
	 * all attributes and returns a new annotation reference.</p>
	 * 
	 * <p>This version does not copy the complete type adaption rule, but performs a transformation
	 * on it.</p>
	 * 
	 * <p>The parameter <code>expectedTypeParameterRules</code> specifies how many (add) type paramter rules
	 * are expected within the complete rule. If this count is not found (exactly), the annotation is
	 * actually not copied.</p>
	 * 
	 * <p>The given <code>ruleModifier</code> is then responsible for generating the rule for the copied
	 * annotation.</p>
	 */
	static def AnnotationReference copyAnnotationAndTransform(AnnotationTarget annotationTarget,
		int expectedTypeParameterRules, (String[])=>String ruleModifier, extension TransformationContext context) {

		val annotationTypeAdaptionRule = annotationTarget.getAnnotation(TypeAdaptionRule)
		val typeAdaptionRule = annotationTypeAdaptionRule?.getStringValue("value")

		if (typeAdaptionRule === null)
			return null

		val adaptionFunctions = AdaptionFunctions.createFunctions(typeAdaptionRule, null)
		val typeParamFunctionStrings = adaptionFunctions.filter[it instanceof AddTypeParam].map[it.print(true)]

		// do not copy annotation if there is no adaption of the required type parameter
		if (typeParamFunctionStrings.size != expectedTypeParameterRules)
			return null

		return TypeAdaptionRule.newAnnotationReference [
			setStringValue(
				"value",
				ruleModifier.apply(typeParamFunctionStrings)
			)
		]

	}

	override void doValidate(Declaration annotatedDeclaration, extension ValidationContext context) {

		super.doValidate(annotatedDeclaration, context)

		val xtendDeclaration = annotatedDeclaration.primarySourceElement as Declaration

		var Declaration declarationForShowingError = xtendDeclaration

		// retrieve executable which is in context of annotation
		var ExecutableDeclaration executableInContext = null
		if (annotatedDeclaration instanceof MethodDeclaration)
			executableInContext = annotatedDeclaration as ExecutableDeclaration
		else if (annotatedDeclaration instanceof ParameterDeclaration)
			executableInContext = annotatedDeclaration.declaringExecutable

		if (executableInContext !== null) {

			val xtendExecutableDeclaration = executableInContext.primarySourceElement as ExecutableDeclaration

			declarationForShowingError = xtendExecutableDeclaration

			// must not be used on static method if it does not use implementation adaption as well
			if (executableInContext instanceof MethodDeclaration)
				if (executableInContext.static && !executableInContext.hasAnnotation(ImplAdaptionRule))
					declarationForShowingError.
						addError('''Annotation @«getProcessedAnnotationType.simpleName» without @ImplAdaptionRule cannot be used with static methods''')

		} else if (annotatedDeclaration instanceof FieldDeclaration) {

			if (!annotatedDeclaration.hasAnnotation(GetterRule) && !annotatedDeclaration.hasAnnotation(SetterRule) &&
				!annotatedDeclaration.hasAnnotation(AdderRule) && !annotatedDeclaration.hasAnnotation(RemoverRule))
				declarationForShowingError.
					addError('''Annotation @«getProcessedAnnotationType.simpleName» cannot be applied to a field that is not annotated by @GetterRule, @SetterRule, @AdderRule or @RemoverRule''')

		} else {

			declarationForShowingError.
				addError('''Annotation @«getProcessedAnnotationType.simpleName» cannot be applied to this element type''')

			return

		}

		// parse and check for errors
		val errors = new ArrayList<String>
		val ruleParam = xtendDeclaration.getAnnotation(TypeAdaptionRule)?.getStringValue("value")
		val adaptionFunctions = AdaptionFunctions.createFunctions(ruleParam, errors)
		declarationForShowingError.reportErrors(errors, context)

		// type adaption rules with alternatives are not supported if annotated on a field with @AdderRule or @RemoverRule,
		// because the type adaption rule reduced (for content type) and then be applied to adder/remover method as well 
		if (annotatedDeclaration.hasAnnotation(AdderRule) || annotatedDeclaration.hasAnnotation(RemoverRule))
			for (adaptionFunction : adaptionFunctions)
				if (adaptionFunction instanceof Alternative)
					declarationForShowingError.
						addError('''Function "«AdaptionFunctions.RULE_FUNC_ALTERNATIVE»" must not be used in context of @AdderRule or @RemoverRule''')

	}

}

/**
 * <p>Active Annotation Processor for {@link ImplAdaptionRule}.</p>
 * 
 * @see ImplAdaptionRule
 */
class ImplAdaptionRuleProcessor extends RuleProcessor<ExecutableDeclaration, MutableExecutableDeclaration> {

	protected override getProcessedAnnotationType() {
		ImplAdaptionRuleProcessor
	}

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof ExecutableDeclaration
	}

	/**
	 * <p>Returns <code>true</code> if method has any specific adaption rule.</p>
	 */
	static def hasImplAdaptionRule(MethodDeclaration methodDeclaration) {
		return methodDeclaration.hasAnnotation(ImplAdaptionRule)
	}

	override void doValidate(ExecutableDeclaration annotatedExecutable, extension ValidationContext context) {

		super.doValidate(annotatedExecutable, context)

		val xtendExecutableDeclaration = annotatedExecutable.primarySourceElement as ExecutableDeclaration

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
 * <p>Active Annotation Processor for {@link CopyConstructorRule}.</p>
 * 
 * @see CopyConstructorRule
 */
class CopyConstructorRuleProcessor extends RuleProcessor<ConstructorDeclaration, MutableConstructorDeclaration> {

	protected override getProcessedAnnotationType() {
		CopyConstructorRuleProcessor
	}

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof ConstructorDeclaration
	}

}
