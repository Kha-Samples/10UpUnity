package dialogue;

import Dialogue.DialogueItem;
import kha.input.Keyboard;
import kha.Key;
import kha.Sprite;

using StringTools;

enum BlaWithChoicesStatus {
	BLA;
	CHOICE;
}

class BlaWithChoices extends Bla {
	var txtKey : String;
	var choices : Array<Array<DialogueItem>>;
	var status : BlaWithChoicesStatus = BlaWithChoicesStatus.BLA;
	
	public function new (txtKey : String, speaker : Sprite, choices: Array<Array<DialogueItem>>) {
		super(txtKey, speaker);
		this.txtKey = txtKey;
		this.choices = choices;
		
		this.finished = false;
	}
	
	@:access(Dialogues.dlgChoices) 
	private function keyUpListener(key:Key, char: String) {
		var choice = char.fastCodeAt(0) - '1'.fastCodeAt(0);
		if (choice >= 0 && choice < choices.length) {
			Keyboard.get().remove(null, keyUpListener);
			this.finished = true;
			Dialogue.insert(choices[choice]);
			Dialogue.next();
		}
	}
	
	override public function execute() : Void {
		switch (status) {
			case BlaWithChoicesStatus.BLA:
				super.execute();
				Keyboard.get().notify(null, keyUpListener);
				status = BlaWithChoicesStatus.CHOICE;
			case BlaWithChoicesStatus.CHOICE:
				// just wait for input
		}
	}
}
