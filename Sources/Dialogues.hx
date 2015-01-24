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
		Dialogue.insert( [
			new BlaWithChoices(msg, null, choices)
			, new StartDialogue(Cfg.save)
			, new StartDialogue(function () { Localization.language = Cfg.language; } )
		], true );
	}
}
