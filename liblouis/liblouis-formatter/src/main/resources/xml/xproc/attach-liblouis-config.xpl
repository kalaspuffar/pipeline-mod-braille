<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:attach-liblouis-config" name="attach-liblouis-config"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    exclude-inline-prefixes="#all"
    version="1.0">
    
    <p:input port="source" sequence="true" primary="true"/>
    <p:option name="directory" required="true"/>
    <p:output port="result" sequence="true" primary="true"/>
    
    <p:import href="utils/fileset-add-tempfile.xpl"/>
    <p:import href="utils/copy-text-file.xpl"/>
    <p:import href="utils/select-by-position.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    
    <px:fileset-create name="directory">
        <p:with-option name="base" select="$directory">
            <p:empty/>
        </p:with-option>
    </px:fileset-create>
    <p:sink/>
    
    <p:group name="liblouis-ini-file">
        <p:output port="result" primary="true"/>
        <pxi:copy-text-file>
            <p:with-option name="href" select="resolve-uri('../../lbx_files/liblouisutdml.ini')">
                <p:document href="attach-liblouis-config.xpl"/>
            </p:with-option>
            <p:with-option name="target" select="resolve-uri('liblouisutdml.ini', $directory)"/>
        </pxi:copy-text-file>
        <pxi:copy-text-file>
            <p:with-option name="href" select="resolve-uri('../../lbx_files/braille-patterns.cti')">
                <p:document href="attach-liblouis-config.xpl"/>
            </p:with-option>
            <p:with-option name="target" select="resolve-uri('braille-patterns.cti', $directory)"/>
        </pxi:copy-text-file>
        <pxi:copy-text-file>
            <p:with-option name="href" select="resolve-uri('../../lbx_files/nabcc.dis')">
                <p:document href="attach-liblouis-config.xpl"/>
            </p:with-option>
            <p:with-option name="target" select="resolve-uri('nabcc.dis', $directory)"/>
        </pxi:copy-text-file>
        <pxi:copy-text-file>
            <p:with-option name="href" select="resolve-uri('../../lbx_files/pagenum.cti')">
                <p:document href="attach-liblouis-config.xpl"/>
            </p:with-option>
            <p:with-option name="target" select="resolve-uri('pagenum.cti', $directory)"/>
        </pxi:copy-text-file>
        <px:fileset-add-entry href="liblouisutdml.ini">
            <p:input port="source">
                <p:pipe step="directory" port="result"/>
            </p:input>
        </px:fileset-add-entry>
    </p:group>
    <p:sink/>
    
    <pxi:fileset-add-tempfile name="styles-directory" suffix=".cfg">
        <p:input port="source">
            <p:inline><louis:config-file># Default styles

style no-pagenum
    braillePageNumberFormat blank

style contentsheader
    leftMargin 0
    rightMargin 0
    firstLineIndent 0
    format leftJustified

style preformatted
    firstLineIndent 0
    format leftJustified
    skipNumberLines yes
</louis:config-file></p:inline>
        </p:input>
        <p:input port="directory">
            <p:pipe step="liblouis-ini-file" port="result"/>
        </p:input>
    </pxi:fileset-add-tempfile>
    <p:sink/>
    
    <pxi:fileset-add-tempfile name="semantics-directory" suffix=".sem">
        <p:input port="source">
            <p:inline><louis:semantic-file># Default semantics

no-pagenum     &amp;xpath(//louis:no-pagenum)
contentsheader &amp;xpath(//louis:toc)
none           &amp;xpath(//louis:box)
none           &amp;xpath(//louis:include)
none           &amp;xpath(//louis:result)
preformatted   &amp;xpath(//louis:line)
preformatted   &amp;xpath(//louis:border)
pagenum        &amp;xpath(//louis:print-page)
skip           &amp;xpath(//louis:page-layout)
skip           &amp;xpath(//louis:styles)
skip           &amp;xpath(//louis:semantics)
</louis:semantic-file></p:inline>
        </p:input>
        <p:input port="directory">
            <p:pipe step="directory" port="result"/>
        </p:input>
    </pxi:fileset-add-tempfile>
    <p:sink/>
    
    <p:for-each name="attach-liblouis-styles">
        <p:iteration-source>
            <p:pipe step="attach-liblouis-config" port="source"/>
        </p:iteration-source>
        <pxi:select-by-position include-not-matched="true">
            <p:input port="source">
                <p:pipe step="attach-liblouis-config" port="source"/>
            </p:input>
            <p:with-option name="position" select="p:iteration-position()">
                <p:empty/>
            </p:with-option>
        </pxi:select-by-position>
        <p:xslt name="generate-liblouis-styles">
            <p:input port="stylesheet">
                <p:document href="../xslt/generate-liblouis-styles.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <p:sink/>
        <p:choose name="base-directory">
            <p:xpath-context>
                <p:pipe step="attach-liblouis-styles" port="current"/>
            </p:xpath-context>
            <p:when test="/louis:toc">
                <p:output port="result" primary="true"/>
                <p:identity>
                    <p:input port="source">
                        <p:pipe step="directory" port="result"/>
                    </p:input>
                </p:identity>
            </p:when>
            <p:otherwise>
                <p:output port="result" primary="true"/>
                <p:identity>
                    <p:input port="source">
                        <p:pipe step="styles-directory" port="result"/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
        <p:sink/>
        <pxi:fileset-add-tempfile suffix=".cfg">
            <p:input port="source">
                <p:pipe step="generate-liblouis-styles" port="secondary"/>
            </p:input>
            <p:input port="directory">
                <p:pipe step="base-directory" port="result"/>
            </p:input>
        </pxi:fileset-add-tempfile>
        <p:wrap name="liblouis-styles" match="/*" wrapper="louis:styles"/>
        <p:sink/>
        <p:insert match="/*" position="last-child">
            <p:input port="source">
                <p:pipe step="generate-liblouis-styles" port="result"/>
            </p:input>
            <p:input port="insertion">
                <p:pipe step="liblouis-styles" port="result"/>
            </p:input>
        </p:insert>
    </p:for-each>
    
    <p:for-each name="attach-liblouis-semantics">
        <p:xslt name="generate-liblouis-semantics">
            <p:input port="stylesheet">
                <p:document href="../xslt/generate-liblouis-semantics.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <p:sink/>
        <p:choose name="base-directory">
            <p:xpath-context>
                <p:pipe step="attach-liblouis-semantics" port="current"/>
            </p:xpath-context>
            <p:when test="/louis:toc">
                <p:output port="result" primary="true"/>
                <p:identity>
                    <p:input port="source">
                        <p:pipe step="directory" port="result"/>
                    </p:input>
                </p:identity>
            </p:when>
            <p:otherwise>
                <p:output port="result" primary="true"/>
                <p:identity>
                    <p:input port="source">
                        <p:pipe step="semantics-directory" port="result"/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
        <p:sink/>
        <pxi:fileset-add-tempfile suffix=".sem">
            <p:input port="source">
                <p:pipe step="generate-liblouis-semantics" port="result"/>
            </p:input>
            <p:input port="directory">
                <p:pipe step="base-directory" port="result"/>
            </p:input>
        </pxi:fileset-add-tempfile>
        <p:wrap name="liblouis-semantics" match="/*" wrapper="louis:semantics"/>
        <p:sink/>
        <p:insert match="/*" position="last-child">
            <p:input port="source">
                <p:pipe step="attach-liblouis-semantics" port="current"/>
            </p:input>
            <p:input port="insertion">
                <p:pipe step="liblouis-semantics" port="result"/>
            </p:input>
        </p:insert>
    </p:for-each>
    
</p:declare-step>
