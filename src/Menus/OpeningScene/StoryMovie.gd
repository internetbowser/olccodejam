extends Node2D

onready var player_detection_zone = $PlayerStopper/PlayerDetectionZone
onready var portal_timer = $PortalTimer
onready var portal_close_timer = $PortalCloseTimer
onready var portal = $Portal

var finished = false

func _ready() -> void:
	portal.set_visibility(false)

func _process(delta: float) -> void:
	if player_detection_zone.can_see_player() &&  portal_timer.time_left <= 0 && !finished:
		portal_timer.start()
	
	if portal_timer.time_left < portal_timer.wait_time * 0.75 && portal_timer.time_left > 0:
		portal.set_visibility(true)

func _on_PortalTimer_timeout() -> void:
	portal.start_terminate()
	finished = true

func _on_Portal_finished() -> void:
	portal_close_timer.start()

func _on_PortalCloseTimer_timeout() -> void:
	get_tree().change_scene("res://src/Menus/FutureScene/FutureScene.tscn")
