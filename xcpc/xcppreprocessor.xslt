<?xml version="1.0"?>

<!-- xcodepluging Preprocessor

This XSLT allows you to generate xcodeplugin files easier

* For VariantDictionary definitions

Example:

<definition name="..." class="VariantDictionary" default="[variantValue]Element">
    <xc:variants variantKey="[variantKey]" localizedString="variantKeyLocalizedString]">
		<xc:variant variantValue="[variantValue]" localizedString="[variantValueLocalizedString]" identifyingKey="[key]">
			// List all the keys of this variant of the Dictionary with <key name=... /> as usual
			// Except the [variantKey], which will be generated automatically
			<key ... />
		</xc:variant>
		// Some other <xc:variant> nodes...
	</xc:variants>
</definition>

Note: the generated elements representing dictionary variants are named "[variantValue]Element"
  (where [variantValue] is the value of the [variantKey] key that define this variant).
So if you have a variant with <xs:variant variantValue="TextFieldType">, the corresponding
  generated element/dictionary will be of class "TextFieldTypeElement".
Use this "[variantValue]Element" for example in the "default" attribute of the VariantDictionary definition:
	<definition class="VariantDictionary" default="TextFieldTypeElement">
	or in the <entry class="TextFieldTypeElement"> of the <arrayEntries> of an array whose arrayElementClass
	is your VariantDictionary's name

* To avoid copy-paste some XML fragments that needs to be repeated (like common keys definitions)

<xc:define id="[id]">
	// Some XML fragment
</xc:define>

<xc:paste idref="[id]" /> // Will insert here a copy of the XML fragment defined in the xc:define node with id 'id'

-->


<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xc="urn:X-AliSoftware:xcodeplugin:preprocessor"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	exclude-result-prefixes="xc fn">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />
	
	<!-- General rule: copy every node and attributes, except xc:* nodes -->
	<!-- Note: we use <xsl:element name="{name()}" /> instead of <xsl:copy> to avoid
		Copying unwanted namespaces in the namespace tree.
	-->
	<xsl:template match="*">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="@*|node()"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="@*">
		<xsl:attribute name="{name()}"><xsl:value-of select="." /></xsl:attribute>
	</xsl:template>
	<xsl:template match="xc:*" />
	
	<!-- Plugin and Extension nodes : add useful attributes if not present-->
	<xsl:template match="plugin">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="@*"/>
			<xsl:if test="not(@version)">
				<xsl:attribute name="version">1.0</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="extension">
		<xsl:element name="{name()}">
			<xsl:if test="not(@point)">
				<xsl:attribute name="point">com.apple.xcode.plist.structure-definition</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="@*"/>
			<xsl:if test="not(@version)">
				<xsl:attribute name="version">1.0</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()"/>
		</xsl:element>	
	</xsl:template>
	
	<!-- When we encounter a VariantDictionary, generate associated Types and Elements definitions after it -->
	<xsl:template match="definition[@class='VariantDictionary']">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="@*|node()"/>
		</xsl:element>
		<xsl:apply-templates mode="VariantTypes" />
	</xsl:template>

	<!-- xc:variants in VariantsDictionary = replace with "variants" node -->
	<xsl:template match="xc:variants">
		<variants>
			<xsl:apply-templates select="xc:variant" />
			<xsl:comment> Workaround for Xcode/PlistEditor bug that fail to list the first value in alphabetical order in the VariantDictionary dropdown </xsl:comment>
			<variant name="*" localizedString="___Unknown___" class="Dictionary" />
		</variants>
	</xsl:template>
	
	<!-- xc:variant in xc:variants = replace with "variant" node -->
	<xsl:template match="xc:variant">
		<variant name="{@variantValue}" localizedString="{@localizedString}"
			class="{concat(@variantValue,'Element')}">
		</variant>
	</xsl:template>
	
	
	<!-- VariantDictionary Types and Definitions generation -->
	<xsl:template match="xc:variants" mode="VariantTypes">
	
		<xsl:variable name="allowableValues">
			<allowableValues>
				<xsl:for-each select="xc:variant">
					<value name="{@variantValue}" localizedString="{@localizedString}" />
				</xsl:for-each>
			</allowableValues>
		</xsl:variable>

		<xsl:for-each select="xc:variant">
			<xsl:comment> Variant for <xsl:value-of select="concat(@variantValue,'Element')" /> </xsl:comment>
			<definition name="{concat(@variantValue,'Element_VariantKey')}" class="String" default="{@variantValue}">
				<xsl:copy-of select="$allowableValues" />
			</definition>
			<definition name="{concat(@variantValue,'Element')}" localizedString="{@localizedString}" class="Dictionary"
				variantKey="{../@variantKey}" variantValue="{@variantValue}" identifyingKey="{@identifyingKey}">
				<dictionaryKeys>
					<key name="{../@variantKey}" localizedString="{../@localizedString}" class="{concat(@variantValue,'Element_VariantKey')}" use="required"/>
					<xsl:apply-templates select="node()" />
				</dictionaryKeys>
			</definition>
        </xsl:for-each>
        
	</xsl:template>
	
	
	<!-- Copy/Paste Utility -->
	<xsl:template match="xc:paste">
		<xsl:apply-templates select="//xc:define[@id=current()/@idref]/node()" />
	</xsl:template>
	
</xsl:stylesheet>