extends Node

const USERNAMES := ["Judah", "Yochanan", "Shimon", "Elazar", "Yonatan"]
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


func reset_state() -> void:
	players = {}


func add_player(id: int) -> void:
	var _players := players.duplicate(true)
	_players[id] = {
		"name": USERNAMES[players.size()],
		"gelt": PLAYER_STARTING_GELT,
		"ready": false,
		"in": true,
		"paid_ante": true,
	}
	rset("players", _players)


func remove_player(id: int) -> void:
	var _players := players.duplicate(true)
	_players.erase(id)
	rset("players", _players)


func make_player_ready(id: int) -> void:
	var _players := players.duplicate(true)
	_players[id]["ready"] = true
	rset("players", _players)
