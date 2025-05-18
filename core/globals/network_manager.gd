extends Node

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 20

var players = {}

var player_info = {"name": "Name"}
var players_loaded = 0


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func create_game(port: int = PORT, max_connections: int = MAX_CONNECTIONS) -> bool:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, max_connections)
	if error:
		push_error("[ERROR] FAILED TO CREATE SERVER: %s" % error)
		return false
	multiplayer.multiplayer_peer = peer
	
	players[1] = player_info
	SignalBus.player_connected.emit(1, player_info)

	return true

func join_game(address: String = "127.0.0.1") -> bool:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		push_error("[ERROR] FAILED TO CREATE CLIENT: %s" % error)
		return false
	multiplayer.multiplayer_peer = peer
	
	return true
	

################################################################################
### RPC's

# Called by the server when the game starts
@rpc('call_local', 'reliable')
func load_game(game_scene_path: StringName) -> void:
	# TODO: Change this to a better scene management system.
	get_tree().change_scene_to_file(game_scene_path)


# Peers should call this when they have loaded the game scene
@rpc('any_peer', 'call_local', 'reliable')
func player_loaded() -> void:
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			SignalBus.start_game.emit()
			players_loaded = 0
	

@rpc('any_peer', 'reliable')
func _register_player(new_player_info) -> void:
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	SignalBus.player_connected.emit(new_player_id, new_player_info)


################################################################################
### Signals

func _on_peer_connected(peer_id: int) -> void:
	_register_player.rpc_id(peer_id, player_info)


func _on_peer_disconnected(peer_id: int) -> void:
	players.erase(peer_id)
	SignalBus.player_disconnected.emit(peer_id)


func _on_connected_to_server() -> void:
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	SignalBus.player_connected.emit(peer_id, player_info)


func _on_connection_failed() -> void:
	multiplayer.multiplayer_peer = null


func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	players.clear()
	SignalBus.server_disconnected.emit()