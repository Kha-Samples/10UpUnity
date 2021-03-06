package;

import kha.Assets;
import kha2d.Animation;
import kha2d.Rectangle;
import kha2d.Scene;
import kha2d.Sprite;
import localization.Keys_text;
import projectiles.FistOfDoom;

class PlayerBullie extends Player {
	static public var the(default, null) : PlayerBullie; 
	
	override public function getName(): String {
		return "Mr. B";
	}
	
	public function new(x: Float, y: Float) {
		super(1, x, y - 8, "rowdy", Std.int(410 / 10) * 2, Std.int(455 / 7) * 2, 100);
		mini = Assets.images.rowdymini;
		the = this;
		_health = 100;
		baseSpeed = 3.0;
		
		collider = new Rectangle(15, 25, 41 * 2 - 30, (65 - 1) * 2 - 25);
		walkLeft = Animation.createRange(11, 18, 4);
		walkRight = Animation.createRange(1, 8, 4);
		standLeft = Animation.create(10);
		standRight = Animation.create(0);
		jumpLeft = Animation.create(11);
		jumpRight = Animation.create(1);
	}
	
	override public function zzzzzXDif(): Float {
		return 10;
	}
	
	override public function hit(sprite: Sprite): Void {
		if (sprite != fistOfDoom) {
			super.hit(sprite);
		}
	}
	
	override public function sleep() {
		super.sleep();
		if (fistOfDoom != null) {
			fistOfDoom.remove();
		}
		if (lifted != null) {
			lifted = null;
		}
	}
	
	override public function update() {
		super.update();
		
		if (lifted != null) {
			var lc = lifted.center;
			var ldiffx = lifted.x - lc.x;
			var ldiffy = lifted.y - lc.y;
			var c = center;
			lifted.x = c.x + ldiffx;
			lifted.y = c.y + ldiffy - 0.5 * lifted.height;
		}
	}
	
	override public function leftButton(): String {
		return Localization.getText(Keys_text.ABILITY_PUNCH);
	}
	
	override public function rightButton(): String {
		return Localization.getText(Keys_text.ABILITY_LIFT);
	}
	
	/**
	  Hauen
	**/
	var fistOfDoom : FistOfDoom;
	override public function prepareSpecialAbilityA(): Void {
		if (fistOfDoom == null) {
			fistOfDoom = new FistOfDoom(this, 20, 20);
			Scene.the.addProjectile( fistOfDoom );
		}
	}
	
	override public function useSpecialAbilityA() : Void {
		if (fistOfDoom != null) {
			fistOfDoom.releaseDoom();
		}
	}
	
	/**
	  Heben
	**/
	var lifted : InteractiveSprite;
	  
	override public function prepareSpecialAbilityB(): Void {
		if (lifted == null) {
			var rect = collisionRect();
			for (checkSprite in Level.the.interactiveSprites) {
				if ( checkSprite != this && checkSprite.isLiftable ) {
					if ( rect.collision( checkSprite.collisionRect() ) ) {
						lifted = checkSprite;
						return;
					}
				}
			}
		}
	}
	override public function useSpecialAbilityB(): Void {
		lifted = null;
	}
}
