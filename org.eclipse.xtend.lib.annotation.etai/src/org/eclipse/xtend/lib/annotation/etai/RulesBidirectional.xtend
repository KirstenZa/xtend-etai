package org.eclipse.xtend.lib.annotation.etai

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.List
import java.util.Set
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.NamedElement
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.services.TypeLookup

import static extension org.eclipse.xtend.lib.annotation.etai.utils.ProcessUtils.*

/**
 * <p>This attribute can be set if the field has applied a setter or adder/remover rule. In addition,
 * the field's type must be a simple type reference or a set of type references.</p>
 * 
 * <p>With this rule 1:0..1, 1:n or n:m relations between types can be realized.</p>
 * 
 * <p>The rule ensures that the "opposite field" in another object adjusted automatically as soon as
 * the annotated field is changed.</p>
 * 
 * <p>For example, if there are classes <code>A</code> and <code>B</code>.
 * Class <code>A</code> has a field <code>b</code> (type <code>B</code>) and class <code>B</code> has
 * a field <code>a</code> (type <code>A</code>). The target in this case is a 1:0..1 relationship
 * between these classes via these fields. Therefore, both are annotated by this rule. In addition,
 * setters for both fields are generated. If now field <code>b</code> of an object <code>a1</code>
 * (type <code>A</code>) is changed to an object <code>b1</code> (type <code>A</code>), field 
 * <code>a</code> of <code>b1</code> will also be changed to <code>a1</code>. For this, the according
 * (generated) setter will be called. </p>
 * 
 * <p>This schema works in a similar way for 1:n or m:n relationships, i.e., there are fields of type
 * <code>java.util.Set</code> that must be parameterized in order to find the "opposite field".
 * The major difference is that adders/removers must be called for sets.</p>
 * 
 * <p>Of course, the called mechanisms also ensure that previous bidirectional connections are disconnected,
 * if necessary. Therefore, it can be dangerous to use the {@link NotNullRule} together with this rule, e.g.
 * in case of a 1:0..1 relationship both sides should not be annotated accordingly.</p>
 * 
 * <p>While the mechanisms in general do not search for fields but for the setter/adders/removers in the
 * "opposite class", the rule should be used with generated setter/adders/removers. Of course, the rule
 * should also be annotated on both sides in a correlating way.</p>
 * 
 * <p>If this annotation is used, it should be avoided to throw exceptions within change methods that are
 * called before the actual change, e.g., set via <code>beforeSet</code> in {@link SetterRule}. 
 * When executing them, there might be inconsistent connection states. If throwing an exception, this
 * state would remain.</p>
 */
@Target(ElementType.FIELD)
@Active(BidirectionalRuleProcessor)
annotation BidirectionalRule {

	/**
	 * <p>This attribute specifies the name of the "opposite" field via <code>String</code>.</p>
	 */
	String value = ""

}

/**
 * <p>Active Annotation Processor for {@link BidirectionalRule}.</p>
 * 
 * @see SetterRule
 * @see AdderRule
 * @see RemoverRule
 */
class BidirectionalRuleProcessor extends RuleProcessor<FieldDeclaration, MutableFieldDeclaration> {

	static class BidirectionalRuleInfo {

		public String oppositeField = null

	}

	override protected getProcessedAnnotationType() {
		BidirectionalRule
	}

	override boolean annotatedNamedElementSupported(NamedElement annotatedNamedElement) {
		return annotatedNamedElement instanceof FieldDeclaration
	}

	/**
	 * <p>Retrieves information from annotation (@BidirectionalRule).</p>
	 */
	static def BidirectionalRuleInfo getBidirectionalRuleInfo(FieldDeclaration annotatedField,
		extension TypeLookup context) {

		val bidirectionalRuleProcessorInfo = new BidirectionalRuleInfo
		val annotationBidirectionalRule = annotatedField.getAnnotation(BidirectionalRule)

		bidirectionalRuleProcessorInfo.oppositeField = annotationBidirectionalRule.getStringValue("value")

