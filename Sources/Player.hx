package;

import kha.Assets;
import kha.audio1.Audio;
import kha2d.Animation;
import kha.Color;
import kha2d.Direction;
import kha.graphics2.Graphics;
import kha.Image;
import kha.math.FastMatrix3;
import kha.math.Vector2;
import kha2d.Rectangle;
import kha.Rotation;
import kha2d.Scene;
import kha.Sound;
import kha2d.Sprite;

class Player extends DestructibleSprite {
	public var left : Bool;
	public var right : Bool;
	public var up : Bool;
	public var lookRight(default, null) : Bool;
	public var walking: Bool = false;
	public var index: Int;
	private var zzzzz: Image;
	private var zzzzzIndex: Int = 0;
	var standing : Bool;
	var killed : Bool;
	var jumpcount : Int;
	var lastupcount : Int;
	var walkLeft : Animation;
	var walkRight : Animation;
	var standLeft : Animation;
	var standRight : Animation;
	var jumpLeft : Animation;
	var jumpRight : Animation;
	public var mini : Image;
	private var hitSound: Sound;
	private static var currentPlayer: Player = null;
	
	public var id: Int;
	public var aimx: Float;
	public var aimy: Float;
	public var ataimx: Bool = true;
	public var ataimy: Bool = true;
	
	var muzzlePoint : Vector2;
	
	public function new(id: Int, x: Float, y: Float, image: String, width: Int, height: Int, maxHealth: Int = 50) {
		super(maxHealth, Assets.images.get(image), width, height, 1);
		this.id = id;
		this.x = x;
		this.y = y;
		standing = false;
		walkLeft = Animation.create(0);
		walkRight = Animation.create(0);
		standLeft = Animation.create(0);
		standRight = Animation.create(0);
		jumpLeft = Animation.create(0);
		jumpRight = Animation.create(0);
		setAnimation(jumpRight);
		collider = null;
		up = false;
		right = false;
		left = false;
		lookRight = true;
		killed = false;
		jumpcount = 0;
		crosshair = new Vector2(1, 0);
		isRepairable = true;
		hitSound = Assets.sounds.hit;
		zzzzz = Assets.images.zzzzz;
	}
	
	public static inline function current(): Player {
		return currentPlayer;
	}
	
	public function setCurrent(): Void {
		currentPlayer = this;
	}
	
	public function reset() {
		x = y = 50;
		standing = false;
		setAnimation(jumpRight);
	}
	
	private var baseSpeed = 4.0;
	public override function update(): Void {
		if (!ataimx) {
			if (isSleeping()) {
				x = aimx;
				ataimx = true;
			}
			else {
				if (Math.abs(x - aimx) < baseSpeed) {
					left = false;
					right = false;
					ataimx = true;
				}
				else if (aimx < x) {
					left = true;
					right = false;
				}
				else if (aimx > x) {
					right = true;
					left = false;
				}
				else {
					left = false;
					right = false;
					ataimx = true;
				}
			}
		}
		if (!ataimy) {
			if (isSleeping()) {
				y = aimy;
				ataimy = true;
			}
			else {
				if (aimy < y) {
					setUp();
				}
				else if (aimy > y) {
					up = false;
				}
				else {
					up = false;
					ataimy = true;
				}
			}
		}
		
		walking = false;
		if (lastupcount > 0) --lastupcount;
		if (killed) {
			++zzzzzIndex;
		} else {
			if (right) {
				if (standing) {
					setAnimation(walkRight);
					walking = true;
				}
				speedx = baseSpeed;
				lookRight = true;
			}
			else if (left) {
				if (standing) {
					setAnimation(walkLeft);
					walking = true;
				}
				speedx = -baseSpeed;
				lookRight = false;
			}
			else {
				if (standing) setAnimation(lookRight ? standRight : standLeft);
				speedx = 0;
			}
			if (up && standing) {
				setAnimation(lookRight ? jumpRight : jumpLeft);
				speedy = -8.2;
			}
			else if (!standing && !up && speedy < 0 && jumpcount == 0) speedy = 0;
			
			if (!standing) setAnimation(lookRight ? jumpRight : jumpLeft);
			
			standing = false;
		}
		if (jumpcount > 0) --jumpcount;
		super.update();
		if (Player.currentPlayer == this) {
			updateCrosshair();
		}
	}
	
	public function setUp() {
		up = true;
		lastupcount = 8;
	}
	
	public override function hitFrom(dir : Direction) {
		if (dir == Direction.UP) {
			standing = true;
			if (lastupcount < 1) up = false;
		}
		else if (dir == Direction.DOWN) speedy = 0;
	}
	
	public function sleep() {
		isLiftable = true;
		setAnimation(Animation.create(0));
		angle = Math.PI * 1.5;
		originX = width / 2;
		originY = collider.height - 4;
		y += collider.height - collider.width;
		x += collider.width - collider.height;
		collider = new Rectangle(-collider.y,collider.x + collider.width,collider.height,collider.width);
		
		speedy = 0;
		speedx = 0;
		killed = true;
	}
	
	public function unsleep() {
		isLiftable = false;
		angle = 0;
		collider = new Rectangle(collider.y - collider.height, -collider.x, collider.height, collider.width);
		y -= collider.height - collider.width;
		x -= collider.width - collider.height;
		if (lookRight) setAnimation(standRight);
		else setAnimation(standLeft);
		killed = false;
	}
	
	public function getName(): String {
		return "Anonymous";
	}
	
	public function leftButton(): String {
		return "";
	}
	
	public function rightButton(): String {
		return "";
	}
	
