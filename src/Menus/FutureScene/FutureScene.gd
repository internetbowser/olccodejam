extends Node2D

onready var start_timer = $StartTimer
onready var y_sort = $YSort
onready var player = $YSort/Entities/Player
onready var portal = $Portal
onready var player_detection_zone = $PlayerDetectionZone

func _ready() -> void:
	player.pause()

func _process(delta: float) -> void:
	if player_detection_zone.can_see_player():
		get_tree().change_scene("res://src/World/FutureCity.tscn")

func _on_Portal_finished() -> void:
	start_timer.start()

func _on_StartTimer_timeout() -> void:
	player.un_pause()

func _on_DialogBox_finished_dialog() -> void:
	portal.start_terminate()
