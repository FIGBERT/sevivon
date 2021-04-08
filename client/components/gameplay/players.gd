extends Node


var id := get_tree().get_network_unique_id()


func create_self() -> Node:
	var me: Node = load("res://client/components/sevivon/sevivon.tscn").instance()
	me.set_name(str(id))
	me.translate(Vector3.BACK *  5)
	return me


func _peers() -> Array:
	var peers := State.players.keys().duplicate()
	peers.erase(id)
	return peers
