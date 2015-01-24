package;

import kha.Color;
import kha.Font;
import kha.FontStyle;
import kha.Loader;
import kha.graphics2.Graphics;
import kha.Scene;
import kha.Sprite;

class BlaBox {
	static private var padding = 15;
	static private var maxWidth = 500;
	static public var boxes(default, null) : Array<BlaBox> = new Array();
	private var width : Float;
	private var height : Float;
	private var speaker: Sprite;
	private var font: Font;
	private var text: Array<String> = null;
	public var isThought = false;
	
	public function new(text: String, speaker: Sprite = null) {
		this.speaker = speaker;
		setText(text);
	}
	
	public function pointAt(sprite: Sprite): Void {
		speaker = sprite;
	}
	
	public function setText(text: String): Void {
		if (text != null) {
			if (font == null) font = Loader.the.loadFont("Liberation Sans", new FontStyle(false, false, false), 20);
			var maxWidth = BlaBox.maxWidth - 2 * padding;
			this.text = new Array();
			width = 200;
			height = 50;
			text = Localization.getText(text);
			var lines = text.split("\n");
			for (line in lines) {
				var tw = font.stringWidth(line);
				if (tw > maxWidth) {
					var words = Lambda.list(line.split(" "));
					while (!words.isEmpty()) {
						line = words.pop();
						tw = font.stringWidth(line);
						width = Math.max(width, tw);
						var nextWord = words.pop();
						while (nextWord != null && (tw = font.stringWidth(line + " " + nextWord)) <= maxWidth) {
							width = Math.max(width, tw);
							line += " " + nextWord;
							nextWord = words.pop();
						}
						this.text.push(line);
						if (nextWord != null) {
							words.push(nextWord);
						}
					}
				} else {
					width = Math.max(width, tw);
					this.text.push(line);
				}
			}
			width += 2 * padding;
			height = (font.getHeight() * this.text.length) + 2 * padding;
		} else {
			this.text = null;
		}
	}
	
	public function render(g: Graphics): Void {
		if (text == null) return;
		
		var sx : Float = -1;
		var sy : Float = -1;
		if (speaker != null) {
			sx = speaker.x + (0.5 * speaker.collisionRect().width) - Scene.the.screenOffsetX;
			sy = speaker.y - 15 - Scene.the.screenOffsetY;
		}
		
		var x : Float = (speaker == null) ? (0.5 * (kha.Game.the.width - width)) : sx - 0.3 * width;
		
		if (x + width > kha.Game.the.width) {
			x -= 30 + x + width - kha.Game.the.width;
		}
		if (x < 0) {
			x = 30;
		}
		
		var y : Float = (speaker == null) ? (0.3 * (kha.Game.the.height - height)) : sy - 30 - height;
		if (y < 0) {
			sy += speaker.height + 15;
			y = sy + 30;
		}
		
		g.color = Color.White;
		g.fillRect(x, y, width, height);
		g.color = Color.Black;
		g.drawRect(x, y, width, height, 5);
		g.color = Color.White;
		if (speaker != null) {
			if (sy < y) {
				g.fillTriangle(sx - 10, y + 0.5 * padding, sx + 10, y + 0.5 * padding, sx, sy);
				g.color = Color.Black;
				g.drawLine(sx - 10, y + 0.5 * padding, sx, sy, 3);
				g.drawLine(sx + 10, y + 0.5 * padding, sx, sy, 3);
			} else {
				g.fillTriangle(sx - 10, y + height - 0.5 * padding, sx + 10, y + height - 0.5 * padding, sx, sy);
				g.color = Color.Black;
				g.drawLine(sx - 10, y + height - 0.5 * padding, sx, sy, 3);
				g.drawLine(sx + 10, y + height - 0.5 * padding, sx, sy, 3);
			}
		} else {
			g.color = Color.Black;
		}
		g.font = font;
		
		var tx: Float = x + padding;
		var ty: Float = y + padding;
		
		for (line in text) {
			g.drawString(line, tx, ty);
			ty += font.getHeight();
		}
	}
}
