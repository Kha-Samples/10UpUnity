package;

import dialogue.Action;
import dialogue.Bla;
import dialogue.BlaWithChoices;
import dialogue.Branch.BooleanBranch;
import dialogue.Branch.IntBranch;
import dialogue.EndGame;
import dialogue.StartDialogue;
import Cfg;
import haxe.macro.Expr.Var;
import localization.Keys_text;
import kha.Scene;
import kha.Sprite;

using Lambda;

class Dialogues {
		
	static public function escMenu() {
		var msg = "What to do?";
		var choices = new Array<Array<Dialogue.DialogueItem>>();
		var i = 1;
		for (l in Localization.availableLanguages.keys()) {
			if (l != Cfg.language) {
				choices.push([new StartDialogue(function() { Cfg.language = l; } )]);
				msg += '\n($i): Set language to "${Localization.availableLanguages[l]}"';
				++i;
			}
		}
		msg += '\n($i): Back"';
		choices.push( [] );
		TenUp4.the.dlg.insert( [
			new BlaWithChoices(msg, null, choices)
			, new StartDialogue(Cfg.save)
			, new StartDialogue(function () { Localization.language = Cfg.language; } )
		], true );
	}
	
	static public function startAsBully() {
		PlayerBullie.the.setCurrent();
		PlayerBullie.the.dlg.insert( [
			new Action( null, ActionType.FADE_FROM_BLACK )
			, new Bla(Keys_text.START_AS_BULLY_1, PlayerBullie.the)
			, new Action( [PlayerBullie.the], ActionType.AWAKE )
			, new Bla(Keys_text.START_AS_BULLY_2, PlayerBullie.the)
			, new Bla(Keys_text.START_AS_BULLY_3, PlayerBullie.the)
		] );
	}
	static public function startAsMechanic() {
		PlayerBlondie.the.setCurrent();
		PlayerBlondie.the.dlg.insert( [
			new Action( null, ActionType.FADE_FROM_BLACK )
			, new Action(null, ActionType.PAUSE )
			, new Action( [PlayerBlondie.the], ActionType.AWAKE )
			, new Bla(Keys_text.START_AS_MECHANIC, PlayerBlondie.the)
		] );
	}
}
