extends Control


func set_gelt(gelt: int) -> void:
	$Gelt.set_text(str(gelt))


func set_username(username: String) -> void:
	$Name.set_text(username)


func set_color(color: Color) -> void:
	$Gelt.set("custom_colors/font_color", color)
	$Name.set("custom_colors/font_color", color)
