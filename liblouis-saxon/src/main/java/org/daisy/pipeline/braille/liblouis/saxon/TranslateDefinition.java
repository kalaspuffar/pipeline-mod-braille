package org.daisy.pipeline.braille.liblouis.saxon;

import java.net.URL;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.SingletonIterator;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

import org.daisy.pipeline.braille.liblouis.Liblouis;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TranslateDefinition extends ExtensionFunctionDefinition {

	private static final StructuredQName funcname = new StructuredQName("louis",
			"http://liblouis.org/liblouis", "translate");

	private Liblouis liblouis = null;
	
	public void bindLiblouis(Liblouis liblouis) {
		this.liblouis = liblouis;
	}

	public void unbindLiblouis(Liblouis liblouis) {
		this.liblouis = null;
	}
	
	@Override
	public StructuredQName getFunctionQName() {
		return funcname;
	}

	@Override
	public int getMinimumNumberOfArguments() {
		return 2;
	}

	@Override
	public int getMaximumNumberOfArguments() {
		return 3;
	}

	@Override
	public SequenceType[] getArgumentTypes() {
		return new SequenceType[] { SequenceType.SINGLE_STRING,
				SequenceType.SINGLE_STRING, SequenceType.SINGLE_STRING };
	}

	@Override
	public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
		return SequenceType.OPTIONAL_STRING;
	}

	@Override
	public ExtensionFunctionCall makeCallExpression() {
		return new ExtensionFunctionCall() {

			@SuppressWarnings({ "unchecked", "rawtypes" })
			@Override
			public SequenceIterator call(SequenceIterator[] arguments, XPathContext context)
					throws XPathException {
				
				try {
					URL table = new URL(((StringValue)arguments[0].next()).getStringValue());
					String text = ((StringValue)arguments[1].next()).getStringValue();
					if (arguments.length == 3) {
						byte[] typeform = ((StringValue)arguments[2].next()).getStringValue().getBytes();
						for (int i=0; i < typeform.length; i++)
							typeform[i] -= 48;
						return SingletonIterator.makeIterator(
							new StringValue(liblouis.translate(table, text, typeform))); }
					else
						return SingletonIterator.makeIterator(
							new StringValue(liblouis.translate(table, text))); }
				catch (Exception e) {
					logger.error("louis:translate failed", e);
					throw new XPathException("louis:translate failed"); }
			}

			private static final long serialVersionUID = 1L;
		};
	}
	
	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(TranslateDefinition.class);
}
