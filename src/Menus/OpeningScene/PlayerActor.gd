extends KinematicBody2D

var velocity = Vector2(250, 0)

onready var player_hurt_sound = preload("res://src/Entities/Player/PlayerHurtSound.tscn")

var go_yet = false

func _physics_process(delta: float) -> void:
	if go_yet:
		velocity = move_and_slide(velocity)

func _on_DialogBox_finished_dialog() -> void:
	add_child(player_hurt_sound.instance())
	go_yet = true


func _on_PortalTimer_timeout() -> void:
	queue_free()
