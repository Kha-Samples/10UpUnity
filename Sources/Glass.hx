package;

import kha.Direction;
import kha.Loader;
import kha.math.Random;
import kha.math.Vector2;
import kha.Rotation;
import kha.Scene;
import kha.Sprite;

class Glass extends Sprite {
	private var left: Int;
	
	public function new(x: Float, y: Float) {
		super(Loader.the.getImage("glass"), 6 * 2, 4 * 2);
		this.x = x;
		this.y = y;
		angle = Random.getUpTo(6);
		originX = 6;
		originY = 4;
		left = Random.getUpTo(1) == 0 ? 1 : -1;
		speedy = -2 - Random.getUpTo(5);
		speedx = -10 + Random.getUpTo(20);
	}

	override public function update(): Void {
		super.update();
		angle += 0.1 * left;
	}
	
	override public function hitFrom(dir: Direction): Void {
		super.hitFrom(dir);
		Scene.the.removeOther(this);
	}
}
