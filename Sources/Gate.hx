package;

import kha.graphics2.Graphics;
import kha.Loader;
import kha.Sprite;

class Gate extends Sprite {
	private var opened = false;
	private var gateHeight: Float;
	
	public function new(x: Float, y: Float) {
		super(Loader.the.getImage("gate"), 16 * 2, 96 * 2);
		this.x = x;
		this.y = y;
		accy = 0;
		gateHeight = height;
	}
	
	override public function update(): Void {
		super.update();
		if (opened) {
			if (gateHeight > 0) gateHeight -= 1;
		}
	}
	
	override public function hit(sprite: Sprite): Void {
		super.hit(sprite);
		if (isOpen()) {
			return;
		}
		if (sprite.x < x + collisionRect().width / 2) sprite.x = x - sprite.collisionRect().width - 1;
	}
	
	public function open(): Void {
		opened = true;
	}
	
	public function isOpen(): Bool {
		return gateHeight < height / 2;
	}
	
	override public function render(g: Graphics): Void {
		if (image != null) {
			g.drawScaledSubImage(image, 0, height - gateHeight, width, gateHeight, x, y, width, gateHeight);
		}
	}
}
