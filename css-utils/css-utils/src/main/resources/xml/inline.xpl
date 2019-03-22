<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0"
                type="css:inline"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-inline-prefixes="#all"
                name="main">
	
	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		<p>Inline a CSS stylesheet in XML.</p>
		<p>CSS cascading and inlining happens according to <a
		href="http://braillespecs.github.io/braille-css/#h2_cascade">http://braillespecs.github.io/braille-css/#h2_cascade</a>
		and <a
		href="http://braillespecs.github.io/braille-css/#h2_style-attribute">http://braillespecs.github.io/braille-css/#h2_style-attribute</a>.
		</p>
	</p:documentation>
	
	<p:input port="source" sequence="false" primary="true">
		<p:documentation>
			Style sheets can be attached to the source in several ways: linked (using the 'link'
			element), embedded (using the 'style' element) and/or inlined (using 'style'
			attributes).
		</p:documentation>
	</p:input>
	
	<p:input port="context" sequence="true">
		<p:documentation>
			Style sheets that are linked to from the source document, or included via the
			'default-stylesheet' option, must either exist on disk, or must be provided in memory
			via this port. Style sheets on this port must be wrapped in &lt;c:result
			content-type="text/plain"&gt; elements. Style sheet URIs are resolved by matching
			against the context documents's base URIs.
		</p:documentation>
		<p:empty/>
	</p:input>
	
	<p:input port="sass-variables" kind="parameter" primary="false"/>
	
	<p:output port="result" sequence="false" primary="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>All styles are parsed, validated, normalized, cascaded and finally serialized into
			<code>style</code> attributes.</p>
			<p>Shorthand declarations such as <code>margin: a b c d</code> are decomposed as
			<code>margin-top: a; margin-right: b; margin-bottom: c; margin-left: d</code>.</p>
			<p>'before' and 'after' rules are serialized as <code>&amp;::before { ... }</code> and
			<code>&amp;::after { ... }</code>.</p>
			<p>'page' properties are replaced with the corresponding named 'page' rules (without the
			page type selector). If the root element does not have a 'page' property, the default
			page rule is inserted. 'page' rules are serialized as <code>@page { ... } @page:left {
			... } @page:right { ... }</code>. The declarations that named page rules inherit from
			the default page rule are made explicit. The declarations that 'left' and 'right' page
			rules inherit from their principal page rule are also made explicit.</p>
			<p>'volume' rules are serialized as <code>@volume { ... } @volume:first { ... }
			@volume:last { ... } @volume:nth(...) { ... } @volume:nth-last(...) { ... }</code> and
			inserted for the root element. The declarations that '@volume:first' etc. inherit from
			the principal volume rule are made explicit. ':nth(1)' and ':nth-last(1)' are normalized
			to ':first' and ':last'. A special '@volume:only' rule, which is a combination of the
			'@volume:first' and '@volume:last' rules, is created for the case that there is only a
			single volume.</p>
		</p:documentation>
	</p:output>
	
	<p:option name="default-stylesheet" required="false" select="''">
		<p:documentation>
			Space separated list of URIs, absolute or relative to source. Applied prior to all other
			style sheets defined within the source.
		</p:documentation>
	</p:option>
	
	<p:option name="media" required="false" select="'embossed'">
		<p:documentation>
			The target medium. All rules that are contained in a stylesheet that matches the
			specified medium is included. Supported values are `embossed` and `print`.
		</p:documentation>
	</p:option>
	
	<p:option name="attribute-name" required="false" select="'style'">
		<p:documentation>
			Name of attribute to use for inlined styles. Default name is 'style'.
		</p:documentation>
	</p:option>
	
	<!--
	    implemented in Java
	-->
	<p:declare-step type="pxi:css-inline">
		<p:input port="source" primary="true"/>
		<p:input port="context" sequence="true"/>
		<p:input port="sass-variables" kind="parameter" primary="false"/>
		<p:output port="result"/>
		<p:option name="default-stylesheet"/>
		<p:option name="media"/>
		<p:option name="attribute-name"/>
	</p:declare-step>
	
	<pxi:css-inline>
		<p:input port="context">
			<p:pipe step="main" port="context"/>
		</p:input>
		<p:input port="sass-variables">
			<p:pipe step="main" port="sass-variables"/>
		</p:input>
		<p:with-option name="default-stylesheet" select="$default-stylesheet"/>
		<p:with-option name="media" select="$media"/>
		<p:with-option name="attribute-name" select="$attribute-name"/>
	</pxi:css-inline>
	
</p:declare-step>
