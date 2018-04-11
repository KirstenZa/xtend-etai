/**
 * Test passes, if this file compiles without problem.
 */
package org.eclipse.xtend.lib.annotation.etai.tests.extraction

import org.eclipse.xtend.lib.annotation.etai.ExtractInterface
import org.eclipse.xtend.lib.annotation.etai.tests.extraction.intf.IB
import org.eclipse.xtend.lib.annotation.etai.tests.extraction.intf.IA

@ExtractInterface
public class A<T> {

	public IB<T> comp;
	public IA<T> controllerParent;

	public override IB<T> _comp() {
		return comp;
	}
	
}

@ExtractInterface
public class B<T> {

	public IB<T> componentParent;
	public IA<T> controller;

}