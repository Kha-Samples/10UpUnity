package;

import kha.Animation;
import kha.Color;
import kha.Direction;
import kha.graphics2.Graphics;
import kha.Image;
import kha.Loader;
import kha.math.Matrix3;
import kha.math.Vector2;
import kha.Music;
import kha.Rectangle;
import kha.Rotation;
import kha.Scene;
import kha.Sound;
import kha.Sprite;

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
	var score : Int;
	var round : Int;
	private var hitSound: Sound;
	private var time: Float;
	private static var currentPlayer: Player = null;
	private static var jumpmans: Array<Player>;
	
	var muzzlePoint : Vector2;
	
	public function new(x: Float, y: Float, image: String, width: Int, height: Int, maxHealth: Int = 50) {
		super(maxHealth, Loader.the.getImage(image), width, height, 0);
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
		score = 0;
		round = 1;
		up = false;
		right = false;
		left = false;
		lookRight = true;
		killed = false;
		time = 0;
		jumpcount = 0;
		crosshair = new Vector2(1, 0);
		isRepairable = true;
		hitSound = Loader.the.getSound("hit");
		zzzzz = Loader.the.getImage("zzzzz");
	}
	
	public static function init(): Void {
		jumpmans = new Array<Player>();
	}
	
	public static function getPlayerCount(): Int {
		return jumpmans.length;
	}
	
	public static function getPlayer(index: Int): Player {
		return jumpmans[index];
	}
	
	public static function getPlayerIndex(): Int {
		for (i in 0...4) {
			if (jumpmans[i] == currentPlayer) return i;
		}
		return -1;
	}
	
	public static function setPlayer(index: Int, jumpman: Player): Void {
		jumpmans[index] = jumpman;
		jumpman.index = index;
	}
	
	public static function current(): Player {
		return currentPlayer;
	}
	
	public function setCurrent(): Void {
		currentPlayer = this;
	}
	
	public function timeLeft(): Float {
		return Math.max(10 - time, 0);
	}
	
	public function elapse(time: Float): Void {
		if (killed) return;
		this.time += time;
		if (this.time > 10) sleep();
	}
	
	public function reset() {
		x = y = 50;
		standing = false;
		setAnimation(jumpRight);
	}
	
	public function selectCoin() {
		score += 50;
	}
	
	public function getScore() : Int {
		return score;
	}
	
	public function getRound() : Int {
		return round;
	}
	
	public function nextRound() {
		++round;
	}
	
	private var baseSpeed = 4.0;
	public override function update(): Void {
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
				speedx = baseSpeed * Math.round(Math.pow(1.1, getRound()));
				lookRight = true;
			}
			else if (left) {
				if (standing) {
					setAnimation(walkLeft);
					walking = true;
				}
				speedx = -baseSpeed * Math.round(Math.pow(1.1, getRound()));
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
		if (this == currentPlayer) {
			TenUp4.getInstance().pause();
		}
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
	
	
	public function prepareSpecialAbilityA(gameTime : Float) : Void {
		
	}
	
	public function useSpecialAbilityA(gameTime : Float) : Void {
		
	}
	
	public function prepareSpecialAbilityB(gameTime : Float) : Void {
		
	}
	
	public function useSpecialAbilityB(gameTime : Float) : Void {
		
	}
	
	override private function set_health(value:Int):Int {
		if ( value <= 0 ) {
			if ( value < _health ) {
				if (_health - value > 1) {
					hitSound.play();
				}
				for (i in 0...Math.ceil(0.3 * (_health - value))) kha.Scene.the.addProjectile(new Blood(x + 20, y + 20));
			}
			if (!killed) {
				sleep();
			}
		} else if ( value < _health ) {
			for (i in 0...Math.ceil(0.3 * (_health - value))) kha.Scene.the.addProjectile(new Blood(x + 20, y + 20));
				if (_health - value > 1) {
					hitSound.play();
				}
		} else if ( value > _health && _health <= 0 ) {
			var resurected = timeLeft() > 0;
			if (killed && resurected) {
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
			v.x = TenUp4.instance.mouseX - v.x;
			v.y = TenUp4.instance.mouseY - v.y;
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
			//painter.drawImage2(image, 0, 0, width, height, x, y, width, height, rotation);
			g.pushTransformation(g.transformation * Matrix3.translation(x + originX, y + originY) * Matrix3.rotation(angle) * Matrix3.translation(-x - originX, -y - originY));
			g.drawScaledSubImage(image, 0, 0, width, height, x-collider.x, y-collider.y, width, height);
			g.popTransformation();
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
}
