package;

import kha.graphics2.Graphics;
import kha.Loader;
import kha.Scene;
import kha.Scheduler;
import kha.Sprite;

class WaterSplash extends Sprite {
	private var start: Float;
	
	public function new(x: Float, y: Float, speedx: Float, speedy: Float) {
		super(Loader.the.getImage('watersplash'), 32, 32);
		this.x = x;
		this.y = y;
		this.speedx = speedx;
		this.speedy = speedy;
		scaleX = scaleY = 0.5;
		start = Scheduler.time();
	}
	
	override public function update(): Void {
		super.update();
		var alpha = Scheduler.time() - start;
		if (alpha > 1) {
			Scene.the.removeProjectile(this);
			return;
		}
	}
	
	override public function render(g: Graphics): Void {
		var alpha = Scheduler.time() - start;
		if (alpha > 1) {
			return;
		}
		g.pushOpacity(1 - alpha);
		scaleX = scaleY = (1 - alpha) / 2;
		super.render(g);
		g.popOpacity();
	}
}
