package;

import kha.Animation;
import kha.Direction;
import kha.Loader;
import kha.math.Random;
import kha.Scene;
import kha.Sprite;

class Portal extends Sprite {
	private var count: Int = 0;
	private var water: Water;
	private var water2: Water;
	private var lava: Lava;
	public var canIndex: Int;
	
	public function new(x: Float, y: Float, speedx: Float, speedy: Float, canIndex: Int) {
		super(Loader.the.getImage('portal'), 32, 32);
		this.x = x;
		this.y = y;
		this.speedx = speedx;
		this.speedy = speedy;
		accy = 0;
		this.canIndex = canIndex;
	}
	
	public function remove(): Void {
		if (water != null) {
			Scene.the.removeOther(water);
		}
		if (water2 != null) {
			Scene.the.removeOther(water2);
		}
		if (lava != null) {
			Scene.the.removeOther(lava);
		}
	}
	
	override public function hitFrom(dir: Direction): Void {
		super.hitFrom(dir);
		switch (canIndex) {
			case 0:
				Cfg.setVictoryCondition(VictoryCondition.WATER, true);
				switch (dir) {
					case UP:
						setAnimation(Animation.create(2));
					case LEFT:
						setAnimation(Animation.create(1));
					case RIGHT:
						setAnimation(Animation.create(4));
					case DOWN:
						setAnimation(Animation.create(3));
				}
				Scene.the.addOther(water = new Water(x, y, 12, -0));
				Scene.the.addOther(water2 = new Water(x, y, -12, -0));
			case 1:
				switch (dir) {
				case UP:
					setAnimation(Animation.create(2));
					Scene.the.addOther(lava = new Lava(x, y, speedx > 0 ? 12 : -12, -0));
				case LEFT:
					setAnimation(Animation.create(1));
					Scene.the.addOther(lava = new Lava(x, y, -12, 0));
				case RIGHT:
					setAnimation(Animation.create(4));
					Scene.the.addOther(lava = new Lava(x, y, 12, 0));
				case DOWN:
					setAnimation(Animation.create(3));
					Scene.the.addOther(lava = new Lava(x, y, speedx > 0 ? 12 : -12, 0));
				}
			default:
				switch (dir) {
					case UP:
						setAnimation(Animation.create(2));
					case LEFT:
						setAnimation(Animation.create(1));
					case RIGHT:
						setAnimation(Animation.create(4));
					case DOWN:
						setAnimation(Animation.create(3));
				}
		}
		speedx = 0;
		speedy = 0;
	}
	
	override public function update(): Void {
		super.update();
		if (speedx == 0 && speedy == 0) {
			++count;
			if (count % 5 == 0) {
				var x = this.x;
				var y = this.y;
				var speedx: Float = 0;
				var speedy: Float = 0;
				switch (animation.get()) {
					case 1:
						if (canIndex == 0) {
							x += 16;
							y += 8;
						}
						speedx = -4;
						speedy = (Random.getIn(0, 2000) - 1000) / 250;
					case 2:
						if (canIndex == 0) {
							x += 8;
							y += 8;
						}
						speedx = (Random.getIn(0, 2000) - 1000) / 250;
						speedy = -4;
					case 3:
						if (canIndex == 0) {
							x += 8;
							y += 0;
						}
						speedx = (Random.getIn(0, 2000) - 1000) / 250;
						speedy = 0;
					case 4:
						if (canIndex == 0) {
							x += 0;
							y += 8;
						}
						speedx = 4;
						speedy = (Random.getIn(0, 2000) - 1000) / 250;
				}
				switch (canIndex) {
					case 0:
						Scene.the.addProjectile(new WaterSplash(x, y, speedx, speedy));
					case 1:
						Scene.the.addProjectile(new LavaSplash(x, y, speedx, speedy));
					case 2:
						if (count % 25 == 0) {
							switch (animation.get()) {
								case 1: // Left
									Scene.the.addOther(new Gas(x + (Random.getIn(0, 2001) - 1000) / 100 + 5, y + 10, -1.5 + Math.random(), 0));
								case 2: // Up
									Scene.the.addOther(new Gas(x + (Random.getIn(0, 2001) - 1000) / 100 + 10, y, -0.5 + Math.random(), 0));
								case 3: // Down
									Scene.the.addOther(new Gas(x + (Random.getIn(0, 2001) - 1000) / 100 + 10, y, -0.5 + Math.random(), 4));
								case 4: // Right
									Scene.the.addOther(new Gas(x + (Random.getIn(0, 2001) - 1000) / 100 + 10, y + 10, 1.5 + Math.random(), 0));
							}
						}
				}
			}
		}
	}
}
