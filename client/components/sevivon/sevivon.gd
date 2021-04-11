extends KinematicBody


func set_username_tag(username: String) -> void:
	$NameTag.set_username(username)
	if not $NameTag.visible:
		$NameTag.show()
