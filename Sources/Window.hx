package;

import kha.graphics2.Graphics;
import kha.Loader;
import kha.math.Random;
import kha.Scene;
import kha.Sprite;

class Window extends Sprite {
	private var visible = true;
	
	public function new(x: Float, y: Float) {
		super(Loader.the.getImage("window"), 16 * 2, 80 * 2);
		this.x = x;
		this.y = y;
		accy = 0;
	}
	
	override public function hit(sprite: Sprite): Void {
		if (visible) {
			visible = false;
			for (i in 0...100) Scene.the.addProjectile(new Glass(x + Random.getUpTo(16 * 2), y + Random.getUpTo(16 * 2)));
		}
	}
	
	override public function render(g: Graphics): Void {
		if (visible) super.render(g);
	}
}
