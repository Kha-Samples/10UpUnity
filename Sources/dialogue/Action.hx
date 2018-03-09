package dialogue;

import Dialogue.DialogueItem;
import kha.Color;
import kha.math.Vector2;
import kha2d.Scene;
import kha.Scheduler;
import kha2d.Sprite;

enum ActionType {
	FADE_TO_BLACK;
	FADE_FROM_BLACK;
	THROW;
	PAUSE;
	AWAKE;
}

class Action implements DialogueItem {
	var autoAdvance : Bool = true;
	var started : Bool = false;
	var sprites : Array<Sprite>;
	var type : ActionType;
	var counter : Int = 0;
	public var finished(default, null) : Bool = false;
	public function new(sprites: Array<Sprite>, type: ActionType) {
		this.sprites = sprites;
		this.type = type;
	}
	
	static public var finishThrow = false;
	
	@:access(Dialogue.isActionActive) 
	public function execute(dlg: Dialogue) : Void {
		if (!started) {
			started = true;
			counter = 0;
			switch(type) {
				case ActionType.FADE_TO_BLACK:
					counter = TenUp4.the.overlayColor.Ab;
				case ActionType.FADE_FROM_BLACK:
					counter = TenUp4.the.overlayColor.Ab;
				case ActionType.PAUSE:
					counter = 0;
				case ActionType.AWAKE:
					cast(sprites[0], Player).unsleep();
				case ActionType.THROW:
					finishThrow = false;
					var from = sprites[0];
					var to = sprites[1];
					var proj = sprites[2];
					var spos = new Vector2(from.x + 0.5 * from.width, from.y + 0.2 * from.height);
					var dpos = new Vector2(to.x + 0.5 * to.width, to.y + 0.2 * to.height);
					var speed = dpos.sub(spos);
					speed.length = proj.speedx;
					proj.x = spos.x;
					proj.y = spos.y;
					proj.speedx = speed.x;
					proj.speedy = speed.y;
					proj.maxspeedy = speed.y;
					proj.accx = 0;
					proj.accy = 0;
					Scene.the.addProjectile(proj);
					/*if (proj == Cfg.broetchen) {
						cast(from, Player).inventory.loose(Cfg.broetchen);
						cast(from, Player).inventory.loose(Cfg.broetchen_mehrkorn);
						var newProj;
						if (Cfg.getVictoryCondition(VictoryCondition.MEHRKORN)) {
							newProj = new Broetchen(true);
						} else {
							newProj = new Broetchen(false);
						}
						newProj.x = spos.x;
						newProj.y = spos.y;
						newProj.speedx = speed.x;
						newProj.speedy = speed.y;
						newProj.maxspeedy = speed.y;
						newProj.accx = 0;
						newProj.accy = 0;
						Scheduler.addTimeTask(function () {
							Scene.the.addProjectile(newProj);
							
						}, 0.6);
					}*/
			}
			return;
		} else {
			switch(type) {
				case ActionType.FADE_TO_BLACK:
					counter += 4;
					if (!TenUp4.the.renderOverlay || counter >= 256) {
						actionFinished(dlg);
					} else {
						TenUp4.the.overlayColor.Ab = counter;
					}
				case ActionType.FADE_FROM_BLACK:
					counter -= 4;
					if (!TenUp4.the.renderOverlay || counter <= 0) {
						TenUp4.the.renderOverlay = false;
						actionFinished(dlg);
					} else {
						TenUp4.the.overlayColor.Ab = counter;
					}
				case ActionType.PAUSE:
					++counter;
					if (counter == 60) {
						actionFinished(dlg);
					}
				case ActionType.AWAKE:
					actionFinished(dlg);
				case ActionType.THROW:
					if (finishThrow) {
						actionFinished(dlg);
					}
			}
		}
	}
	
	@:access(Dialogue.isActionActive) 
	function actionFinished(dlg: Dialogue) {
		finished = true;
		if (autoAdvance) {
			dlg.next();
		}
	}
}
