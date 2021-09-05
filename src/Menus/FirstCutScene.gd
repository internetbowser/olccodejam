extends Node2D

onready var button = $Button
onready var dialog_box2 = $CanvasLayer/DialogBox2
onready var dialog_box1 = $CanvasLayer/DialogBox1
onready var player = $Player
onready var player_detection_zone = $PlayerDetectionZone2/CollisionShape2D

func _ready() -> void:
	player.pause()

func _on_Button_pressed() -> void:
	dialog_box2.start()
	player.pause()

func _on_Button_released() -> void:
	pass # Replace with function body.

func _on_DialogBox_finished_dialog() -> void:
	player.un_pause()
	player_detection_zone.disabled = false

func _on_PlayerDetectionZone2_body_entered(body: Node) -> void:
	get_tree().change_scene("res://src/Menus/OpeningScene/StoryMovie.tscn")


func _on_DialogBox1_finished_dialog() -> void:
	player.un_pause()
