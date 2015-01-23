package;

import kha.Animation;
import kha.Direction;
import kha.Loader;
import kha.Sprite;

class Fishman extends Sprite {
	private var left: Animation;
	private var right: Animation;
	
	public function new(x: Float, y: Float) {
		super(Loader.the.getImage('fishy'), Std.int(594 * 2 / 9), Std.int(146 * 2 / 2));
		this.x = x;
		this.y = y;
		speedx = -3;
		left = Animation.createRange(1, 8, 4);
		right = Animation.createRange(10, 17, 4);
		setAnimation(left);
	}
	
	override public function hitFrom(dir: Direction): Void {
		super.hitFrom(dir);
		if (dir == Direction.RIGHT) {
			speedx = 3;
			setAnimation(right);
		}
		else if (dir == Direction.LEFT) {
			speedx = -3;
			setAnimation(left);
		}
	}
}
