<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:re="regex-utils"
                version="2.0">
	
	<xsl:function name="re:join" as="xs:string">
		<xsl:param name="regexes" as="xs:string*"/>
		<xsl:param name="separator" as="xs:string"/>
		<xsl:sequence select="string-join($regexes, $separator)"/>
	</xsl:function>
	
	<xsl:function name="re:concat" as="xs:string">
		<xsl:param name="regexes" as="xs:string*"/>
		<xsl:sequence select="re:join($regexes, '')"/>
	</xsl:function>
	
	<xsl:function name="re:or" as="xs:string">
		<xsl:param name="regexes" as="xs:string*"/>
		<xsl:choose>
			<xsl:when test="$regexes[1]">
				<xsl:sequence select="concat('(', re:join($regexes, '|'), ')')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="''"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="re:exact" as="xs:string">
		<xsl:param name="regex" as="xs:string"/>
		<xsl:sequence select="concat('^', $regex, '$')"/>
	</xsl:function>
	
	<xsl:function name="re:space-separated" as="xs:string">
		<xsl:param name="regex" as="xs:string"/>
		<xsl:sequence select="re:join(($regex,'(\s+',$regex,')*'), '')"/>
	</xsl:function>
	
	<xsl:function name="re:comma-separated" as="xs:string">
		<xsl:param name="regex" as="xs:string"/>
		<xsl:sequence select="re:join(($regex,'(\s*,\s*',$regex,')*'), '')"/>
	</xsl:function>
	
</xsl:stylesheet>