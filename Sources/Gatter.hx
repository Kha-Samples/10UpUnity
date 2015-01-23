package;

import kha.Loader;
import kha.math.Vector2;
import kha.Rotation;
import kha.Sprite;

class Gatter extends Sprite {
	public function new(x: Float, y: Float) {
		super(Loader.the.getImage("gatter"), 32 * 2, 6 * 2);
		this.x = x;
		this.y = y;
		accy = 0;
	}
	
	public override function hit(sprite: Sprite) {
		if (collides && sprite.y < y + collisionRect().height / 2) sprite.y = y - sprite.collisionRect().height;
	}
	
	public function fly(): Void {
		collides = false;
		speedx = -5;
		speedy = -5;
		originX = 32;
		originY = 6;
	}
	
	override public function update(): Void {
		super.update();
		angle -= 0.1;
	}
}
