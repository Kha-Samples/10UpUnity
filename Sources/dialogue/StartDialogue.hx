package dialogue;
import kha.Sprite;

class StartDialogue implements Dialogue.DialogueItem
{
	var func : Void -> Void;

	public function new(func : Void -> Void) 
	{
		this.func = func;
	}
	
	public var finished(default, null) : Bool = true;
	
	public function execute(): Void {
		func();
		Dialogue.next();
	}
}