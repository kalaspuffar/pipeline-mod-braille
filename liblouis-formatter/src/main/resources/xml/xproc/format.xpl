<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="louis:format" name="format"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:pef="http://www.daisy.org/ns/2008/pef"
    exclude-inline-prefixes="louis pef px p"
    version="1.0">
    
    <p:input port="source" sequence="false" primary="true"/>
    <p:option name="temp-dir" required="true"/>
    <p:option name="title" required="false" select="''"/>
    <p:option name="creator" required="false" select="''"/>
    <p:output port="result" sequence="false" primary="true"/>
    
    <p:import href="create-liblouis-files.xpl"/>
    <p:import href="format-vertical-border.xpl"/>
    <p:import href="format-toc.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/liblouis-calabash/xproc/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-calabash/xproc/library.xpl"/>

    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/handle-print-page.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
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
            <p:empty/>
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
    
    <p:xslt name="create-styles-xml">
        <p:input port="stylesheet">
            <p:document href="../xslt/create-styles-xml.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:add-attribute attribute-name="xml:base" match="/*" name="temp-directory">
        <p:input port="source">
            <p:inline>
                <c:directory/>
            </p:inline>
        </p:input>
        <p:with-option name="attribute-value" select="$temp-dir">
            <p:empty/>
        </p:with-option>
    </p:add-attribute>
    
    <louis:create-liblouis-files name="create-liblouis-files">
        <p:input port="source">
            <p:pipe step="create-styles-xml" port="result"/>
        </p:input>
        <p:input port="styles">
            <p:pipe step="create-styles-xml" port="secondary"/>
        </p:input>
        <p:input port="directory">
            <p:pipe step="temp-directory" port="result"/>
        </p:input>
    </louis:create-liblouis-files>
    
    <louis:format-vertical-border>
        <p:input port="source">
            <p:pipe step="create-styles-xml" port="result"/>
        </p:input>
        <p:input port="config-files">
            <p:pipe step="create-liblouis-files" port="config"/>
        </p:input>
        <p:input port="semantic-files">
            <p:pipe step="create-liblouis-files" port="semantic"/>
        </p:input>
        <p:with-option name="temp-dir" select="$temp-dir">
            <p:empty/>
        </p:with-option>
    </louis:format-vertical-border>
    
    <louis:format-toc name="format-toc">
        <p:input port="toc-styles">
            <p:pipe step="create-styles-xml" port="secondary"/>
        </p:input>
        <p:input port="config-files">
            <p:pipe step="create-liblouis-files" port="config"/>
        </p:input>
        <p:input port="semantic-files">
            <p:pipe step="create-liblouis-files" port="semantic"/>
        </p:input>
        <p:with-option name="temp-dir" select="$temp-dir">
            <p:empty/>
        </p:with-option>
    </louis:format-toc>
    
    <louis:translate-file name="xml2brl">
        <p:input port="source">
            <p:pipe step="format-toc" port="result"/>
        </p:input>
        <p:input port="config-files">
            <p:pipe step="create-liblouis-files" port="config"/>
        </p:input>
        <p:input port="semantic-files">
            <p:pipe step="create-liblouis-files" port="semantic"/>
        </p:input>
        <!-- FIXME this is a very ugly solution -->
        <p:with-option name="ini-file"
            select="concat(substring(base-uri(/), 0, string-length(base-uri(/))-19), 'lbx_files/liblouisutdml.ini')">
            <p:document href="format.xpl"/>
        </p:with-option>
        <p:with-option name="table"
            select="'http://www.daisy.org/pipeline/modules/braille/liblouis-formatter/tables/nabcc.dis,braille-patterns.cti,pagenum.cti'">
            <p:empty/>
        </p:with-option>
        <p:with-option name="temp-dir" select="$temp-dir">
            <p:empty/>
        </p:with-option>
    </louis:translate-file>

    <!-- Convert to pef with brailleutils -->
    
    <pef:text2pef name="text-to-pef">
        <p:with-option name="temp-dir" select="$temp-dir">
            <p:empty/>
        </p:with-option>
        <p:with-option name="table" select="'org.daisy.pipeline.liblouis.pef.LiblouisTableProvider.TableType.NABCC_8DOT'">
            <p:empty/>
        </p:with-option>
        <p:with-option name="title" select="$title">
            <p:empty/>
        </p:with-option>
        <p:with-option name="creator" select="$creator">
            <p:empty/>
        </p:with-option>
    </pef:text2pef>
    
</p:declare-step>
