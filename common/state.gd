extends Node


const USERNAMES := ["Judah", "Yochanan", "Shimon", "Elazar", "Yonatan"]
const POT_STARTING_GELT := 5
const PLAYER_STARTING_GELT := 10
remotesync var pot := POT_STARTING_GELT
remotesync var players := {}
remotesync var current_turn := 0


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


func eliminate_player(id: int) -> void:
	var _players := players.duplicate()
	_players[id].in_game = false
	rset("players", _players)


func set_player_ante_value(id: int, value: bool) -> void:
	var _players := players.duplicate()
	_players[id].paid_ante = value
	rset("players", _players)


func increase_player_gelt(id: int, addend: int) -> void:
	_modify_player_gelt(id, addend)


func decrease_player_gelt(id: int, minuend: int) -> void:
	_modify_player_gelt(id, -minuend)


func _modify_player_gelt(id: int, modifier: int) -> void:
	var _players := players.duplicate()
	_players[id].gelt += modifier
	rset("players", _players)
	rset("pot", pot - modifier)


func all_players_ready() -> bool:
	var sum := 0
	for id in players.keys():
		sum += int(players[id].ready)
	return true if sum == players.size() else false


func all_players_anted() -> bool:
	var sum := 0
	for id in players.keys():
		sum += int(players[id].paid_ante)
	return true if sum == players.size() else false


func has_a_winner() -> bool:
	var sum := 0
	for id in players.keys():
		sum += int(players[id].in_game)
	return true if sum == 1 else false


func get_winner() -> Player:
	for id in players.keys():
		if players[id].in_game:
			return players[id]
	return null


func get_peer_ids(id: int) -> Array:
	var peers: Array
	for pid in players.keys():
		if pid != id:
			peers.append(pid)
	return peers


func iterate_turn() -> void:
	var index := players.keys().find(current_turn) + 1
	if index == players.size() or index == -1:
		index = 0
	current_turn = players.keys()[index]


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
