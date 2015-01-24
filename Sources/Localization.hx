package ;

import haxe.io.Path;
import haxe.xml.Parser;

#if !macro

import kha.Loader;

#end

class Localization
{
#if !macro
	static var fallbackLanguage : String = "en";
	static public var language : String;
	static public var availableLanguages(default, null) : Map<String, String>;
	static var texts : Map <String, Map <String, String>> = null;
	
	static public function init(initFilename : String, startingLanguage = "en") {
		availableLanguages = new Map();
		var xml = Parser.parse(Loader.the.getBlob(initFilename).toString());
		var languages = xml.firstElement();
		if (languages.nodeName.toLowerCase() == "languages") {
			for (language in languages.elements()) {
				var key = language.nodeName.toLowerCase();
				availableLanguages[key] = language.firstChild().nodeValue;
			}
		}
		
		if (availableLanguages.exists(startingLanguage)) {
			language = startingLanguage;
		} else {
			language = availableLanguages.keys().next();
		}
		if (!availableLanguages.exists(fallbackLanguage)) {
			fallbackLanguage = availableLanguages.keys().next();
		}
	}
	
	static public function load(filename : String, replace = false) {
		if (texts == null || replace) {
			texts = new Map();
		}
		
		var xml = Parser.parse(Loader.the.getBlob(filename).toString());
		for (item in xml.elements()) {
			var key = item.nodeName;
			if (key == "DefaultLanguage") {
				fallbackLanguage = item.firstChild().nodeValue.toLowerCase();
			} else {
				texts[key] = new Map();
				for (language in item.elements()) {
					var l = language.nodeName.toLowerCase();
					texts[key][l] = StringTools.replace(StringTools.replace(StringTools.replace(language.firstChild().nodeValue, "\r\n", "\n"),"\r","\n"), "\t", "");
				}
			}
		}
	}
	
	static public function getText(key : String) {
		if (texts != null) {
			var t = texts[key];
			if (t != null) {
				if (t.exists(language)) {
					return t[language];
				} else if (t.exists(fallbackLanguage)) {
					return t[fallbackLanguage];
				}
			}
		}
		return key;
	}
#end

	macro static public inline function buildKeys(file: String, assetName: String) : haxe.macro.Expr {
		trace ('Building keys for "$file"');
		var f = haxe.macro.Context.getPosInfos(haxe.macro.Context.currentPos()).file;
		var dir = Path.directory(f) + "/";
		var name = 'Keys_$assetName';
		var contend = new StringBuf();
		contend.add("package localization;\n\n");
		contend.add('class $name {\n');
		
		var xml = Parser.parse(sys.io.File.getContent(file));
		for (item in xml.elements()) {
			var key = item.nodeName;
			if (key != "DefaultLanguage") {
				contend.add('\tstatic public var ${key.toUpperCase()} = "$key";\n');
			}
		}
		contend.add("}");
		
		var ldir = dir + "localization";
		if (!sys.FileSystem.exists(ldir) || !sys.FileSystem.isDirectory(ldir)) {
			sys.FileSystem.createDirectory(ldir);
		}
		sys.io.File.saveContent(ldir + '/$name.hx', contend.toString());
		
		return haxe.macro.Context.parse('Localization.load("$assetName")' , haxe.macro.Context.currentPos());
	}
}