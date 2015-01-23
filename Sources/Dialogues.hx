package;

import dialogue.Action;
import dialogue.Bla;
import dialogue.BlaWithChoices;
import dialogue.Branch.BooleanBranch;
import dialogue.Branch.IntBranch;
import dialogue.EndGame;
import dialogue.InventoryAction;
import dialogue.SetVictoryCondition;
import dialogue.ShowOther;
import dialogue.StartDialogue;
import Cfg;
import haxe.macro.Expr.Var;
import localization.Keys_text;
import kha.Scene;
import kha.Sprite;

using Lambda;

class Dialogues {
		
	static public function startProfStartDialog(prof: Sprite) {
		if (Cfg.getVictoryCondition(VictoryCondition.MATHEGENIE)) {
			var verkaeuferin = Cfg.verkaeuferin;
			Scene.the.removeHero(verkaeuferin);
			Scene.the.addHero(verkaeuferin);
			verkaeuferin.operateTheke(true);
		}
		if (Cfg.getVictoryCondition(VictoryCondition.PLAYED_MANN) && Cfg.getVictoryCondition(VictoryCondition.DELIVERED_ROLLS)) {
			Scene.the.addHero(Cfg.mann);
			Cfg.mann.lookRight = false;
			Dialogue.insert([new Action(null, ActionType.FADE_FROM_BLACK), new StartDialogue(setMannEndeDlg), new Bla(Keys_text.PROF1, prof), new Bla(Keys_text.PROF2, prof), new Bla(Keys_text.PROF3, prof), new Bla(Keys_text.PROF4, prof), new Bla(Keys_text.PROF5, prof)]);
		} else {
			Dialogue.insert([new Action(null, ActionType.FADE_FROM_BLACK), new Bla(Keys_text.PROF1, prof), new Bla(Keys_text.PROF2, prof), new Bla(Keys_text.PROF3, prof), new Bla(Keys_text.PROF4, prof), new Bla(Keys_text.PROF5, prof)]);
		}
	}
	
	static public function startProfGotItDialog(prof: Sprite) {
		Dialogue.insert([new Bla(Keys_text.PROF6, prof)]);
	}
	
	static public function startProfWinDialog(prof: Sprite) {
		Dialogue.insert([new Bla(Keys_text.PROF7, prof)]);
	}
	
	static public function startProfLooseDialog(prof: Sprite) {
		Dialogue.insert([new Bla(Keys_text.PROF8, prof)]);
	}
	
	static public function setStartDlg() {
		var mann = Cfg.mann;
		var eheweib = Cfg.eheweib;
		Dialogue.insert( [
			new Action(null, ActionType.FADE_FROM_BLACK)
			, new Bla(Keys_text.DLG_START_1, mann)
			,new Bla(Keys_text.DLG_START_2, eheweib)
			,new Bla(Keys_text.DLG_START_3, eheweib)
			,new Bla(Keys_text.DLG_START_4, mann)
			,new Bla(Keys_text.DLG_START_5, eheweib)
			,new Bla(Keys_text.DLG_START_6, mann)
		] );
	}
	
	static public function setGeldGefundenMannDlg() {
		var mann = Cfg.mann;
		var cent = Cfg.cent;
		Dialogue.insert([
			new BlaWithChoices(Localization.getText(Keys_text.DLG_GELD_GEFUNDEN_1_C), mann, [
				[ new InventoryAction(mann, cent, InventoryActionMode.PICKUP), new SetVictoryCondition(VictoryCondition.CENT_TAKEN, true) ]
				, [ new SetVictoryCondition(VictoryCondition.CENT_TAKEN, false) ]
			])
		]);
	}
	
