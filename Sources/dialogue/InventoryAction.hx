package dialogue;
import kha.Scene;
import kha.Sprite;

enum InventoryActionMode {
	ADD;
	PICKUP;
	DROP;
	REMOVE;
}

class InventoryAction implements Dialogue.DialogueItem
{
	var source: Player;
	var item: Sprite;
	var mode: InventoryActionMode;
	
	public function new(source: Player, item: Sprite, mode: InventoryActionMode) {
		this.source = source;
		this.item = item;
		this.mode = mode;
	}
	
	public var finished(default, null) : Bool = true;
	
	public function execute() : Void {
		switch (mode) {
			case ADD:
				source.inventory.pick(item);
			case PICKUP:
				Scene.the.removeProjectile(item);
				source.inventory.pick(item);
			case DROP:
				Scene.the.addProjectile(item);
				source.inventory.loose(item);
				item.x = source.x + 0.5 * source.width;
				item.y = source.y;
			case REMOVE:
				source.inventory.loose(item);
		}
		Dialogue.next();
	}
}