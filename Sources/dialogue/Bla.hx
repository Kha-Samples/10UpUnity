package dialogue;

import Dialogue.DialogueItem;
import kha2d.Sprite;

class Bla implements DialogueItem {
	var text : String;
	var speaker : Sprite;
	var persistent: Bool = false;
	
	public var finished(default, null) : Bool = false;
	
	public function new (txtKey : String, speaker : Sprite) {
		this.text = Localization.getText(txtKey);
		this.speaker = speaker;
	}
	
	public function execute(dlg: Dialogue) : Void {
		if (dlg.blaBox == null) {
			dlg.blaBox = new BlaBox(text, speaker, persistent);
			BlaBox.boxes.push(dlg.blaBox);
		} else {
			finished = !Lambda.has(BlaBox.boxes, dlg.blaBox);
		}
	}
}
