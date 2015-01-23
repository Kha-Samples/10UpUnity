package;

import kha.Color;
import kha.Font;
import kha.FontStyle;
import kha.Loader;
import kha.graphics2.Graphics;
import kha.Scene;
import kha.Sprite;

class BlaBox {
	private static var padding = 15;
	private static var maxWidth = 500;
	private static var width : Float;
	private static var height : Float;
	private static var pointed: Sprite;
	private static var font: Font;
	private static var text: Array<String> = null;
	
	public static function pointAt(sprite: Sprite): Void {
		pointed = sprite;
	}
	
	public static function setText(text: String): Void {
		if (text != null) {
			if (font == null) font = Loader.the.loadFont("Liberation Sans", new FontStyle(false, false, false), 20);
			var maxWidth = BlaBox.maxWidth - 2 * padding;
			BlaBox.text = new Array();
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
						BlaBox.text.push(line);
						if (nextWord != null) {
							words.push(nextWord);
						}
					}
				} else {
					width = Math.max(width, tw);
					BlaBox.text.push(line);
				}
			}
			width += 2 * padding;
			height = (font.getHeight() * BlaBox.text.length) + 2 * padding;
		} else {
			BlaBox.text = null;
		}
	}
	
	public static function render(g: Graphics): Void {
		if (text == null) return;
		
		var sx : Float = -1;
		var sy : Float = -1;
		if (pointed != null) {
			sx = pointed.x + (0.5 * pointed.collisionRect().width) - Scene.the.screenOffsetX;
			sy = pointed.y - 15 - Scene.the.screenOffsetY;
		}
		
		var x : Float = (pointed == null) ? (0.5 * (kha.Game.the.width - width)) : sx - 0.3 * width;
		
		if (x + width > kha.Game.the.width) {
			x -= 30 + x + width - kha.Game.the.width;
		}
		if (x < 0) {
			x = 30;
		}
		
		var y : Float = (pointed == null) ? (0.3 * (kha.Game.the.height - height)) : sy - 30 - height;
		if (y < 0) {
			sy += pointed.height + 15;
			y = sy + 30;
		}
		
		g.color = Color.White;
		g.fillRect(x, y, width, height);
		g.color = Color.Black;
		g.drawRect(x, y, width, height, 5);
		g.color = Color.White;
		if (pointed != null) {
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
