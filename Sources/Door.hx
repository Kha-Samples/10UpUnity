package;

import kha.Animation;
import kha.Loader;
import kha.Scene;
import kha.Sprite;

class Door extends DestructibleSprite {
	public var opened(default,set) = false;
	private var openAnim: Animation;
	private var closedAnim: Animation;
	private var crackedAnim: Animation;
	private var destroyedAnim: Animation;
	public var id: Int;
	
	public function new(id: Int, x: Int, y: Int) {
		super(100, Loader.the.getImage("door"), 32 * 2, 64 * 2, 0);
		this.id = id;
		this.x = x;
		this.y = y;
		accy = 0;
		closedAnim = Animation.create(0);
		openAnim = Animation.create(1);
		crackedAnim = Animation.create(2);
		destroyedAnim = Animation.create(3);
		setAnimation(closedAnim);
		isStucture = true;
		isRepairable = true;
	}
	
	private function set_opened(value : Bool) : Bool {
		if (opened == value) {
			return opened;
		}
		Server.the.changeDoorOpened(id, value);
		if ( opened = value ) {
			setAnimation(openAnim);
		} else {
			if ( health <= 0 ) {
				setAnimation(destroyedAnim);
			} else if ( health < 75 ) {
				setAnimation(crackedAnim);
			}
			else {
				setAnimation(closedAnim);
			}
		}
		return opened;
	}
	
	override private function set_health(value:Int):Int {
		if (value != _health) Server.the.changeDoorHealth(id, value);
		if (opened) return _health;
		
		if ( value <= 0 ) {
			setAnimation(destroyedAnim);
		} else if ( value < _health ) {
			// TODO: pain cry
			if (value < 75) {
				setAnimation(crackedAnim);
			}
		} else if ( value > _health ) {
			if (value < 75) {
				setAnimation(crackedAnim);
			} else {
				setAnimation(closedAnim);
			}
		}
		return super.set_health(value);
	}
	
	public override function hit(sprite: Sprite) {
		super.hit(sprite);
		if (opened) return;
		if (health <= 0) return;
		if (sprite.x < x + collisionRect().width / 2) sprite.x = x - sprite.collisionRect().width - 1;
		else if ( Std.is(sprite, Player) ) {
			opened = true;
		}
	}
}