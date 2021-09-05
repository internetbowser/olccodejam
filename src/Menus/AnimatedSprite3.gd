extends AnimatedSprite

func _on_Button2_button_up() -> void:
	get_tree().change_scene("res://src/Menus/Menu.tscn")

func _on_Button2_button_down() -> void:
	self.play("pressed")
