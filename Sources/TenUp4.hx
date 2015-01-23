package;

import kha.Button;
import kha.Color;
import kha.Font;
import kha.FontStyle;
import kha.Framebuffer;
import kha.Game;
import kha.graphics2.Graphics;
import kha.HighscoreList;
import kha.Image;
import kha.Key;
import kha.Loader;
import kha.LoadingScreen;
import kha.math.Matrix3;
import kha.math.Random;
import kha.Music;
import kha.Scaler;
import kha.Scene;
import kha.Scheduler;
import kha.Score;
import kha.Configuration;
import kha.Sprite;
import kha.Tile;
import kha.Tilemap;
import levels.Intro;
import levels.Level1;

enum Mode {
	Loading;
	StartScreen;
	MissionBriefing;
	Game;
	Pause;
	GameOver;
	Congratulations;
}

class TenUp4 extends Game {
	public static var instance(default, null): TenUp4;
	private var backbuffer: Image;
	//var music : Music;
	var tileColissions : Array<Tile>;
	var map : Array<Array<Int>>;
	var originalmap : Array<Array<Int>>;
	var highscoreName : String;
	var shiftPressed : Bool;
	private var font: Font;
	private var pauseAnimIndex: Int = 0;
	public var level(default, null): Level;
	
	public var currentGameTime(default, null) : Float;
	public var currentTimeDiff(default, null) : Float;
	var lastTime : Float;
	private var minis: Array<Image>;
	
	public var mode(default, null) : Mode;
	
	public function new() {
		super("10Up", false);
		instance = this;
		shiftPressed = false;
		highscoreName = "";
		mode = Mode.Loading;
		minis = new Array<Image>();
	}
	
	public static function getInstance(): TenUp4 {
		return instance;
	}
	
	public function pause(): Void {
		if (mouseUpAction != null) {
			mouseUpAction(currentGameTime);
			mouseUpAction = null;
		}
		if (nextPlayer() && !level.checkVictory()) mode = Pause;
	}
	
	public override function init(): Void {
		backbuffer = Image.createRenderTarget(1024, 768);
		Configuration.setScreen(new LoadingScreen());
		Loader.the.loadRoom("start", initStart);
	}
	
	public function enterLevel(levelNumber: Int) : Void {
		Configuration.setScreen( new LoadingScreen() );
		switch (levelNumber) {
		case 0:
			level = new Intro();
			Loader.the.loadRoom("start", initLevel.bind(0));
		case 1:
			level = new Level1();
			Loader.the.loadRoom("level1", initLevel.bind(1));
		}
	}
	
	public function initStart(): Void {
		Random.init( Math.round( Scheduler.time() * 1000 ) );
		var logo = new Sprite( Loader.the.getImage( "10up-logo" ) );
		logo.x = 0.5 * width - 0.5 * logo.width;
		logo.y = 0.5 * height - 0.5 * logo.height;
		Scene.the.clear();
		Scene.the.setBackgroundColor(Color.fromBytes(0, 0, 0));
		Scene.the.addHero( logo );
		mode = StartScreen;
		Configuration.setScreen(this);
        //flash.Lib.current.stage.displayState = FULL_SCREEN;
	}
	
