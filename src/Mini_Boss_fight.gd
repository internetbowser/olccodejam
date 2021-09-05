extends Node2D

onready var bomber = $YSort/Bomber
onready var player = $YSort/Player
onready var portal = $Portal
onready var player_detection_zone = $Portal/PlayerDetectionZone
onready var dialogbox = $CanvasLayer/DialogBox

var gravity_for_portal = false

func _ready() -> void:
	bomber.set_player(player)

func _physics_process(delta: float) -> void:
	if gravity_for_portal:
		player.global_position.move_toward(portal.global_position, 250 * delta)

func _on_DialogBox_finished_dialog() -> void:
	player.un_pause()
	portal.visible = true
	gravity_for_portal = true
	player_detection_zone.connect("body_entered", self, "on_PlayerDetectionZone_body_entered")

func on_PlayerDetectionZone_body_entered(body: Node) -> void:
	player.pause()
	portal.start_terminate()
	gravity_for_portal = false

func _on_Portal_finished() -> void:
	player.queue_free()
	get_tree().change_scene("res://src/World/FutureCity.tscn")

func _on_Bomber_no_health() -> void:
	Globals.has_beaten_mini_boss = true
	dialogbox.start()
	player.pause()
