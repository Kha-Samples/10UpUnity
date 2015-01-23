package;

import kha.Loader;
import kha.math.Random;
import kha.math.Vector2;
import kha.Rotation;
import kha.Scene;
import kha.Sprite;

class Blood extends Sprite {
	private var count = 30;
	
	public function new(x: Float, y: Float) {
		super(Loader.the.getImage("blood"), 4 * 2, 4 * 2);
		this.x = x;
		this.y = y;
		collides = false;
		angle = Random.getUpTo(6);
		originX = 4;
		originY = 4;
		speedy = -2 - Random.getUpTo(3);
		speedx = -10 + Random.getUpTo(10);
	}
	
	override public function update(): Void {
		super.update();
		angle += 0.1;
		--count;
		if (count < 0) Scene.the.removeOther(this);
	}
}
