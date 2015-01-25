package;

import haxe.Json;
import TenUp4;

#if js
import js.html.WebSocket;
#end

class PlayerData {
	public function new() { }
	public var lastX: Float;
	public var lastY: Float;
}

@:access(TenUp4) 
class Server {
	public static var the(get, null): Server;
	
	private static var instance: Server = null;
	
	private static function get_the(): Server {
		if (instance == null) instance = new Server();
		return instance;
	}
	
	#if js
	private var socket: WebSocket;
	private var connected: Bool = false;
	#end
	
	private function new() {
		#if js
		//socket = new WebSocket('ws://10upunityserver.robdangero.us'); 
		socket = new WebSocket('ws://127.0.0.1:8789');
		socket.onopen = function (value: Dynamic) {
			trace('connected');
			connected = true;
			socket.send(Json.stringify({ command: 'language', language: Cfg.language }));
		};
		socket.onmessage = function (value: Dynamic) {
			var data: Dynamic = Json.parse(value.data);
			trace('message: ' + data);
			switch (data.command) {
				case 'setPlayer':
					if (data.id == 0) {
						Dialogues.startAsMechanic();
					}
					else if (data.id == 1) {
						Dialogues.startAsBully();
					}
					kha.Configuration.setScreen(TenUp4.the);
					TenUp4.the.mode = Game;
				case 'updatePerson':
					for (person in Level.the.persons) {
						if (Std.is(person, Player)) {
							var player: Player = cast person;
							if (player.id == data.id) {
								player.aimx = data.x;
								player.aimy = data.y;
								player.ataimx = false;
								player.ataimy = false;
								if (data.sleeping && !player.isSleeping()) player.sleep();
								else if (!data.sleeping && player.isSleeping()) player.unsleep();
								break;
							}
						}
					}
				case 'speak':
					var player: Player = PlayerBlondie.the;
					if (player == Player.current()) player = PlayerBullie.the;
					BlaBox.boxes.push(new BlaBox(data.text, player));
				case 'changeDoor':
					for (door in Level.the.doors) {
						if (door.id == data.id) {
							door.health = data.health;
							door.opened = data.opened;
							break;
						}
					}
			}
		};
		#end
	}
	
	public function trigger(): Void {
		#if !js
		Dialogues.startAsBully();
		kha.Configuration.setScreen(TenUp4.the);
		TenUp4.the.mode = Game;
		#end
	}
	
	private var players: Map<Player, PlayerData> = new Map();
	
	public function updatePlayer(player: Player): Void {
		#if js
		if (!connected) return;
		if (players.exists(player)) {
			var old = players[player];
			if (player.x != old.lastX || player.y != old.lastY) {
				socket.send(Json.stringify( { command: 'move', id: player.id, x: player.x, y: player.y } ));
				old.lastX = player.x;
				old.lastY = player.y;
			}
		}
		else {
			socket.send(Json.stringify( { command: 'move', id: player.id, x: player.x, y: player.y } ));
			var data = new PlayerData();
			data.lastX = player.x;
			data.lastY = player.y;
			players[player] = data;
		}
		#end
	}
	
	public function sendText(text: String): Void {
		#if js
		socket.send(Json.stringify( { command: 'speak', text: text } ));
		#end
	}
	
	public function changeDoorOpened(id: Int, opened: Bool): Void {
		#if js
		socket.send(Json.stringify( { command: 'doorSetOpened', opened: opened, id: id } ));
		#end
	}
	
	public function changeDoorHealth(id: Int, health: Int): Void {
		#if js
		socket.send(Json.stringify( { command: 'doorSetHealth', health: health, id: id } ));
		#end
	}
	
	public function useElevator(id: Int, destinationLevel: Int): Void {
		#if js
		socket.send(Json.stringify( { command: 'useElevator', id: id, destination: destinationLevel, player: Player.current().id } ));
		#end
		kha.Scene.the.removeHero(Player.current());
		Level.the.elevatorDoor.opened = false;
	}
}
