extends Spatial


func set_username(username: String) -> void:
	$Viewport/Control/Panel/Label.set_text(username)