	private function initLevel(levelNumber: Int): Void {
		level.init();
		font = Loader.the.loadFont("arial", new FontStyle(false, false, false), 34);
		minis = new Array();
		minis.push(Loader.the.getImage("agentmini"));
		minis.push(Loader.the.getImage("professormini"));
		minis.push(Loader.the.getImage("rowdymini"));
		minis.push(Loader.the.getImage("mechanicmini"));
		tileColissions = new Array<Tile>();
		for (i in 0...352) {
			tileColissions.push(new Tile(i, isCollidable(i)));
		}
		if ( levelNumber == 0 ) {
			Scene.the.clear();
			Configuration.setScreen(this);
			currentGameTime = 0;
			lastTime = Scheduler.time();
			mode = MissionBriefing;
		} else {
			var blob = Loader.the.getBlob("level" + levelNumber);
			var levelWidth: Int = blob.readS32BE();
			var levelHeight: Int = blob.readS32BE();
			originalmap = new Array<Array<Int>>();
			for (x in 0...levelWidth) {
				originalmap.push(new Array<Int>());
				for (y in 0...levelHeight) {
					originalmap[x].push(blob.readS32BE());
				}
			}
			map = new Array<Array<Int>>();
			for (x in 0...originalmap.length) {
				map.push(new Array<Int>());
				for (y in 0...originalmap[0].length) {
					map[x].push(0);
				}
			}
			var spriteCount = blob.readS32BE();
			var sprites = new Array<Int>();
			for (i in 0...spriteCount) {
				sprites.push(blob.readS32BE());
				sprites.push(blob.readS32BE());
				sprites.push(blob.readS32BE());
			}
			//music = Loader.the.getMusic("level1");
			startGame(spriteCount, sprites);
		}
	}
	
