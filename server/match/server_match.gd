extends Node


signal client_anted
signal spin_finished
const DREIDEL_FACES := ["nun", "gimmel", "hey", "pey/shin"]


func _ready() -> void:
	print("%sMatch started" % State.time())
	State.iterate_turn()


remote func shake_action() -> void:
	var sender := get_tree().get_rpc_sender_id()
	if sender == State.current_turn and State.players[sender]["in"] and State.all_players_anted() and State.all_spins_finished():
		print("%s%s (%s) spun the dreidel" % [State.time(), sender, State.players[sender]["name"]])
		_client_spun(sender)
		rpc_id(sender, "vibrate_device")
	elif not State.players[sender]["paid_ante"]:
		emit_signal("client_anted", sender)
		rpc_id(sender, "vibrate_device")


func _client_spun(sender: int) -> void:
	yield(_spin_dreidel(sender), "completed")
	yield(_everyone_puts_in_one(), "completed")
	var has_won := State.has_a_winner()
	if has_won:
		var winner := State.get_winner()
		print("%s%s (%s) has won the game, resetting..." % [
			State.time(), winner, State.players[winner]["name"]
			])
		rpc("game_over", winner)
		get_tree().change_scene("res://server/server_lobby.tscn")
	else:
		State.iterate_turn()
		rpc("update_ui")


func _spin_dreidel(id: int) -> void:
	randomize()
	var spin := int(floor(rand_range(0, 4)))
	var username: String = State.players.get(id)["name"]
	print("%s%s (%s) got %s" % [State.time(), id, username, State.stringify_dreidel_spin(spin)])
	rpc("show_spin_alert", spin, username)
	yield(_started_spin(), "completed")
	print("%sAll spin animations finished, moving on" % State.time())
	match(spin):
		1: # gimmel
			State.increase_player_gelt(id, State.pot)
		2: # hey
			State.increase_player_gelt(id, int(ceil(State.pot / 2.0)))
		3: # pey/shin
			if State.players[id]["gelt"] > 0:
				State.decrease_player_gelt(id, 1)
			else:
				State.eliminate_player(id)


func _everyone_puts_in_one() -> void:
	print("%sWaiting for players to ante..." % State.time())
	for id in State.players.keys():
		if State.players[id]["in"]:
			State.set_player_ante_value(id, false)
	rpc("update_ui")
	
	while not State.all_players_anted():
		var id: int = yield(self, "client_anted")
		if not State.players[id]["in"] or State.players[id]["paid_ante"]:
			continue
		if State.players[id]["gelt"] > 0:
			State.decrease_player_gelt(id, 1)
			print("%s%s (%s) paid ante" % [State.time(), id, State.players[id]["name"]])
		else:
			State.eliminate_player(id)
			print("%s%s (%s) was unable to pay ante, and has been eliminated" % [
				State.time(), id, State.players[id]["name"]
				])
		State.set_player_ante_value(id, true)
		rpc("update_ui")


func _started_spin() -> void:
	for id in State.players.keys():
		State.set_player_spin_value(id, false)
	print("%sWaiting for spin animations to finish..." % State.time())
	while not State.all_spins_finished():
		var id: int = yield(self, "spin_finished")
		State.set_player_spin_value(id, true)
		print("%s%s (%s) finished the spin animation" % [State.time(), id, State.players[id]["name"]])


remote func finished_spin() -> void:
	var sender := get_tree().get_rpc_sender_id()
	emit_signal("spin_finished", sender)
