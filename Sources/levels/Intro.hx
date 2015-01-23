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
	
	var state = 0;
	override public function updateMissionBriefing(time:Float): Bool {
		if (anyKey) {
			state++;
			switch (state) {
				case 1:
					var logo = new Sprite( Loader.the.getImage( "10up-logo" ) );
					logo.x = 50;
					logo.y = 0.5 * TenUp4.instance.height - 0.5 * logo.height;
					missionBriefingSprites.push( logo );
					var sprite = new kha.Sprite( Loader.the.getImage("level1briefing0") );
					sprite.x = logo.x + logo.width + 40;
					sprite.y = 0.5 * TenUp4.instance.height - 0.5 * sprite.height;
					missionBriefingSprites.push( sprite );
					missionBriefingSprites.push( sprite );
					missionBriefingSprites.push( sprite );
					missionBriefingSprites.push( sprite );
					var sprite = new kha.Sprite( Loader.the.getImage("introtext1") );
					sprite.x = logo.x + logo.width + 50;
					sprite.y = 0.5 * TenUp4.instance.height - 0.5 * sprite.height;
					missionBriefingSprites.push( sprite );
				case 2:
					missionBriefingSprites = new Array();
					var logo = new Sprite( Loader.the.getImage( "10up-logo" ) );
					logo.x = 50;
					logo.y = 0.5 * TenUp4.instance.height - 0.5 * logo.height;
					missionBriefingSprites.push( logo );
					var sprite = new kha.Sprite( Loader.the.getImage("level1briefing0") );
					sprite.x = logo.x + logo.width + 40;
					sprite.y = 0.5 * TenUp4.instance.height - 0.5 * sprite.height;
					missionBriefingSprites.push( sprite );
					missionBriefingSprites.push( sprite );
					missionBriefingSprites.push( sprite );
					missionBriefingSprites.push( sprite );
					missionBriefingSprites.push( sprite );
					var sprite = new kha.Sprite( Loader.the.getImage("introtext2") );
					sprite.x = logo.x + logo.width + 50;
					sprite.y = 0.5 * TenUp4.instance.height - 0.5 * sprite.height;
					missionBriefingSprites.push( sprite );
					// TODO: play SOUND!!!
				default:
					TenUp4.instance.victory();
			}
		}
		return false;
	}
}
