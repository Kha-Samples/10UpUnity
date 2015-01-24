package levels;

import kha.gui.TextItem;
import kha.Loader;
import kha.Scene;
import kha.Sprite;

class Intro extends Level {
	public function new() {
		super();
		nextLevelNum = 1;
	}
	
	override public function checkVictory():Bool { return true; }
}
