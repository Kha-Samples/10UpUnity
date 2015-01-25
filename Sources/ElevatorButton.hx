package;

import dialogue.BlaWithChoices;
import dialogue.StartDialogue;
import kha.Animation;
import kha.Direction;
import kha.Loader;
import kha.Scene;
import kha.Sprite;
import localization.Keys_text;

class ElevatorButton extends InteractiveSprite {
	private var called: Bool = false;
	private var redAnim: Animation;
	private var greenAnim: Animation;
	private var greyAnim: Animation;
	private var id: Int;
	
	public function new(id: Int, x: Int, y: Int) {
		super(Loader.the.getImage("elevatorbuttons"), 23 * 2, 15 * 2, 0);
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