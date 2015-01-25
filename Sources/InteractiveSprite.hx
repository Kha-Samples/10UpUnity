package ;

import kha.Animation;
import kha.Direction;
import kha.graphics2.Graphics;
import kha.Image;
import kha.math.Vector2;
import kha.Rectangle;
import kha.Rotation;
import kha.Scene;
import kha.Sprite;

class InteractiveSprite extends Sprite {
	public var isUseable(default, null) : Bool = false;
	public var isLiftable(default, null) : Bool = false;
	public var dlg(default, null) : Dialogue;
	public var playerCanUseIt(default, null) : Bool = false;
	
	public function new(image:Image, width:Int=0, height:Int=0, z:Int=1) {
		super(image, width, height, z);
		dlg = new Dialogue();
	}
	
	public var center(get, never) : Vector2;
	@:noCompletion private inline function get_center() : Vector2 {
		return new Vector2(Math.round(x - collider.x) + 0.5 * width, Math.round(y - collider.y) + 0.5 * height);
	}
	
	public function useFrom( dir : Direction ) { }
	
	override public function update():Void 
	{
		super.update();
		
		dlg.update();
		
		if (playerCanUseItClear) playerCanUseIt = false;
		else playerCanUseItClear = true;
	}
	
	var playerCanUseItClear = true;
	override public function hit(sprite:Sprite):Void 
	{
		if (sprite == Player.current()) {
			playerCanUseIt = true;
			playerCanUseItClear = false;
		}
	}
}