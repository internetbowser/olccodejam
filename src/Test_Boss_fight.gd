extends Node2D

onready var boss = $YSort/Boss
onready var player = $YSort/Player
onready var portal = $Portal
onready var player_detection_zone = $Portal/PlayerDetectionZone
onready var dialogbox = $CanvasLayer/DialogBox

var gravity_for_portal = false

func _ready() -> void:
	boss.set_player(player)

func _physics_process(delta: float) -> void:
	if gravity_for_portal:
		player.global_position.move_toward(portal.global_position, 250 * delta)

func _on_Boss_no_health() -> void:
	dialogbox.start()
	player.pause()

func _on_DialogBox_finished_dialog() -> void:
	player.un_pause()
	portal.visible = true
	gravity_for_portal = true
	player_detection_zone.connect("body_entered", self, "on_PlayerDetectionZone_body_entered")
	get_tree().change_scene("res://src/Menus/EndScene/EndScene.tscn")

func on_PlayerDetectionZone_body_entered(body: Node) -> void:
	player.pause()
	portal.start_terminate()
	gravity_for_portal = false

func _on_Portal_finished() -> void:
	player.queue_free()
	
