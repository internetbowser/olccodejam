extends Node2D

onready var dialog_box = $Ui/DialogBox
onready var portal = $Portal

func _on_DialogBox_finished_dialog() -> void:
	portal.show()
	portal.start_terminate()


func _on_Portal_finished() -> void:
	get_tree().change_scene("res://src/Menus/Menu.tscn")
