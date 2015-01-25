package;

import dialogue.BlaWithChoices;
import dialogue.StartDialogue;
import kha.Animation;
import kha.Loader;
import kha.Scene;
import kha.Sprite;
import localization.Keys_text;

class ElevatorDoor extends Sprite {
	public var opened(default,set) = false;
	private var openAnim: Animation;
	private var closedAnim: Animation;
	private var id: Int;
	
	public function new(id: Int, x: Int, y: Int) {
		super(Loader.the.getImage("elevator"), 78 * 2, 64 * 2, 0);
		this.id = id;
		this.x = x;
		this.y = y;
		accy = 0;
		closedAnim = Animation.create(0);
		openAnim = Animation.create(1);
		setAnimation(closedAnim);
	}
	
	private function set_opened(value : Bool) : Bool {
		if (opened == value) {
			return opened;
		}
		if ( opened = value ) {
			setAnimation(openAnim);
		} else {
			setAnimation(closedAnim);
		}
		return opened;
	}
	
	function pushOut(sprite: Sprite) {
		sprite.x = x - sprite.tempcollider.width - 1;
		if (sprite == Player.current()) Player.current().usesElevator = false;
	}
	
	public override function hit(sprite: Sprite) {
		super.hit(sprite);
		if (opened) {
			if (!Player.current().usesElevator && sprite == Player.current() && sprite.x > x + tempcollider.width / 3) {
				Player.current().usesElevator = true;
				Player.current().left = false;
				Player.current().right = false;
				Player.current().up = false;
				var msg = Localization.getText(Keys_text.DLG_ELEVATOR);
				var choices = new Array<Array<Dialogue.DialogueItem>>();
				var numLevels = 3; // TODO: FIXME!
				for (i in 1...3) {
					msg += '\n$i. ${Localization.getText(Keys_text.FLOOR)}';
					if (i == Level.the.levelNum) {
						msg += ' (${Localization.getText(Keys_text.DLG_ELEVATOR_STAY)})';
						choices.push( [ new StartDialogue(pushOut.bind(sprite)) ] );
					} else {
						choices.push( [ new StartDialogue(Server.the.useElevator.bind(id, i)) ] );
					}
				}
				Player.current().dlg.insert( [
					new BlaWithChoices(msg, null, choices)
				] );
			}
		}
	}
}