extends Node


signal client_anted
const DREIDEL_FACES := ["nun", "gimmel", "hey", "pey/shin"]


func _ready() -> void:
	State.iterate_turn()


remote func shake_action() -> void:
	var sender := get_tree().get_rpc_sender_id()
	if sender == State.current_turn and State.players[sender]["in"] and State.all_players_anted():
		_client_spun(sender)
		rpc_id(sender, "vibrate_device")
	elif not State.players[sender]["paid_ante"]:
		emit_signal("client_anted", sender)
		rpc_id(sender, "vibrate_device")


func _client_spun(sender: int) -> void:
	_spin_dreidel(sender)
	yield(_everyone_puts_in_one(), "completed")
	var has_won := State.has_a_winner()
	if has_won:
		var winner := State.get_winner()
	else:
		State.iterate_turn()
		rpc("set_username_tag", State.players[State.current_turn]["name"])
		rpc("update_ui")


func _spin_dreidel(id: int) -> void:
	randomize()
	var spin := int(floor(rand_range(0, 4)))
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
	for id in State.players.keys():
		if State.players[id]["in"]:
			State.set_player_ante_value(id, false)
	
	while not State.all_players_anted():
		var id: int = yield(self, "client_anted")
		if not State.players[id]["in"] or State.players[id]["paid_ante"]:
			continue
		if State.players[id]["gelt"] > 0:
			State.decrease_player_gelt(id, 1)
		else:
			State.eliminate_player(id)
		State.set_player_ante_value(id, true)
