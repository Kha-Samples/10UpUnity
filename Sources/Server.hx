package;

import haxe.Json;

#if js
import js.html.WebSocket;
#end

class PlayerData {
	public function new() { }
	public var lastX: Float;
	public var lastY: Float;
}

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
		};
		socket.onmessage = function (value: Dynamic) {
			var data: Dynamic = Json.parse(value.data);
			trace('message: ' + data);
			switch (data.command) {
				case 'setPlayer':
					if (data.id == 0) {
						PlayerBlondie.the.setCurrent();
						PlayerBullie.the.sleep();
					}
					else if (data.id == 1) {
						PlayerBullie.the.setCurrent();
						PlayerBlondie.the.sleep();
					}
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
			}
		};
		#end
	}
	
	public function trigger(): Void {
		#if !js
		PlayerBullie.the.setCurrent();
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
}
