extends Node


const USERNAMES := ["Judah", "Yochanan", "Shimon", "Elazar", "Yonatan"]
const POT_STARTING_GELT := 5
const PLAYER_STARTING_GELT := 10
# A dictionary containing all the current players.
# Each player is assigned an integer key, equal to
# their network unique id. The value of each key
# is another dictionary, containing a number of
# properties:
#
# name: String = player's username.
# gelt: int = quantity of player's gelt.
# ready: bool = whether or not the player is ready
#               to begin the game. `true` after the
#               game has begun.
# in: bool = whether or not the player is in or out.
# paid_ante: bool = whether or not the player has
#                   paid all required antes.
remotesync var players := {}
remotesync var current_turn := 0
remotesync var pot := POT_STARTING_GELT


func reset_state() -> void:
	players = {}


func add_player(id: int) -> void:
	var _players := players.duplicate(true)
	_players[id] = _create_player(USERNAMES[players.size()])
	rset("players", _players)


func remove_player(id: int) -> void:
	var _players := players.duplicate(true)
	_players.erase(id)
	rset("players", _players)


func make_player_ready(id: int) -> void:
	var _players := players.duplicate(true)
	_players[id]["ready"] = true
	rset("players", _players)


func eliminate_player(id: int) -> void:
	var _players := players.duplicate(true)
	_players[id]["in"] = false
	rset("players", _players)


func set_player_ante_value(id: int, value: bool) -> void:
	var _players := players.duplicate(true)
	_players[id]["paid_ante"] = value
	rset("players", _players)


func increase_player_gelt(id: int, addend: int) -> void:
	_modify_player_gelt(id, addend)


func decrease_player_gelt(id: int, minuend: int) -> void:
	_modify_player_gelt(id, -minuend)


func all_players_ready() -> bool:
	var sum := 0
	for id in players.keys():
		sum += int(players[id]["ready"])
	return true if sum == players.size() else false


func all_players_anted() -> bool:
	var sum := 0
	for id in players.keys():
		sum += int(players[id]["paid_ante"])
	return true if sum == players.size() else false


func has_a_winner() -> bool:
	var sum := 0
	for id in players.keys():
		sum += int(players[id]["in"])
	return true if sum == 1 else false


func get_winner() -> int:
	for id in players.keys():
		if players[id]["in"]:
			return id
	return -1


func get_peer_ids(id: int) -> Array:
	var peers: Array
	for pid in players.keys():
		if pid != id:
			peers.append(pid)
	return peers


func iterate_turn() -> void:
	var index := players.keys().find(current_turn)
	if index == players.size() - 1 or index == -1:
		index = 0
	else:
		index += 1
	var new_turn: int = players.keys()[index]
	rset("current_turn", new_turn)


func _create_player(username: String) -> Dictionary:
	return {
		"name": username,
		"gelt": PLAYER_STARTING_GELT,
		"ready": false,
		"in": true,
		"paid_ante": true,
	}


func _modify_player_gelt(id: int, modifier: int) -> void:
	var _players := players.duplicate(true)
	_players[id]["gelt"] += modifier
	rset("players", _players)
	rset("pot", pot - modifier)
