package dialogue;

import Dialogue.DialogueItem;
import kha.Color;
import kha.math.Vector2;
import kha.Scene;
import kha.Scheduler;
import kha.Sprite;

enum ActionType {
	MG;
	FADE_TO_BLACK;
	FADE_FROM_BLACK;
	THROW;
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
	public function execute() : Void {
		if (!started) {
			started = true;
			counter = 0;
			switch(type) {
				case ActionType.MG:
					Cfg.mafioso.useMg = true;
				case ActionType.FADE_TO_BLACK:
					TenUp3.getInstance().renderOverlay = true;
					counter = TenUp3.getInstance().overlayColor.Ab;
				case ActionType.FADE_FROM_BLACK:
					counter = TenUp3.getInstance().overlayColor.Ab;
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
					if (proj == Cfg.broetchen) {
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
					}
			}
			return;
		} else {
			switch(type) {
				case ActionType.MG:
					// TODO
					actionFinished();
				case ActionType.FADE_TO_BLACK:
					++counter;
					++counter;
					if (!TenUp3.getInstance().renderOverlay || counter >= 256) {
						actionFinished();
					} else {
						TenUp3.getInstance().overlayColor.Ab = counter;
					}
				case ActionType.FADE_FROM_BLACK:
					--counter;
					--counter;
					if (!TenUp3.getInstance().renderOverlay || counter <= 0) {
						TenUp3.getInstance().renderOverlay = false;
						actionFinished();
					} else {
						TenUp3.getInstance().overlayColor.Ab = counter;
					}
				case ActionType.THROW:
					if (finishThrow) {
						actionFinished();
					}
			}
		}
	}
	
	@:access(Dialogue.isActionActive) 
	function actionFinished() {
		finished = true;
		if (autoAdvance) {
			Dialogue.next();
		}
	}
}
