package;

import dialogue.Action;
import dialogue.Bla;
import dialogue.BlaWithChoices;
import dialogue.StartDialogue;
import kha.Button;
import kha.Color;
import kha.Font;
import kha.FontStyle;
import kha.Framebuffer;
import kha.Game;
import kha.graphics2.Graphics;
import kha.HighscoreList;
import kha.Image;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.Mouse;
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
import kha.Sys;
import kha.Configuration;
import kha.ScreenRotation;
import kha.SoundChannel;
import kha.Sprite;
import kha.Storage;
import kha.Tile;
import kha.Tilemap;
import localization.Keys_text;

enum Mode {
	Loading;
	StartScreen;
	Game;
	BlaBlaBla;
	Menu;
	GameOver;
	Congratulations;
}

class TenUp4 extends Game {
	public static var the(default, null): TenUp4;
	private var backbuffer: Image;
	//var music : Music;
	var tileColissions : Array<Tile>;
	var map : Array<Array<Int>>;
	var originalmap : Array<Array<Int>>;
	var highscoreName : String;
	private var font: Font;
	
	public var mouseX: Float;
	public var mouseY: Float;
	private var screenMouseX: Float;
	private var screenMouseY: Float;
	
	public var dlg : Dialogue;
	
	public var mode(default, null) : Mode;
	
	public function new() {
		super("10Up: Unity", false);
		the = this;
		highscoreName = "";
		mode = Mode.Loading;
		
		Level.the = new Level(0);
		dlg = new Dialogue();
	}
	
	public override function init(): Void {
		backbuffer = Image.createRenderTarget(width, height);
		Configuration.setScreen(new LoadingScreen());
		Loader.the.loadRoom("start", initStart);
		Random.init( Math.round( Sys.getTime() * 1000 ) );
		kha.Sys.mouse.hide();
	}
	
	public function initStart(): Void {
		if (Gamepad.get(0) != null) Gamepad.get(0).notify(axisListener, buttonListener);
		Keyboard.get().notify(keydown, keyup);
		Mouse.get().notify(mousedown, mouseup, mousemove, mousewheel);
		
		font = Loader.the.loadFont("arial", FontStyle.Default, 34);
		Localization.init("localizations");
		
		Cfg.init();
		if (Cfg.language == null) {
			Configuration.setScreen(this);
			var msg = "Please select your language:";
			var choices = new Array<Array<Dialogue.DialogueItem>>();
			var i = 1;
			for (l in Localization.availableLanguages.keys()) {
				choices.push([new StartDialogue(function() { Cfg.language = l; } )]);
				msg += '\n($i): ${Localization.availableLanguages[l]}';
				++i;
			}
			dlg.set( [
				new BlaWithChoices(msg, null, choices)
				, new StartDialogue(Cfg.save)
				, new StartDialogue(initTitleScreen)
			] );
		} else {
			initTitleScreen();
		}
	}

	@:access(BlaBox) 
	function initTitleScreen() {
		mode = StartScreen;
		
		Localization.language = Cfg.language;
		Localization.buildKeys("../Assets/text.xml","text");
		
		var logo = new Sprite( Loader.the.getImage( "10up-logo" ) );
		logo.x = 0.5 * width - 0.5 * logo.width;
		logo.y = 0.5 * height - 0.5 * logo.height;
		Scene.the.clear();
		Scene.the.setBackgroundColor(Color.fromBytes(0, 0, 0));
		Scene.the.addHero( logo );
		Configuration.setScreen(this);
		
		playerWantsToTalk = new BlaBox(null, null);
		playerWantsToTalk.maxWidth = 360;
		playerWantsToTalk.padding = 5;
		playerWantsToTalk.persistent = true;
		playerWantsToTalk.setText("", 350, 70);
	}
	
	public function enterLevel(levelNumber: Int) : Void {
		Configuration.setScreen( new LoadingScreen() );
		switch (levelNumber) {
		case 0:
			//Level.the = new Intro();
			Loader.the.loadRoom("start", initLevel.bind(0));
		default:
			Level.the = new Level(levelNumber);
			Loader.the.loadRoom("level1", initLevel.bind(levelNumber));
		}
	}
	