	static public function setGeldVerlohrenVerkDlg() {
		var verkaeuferin = Cfg.verkaeuferin;
		var cent = Cfg.cent;
		Dialogue.insert([
			new InventoryAction(verkaeuferin, cent, InventoryActionMode.DROP)
			, new BlaWithChoices(Keys_text.DLG_GELD_VERLOHREN_1_C, verkaeuferin, [
				[
					new InventoryAction(verkaeuferin, cent, InventoryActionMode.PICKUP)
					, new SetVictoryCondition(VictoryCondition.CENT_DROPPED, false)
					, new SetVictoryCondition(VictoryCondition.CENT_TAKEN, false) ]
				, [
					new SetVictoryCondition(VictoryCondition.CENT_DROPPED, true)
				]
			])
		]);
	}
	
	static public function setVerkaufMannDlg() {
		var mann = Cfg.mann;
		var verkaeuferin = Cfg.verkaeuferin;
		var euro = Cfg.euro;
		var cent = Cfg.cent;
		var part1 = [
			new Bla(Keys_text.DLG_VERKAUFEN_1, verkaeuferin)
			, new BlaWithChoices(Keys_text.DLG_VERKAUFEN_2_C, mann, [
				[ // Antwort 1
					new Bla(Keys_text.DLG_VERKAUFEN_2A_1, verkaeuferin)
					, new BooleanBranch(Cfg.getVictoryCondition.bind(VictoryCondition.CENT_TAKEN)
						, [ // HAS CENT
							new Bla(Keys_text.DLG_VERKAUFEN_2A_2_GELD, mann)
							, new InventoryAction(mann, euro, InventoryActionMode.REMOVE)
							, new InventoryAction(mann, cent, InventoryActionMode.REMOVE)
							, new SetVictoryCondition(VictoryCondition.MEHRKORN, true)
							, new InventoryAction(mann, Cfg.broetchen_mehrkorn, InventoryActionMode.ADD)
							, new SetVictoryCondition(VictoryCondition.MATHEGENIE, true)
						] 
						, [ // ONLY ONE EURO
							new BlaWithChoices(Keys_text.DLG_VERKAUFEN_2A_2_C, mann, [
								[ // Antwort 1
									new Bla(Keys_text.DLG_VERKAUFEN_2A_2A_1, verkaeuferin)
									, new Bla(Keys_text.DLG_VERKAUFEN_2A_2A_2, verkaeuferin)
									, new IntBranch(Cfg.getDlgChoice.bind(Keys_text.DLG_VERKAUFEN_2A_2A_3_C), [
										[ // Antwort 1: Da kann ich nix machen
											new Bla(Keys_text.DLG_VERKAUFEN_2A_2A_3A, verkaeuferin)
											, new Bla(Keys_text.DLG_VERKAUFEN_2A_2A_3A_1, mann)
											, new InventoryAction(mann, euro, InventoryActionMode.REMOVE)
											, new SetVictoryCondition(VictoryCondition.MEHRKORN, false)
											, new InventoryAction(mann, Cfg.broetchen, InventoryActionMode.ADD)
											, new SetVictoryCondition(VictoryCondition.MATHEGENIE, true)
										]
										, [ // Antwort 2: sehe darüber hinweg
											new Bla(Keys_text.DLG_VERKAUFEN_2A_2A_3B, verkaeuferin)
											, new Bla(Keys_text.DLG_VERKAUFEN_2A_2A_3B_1, mann)
											, new InventoryAction(mann, euro, InventoryActionMode.REMOVE)
											, new SetVictoryCondition(VictoryCondition.MEHRKORN, true)
											, new InventoryAction(mann, Cfg.broetchen_mehrkorn, InventoryActionMode.ADD)
											, new SetVictoryCondition(VictoryCondition.MATHEGENIE, false)
										]
									])
								]
								, [ // Antwort 2
									new IntBranch(Cfg.getDlgChoice.bind(Keys_text.DLG_VERKAUFEN_2A_2B_1_C), [
										[ // Antwort 1
											new InventoryAction(mann, euro, InventoryActionMode.REMOVE)
											, new Bla(Keys_text.DLG_VERKAUFEN_2A_2B_1A, verkaeuferin)
											, new Bla(Keys_text.DLG_VERKAUFEN_2A_2B_1A_1, mann)
											, new Bla(Keys_text.DLG_VERKAUFEN_2A_2A_3A, verkaeuferin)
											, new Bla(Keys_text.DLG_VERKAUFEN_2A_2A_3A_1, mann)
											, new SetVictoryCondition(VictoryCondition.MEHRKORN, false)
											, new InventoryAction(mann, Cfg.broetchen, InventoryActionMode.ADD)
										]
										, [ // Antwort 2
											new InventoryAction(mann, euro, InventoryActionMode.REMOVE)
											, new SetVictoryCondition(VictoryCondition.MEHRKORN, true)
											, new InventoryAction(mann, Cfg.broetchen_mehrkorn, InventoryActionMode.ADD)
											, new SetVictoryCondition(VictoryCondition.MATHEGENIE, false)
										]
									])
								]
							])
						]
					)
				]
				, [ // Antwort 2
					new Bla(Keys_text.DLG_VERKAUFEN_2B_1, verkaeuferin)
					, new Bla(Keys_text.DLG_VERKAUFEN_2B_2, mann)
					, new InventoryAction(mann, euro, InventoryActionMode.REMOVE)
					, new SetVictoryCondition(VictoryCondition.MEHRKORN, false)
				]
			] )
			, new Bla(Keys_text.DLG_VERKAUFEN_ERFOLG_1,verkaeuferin)
			, new InventoryAction(mann, Cfg.broetchen, InventoryActionMode.ADD)
			, new SetVictoryCondition(VictoryCondition.BOUGHT_ROLLS, true)
			, new Bla(Keys_text.DLG_VERKAUFEN_ERFOLG_2,mann)
		];
		Dialogue.insert(part1);
	}
	