	public function startGame(spriteCount: Int, sprites: Array<Int>) {
		Scene.the.clear();
		Player.init();
		var tilemap : Tilemap = new Tilemap("outside", 32, 32, map, tileColissions);
		Scene.the.setColissionMap(tilemap);
		Scene.the.addBackgroundTilemap(tilemap, 1);
		var TILE_WIDTH : Int = 32;
		var TILE_HEIGHT : Int = 32;
		for (x in 0...originalmap.length) {
			for (y in 0...originalmap[0].length) {
				switch (originalmap[x][y]) {
				default:
					map[x][y] = originalmap[x][y];
				}
			}
		}
		
		for (i in 0...spriteCount) {
			var sprite : kha.Sprite = null;
			switch (sprites[i * 3]) {
			case 0:
				//sprite = new PlayerAgent(sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
				//Scene.the.addHero(sprite);
			case 1:
				//sprite = new PlayerProfessor(sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
				//Scene.the.addHero(sprite);
			case 2:
				sprite = new PlayerBullie(sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
				Scene.the.addHero(sprite);
			case 3:
				sprite = new PlayerBlondie(sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
				Scene.the.addHero(sprite);
			case 4:
				sprite = new Door(sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
				level.doors.push( cast sprite );
				Scene.the.addOther(sprite);
			case 5:
				/*sprite = new Enemy(sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
				Scene.the.addEnemy(sprite);*/
			case 6:
				sprite = new Window(sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
				Scene.the.addOther(sprite);
			case 7:
				/*sprite = new Gate(sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
				level.gates.push(cast sprite);
				Scene.the.addOther(sprite);*/
			case 8:
				/*sprite = new Gatter(sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
				level.gatters.push(cast sprite);
				Scene.the.addOther(sprite);*/
			case 9:
				sprite = new Computer(sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
				level.computers.push(cast sprite);
				Scene.the.addOther(sprite);
			case 10:
				/*sprite = new Machinegun(sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
				Scene.the.addEnemy(sprite);*/
			case 11:
				/*sprite = new Boss(sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
				level.bosses.push(cast sprite);
				Scene.the.addEnemy(sprite);*/
			case 12:
				/*sprite = new Car(sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
				level.cars.push(cast sprite);
				Scene.the.addOther(sprite);*/
			default:
				trace ("That should never happen! We are therefor going to ignore it.");
				continue;
			}
			if ( Std.is( sprite, DestructibleSprite ) ) {
				level.destructibleSprites.push( cast sprite );
				level.interactiveSprites.push( cast sprite );
			} else if ( Std.is( sprite, InteractiveSprite ) ) {
				level.interactiveSprites.push( cast sprite );
			}
		}
		
		//music.play();
		Player.getPlayer(0).setCurrent();
		//Player.getInstance().reset();
		Configuration.setScreen(this);
		currentGameTime = 0;
		lastTime = Scheduler.time();
		mode = MissionBriefing;
		Scene.the.camx = Std.int(width / 2);
	}
	
	public function victory() : Void {
		if (level.nextLevelNum < 0) {
			showCongratulations();
		} else {
			enterLevel( level.nextLevelNum );
		}
	}
	
	public function defeat() : Void {
		showGameOver();
	}
	
	public function showCongratulations() {
		Scene.the.clear();
		mode = Mode.Congratulations;
		//music.stop();
	}
	
	public function showGameOver() {
		Scene.the.clear();
		mode = Mode.GameOver;
		//music.stop();
	}
	
	private static function isCollidable(tilenumber : Int) : Bool {
		switch (tilenumber) {
		case 64, 65, 66, 128, 320, 341, 342: return true;
		default:
			return false;
		}
	}
	
	public override function update() {
		var currentTime = Scheduler.time();
		if (mode == Game || mode == MissionBriefing) {
			currentTimeDiff = currentTime - lastTime;
			currentGameTime += currentTimeDiff;
			if (mode == Game) {
				Player.current().elapse( currentTimeDiff );
				super.update();
				Scene.the.camx = Std.int(Player.current().x) + Std.int(Player.current().width / 2);
				level.update(currentGameTime);
			} else {
				if (level.updateMissionBriefing(currentGameTime)) {
					currentGameTime = 0;
					mode = Pause;
				}
				lastTime = currentTime;
				return;
			}
		} else if (mode != Pause) {
			super.update();
		} else {
			pauseAnimIndex += 1;
			
			var aimx = Std.int(Player.current().x) + Std.int(Player.current().width / 2);
			var camspeed: Int = 10;
			if (Scene.the.camx > aimx) {
				Scene.the.camx -= camspeed;
				if (Scene.the.camx < aimx) Scene.the.camx = aimx; 
			}
			else if (Scene.the.camx < aimx) {
				Scene.the.camx += camspeed;
				if (Scene.the.camx > aimx) Scene.the.camx = aimx; 
			}
		}
		lastTime = currentTime;
	}
	
	public override function render(frame: Framebuffer) {
		//if (Player.getInstance() == null) return;
		var g = backbuffer.g2;
		g.begin();
		switch (mode) {
		case GameOver:
			var congrat = Loader.the.getImage("gameover");
			g.drawImage(congrat, width / 2 - congrat.width / 2, height / 2 - congrat.height / 2);
		case Congratulations:
			var congrat = Loader.the.getImage("congratulations");
			g.drawImage(congrat, width / 2 - congrat.width / 2, height / 2 - congrat.height / 2);
		case Game, Pause:
			scene.render(g);
			g.transformation = Matrix3.identity();
			//painter.setColor(Color.fromBytes(0, 0, 0));
			//painter.drawString("Score: " + Std.string(Player.getInstance().getScore()), 20, 25);
			//painter.drawString("Round: " + Std.string(Player.getInstance().getRound()), width - 100, 25);
			
			drawPlayerInfo(g, 0, 20, 700, Color.fromBytes(255, 0, 0));
			drawPlayerInfo(g, 1, 80, 700, Color.fromBytes(0, 255, 0));
			drawPlayerInfo(g, 2, 140, 700, Color.fromBytes(0, 0, 255));
			drawPlayerInfo(g, 3, 200, 700, Color.fromBytes(255, 255, 0));
			
			if (mode == Pause) {
				var pauseImage = Loader.the.getImage("pause");
				g.drawScaledSubImage(pauseImage, 0, (Std.int(pauseAnimIndex / 12) % 5) * (pauseImage.height / 5), pauseImage.width, pauseImage.height / 5, width / 2 - pauseImage.width / 2, height / 4 - pauseImage.height / 5 / 2, pauseImage.width, pauseImage.height / 5);
			}
		case MissionBriefing:
			scene.render(g);
			Level.the.renderMissionBriefing(g);
		case Loading, StartScreen:
			scene.render(g);
		}
		g.end();
		
		frame.g2.begin();
		Scaler.scale(backbuffer, frame, kha.Sys.screenRotation);
		frame.g2.end();
	}
	
	@:access(Player) 
	private function drawPlayerInfo(g: Graphics, index: Int, x: Float, y: Float, color: Color): Void {
		if (Player.getPlayerIndex() == index) {
			g.color = Color.White;
			
			g.font = font;
			//painter.fillRect(0, y - 30, 1024, 5);
			g.drawString("Left Mouse", 600, y - 25);
			//painter.fillRect(0, y + 20, 1024, 5);
			g.drawString(Player.current().leftButton(), 620, y + 25);
			g.drawString("Right Mouse", 800, y - 25);
			g.drawString(Player.current().rightButton(), 820, y + 25);
			
			//painter.fillRect(x - 5, y - 5, 50, 50);
			g.fillRect(x - 10, y - 25, 50, 10);
			g.fillRect(x - 10, y - 25, 10, 90);
			g.fillRect(x + 40, y - 25, 10, 90);
			g.fillRect(x - 10, y - 25 + 80, 50, 10);
		}
		g.color = Color.White;
		g.drawImage(minis[index], x, y - 20);
		g.color = Color.fromBytes(50, 50, 50);
		g.fillRect(x, y + 45, 40, 10);
		g.color = Color.fromBytes(150, 0, 0);
		var healthBar = 40 * Player.getPlayer(index).health / Player.getPlayer(index).maxHealth;
		if (healthBar < 0) healthBar = 0;
		g.fillRect(x, y + 35, healthBar, 10);
		g.color = Color.Black;
		g.fillRect(x + healthBar, y + 35, 40 - healthBar, 10);
		g.color = Color.fromBytes(0, 255, 255);
		g.fillRect(x, y + 45, Player.getPlayer(index).timeLeft() * 4, 10);
	}

	override public function buttonDown(button : Button) : Void {
		switch (mode) {
		case Game:
			switch (button) {
			case UP:
				Player.current().setUp();
			case LEFT:
				Player.current().left = true;
			case RIGHT:
				Player.current().right = true;
			case BUTTON_1:
				Player.current().prepareSpecialAbilityA(currentGameTime);
			case BUTTON_2:
				Player.current().prepareSpecialAbilityB(currentGameTime);
			default:
			}
		case Pause:
			switch (button) {
				case LEFT:
					prevPlayer();
				case RIGHT:
					nextPlayer();
				default:
			}
		default:
		}
	}
	
	override public function buttonUp(button : Button) : Void {
		switch (mode) {
		case Game:
			switch (button) {
			case UP:
				Player.current().up = false;
			case LEFT:
				Player.current().left = false;
			case RIGHT:
				Player.current().right = false;
			case BUTTON_1:
				Player.current().useSpecialAbilityA(currentGameTime);
			case BUTTON_2:
				Player.current().useSpecialAbilityB(currentGameTime);
			default:
			}
		default:
		}
	}
	
	private function nextPlayer(): Bool {
		var count: Int = 0;
		var index = Player.getPlayerIndex();
		while (true) {
			++index;
			if (index > 3) index = 0;
			var player = Player.getPlayer(index);
			++count;
			if (!player.isSleeping()) {
				player.setCurrent();
				return true;
			}
			if (count > 4) return false;
		}
		return false;
	}
	
	private function prevPlayer(): Bool {
		var count: Int = 0;
		var index = Player.getPlayerIndex();
		while (true) {
			--index;
			if (index < 0) index = 3;
			var player = Player.getPlayer(index);
			++count;
			if (!player.isSleeping()) {
				player.setCurrent();
				return true;
			}
			if (count > 4) return false;
		}
		return false;
	}
	
	override public function keyDown(key : Key, char : String) : Void {
		if (key == Key.SHIFT) shiftPressed = true;
		
		if ( mode == MissionBriefing ) {
			return;
		}
		
		if (key == Key.CHAR) {
			switch (char) {
				case 'a', 'A':
					buttonDown(Button.LEFT);
				case 'd', 'D':
					buttonDown(Button.RIGHT);
				case 'w', 'W':
					buttonDown(Button.UP);
				case 's', 'S':
					buttonDown(Button.DOWN);
			}
			
			if (mode == Mode.Game) {
				if (char == " ") {
					mode = Pause;
					if (mouseUpAction != null) {
						mouseUpAction(currentGameTime);
						mouseUpAction = null;
					}
					Player.current().right = false;
					Player.current().left = false;
					Player.current().up = false;
				}
			}
			else if (mode == Mode.Pause) {
				if (char == " ") {
					mode = Game;
				}
			}
		}
	}
	
	override public function keyUp(key : Key, char : String) : Void {
		//if (key != null && key == Key.SHIFT) shiftPressed = false;
		if (key == Key.SHIFT) shiftPressed = false;
		
		if ( mode == MissionBriefing ) {
			level.anyKey = true;
			return;
		}
		
		if (mode == StartScreen) {
			enterLevel(0);
		} else {
			switch (char) {
				case 'a', 'A':
					buttonUp(Button.LEFT);
				case 'd', 'D':
					buttonUp(Button.RIGHT);
				case 'w', 'W':
					buttonUp(Button.UP);
				case 's', 'S':
					buttonUp(Button.DOWN);
			}
		}
	}
	
	public var mouseX(default, null) : Float;
	public var mouseY(default, null) : Float;
	override public function mouseMove(x:Int, y:Int) : Void {
		mouseX = x + Scene.the.screenOffsetX;
		mouseY = y + Scene.the.screenOffsetY;
	}
	
	override public function mouseDown(x: Int, y: Int): Void {
		if ( mode == MissionBriefing ) {
			return;
		}
		mouseX = x + Scene.the.screenOffsetX;
		mouseY = y + Scene.the.screenOffsetY;
		if (mode == Game) {
			if (mouseUpAction == null) {
				if (shiftPressed) {
					Player.current().prepareSpecialAbilityB(currentGameTime);
					mouseUpAction = Player.current().useSpecialAbilityB;
				}
				else {
					Player.current().prepareSpecialAbilityA(currentGameTime);
					mouseUpAction = Player.current().useSpecialAbilityA;
				}
			}
		}
	}
	
	private var mouseUpAction : Float->Void;
	
	override public function mouseUp(x: Int, y: Int): Void {
		if ( mode == MissionBriefing ) {
			level.anyKey = true;
			return;
		}
		mouseX = x + Scene.the.screenOffsetX;
		mouseY = y + Scene.the.screenOffsetY;
		switch (mode) {
		case Game:
			if (mouseUpAction != null) {
				mouseUpAction( currentGameTime );
				mouseUpAction = null;
			}
		case StartScreen:
			enterLevel(0);
		default:
		}
	}
	
	override public function rightMouseDown(x: Int, y: Int): Void {
		if ( mode == MissionBriefing ) {
			return;
		}
		mouseX = x + Scene.the.screenOffsetX;
		mouseY = y + Scene.the.screenOffsetY;
		if (mode == Game) {
			if (mouseUpAction == null) {
				Player.current().prepareSpecialAbilityB(currentGameTime);
				mouseUpAction = Player.current().useSpecialAbilityB;
			}
		}
	}
	
	override public function rightMouseUp(x: Int, y: Int): Void {
		if ( mode == MissionBriefing ) {
			level.anyKey = true;
			return;
		}
		mouseX = x + Scene.the.screenOffsetX;
		mouseY = y + Scene.the.screenOffsetY;
		switch (mode) {
		case Game:
			if (mouseUpAction != null) {
				mouseUpAction( currentGameTime );
				mouseUpAction = null;
			}
		case StartScreen:
			enterLevel(0);
		default:
		}
	}
}