package;

import kha.Assets;
import kha2d.Sprite;

class Computer extends Sprite {
	public function new(x: Float, y: Float ) {
		super(Assets.images.computer, 46 * 2, 60 * 2, 0);
		this.x = x;
		this.y = y;
	}	
}
