package dialogue;

import Cfg;

class SetVictoryCondition implements Dialogue.DialogueItem
{
	var condition : VictoryCondition;
	var value : Bool;
	
	public function new(condition: VictoryCondition, value: Bool) {
		this.condition = condition;
		this.value = value;
	}
	
	public var finished(default, null) : Bool = true;
	
	public function execute(): Void {
		Cfg.setVictoryCondition(condition, value);
		Dialogue.next();
	}
}