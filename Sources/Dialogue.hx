package;

import TenUp4.Mode;
import kha.Scene;

interface DialogueItem {
	public function execute(dlg: Dialogue) : Void;
	public var finished(default, null) : Bool;
}

class Dialogue {
	private var items: Array<DialogueItem>;
	private var index: Int = -1;
	public var isActionActive(default, null): Bool = false;
	public var blaBox: BlaBox;
	
	public function new() {}
	
	public function set(newItems: Array<DialogueItem>): Void {
		if (newItems == null || newItems.length <= 0) {
			return;
		}
		items = newItems;
		index = -1;
		next();
	}
	
	public function insert(insert: Array<DialogueItem>, argl = false) {
		if (items == null) {
			set(insert);
		} else if (index < 0) {
			for (item in items) {
				insert.push(item);
			}
			items = insert;
		} else {
			var newItems = new Array<DialogueItem>();
			if (!argl) {
				newItems.push(items[index]);
			}
			for (item in insert) {
				newItems.push(item);
			}
			if (!argl) {
				++index;
			}
			while (index < items.length) {
				newItems.push(items[index]);
				++index;
			}
			index = 0;
			items = newItems;
		}
	}
	
	public function update() : Void {
		if (index >= 0 && !items[index].finished) {
			items[index].execute(this);
		} else {
			next();
		}
	}
	
	public function next(): Void {
		if (items == null) return;
		
		if (index >= 0 && !items[index].finished) {
			items[index].execute(this);
			return;
		}
		
		++index;
		if (blaBox != null) {
			BlaBox.boxes.remove(blaBox);
			blaBox = null;
		}
		
		if (index >= items.length) {
			items = null;
			index = -1;
			return;
		}
		
		items[index].execute(this);
	}
}
