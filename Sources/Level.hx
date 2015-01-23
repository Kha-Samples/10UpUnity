package;

import kha.graphics2.Graphics;
import kha.Sprite;

class Level {
	private static var instance: Level;
	private var won: Bool = false;
	
	public var doors(default, null) : Array<Door>;
	public var computers(default, null): Array<Computer>;
	public var interactiveSprites(default, null) : Array<InteractiveSprite>;
	public var destructibleSprites(default, null) : Array<DestructibleSprite>;
	
	public var nextLevelNum(default, null) = -1;
	
	public function new() {
		doors = new Array();
		computers = new Array();
		destructibleSprites = new Array();
		instance = this;
		missionBriefingSprites = new Array();
	}
	
	public function init() : Void { }
	
	public static var the(get, null): Level;
	
	private static function get_the(): Level {
		return instance;
	}
	
	var nextVictoryCheck : Float = 0;
	public function update(time: Float) {
		if ( won ) {
			if (victoryActions(time)) {
				TenUp4.getInstance().victory();
			}
		}
		if ( nextVictoryCheck <= time ) {
			nextVictoryCheck = time + 0.5;
			if ( checkVictory() ) {
				won = true;
			} else {
				var alive: Bool = false;
				for (i in 0...Player.getPlayerCount()) {
					if (!Player.getPlayer(i).isSleeping()) {
						alive = true;
						break;
					}
				}
				if (!alive) {
					TenUp4.getInstance().defeat();
				}
			} 
		}
	}
	
	@:noCompletion var _anyKey: Bool = true;
	public var anyKey(get, set) : Bool;
	@:noCompletion private function set_anyKey( value : Bool ) : Bool {
		return _anyKey = value;
	}
	@:noCompletion private function get_anyKey() : Bool {
		var r = _anyKey;
		_anyKey = false;
		return r;
	}
	
	public function updateMissionBriefing(time: Float) : Bool { return true; }
	
	private var missionBriefingSprites : Array<Sprite>;

	public function renderMissionBriefing(g: Graphics) : Void {
		//**g.translate(0, 0);
		for (sprite in missionBriefingSprites) {
			sprite.render(g);
		}
	}
	
	public function checkVictory() : Bool { return false; }
	private function victoryActions(time) : Bool { return true; }
}
