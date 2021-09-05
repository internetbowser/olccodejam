extends Area2D

const HitEffect: = preload("res://assets/Effects/HitEffect.tscn")

var invincible = false

onready var timer := $Timer
onready var collision_shape: = $CollisionShape2D

signal invincibility_started
signal invincibility_ended

func start_invincibility(duration: float) -> void:
	timer.start(duration)
	emit_signal("invincibility_started")

func create_hit_effect() -> void:
		var effect: = HitEffect.instance()
		var main: = get_tree().current_scene
		main.add_child(effect)
		effect.global_position = global_position


func _on_Timer_timeout() -> void:
	self.invincible = false
	emit_signal("invincibility_ended")
	

func _on_HurtBox_invincibility_ended() -> void:
	collision_shape.set_deferred("disabled", false)

func _on_HurtBox_invincibility_started() -> void:
	collision_shape.set_deferred("disabled", true)
