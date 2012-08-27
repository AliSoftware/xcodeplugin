<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xcpp="urn:X-AliSoftware:xcodeplugin:preprocessor"
	exclude-result-prefixes="xcpp">

<xsl:output method="xml" version="1.0" encoding="UTF-8" standalone="yes"
	doctype-public="-//Apple//DTD PLIST 1.0//EN"
	doctype-system="http://www.apple.com/DTDs/PropertyList-1.0.dtd"
	indent="yes" />
<xsl:strip-space elements="*" />

<xsl:template match="plugin">
	<plist version="1.0">
	<dict>
		<key>plug-in</key>
		<dict>
			<key>id</key>
			<string><xsl:value-of select="@id" /></string>
			<key>name</key>
			<string><xsl:value-of select="@name" /></string>
			<key>version</key>
			<string><xsl:value-of select="@version" /></string>
			<key>extension-points</key>
			<dict/>
			<key>extensions</key>
			<dict>
				<xsl:apply-templates select="extension" />
			</dict>
		</dict>
		<key>version</key>
		<dict>
			<key>compiler-build</key>
			<real>1534</real>
			<key>file-format</key>
			<integer>1</integer>
		</dict>
	</dict>
	</plist>
</xsl:template>

<xsl:template match="extension">
	<key><xsl:value-of select="@id" /></key>
	<dict>
		<key>id</key>
		<string><xsl:value-of select="@id" /></string>
		<key>name</key>
		<string><xsl:value-of select="@name" /></string>
		<key>point</key>
		<string><xsl:value-of select="@point" /></string>
		<key>version</key>
		<string><xsl:value-of select="@version" /></string>
		<key>filename</key>
		<array>
			<xsl:apply-templates select="filename" />
		</array>
		<key>_DVTExtensionXML</key>
		<string>
			<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
			<xsl:copy-of select="." />
			<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
		</string>
	</dict>
</xsl:template>

<xsl:template match="filename">
	<dict>
		<key>pattern</key>
		<string><xsl:value-of select="@pattern" /></string>
	</dict>
</xsl:template>
	
</xsl:stylesheet>