package;

import kha.graphics2.Graphics;
import kha2d.Sprite;

class Level {
	public static var the: Level;
	private var won: Bool = false;
	
	public var doors(default, null) : Array<Door>;
	public var computers(default, null): Array<Computer>;
	public var interactiveSprites(default, null) : Array<InteractiveSprite>;
	public var destructibleSprites(default, null) : Array<DestructibleSprite>;
	public var persons(default, null) : Array<DestructibleSprite>;
	public var elevatorDoor : ElevatorDoor;
	public var elevatorButton : ElevatorButton;
	public var elevatorPositionSign : ElevatorPositionSign;
	
	public var levelNum(default, null) : Int;
	
	public function new(levelNum : Int) {
		doors = new Array();
		computers = new Array();
		destructibleSprites = new Array();
		interactiveSprites = new Array();
		persons = new Array();
		this.levelNum = levelNum;
	}
	
	public function init() : Void { }
	
	var nextVictoryCheck : Float = 0;
	public function update(time: Float) {
		if ( won ) {
			if (victoryActions(time)) {
				TenUp4.the.victory();
			}
		}
		if ( nextVictoryCheck <= time ) {
			nextVictoryCheck = time + 0.5;
			if ( checkVictory() ) {
				won = true;
			} else {
				var alive: Bool = !(PlayerBullie.the.isSleeping() || PlayerBlondie.the.isSleeping());
				if (!alive) {
					TenUp4.the.defeat();
				}
			} 
		}
	}
	
	public function checkVictory() : Bool { return false; }
	private function victoryActions(time) : Bool { return true; }
}
