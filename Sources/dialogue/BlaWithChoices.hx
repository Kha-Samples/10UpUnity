package dialogue;

import Dialogue.DialogueItem;
import kha.input.Keyboard;
import kha.input.KeyCode;
import kha2d.Sprite;

using StringTools;

enum BlaWithChoicesStatus {
	BLA;
	CHOICE;
}

class BlaWithChoices extends Bla {
	var txtKey : String;
	var choices : Array<Array<DialogueItem>>;
	var status : BlaWithChoicesStatus = BlaWithChoicesStatus.BLA;
	var lastMode : TenUp4.Mode;
	
	public function new (txtKey : String, speaker : Sprite, choices: Array<Array<DialogueItem>>) {
		super(txtKey, speaker);
		this.txtKey = txtKey;
		this.choices = choices;
		
		this.finished = false;
		this.persistent = true;
	}
	
	var dlg: Dialogue;
	@:access(Dialogues.dlgChoices)
	@:access(TenUp4.mode)
	private function keyPressListener(char: String) {
		var choice = char.fastCodeAt(0) - '1'.fastCodeAt(0);
		if (choice >= 0 && choice < choices.length) {
			Keyboard.get().remove(null, null, keyPressListener);
			this.finished = true;
			/*BlaBox.boxes.remove(dlg.blaBox);
			dlg.blaBox = null;*/
			TenUp4.the.mode = lastMode;
			dlg.insert(choices[choice]);
			dlg.next();
		}
	}
	
	@:access(TenUp4.mode)
	override public function execute(dlg: Dialogue) : Void {
		switch (status) {
			case BlaWithChoicesStatus.BLA:
				this.lastMode = TenUp4.the.mode;
				TenUp4.the.mode = TenUp4.Mode.Menu;
				this.dlg = dlg;
				super.execute(dlg);
				Keyboard.get().notify(null, null, keyPressListener);
				status = BlaWithChoicesStatus.CHOICE;
			case BlaWithChoicesStatus.CHOICE:
				// just wait for input
		}
	}
}
