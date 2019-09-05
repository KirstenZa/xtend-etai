/**
 * Test passes if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.extraction

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.tests.extraction.intf.IB
import org.eclipse.xtend.lib.annotation.etai.tests.extraction.intf.IA

@ExtractInterface
class A<T> {

	public IB<T> comp;
	public IA<T> controllerParent;

	override IB<T> _comp() {
		return comp;
	}
	
}

@ExtractInterface
class B<T> {

	public IB<T> componentParent;
	public IA<T> controller;

}