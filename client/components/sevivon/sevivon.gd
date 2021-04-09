extends KinematicBody


func create_username_tag(username: String) -> void:
	$NameTag.set_username(username)
	$NameTag.show()