	private function initLevel(levelNumber: Int): Void {
		Level.the.init();
		tileColissions = new Array<Tile>();
		for (i in 0...2048) {
			tileColissions.push(new Tile(i, isCollidable(i)));
		}
		if ( levelNumber == 0 ) {
			Scene.the.clear();
			Configuration.setScreen(this);
			mode = StartScreen; // TODO check!
		} else {
			var blob = Loader.the.getBlob("flatlevel");
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
		var tilemap : Tilemap = new Tilemap("tileset", 32, 32, map, tileColissions);
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
		
		var currentDoorId = 0;
		
		for (i in 0...spriteCount) {
			var sprite : kha.Sprite = null;
			switch (sprites[i * 3]) {
			case 0:
				if (PlayerBlondie.the == null) {
					sprite = new PlayerBlondie(sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
					PlayerBlondie.the.sleep();
					Level.the.persons.push(cast sprite);
					Scene.the.addHero(sprite);
				}
			case 1:
				if (PlayerBullie.the == null) {
					sprite = new PlayerBullie(sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
					PlayerBullie.the.sleep();
					Level.the.persons.push(cast sprite);
					Scene.the.addHero(sprite);
				}
			case 2:
				//klowand
				sprite = new DestructibleSprite(100, null, 40, 40, 0); // TODO: fixme!
				sprite.x = sprites[i * 3 + 1] * 2;
				sprite.y = sprites[i * 3 + 2] * 2;
				Scene.the.addOther(sprite);
			case 3:
				//aufzugstür
				sprite = new ElevatorDoor(Level.the.levelNum, sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
				Level.the.elevatorDoor = cast sprite;
				Scene.the.addOther(sprite);
			case 4:
				//aufzugknopf
				sprite = new ElevatorButton(Level.the.levelNum, sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
				Level.the.elevatorButton = cast sprite;
				Scene.the.addOther(sprite);
			case 5:
				// Tür
				sprite = new Door(currentDoorId++, sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
				Level.the.doors.push( cast sprite );
				Scene.the.addOther(sprite);
			case 6:
				// Klo
				sprite = new Sprite(null, 50, 40, 0); // TODO: fixme!
				sprite.accy = 0;
				sprite.x = sprites[i * 3 + 1] * 2;
				sprite.y = sprites[i * 3 + 2] * 2;
				Scene.the.addOther(sprite);
			case 7:
				// Waschbecken
				sprite = new Sprite(null, 40, 40, 0); // TODO: fixme!
				sprite.accy = 0;
				sprite.x = sprites[i * 3 + 1] * 2;
				sprite.y = sprites[i * 3 + 2] * 2;
				Scene.the.addOther(sprite);
			case 8:
				// Feuerlöscher
				sprite = new Sprite(null, 40, 20, 0); // TODO: fixme!
				sprite.accy = 0;
				sprite.x = sprites[i * 3 + 1] * 2;
				sprite.y = sprites[i * 3 + 2] * 2;
				Scene.the.addOther(sprite);
			case 9:
				// Stockwerk-Nummer
				sprite = new ElevatorPositionSign(Level.the.levelNum, sprites[i * 3 + 1] * 2, sprites[i * 3 + 2] * 2);
				Level.the.elevatorPositionSign = cast sprite;
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
				Level.the.destructibleSprites.push( cast sprite );
				Level.the.interactiveSprites.push( cast sprite );
			} else if ( Std.is( sprite, InteractiveSprite ) ) {
				Level.the.interactiveSprites.push( cast sprite );
			}
		}
		
		//music.play();
		
		//PlayerBullie.the.setCurrent();
		Server.the.trigger();
	}
	
	public function victory() : Void {
		showCongratulations();
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
		case 0: return true;
		default:
			return false;
		}
	}
	
	public override function update() {
		super.update();
		updateMouse();
		var player = Player.current();
		if (player != null) {
			Scene.the.camx = Std.int(player.x) + Std.int(player.width / 2);
			Scene.the.camy = Std.int(player.y + player.height + 80 - 0.5 * height);
		}
		dlg.update();
		
		if (Player.current() != null) Server.the.updatePlayer(Player.current());
	}
	
	public var renderOverlay : Bool;
	public var overlayColor : Color;
	public override function render(frame: Framebuffer) {
		var g = backbuffer.g2;
		g.begin();
		switch (mode) {
		case GameOver:
			var congrat = Loader.the.getImage("gameover");
			g.drawImage(congrat, width / 2 - congrat.width / 2, height / 2 - congrat.height / 2);
		case Congratulations:
			var congrat = Loader.the.getImage("congratulations");
			g.drawImage(congrat, width / 2 - congrat.width / 2, height / 2 - congrat.height / 2);
		case Game, BlaBlaBla, Menu:
			scene.render(g);
			g.transformation = Matrix3.identity();
			g.color = Color.Black;
			for (door in Level.the.doors) {
				if (!door.opened && door.health > 0) {
					if (door.x < Player.current().x) {
						var doorXscreen = door.x - scene.screenOffsetX; 
						if (doorXscreen > 0 && doorXscreen < width) {
							g.fillRect(0, 0, doorXscreen, height);
						}
					} else {
						var doorXscreen = door.x + 0.5 * door.width - scene.screenOffsetX; 
						if (doorXscreen > 0 && doorXscreen < width) {
							g.fillRect(doorXscreen, 0, width - doorXscreen, height);
						}
					}
				}
			}
			// TODO: block fahrstuhl
			if (Player.current() != null) drawPlayerInfo(g);
		case StartScreen:
			scene.render(g);
			g.font = font;
			g.color = Color.Magenta;
			g.pushTransformation(g.transformation.multmat(Matrix3.scale(3, 3)));
			g.drawString("UNITY", 180 + 10 * Math.cos(0.3 * Sys.getTime()), 140 + 10 * Math.sin(0.6 * Sys.getTime()));
			g.popTransformation();
			var b = Math.round(100 + 125 * Math.pow(Math.sin(0.5 * Sys.getTime()),2));
			g.color = Color.fromBytes(b, b, b);
			var str = Localization.getText(Keys_text.CLICK_TO_START);
			g.drawString(str, 0.5 * (width - font.stringWidth(str)), 650);
		case Loading:
			scene.render(g);
		}
		if (renderOverlay) {
			g.color = overlayColor;
			g.fillRect(0, 0, width, height);
		}
		
		g.transformation = Matrix3.identity();
		for (box in BlaBox.boxes) {
			g.color = Color.White;
			box.render(g);
		}
		g.end();
		
		frame.g2.begin();
		Scaler.scale(backbuffer, frame, kha.Sys.screenRotation);
		frame.g2.end();
	}
	
	var playerChatStr : String = "";
	var playerWantsToTalk : BlaBox;
	
	@:access(Player) @:access(BlaBox) 
	private function drawPlayerInfo(g: Graphics): Void {
		var x = 30;
		var y = height - 85;
		g.color = Color.fromBytes(40, 40, 40);
		g.fillRect(x-10, y-30, TenUp4.the.width - 2 * (x-10), 90);
		g.color = Color.White;
		g.font = Loader.the.loadFont("Liberation Sans", FontStyle.Default, 20);
		var lm1 = "L. Mouse, SPACE:";
		var rm1 = "R. Mouse, CTRL:";
		var u1 = "E, SCHIFT:";
		var u2 = Localization.getText(Keys_text.ABILITY_USE);
		var lm2 = Player.current().leftButton();
		var rm2 = Player.current().rightButton();
		var ty : Float = y - 15;
		var w1 = g.font.stringWidth(lm1);
		var w2 = g.font.stringWidth(rm1);
		var w3 = g.font.stringWidth(u1);
		var wm = Math.max(w1, Math.max(w2, w3));
		g.drawString(lm1, 600 + wm - w1, ty);
		g.drawString(lm2, 600 + wm + 5, ty);
		ty += g.font.getHeight() + 1;
		g.drawString(rm1, 600 + wm - w2, ty);
		g.drawString(rm2, 600 + wm + 5, ty);
		ty += g.font.getHeight() + 1;
		g.drawString(u1, 600 + wm - w3, ty);
		g.drawString(u2, 600 + wm + 5, ty);
		
		g.font = font;
		g.drawString(Player.current().getName(), x + 60, y);
		
		playerWantsToTalk.width = playerWantsToTalk.maxWidth;
		playerWantsToTalk.render(g, 225, y - 20);
		
		
		//g.color = Color.fromBytes(30, 30, 30);
		//g.fillRect(x-5, y-25, 50, 80);
		g.color = Color.fromBytes(175, 0, 0);
		var healthBar = 40 * Player.current().health / Player.current().maxHealth;
		if (healthBar < 0) healthBar = 0;
		g.fillRect(x, y + 40, healthBar, 15);
		g.color = Color.White;
		g.drawImage(Player.current().mini, x, y - 20);
	}
	
	function axisListener(axis: Int, value: Float): Void {
		switch (axis) {
			case 0:
				if (value < -0.2) {
					Player.current().left = true;
					Player.current().right = false;
				}
				else if (value > 0.2) {
					Player.current().right = true;
					Player.current().left = false;
				}
				else {
					Player.current().left = false;
					Player.current().right = false;
				}
		}
	}
	
	function buttonListener(button: Int, value: Float): Void {
		switch (button) {
			case 0, 1, 2, 3:
				if (value > 0.5) keydown(Key.UP, null);
				else keyup(Key.UP, null);
			case 14:
				if (value > 0.5) {
					keydown(Key.LEFT, null);
					keyup(Key.RIGHT, null);
				}
				else {
					keydown(Key.LEFT, null);
					keydown(Key.RIGHT, null);
				}
			case 15:
				if (value > 0.5) {
					keyup(Key.LEFT, null);
					keydown(Key.RIGHT, null);
				}
				else {
					keydown(Key.LEFT, null);
					keydown(Key.RIGHT, null);
				}
// TODO: 
	/*
			case BUTTON_1:
				Player.current().prepareSpecialAbilityA(currentGameTime);
			case BUTTON_2:
				Player.current().prepareSpecialAbilityB(currentGameTime);
			case BUTTON_1:
				Player.current().useSpecialAbilityA(currentGameTime);
			case BUTTON_2:
				Player.current().useSpecialAbilityB(currentGameTime);
				*/
		}
	}
	
	function keydown(key: Key, char: String) : Void {
		if (mode == Mode.Game) {
			if (Player.current() == null) return;
			switch (key) {
			case Key.CHAR:
				switch(char) {
				case 'a', 'A':
					keydown(Key.LEFT, null);
				case 'd', 'D':
					keydown(Key.RIGHT, null);
				case 'w', 'W':
					keydown(Key.UP, null);
				case 's', 'S':
					keydown(Key.DOWN, null);
				case ' ':
				Player.current().prepareSpecialAbilityA();
				default:
				}
			case Key.LEFT:
				Player.current().left = true;
			case Key.RIGHT:
				Player.current().right = true;
			case Key.UP:
				Player.current().setUp();
			case Key.SHIFT:
				Player.current().prepareSpecialAbilityB();
			default:
			}
		}
	}
	
	function keyup(key : Key, char : String) : Void {
		switch (mode) {
			case Game:
				if (Player.current() == null) return;
				switch (key) {
				case Key.ESC:
					Dialogues.escMenu();
				case Key.ENTER:
					mode = BlaBlaBla;
					playerWantsToTalk.isInput = true;
				case Key.CHAR:
					switch (char) {
					case 'a', 'A':
						keyup(Key.LEFT, null);
					case 'd', 'D':
						keyup(Key.RIGHT, null);
					case 'w', 'W':
						keyup(Key.UP, null);
					case 'c', 'C':
						mode = BlaBlaBla;
						playerWantsToTalk.isInput = true;
					case ' ':
						Player.current().useSpecialAbilityA();
					case 'e', 'E':
						Player.current().use();
					}
				case Key.LEFT:
					Player.current().left = false;
				case Key.RIGHT:
					Player.current().right = false;
				case Key.UP:
					Player.current().up = false;
				case Key.SHIFT:
					Player.current().useSpecialAbilityB();
				case Key.CTRL:
					Player.current().use();
				default:
				}
			case StartScreen:
				switch (key) {
				case Key.ESC:
					Dialogues.escMenu();
				default:
					dlg.set([new Action(null, ActionType.FADE_TO_BLACK), new StartDialogue(enterLevel.bind(1))]);
				}
			case BlaBlaBla:
				if (Player.current() == null) return;
				switch (key) {
				case Key.ESC:
					playerChatStr = "";
					playerWantsToTalk.isInput = false;
					mode = Game;
				case Key.BACKSPACE:
					playerChatStr = playerChatStr.substr(0, -1);
				case Key.ENTER:
					Player.current().dlg.insert([new Bla(playerChatStr,Player.current())]);
					playerChatStr = "";
					playerWantsToTalk.isInput = false;
					mode = Game;
				case Key.CHAR:
					playerChatStr += char;
				default:
				}
				playerWantsToTalk.setText(playerChatStr, 350, 70);
			default:
				switch (key) {
				case Key.ESC:
					Dialogues.escMenu();
				default:
				}
		}
	}
	
	private function updateMouse(): Void {
		mouseX = screenMouseX + Scene.the.screenOffsetX;
		mouseY = screenMouseY + Scene.the.screenOffsetY;
	}
	
	function mousedown(button: Int, x: Int, y: Int): Void {
		screenMouseX = x;
		screenMouseY = y;
		updateMouse();
		
		switch(mode) {
		case Game:
			if (Player.current() == null) return;
			if (mouseUpAction == null) {
				switch (button) {
				case 0:
					Player.current().prepareSpecialAbilityA();
					mouseUpAction = Player.current().useSpecialAbilityA;
				case 1:
					Player.current().prepareSpecialAbilityB();
					mouseUpAction = Player.current().useSpecialAbilityB;
				}
			}
		default:
		}
	}
	
	private var mouseUpAction : Void->Void;
	public var advanceDialogue: Bool = false;
	function mouseup(button: Int, x: Int, y: Int): Void {
		screenMouseX = x;
		screenMouseY = y;
		updateMouse();
		
		switch (mode) {
		case StartScreen:
			dlg.set([new Action(null, ActionType.FADE_TO_BLACK), new StartDialogue(enterLevel.bind(1))]);
		case Game:
			if (Player.current() == null) return;
			if (mouseUpAction != null) {
				mouseUpAction();
				mouseUpAction = null;
			}
		default:
		}
	}
	
	function mousemove(x: Int, y: Int): Void {
		screenMouseX = x;
		screenMouseY = y;
		updateMouse();
	}
	
	function mousewheel(delta: Int): Void {
	}
}