	static public function setVerkaufVerkDlg() {
		var mann = Cfg.mann;
		var verkaeuferin = Cfg.verkaeuferin; 
		Dialogue.insert( [
			new Bla(Keys_text.DLG_VERKAUFEN_1, verkaeuferin)
			, new IntBranch(Cfg.getDlgChoice.bind(Keys_text.DLG_VERKAUFEN_2_C), [
				[ // Antwort 1: Richtige Brötchen
					new BooleanBranch(Cfg.getVictoryCondition.bind(VictoryCondition.CENT_TAKEN)
						, [ // Cent
							new Bla(Keys_text.DLG_VERKAUFEN_2A, mann)
							, new Bla(Keys_text.DLG_VERKAUFEN_2A_1, verkaeuferin) 
							, new Bla(Keys_text.DLG_VERKAUFEN_2A_2_GELD, mann)
							, new SetVictoryCondition(VictoryCondition.MEHRKORN, true)
							, new SetVictoryCondition(VictoryCondition.MATHEGENIE, true)
							, new Bla(Keys_text.DLG_VERKAUFEN_ERFOLG_1, verkaeuferin)
						]
						, [ // no cent
							new Bla(Keys_text.DLG_VERKAUFEN_2A, mann)
							, new Bla(Keys_text.DLG_VERKAUFEN_2A_1, verkaeuferin)
							, new IntBranch(Cfg.getDlgChoice.bind(Keys_text.DLG_VERKAUFEN_2A_2_C), [
								[ // Antwort 1: hab nur 1 euro
									new Bla(Keys_text.DLG_VERKAUFEN_2A_2A, mann)
									, new Bla(Keys_text.DLG_VERKAUFEN_2A_2A_1, verkaeuferin)
									, new Bla(Keys_text.DLG_VERKAUFEN_2A_2A_2, verkaeuferin)
									, new BlaWithChoices(Keys_text.DLG_VERKAUFEN_2A_2A_3_C, verkaeuferin, [
										[ // Antwort 1: Da kann ich nix machen
											new Bla(Keys_text.DLG_VERKAUFEN_2A_2A_3A_1, mann)
											, new SetVictoryCondition(VictoryCondition.MEHRKORN, false)
											, new SetVictoryCondition(VictoryCondition.MATHEGENIE, true)
											, new Bla(Keys_text.DLG_VERKAUFEN_ERFOLG_1, verkaeuferin)
										]
										, [ // Antwort 2: Sehe darüber hinweg
											new Bla(Keys_text.DLG_VERKAUFEN_2A_2A_3B_1, mann)
											, new SetVictoryCondition(VictoryCondition.MEHRKORN, true)
											, new SetVictoryCondition(VictoryCondition.MATHEGENIE, false)
											, new Bla(Keys_text.DLG_VERKAUFEN_ERFOLG_1, verkaeuferin)
										]
									])
								]
								, [ // Antwort 2: Gibt einen euro
									new Bla(Keys_text.DLG_VERKAUFEN_2A_2B, mann)
									, new BlaWithChoices(Keys_text.DLG_VERKAUFEN_2A_2B_1_C, verkaeuferin, [
										[ // Antwort 1: Entschuldigen sie Bitte!
											new Bla(Keys_text.DLG_VERKAUFEN_2A_2B_1A_1, mann)
											, new Bla(Keys_text.DLG_VERKAUFEN_2A_2A_1, verkaeuferin)
											, new Bla(Keys_text.DLG_VERKAUFEN_2A_2A_2, verkaeuferin)
											, new Bla(Keys_text.DLG_VERKAUFEN_2A_2A_3A, verkaeuferin)
											, new Bla(Keys_text.DLG_VERKAUFEN_2A_2A_3A_1, mann)
											, new SetVictoryCondition(VictoryCondition.MEHRKORN, false)
											, new SetVictoryCondition(VictoryCondition.MATHEGENIE, true)
											, new Bla(Keys_text.DLG_VERKAUFEN_ERFOLG_1, verkaeuferin)
										]
										, [ // Antwort 2: Und hier ihre Brötchen
											new SetVictoryCondition(VictoryCondition.MEHRKORN, true)
											, new SetVictoryCondition(VictoryCondition.MATHEGENIE, false)
										]
									])
								]
							])
						]
					)
				]
				, [ // Antwort 2: Zwo Wasserweck
					new Bla(Keys_text.DLG_VERKAUFEN_2B, mann)
					, new Bla(Keys_text.DLG_VERKAUFEN_2B_1, verkaeuferin) 
					, new Bla(Keys_text.DLG_VERKAUFEN_2B_2, mann)
					, new SetVictoryCondition(VictoryCondition.MEHRKORN, false)
					, new SetVictoryCondition(VictoryCondition.MATHEGENIE, true)
					, new Bla(Keys_text.DLG_VERKAUFEN_ERFOLG_1, verkaeuferin)
				]
			])
			, new SetVictoryCondition(VictoryCondition.BOUGHT_ROLLS, true)
			, new Bla(Keys_text.DLG_VERKAUFEN_ERFOLG_2, mann)
			, new Action(null, ActionType.FADE_TO_BLACK)
			, new StartDialogue(setGefeuertDlg)
		] );
	}
	
	
	static public function setGefeuertDlg() {
		Cfg.backdoor.open(true);
		Scene.the.removeHero(Cfg.mann);
		var verkaeuferin = Cfg.verkaeuferin;
		verkaeuferin.operateTheke(false);
		verkaeuferin.lookRight = true;
		var mafioso = Cfg.mafioso;
		if (Cfg.getVictoryCondition(VictoryCondition.MATHEGENIE)) {
			Dialogue.insert( [
				new EndGame()
			] );
		} else {
			Dialogue.insert( [
				new Action(null, ActionType.FADE_FROM_BLACK)
				, new Bla(Keys_text.DLG_ARBEITSLOS_1, mafioso)
				, new Bla(Keys_text.DLG_ARBEITSLOS_2, mafioso)
				, new BlaWithChoices(Keys_text.DLG_ARBEITSLOS_3_C, verkaeuferin, [
					[ // Gefeuert
						new Bla(Keys_text.DLG_ARBEITSLOS_3A_1, mafioso)
						, new StartDialogue(function () { verkaeuferin.left = true; } )
						, new Action(null, ActionType.FADE_TO_BLACK)
						, new StartDialogue(function () { verkaeuferin.left = false; } )
						, new EndGame()
					]
					, [ // weiß zuviel
						new Bla(Keys_text.DLG_ARBEITSLOS_3B_1, mafioso)
						, new Action([mafioso], ActionType.MG)
					]
				])
			] );
		}
	}
	
