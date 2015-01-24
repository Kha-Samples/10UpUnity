package;

import kha.Loader;
import kha.math.Vector2;
import kha.math.Vector2i;
import kha.Sprite;
import kha.Storage;
import localization.Keys_text;

class Cfg
{
	static var the : Cfg;
	
	var _language : String;
	
	static public var language(get, set): String;
	static function get_language():String { return the._language; }
	static function set_language(value:String):String { return the._language = value; }
	
	static public function init() {
		var data = null;
		try {
			data = Storage.defaultFile().readObject();
		}
		catch (e: Dynamic) {
			
		}
		if (data == null) the = new Cfg();
		else the = cast data;
		// TODO: new PlayerBullie?
	}
	
	static public function save(): Void {
		Storage.defaultFile().writeObject(the);
	}
	
	private function new() {
	}
}