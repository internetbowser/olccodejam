extends AnimatedSprite

func _on_Button_button_up() -> void:
	get_tree().change_scene("res://src/Menus/FirstCutScene.tscn")

func _on_Button_button_down() -> void:
	self.play("pressed")
