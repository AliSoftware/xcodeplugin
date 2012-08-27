XCPC : Xcode Plugin Compiler
============================

This tool is intended to generate Xcode 4.x plugins, in dvtplugin file format, especially
to generate PLIST-file structure definitions.

These PLIST-file structure definitions define some well-known PLIST files (like Info.plist or Settings.bundle/Root.plist)
to make Xcode help you fill and edit these files, like:
* associating Human-Readable names for dictionary keys (that's how Xcode display human-readable keys for your Info.plist files)
* propose preformatted dictionary entries (that's how Xcode propose pre-formatted dicts in Settings.bundle/Root.plist files for the various kind of preferences entries (Text Field, ToggleSwitch...))
* Validate your PLIST conformity with the expected structure


## Generating your own PLIST structure definition files

To generate your own PLIST structure definition files, you have to:
* Prepare a XML file describing your PLIST expected structure. See [below](#xml-file-format).
* Preprocess and compile this XML file to generate a dvtplugin file. Use the xcpc shell script for that,
which will apply some XSLT stylesheet magic to the input XML file.

The xcpc shell script command line usage is as follow:
* Invoke `xcpc -xcodeplugin <inputFile>` to generate the output of the preprocessor to stdout. This will print the
XML corresponding to the old ".xcodeplugin" file format for Xcode plugins (Xcode3 file format)
* Invoke `xcpc -install <inputFile>` to generate the final ".dvtplugin" file (new Xcode4 file format) and make the script
install it directly into "~/Library/Developer/Xcode/Plug-Ins" so that is will be available the next time you restart Xcode.

## XML file format

The XML file format expected by xcpc is basically the xcodeplugin file format used in Xcode3.
xcpc will simply add:

* Support for useful tags to simplify the input format, especially for VariantDictionary used to propose pre-filled
dictionaries to your PLIST entries (like what is already done with the Settings.bundle/Info.plist files in Xcode to add
PreferenceSpecifier entries for either Text Fields, Toggle Switches, Titles, Sliders, ...) without have to define a lot of
repeatiting XML fragments; use `<xc:variant>` and `<xc:variant>` tags in your `<definition class="VariantDictionary">` nodes for that.
* Support for "copy/pasting" XML fragments (like #define macros in C). The principle is to associate an id to some XML fragment
so that you can "paste" it anywhere else in your XML without making a lot of copy/pasting. This is especially useful if you have
a lot of common dictionary keys in your PLIST structure and don't want to repeat these key definitions everywhere.
Use `<xc:define id="...">` and `<xc:paste idref="..." />` for that.

The XML xcodeplugin file format is actually not documented by Apple so this is mainly guessing and introspection.
The easiest way to discovery the syntax is to go and find inspiration in the existing xcodeplugin files
present in "Xcode.app/Contents/PlugIns" and in the examples provided with this project (see "Plugins" directory).

----

Here is the generic structure anyway:

    <plugin name="Your Plist Structure Definition"
		id="com.yourcompany.plist-plugin.yourformat"
		version="1.0"
		xmlns:xc="urn:X-AliSoftware:xcodeplugin:preprocessor">
		
	<extension point="com.apple.xcode.plist.structure-definition"
			   id="com.yourcompany.plist.structure-definition.yourformat" version="1.0"
			   name="Your plist">
			   
			   <definition ...>
			   <definition ...>
			   ...
			   
	</extension>
	</plugin>
	
Each `<definition>` tag define a type with its name, and a "class" which can be a standard class like "String", "Boolean",
"Dictionary", "Array" or "VariantDictionary", or any custom class whose definition is provided in another
`<definition name="...">` tag in the same XML.

Definitions of class "Array" can have an attribute "arrayElementClass" to define the class of the items in the array.
They can also have a subnode `<arrayEntries>` that contains some default entries listed using `<entry>` tags.

Definitions of class "String" can have a subnode `<allowableValues>` that contains a list of allowable values using `<value>` tags.

Definitions of class "Dictionary" should have a subnode `<dictionaryKeys>` that list the allows keys in this dictionary.
Each key is defined using a `<key name="..." localizedString="..." class="..." use="[optional|required]">` node.
Class can be "*" to allow the user to select any class instead of forcing a strict type for the key.

As VariantDictionary are quite more complex to define, the tags `<xc:variants>` and `<xc:variant>` can be
used. They will be and preprocessed by the xcppreprocessor.xslt stylesheet to generate the appropriate
`<variants>` and `<variant>` tags, but also all associated definitions, and all allowableValues for the
variantKey in each case automatically. See examples for inspiration.


## Usage in Xcode

Once you have compiled your own dvtplugin to describe your custom PLIST structure and it has been installed into
"~/Library/Developer/Xcode/Plug-Ins", simply open any PLIST file in Xcode.

Then if your plist is not recognized automatically to be of the expected structure
(which could be done by filename matching using the <filename pattern="..." /> tags in your source XML),
simply right-click anywhere of your PLIST and select the appropriate entry in the "Property List Type"
submenu _(You should find your custom type here)_.