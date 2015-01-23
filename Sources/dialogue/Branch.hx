package dialogue;

interface Branch extends Dialogue.DialogueItem {
	
}

class IntBranch implements Branch {
	var condFunc : Void -> Int;
	var branches : Array<Array<Dialogue.DialogueItem>>;
	
	public function new (condFunc: Void -> Int, branches: Array<Array<Dialogue.DialogueItem>>) {
		this.condFunc = condFunc;
		this.branches = branches;
	}
	
	public var finished(default, null) : Bool = true;
	
	public function execute() : Void {
		var r = condFunc();
		if (r < 0) {
			r = branches.length - r;
		}
		Dialogue.insert(branches[r]);
		Dialogue.next();
	}
}

class BooleanBranch implements Branch {
	var condFunc : Void -> Bool;
	var onTrue : Array<Dialogue.DialogueItem>;
	var onFalse : Array<Dialogue.DialogueItem>;
	
	public function new (condFunc: Void -> Bool, onTrue: Array<Dialogue.DialogueItem>, onFalse: Array<Dialogue.DialogueItem>) {
		this.condFunc = condFunc;
		this.onTrue = onTrue;
		this.onFalse = onFalse;
	}
	
	public var finished(default, null) : Bool = true;
	
	public function execute() : Void {
		if (condFunc()) {
			Dialogue.insert(onTrue);
		} else {
			Dialogue.insert(onFalse);
		}
		Dialogue.next();
	}
}