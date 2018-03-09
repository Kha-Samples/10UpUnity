package;

import dialogue.BlaWithChoices;
import dialogue.StartDialogue;
import kha.Assets;
import kha2d.Animation;
import kha2d.Direction;
import kha2d.Scene;
import kha2d.Sprite;
import localization.Keys_text;

class ElevatorPositionSign extends Sprite {
	private var _position: Int;
	public var position(get,set): Int;
	private var id: Int;
	
	public function new(id: Int, x: Int, y: Int) {
		super(Assets.images.floorlevel, 32 * 2, 32 * 2, 0);
		this.id = id;
		this.x = x;
		this.y = y;
		accy = 0;
		position = 0;
	}
	
	function get_position(): Int { return _position; }
	function set_position(value: Int): Int { _position = value; this.setAnimation(Animation.create(_position)); return _position; }
}