	static public function setGefeuertProfDlg() {
		var verkaeuferin = Cfg.verkaeuferin;
		verkaeuferin.lookRight = true;
		verkaeuferin.x = Cfg.verkaeuferinPositions[1].x;
		verkaeuferin.y = Cfg.verkaeuferinPositions[1].y;
		verkaeuferin.operateTheke(false);
		Scene.the.removeHero(verkaeuferin);
		Scene.the.addHero(verkaeuferin);
		var mafioso = Cfg.mafioso;
		Dialogue.insert( [
			new Action(null, ActionType.FADE_FROM_BLACK)
			, new Bla(Keys_text.DLG_ARBEITSLOS_1, mafioso)
			, new Bla(Keys_text.DLG_ARBEITSLOS_2, mafioso)
			, new IntBranch(Cfg.getDlgChoice.bind(Keys_text.DLG_ARBEITSLOS_3_C), [
				[ // Arbeitslos A
					new Bla(Keys_text.DLG_ARBEITSLOS_3A, verkaeuferin)
					, new Bla(Keys_text.DLG_ARBEITSLOS_3A_1, mafioso)
					, new StartDialogue(function () { verkaeuferin.left = true; })
				]
				, [ // Arbeitslos B
					new Bla(Keys_text.DLG_ARBEITSLOS_3B, verkaeuferin)
					, new Bla(Keys_text.DLG_ARBEITSLOS_3B_1, mafioso)
					, new Action([mafioso], ActionType.MG)
				]
			])
		] );
	}
	
