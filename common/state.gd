extends Node


const USERNAMES := ["Judah", "Yochanan", "Shimon", "Elazar", "Yonatan"]
const PLAYER_STARTING_GELT := 10
remotesync var players := {}


func reset_state() -> void:
	players = {}


func add_player(id: int) -> void:
	var _players := players.duplicate()
	_players[id] = Player.new(id, USERNAMES[players.size()])
	rset("players", _players)


func remove_player(id: int) -> void:
	var _players := players.duplicate()
	_players.erase(id)
	rset("players", _players)


func make_player_ready(id: int) -> void:
	var _players := players.duplicate()
	_players[id].ready = true
	rset("players", _players)


class Player:
	var id: int
	var username: String
	var gelt := PLAYER_STARTING_GELT
	var ready := false
	var in_game := true
	var paid_ante := true
	
	func _init(_id: int, _username: String) -> void:
		id = _id
		username = _username
