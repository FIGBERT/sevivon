extends Node


func _ready() -> void:
	if "--server" in OS.get_cmdline_args() or OS.has_feature("Server"):
		get_tree().change_scene("res://src/server/server_entry.tscn")
	else:
		get_tree().change_scene("res://src/client/client_entry.tscn")