	static public function setMannEndeDlg() {
		var weib = Cfg.eheweib;
		var mann = Cfg.mann;
		var bratpfanne = Cfg.bratpfanne;
		Dialogue.insert( [
			new Action(null, ActionType.FADE_FROM_BLACK)
			, new Bla(Keys_text.DLG_EHEWEIB_1, weib)
			, new Bla(Keys_text.DLG_EHEWEIB_2, weib)
			, new SetVictoryCondition(VictoryCondition.DELIVERED_ROLLS, true)
			, new BooleanBranch(Cfg.getVictoryCondition.bind(VictoryCondition.BOUGHT_ROLLS),
				[ // Brötchen gekauft
					new Bla(Keys_text.DLG_EHEWEIB_3A_1, mann)
					, new InventoryAction(mann, Cfg.broetchen, InventoryActionMode.REMOVE)
					, new Action([mann, weib, Cfg.broetchen], ActionType.THROW)
					, new Bla(Keys_text.DLG_EHEWEIB_3A_2, weib)
					, new BooleanBranch(Cfg.getVictoryCondition.bind(VictoryCondition.MEHRKORN),
						[ // 1 Wasserweck + 1 Mehrkorn
							new EndGame()
						]
						, [ // 2 Wasserweck :(
							new Bla(Keys_text.DLG_EHEWEIB_3A_3, weib)
							, new Bla(Keys_text.DLG_EHEWEIB_3A_4, weib)
							, new Action([weib, mann, bratpfanne], ActionType.THROW)
						]
					)
				]
				, [ // keine Brötchen...
					new Bla(Keys_text.DLG_EHEWEIB_3B_1, mann)
					, new Bla(Keys_text.DLG_EHEWEIB_3A_4, weib)
					, new Action([weib, mann, bratpfanne], ActionType.THROW)
				]
			)
		] );
	}
	