	public function zzzzzXDif(): Float {
		return 20;
	}
	
	public function isSleeping(): Bool {
		return killed;
	}
	
	
	public function prepareSpecialAbilityA() : Void {
		
	}
	
	public function useSpecialAbilityA() : Void {
		
	}
	
	public function prepareSpecialAbilityB() : Void {
		
	}
	
	public function useSpecialAbilityB() : Void {
		
	}
	
	override private function set_health(value:Int):Int {
		if ( value <= 0 ) {
			if ( value < _health ) {
				if (_health - value > 1) {
					Audio.play(hitSound);
				}
				for (i in 0...Math.ceil(0.3 * (_health - value))) kha2d.Scene.the.addProjectile(new Blood(x + 20, y + 20));
			}
			if (!killed) {
				sleep();
			}
		} else if ( value < _health ) {
			for (i in 0...Math.ceil(0.3 * (_health - value))) kha2d.Scene.the.addProjectile(new Blood(x + 20, y + 20));
				if (_health - value > 1) {
					Audio.play(hitSound);
				}
		} else if ( value > _health && _health <= 0 ) {
			if (killed) {
				unsleep();
			}
		}
		return super.set_health(value);
	}
	
	// Crosshair:
	var isCrosshairVisible : Bool = false;
	var crosshair : Vector2;
	
	public function updateCrosshair() {
		if (Player.current() != null) {
			var v = center;
			v.x = TenUp4.the.mouseX - v.x;
			v.y = TenUp4.the.mouseY - v.y;
			//v.y += 0.1 * height;
			if (lookRight) {
				if (v.x < 0) {
					v.x = 0;
				}
			} else {
				if ( v.x > 0) {
					v.x = 0;
				}
			}
			
			var vl = v.length;
			if (vl < 0.001) {
				return;
			}
			crosshair = v.div( vl );
		}
		updateMuzzlePoint();
	}
	
	private function updateMuzzlePoint(): Void {
		muzzlePoint = center;
		muzzlePoint.x += 0.6 * crosshair.x * width;
		muzzlePoint.y += 0.6 * crosshair.y * height;
	}
	
	override public function render(g: Graphics): Void {
		if (isSleeping()) {
			g.color = Color.White;
			g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(x + originX, y + originY)).multmat(FastMatrix3.rotation(angle)).multmat(FastMatrix3.translation(-x - originX, -y - originY)));
			g.drawScaledSubImage(image, 0, 0, width, height, x + collider.y * scaleY, y - collider.x * scaleX, width, height);
		#if debug
			g.color = Color.Red;
			g.drawRect(x + collider.y * scaleY, y - collider.x * scaleX, width, height);
		#end
			g.popTransformation();
		#if debug
			g.color = Color.Green;
			g.drawRect(tempcollider.x, tempcollider.y, tempcollider.width, tempcollider.height);
		#end
			g.drawScaledSubImage(zzzzz, (Std.int(zzzzzIndex / 8) % 3) * zzzzz.width / 3, 0, zzzzz.width / 3, zzzzz.height, x + zzzzzXDif(), y - 15 - collider.height, zzzzz.width / 3, zzzzz.height);
		}
		else {
			super.render(g);
			if (isCrosshairVisible) {
				g.color = kha.Color.fromBytes(255, 0, 0, 150);
				
				var px = muzzlePoint.x + 50 * crosshair.x;
				var py = muzzlePoint.y + 50 * crosshair.y;
				g.drawLine( px - 10 * crosshair.x, py - 10 * crosshair.y, px - 2 * crosshair.x, py - 2 * crosshair.y, 2 );
				g.drawLine( px + 10 * crosshair.x, py + 10 * crosshair.y, px + 2 * crosshair.x, py + 2 * crosshair.y, 2 );
				g.drawLine( px - 10 * crosshair.y, py + 10 * crosshair.x, px - 2 * crosshair.y, py + 2 * crosshair.x, 2 );
				g.drawLine( px + 10 * crosshair.y, py - 10 * crosshair.x, px + 2 * crosshair.y, py - 2 * crosshair.x, 2 );
				
				/*var rect = collisionRect();
				var c = center;
				painter.drawRect( rect.x, rect.y, rect.width, rect.height );
				painter.fillRect( c.x - 4, c.y - 4, 9, 9);
					
				painter.drawLine( muzzlePoint.x, muzzlePoint.y, muzzlePoint.x + 50 * crosshair.x, muzzlePoint.y + 50 * crosshair.y);
				painter.fillRect( muzzlePoint.x - 4, muzzlePoint.y - 4, 9, 9);//*/
			}
		}
		/*painter.setColor( kha.Color.fromBytes(255,0,0) );
		var rect = collisionRect();
		painter.drawRect( rect.x, rect.y, rect.width, rect.height );
		painter.setColor( kha.Color.ColorBlack );
		painter.drawRect( x - collider.x, y - collider.y, width, height );
		painter.setColor( kha.Color.fromBytes(0,255,0) );
		painter.fillRect( x - 2, y - 2, 5, 5 );*/
	}
	
	public var usesElevator:Bool = false;
	public function use() {
		var touse = Level.the.interactiveSprites.filter(function(sprite:InteractiveSprite):Bool { return sprite.playerCanUseIt; } );
		var px = x + 0.5 * tempcollider.width;
		for (ias in touse) {
			if (px > ias.x + 0.5 * ias.tempcollider.width) {
				ias.useFrom(Direction.RIGHT);
			} else {
				ias.useFrom(Direction.LEFT);
			}
		}
	}
}
