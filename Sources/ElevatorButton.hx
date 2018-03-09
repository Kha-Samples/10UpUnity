package;

import dialogue.BlaWithChoices;
import dialogue.StartDialogue;
import kha.Assets;
import kha2d.Animation;
import kha2d.Direction;
import kha2d.Scene;
import kha2d.Sprite;
import localization.Keys_text;

class ElevatorButton extends InteractiveSprite {
	private var called: Bool = false;
	private var redAnim: Animation;
	private var greenAnim: Animation;
	private var greyAnim: Animation;
	private var id: Int;
	
	public function new(id: Int, x: Int, y: Int) {
		super(Assets.images.elevatorbuttons, 23 * 2, 15 * 2, 0);
		this.id = id;
		this.x = x;
		this.y = y;
		accy = 0;
		redAnim = Animation.create(0);
		greenAnim = Animation.create(1);
		greyAnim = Animation.create(2);
		setAnimation(greyAnim);
		isUseable = true;
	}
	
	override public function useFrom(dir:Direction) 
	{
		//Level.the.elevatorDoor.opened = true;
		called = true;
		setAnimation(greenAnim);
		Server.the.callElevator();
	}
}