	static public function setGameEnd() {
		if (Player.current() == Cfg.mann) {
			// Mann:
			Cfg.setVictoryCondition(VictoryCondition.PLAYED_MANN, true);
			Cfg.save();
			Dialogue.insert( [
				new Action(null, ActionType.FADE_TO_BLACK)
				, new BooleanBranch(function() { return Cfg.getVictoryCondition(VictoryCondition.MEHRKORN) && Cfg.getVictoryCondition(VictoryCondition.DELIVERED_ROLLS); }, 
					[ // MEhrkorn
						new Bla(Keys_text.GAME_ERFOLG, null)
						, new BooleanBranch(Cfg.getVictoryCondition.bind(VictoryCondition.MATHEGENIE), 
							[ // Mathegenie
								new StartDialogue(setRealVictoryDlg)
							]
							, [ // Plus, minus, mal? Ist doch alles das selbe...
								new ShowOther()
							]
						)
					]
					, [ // kein Mehrkorn...
						new Bla(Keys_text.GAME_VERSAGT, null)
					]
				)
				, new StartDialogue(restartGameDlg)
			] );
		} else if (Player.current() == Cfg.verkaeuferin) {
			// Frau:
			Cfg.setVictoryCondition(VictoryCondition.PLAYED_VERKAEUFERIN, true);
			Cfg.save();
			Dialogue.insert( [
				new Action(null, ActionType.FADE_TO_BLACK)
				, new BooleanBranch(Cfg.getVictoryCondition.bind(VictoryCondition.MATHEGENIE), 
					[ // Mathegenie
						new Bla(Keys_text.GAME_ERFOLG, null)
						, new BooleanBranch(function() { return Cfg.getVictoryCondition(VictoryCondition.MEHRKORN) && Cfg.getVictoryCondition(VictoryCondition.DELIVERED_ROLLS); }, 
							[ // Mehrkorn
								new StartDialogue(setRealVictoryDlg)
							]
							, [ // kein Mehrkorn...
								new ShowOther()
							]
						)
					]
					, [ // Plus, minus, mal? Ist doch alles das selbe...
						new Bla(Keys_text.GAME_VERSAGT, null)
					]
				)
				, new StartDialogue(restartGameDlg)
			] );
		}
	}
	
	static public function setRealVictoryDlg() {
		Dialogue.insert( [
			new Bla(Keys_text.GAME_ERFOLG_2, null)
			, new Bla(Keys_text.GAME_ERFOLG_3, null)
		] );
	}
	
	static public function restartGameDlg() {
		Dialogue.set( [
			new Action(null, ActionType.FADE_TO_BLACK)
			, new StartDialogue(TenUp3.getInstance().loadTheOneAndOnlyLevel)
		] );
	}
	
	static public function setVerkStartDlg() {
		Dialogue.insert( [
			new Action(null, ActionType.FADE_FROM_BLACK)
			, new Bla(Keys_text.DLG_VERK_START_1, Cfg.verkaeuferin)
		] );
	}
	
	static public function setWrongDirection() {
		Dialogue.insert( [
			new Bla(Keys_text.DLG_VERK_START_FALSCHE_RICHTUNG, Cfg.verkaeuferin)
		] );
	}
	
	static public function setVerkaufStartDlg() {
		Dialogue.insert( [
			new Bla(Keys_text.DLG_VERK_START_2, Cfg.mafioso)
			, new Action([], ActionType.FADE_TO_BLACK)
			, new StartDialogue(setVerkaufStart2Dlg)
		] );
	}
	static public function setVerkaufStart2Dlg() {
		Scene.the.removeHero(Cfg.mann);
		Cfg.mann.x = Cfg.mannPositions[1].x;
		Cfg.mann.y = Cfg.mannPositions[1].y + 50;
		Cfg.mann.lookRight = true;
		Cfg.verkaeuferin.operateTheke(true);
		Cfg.verkaeuferin.lookRight = false;
		Scene.the.addHero(Cfg.mann);
		
		Dialogue.insert( [
			new Bla(Keys_text.DLG_VERK_START_3, null)
			, new Action(null, ActionType.FADE_FROM_BLACK)
			, new StartDialogue(setVerkaufVerkDlg)
		] );
	}
}