		return bidirectionalRuleProcessorInfo

	}

	override void doValidate(FieldDeclaration annotatedField, extension ValidationContext context) {

		super.doValidate(annotatedField, context)

		val xtendField = annotatedField.primarySourceElement as FieldDeclaration

		val bidirectionalRuleProcessorInfo = xtendField.getBidirectionalRuleInfo(context)

		// check that field has also setter or adder together with remover
		if (!xtendField.hasAnnotation(SetterRule) &&
			!(xtendField.hasAnnotation(AdderRule) && xtendField.hasAnnotation(RemoverRule))) {
			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» must only be used if also @SetterRule or @AdderRule together with @RemoverRule are used''')
			return
		}

		// check that bidirectional field is set
		if (bidirectionalRuleProcessorInfo.oppositeField.nullOrEmpty) {
			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» must specify name of opposite field''')
			return
		}

		// check used type
		val isSet = context.newTypeReference(Set).type.
			isAssignableFromConsiderUnprocessed(xtendField.type?.type, context)
		var TypeReference oppositeType
		if (isSet) {

			// sets must specify type argument
			if (xtendField.type.actualTypeArguments.size == 0) {
				xtendField.
					addError('''Annotation @«processedAnnotationType.simpleName» must only be used for sets if also a type argument is applied (i.e. the type of the opposite type must be known)''')
				return
			}

			oppositeType = xtendField.type.actualTypeArguments.get(0)

		} else {

			oppositeType = xtendField.type

		}

		// analyze further in case of type parameter ("extends" is expected)
		if (oppositeType.type !== null && oppositeType.type instanceof TypeParameterDeclaration &&
			(oppositeType.type as TypeParameterDeclaration).upperBounds.size == 1)
			oppositeType = (oppositeType.type as TypeParameterDeclaration).upperBounds.get(0)

		// ensure that type is class/interface
		if (oppositeType === null || oppositeType.type === null ||
			!(oppositeType.type instanceof ClassDeclaration || oppositeType.type instanceof InterfaceDeclaration)) {

			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» must only be used if opposite interface/class type is specified''')
			return

		}

		// ensure that no trait class is referenced (directly)
		if (oppositeType.type instanceof ClassDeclaration &&
			(oppositeType.type as ClassDeclaration).hasAnnotation(TraitClass)) {

			xtendField.
				addError('''Annotation @«processedAnnotationType.simpleName» must not be used if opposite type is a trait class (in spite of that its interface can be used)''')
			return

		}

		val oppositeTypeDeclaration = oppositeType.type as TypeDeclaration

		// check if opposite field (or rather setter/adder/remover for that field) exist
		var List<MethodDeclaration> oppositeMethods
		if (oppositeType.type instanceof ClassDeclaration)
			oppositeMethods = (oppositeTypeDeclaration as ClassDeclaration).getMethodClosure(
				null,
				null,
				true,
				true,
				true,
				true,
				false,
				context
			)
		else
			oppositeMethods = (oppositeTypeDeclaration as InterfaceDeclaration).getMethodClosure(
				null,
				true,
				true,
				true,
				true,
				context
			)

		if (oppositeMethods.findFirst [
			it.simpleName == "set" + bidirectionalRuleProcessorInfo.oppositeField.toFirstUpper &&
				it.parameters.size == 1
		] === null && (
			oppositeMethods.findFirst [
			it.simpleName == "addTo" + bidirectionalRuleProcessorInfo.oppositeField.toFirstUpper &&
				it.parameters.size == 1
		] === null || oppositeMethods.findFirst [
			it.simpleName == "removeFrom" + bidirectionalRuleProcessorInfo.oppositeField.toFirstUpper &&
				it.parameters.size == 1
		] === null)) {

			xtendField.
				addError('''Cannot find appropriate method (setter/adder/remover) for bidirectional connections in opposite class "«oppositeTypeDeclaration.simpleName»"''')
			return

		}

	}

}
