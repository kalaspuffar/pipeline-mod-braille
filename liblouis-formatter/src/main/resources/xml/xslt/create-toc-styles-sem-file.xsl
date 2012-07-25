<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:brl="http://www.daisy.org/ns/pipeline/braille"
    xmlns:lblxml="http://xmlcalabash.com/ns/extensions/liblouisxml"
    exclude-result-prefixes="xs brl lblxml"
    version="2.0">

    <xsl:param name="toc-item-styles" as="xs:string*"/>

    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:template name="initial">
        <lblxml:semantic-file>
            <xsl:text>contentsheader &amp;xpath(//lblxml:toc-title)&#xa;</xsl:text>
            <xsl:for-each select="$toc-item-styles">
                <xsl:value-of select="concat('heading', position())"/>
                <xsl:text> &amp;xpath(//lblxml:toc-item[@brl:style='</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>'])&#xa;</xsl:text>
            </xsl:for-each>
            <xsl:text>&#xa;</xsl:text>
        </lblxml:semantic-file>
    </xsl:template>
    
</xsl:stylesheet>