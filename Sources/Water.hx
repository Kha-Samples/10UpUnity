package;

import kha.Animation;
import kha.Direction;
import kha.Loader;
import kha.math.Vector2i;
import kha.Scene;
import kha.Sprite;

class Water extends Sprite {
	private var lastTile: Vector2i;
	private var right: Animation;
	private var left: Animation;
	
	public function new(x: Float, y: Float, speedx: Float, speedy: Float) {
		super(Loader.the.getImage("water"), 32, 32);
		this.x = x;
		this.y = y;
		this.speedx = speedx;
		this.speedy = speedy;
		left = Animation.create(0);
		right = Animation.create(1);
		if (speedx > 0) setAnimation(right);
		else setAnimation(left);
	}
	
	override public function update(): Void {
		super.update();
		if (speedx < 0) setAnimation(left);
		else setAnimation(right);
		splash();
	}
	
	public static function isWater(value: Int): Bool {
		return value > 1 && value < 18;
	}
	
	private function isWallOrWater(value: Int): Bool {
		return value == 0 || isWater(value);
	}
	
	private function isWallOrLiquid(value: Int): Bool {
		return value == 0 || Lava.isLava(value) || isWater(value);
	}
	
	private function splash(): Void {
		var tile = Level.liquids.index(speedx > 0 ? x : x + width - 1, y + height - 1);
		var value = Level.liquids.get(tile.x, tile.y);
		var valueBelow = Level.liquids.get(tile.x, tile.y + 1);
		var floored = isWallOrLiquid(value) || isWallOrLiquid(valueBelow);		
		if (lastTile == null || tile.x != lastTile.x) {
			lastTile = tile;
			if (floored) {
				if (Lava.isLava(value)) {
					if (value == 20) {
						Level.liquids.set(tile.x, tile.y, 1);
					}
					else {
						Level.liquids.set(tile.x, tile.y, value - 1);
					}
					Scene.the.addProjectile(new Haze(x + collider.width / 2, y));
				}
				else if (Lava.isLava(valueBelow)) {
					if (valueBelow == 20) {
						Level.liquids.set(tile.x, tile.y + 1, 1);
					}
					else {
						Level.liquids.set(tile.x, tile.y + 1, valueBelow - 1);
					}
					Scene.the.addProjectile(new Haze(x + collider.width / 2, y));
				}
				else if (isWater(valueBelow) && valueBelow < 17) Level.liquids.set(tile.x, tile.y + 1, valueBelow + 1);
				else if (value > 0 && value < 17) Level.liquids.set(tile.x, tile.y, value + 1);
			}
		}
	}
	
	override public function hitFrom(dir: Direction): Void {
		super.hitFrom(dir);
		if (dir == Direction.LEFT || dir == Direction.RIGHT) {
			speedx = -speedx;
			
			if (speedx < 0) setAnimation(left);
			else setAnimation(right);
			
			splash();
			lastTile = null;
		}
	}
}
