<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="louis:format" name="format"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:pef="http://www.daisy.org/ns/2008/pef"
    exclude-inline-prefixes="louis pef px p css"
    version="1.0">
    
    <p:input port="source" sequence="true" primary="true"/>
    <p:input port="pages" sequence="false" />
    <p:option name="temp-dir" required="true"/>
    <p:option name="title" required="false" select="''"/>
    <p:option name="creator" required="false" select="''"/>
    <p:output port="result" sequence="false" primary="true"/>
    
    <p:import href="generate-liblouis-files.xpl"/>
    <p:import href="format-box.xpl"/>
    <p:import href="format-toc.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/liblouis-calabash/xproc/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-calabash/xproc/library.xpl"/>
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    <p:variable name="liblouis-table"
        select="'http://www.daisy.org/pipeline/modules/braille/liblouis-formatter/tables/nabcc.dis,braille-patterns.cti,pagenum.cti'">
        <p:empty/>
    </p:variable>
    <p:variable name="pef-table" select="'org.daisy.pipeline.braille.liblouis.pef.LiblouisTableProvider.TableType.NABCC_8DOT'">
        <p:empty/>
    </p:variable>
    
    <p:for-each>
        <p:add-xml-base/>
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/handle-print-page.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:for-each>
    
    <p:for-each name="get-page-layout">
        <p:output port="result" sequence="true" primary="true"/>
        <p:xslt name="page-layout">
            <p:input port="source">
                <p:pipe step="get-page-layout" port="current"/>
                <p:pipe step="format" port="pages"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../xslt/get-page-layout.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <p:wrap-sequence wrapper="wrapper">
            <p:input port="source">
                <p:pipe step="get-page-layout" port="current"/>
                <p:pipe step="page-layout" port="result"/>
            </p:input>
        </p:wrap-sequence>
    </p:for-each>
    
    <p:for-each name="handle-css">
        <p:output port="result" sequence="true" primary="true"/>
        <p:filter select="/*/*[2]" name="page-layout"/>
        <p:viewport match="/*/*[1]">
            <p:viewport-source>
                <p:pipe step="handle-css" port="current"/>
            </p:viewport-source>
            <p:xslt>
                <p:input port="stylesheet">
                    <p:document href="../xslt/handle-toc.xsl"/>
                </p:input>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
            </p:xslt>
            <p:xslt>
                <p:input port="stylesheet">
                    <p:document href="../xslt/handle-margin-border-padding.xsl"/>
                </p:input>
                <p:input port="parameters">
                    <p:pipe step="page-layout" port="result"/>
                </p:input>
            </p:xslt>
            <p:xslt>
                <p:input port="stylesheet">
                    <p:document href="../xslt/normalize-css.xsl"/>
                </p:input>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
            </p:xslt>
        </p:viewport>
    </p:for-each>
    
    <p:group name="extract-toc">
        <p:output port="result" sequence="true" primary="true"/>
        <p:output port="result-toc" sequence="true">
            <p:pipe step="filter-toc" port="result"/>
        </p:output>
        <p:group name="filter-toc">
            <p:output port="result" sequence="true" primary="true"/>
            <p:for-each>
                <p:iteration-source>
                    <p:pipe step="handle-css" port="result"/>
                </p:iteration-source>
                <p:filter select="//louis:toc"/>
            </p:for-each>
            <p:for-each>
                <p:add-xml-base/>
            </p:for-each>
        </p:group>
        <p:for-each>
            <p:iteration-source>
                <p:pipe step="handle-css" port="result"/>
            </p:iteration-source>
            <p:viewport match="//louis:toc" name="tocs">
                <p:rename match="/*" new-name="louis:include"/>
                <p:delete match="/*/*|/*/@*"/>
                <p:add-attribute match="/*" attribute-name="ref">
                    <p:with-option name="attribute-value" select="/*/@xml:id">
                        <p:pipe step="tocs" port="current"/>
                    </p:with-option>
                </p:add-attribute>
            </p:viewport>
        </p:for-each>
    </p:group>
    
    <pxi:generate-liblouis-files name="liblouis-files">
        <p:input port="source">
            <p:pipe step="extract-toc" port="result"/>
        </p:input>
        <p:input port="source-toc">
            <p:pipe step="extract-toc" port="result-toc"/>
        </p:input>
        <p:with-option name="directory" select="$temp-dir">
            <p:empty/>
        </p:with-option>
    </pxi:generate-liblouis-files>
    
    <p:for-each>
        <pxi:format-box>
            <p:with-option name="temp-dir" select="$temp-dir"/>
        </pxi:format-box>
    </p:for-each>
    
    <pxi:format-toc>
        <p:input port="source-toc">
            <p:pipe step="liblouis-files" port="result-toc"/>
        </p:input>
        <p:with-option name="temp-dir" select="$temp-dir">
            <p:empty/>
        </p:with-option>
    </pxi:format-toc>
    
    <p:for-each name="translate-file">
        <louis:translate-file>
            <p:input port="source" select="/*/*[1]"/>
            <p:input port="styles" select="/*/*[2]"/>
            <p:input port="semantics" select="/*/*[3]"/>
            <p:input port="page-layout" select="/*/*[4]">
                <p:pipe step="translate-file" port="current"/>
            </p:input>
            <p:with-option name="table" select="$liblouis-table"/>
            <p:with-option name="temp-dir" select="$temp-dir"/>
        </louis:translate-file>
    </p:for-each>
    
    <!-- Convert to pef with brailleutils -->
    
    <p:for-each>
        <pef:text2pef>
            <p:with-option name="table" select="$pef-table"/>
            <p:with-option name="temp-dir" select="$temp-dir"/>
        </pef:text2pef>
    </p:for-each>
    
    <pef:merge>
        <p:with-param name="title" select="$title">
            <p:empty/>
        </p:with-param>
        <p:with-param name="creator" select="$creator">
            <p:empty/>
        </p:with-param>
    </pef:merge>
    
</p:declare-step>