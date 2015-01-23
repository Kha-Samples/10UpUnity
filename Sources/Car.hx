package;

import kha.Animation;
import kha.Loader;
import kha.Sound;
import kha.Sprite;

class Car extends DestructibleSprite {
	private var repaired = false;
	private var startSound: Sound;
	
	public function new(x: Float, y: Float) {
		super(100, Loader.the.getImage("car"), 100 * 2, 41 * 2, 0);
		this.x = x;
		this.y = y;
		health = 0;
		isRepairable = true;
		isLiftable = true;
		startSound = Loader.the.getSound("carstart");
	}
	
	override private function set_health(value: Int): Int {
		if (value == 100) {
			repaired = true;
			speedx = 20;
			setAnimation(Animation.create(1));
			startSound.play();
		}
		return super.set_health(value);
	}
}
