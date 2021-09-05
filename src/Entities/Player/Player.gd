extends KinematicBody2D
class_name Actor

enum {
	Idle=0,
	Run=1,
	Attack=2,
	STUCK
}

var state = Run

export var Knockback_Distance = 120
export var Acceleration = 200
export var Max_Speed = 150
export var Friction = 500

onready var hurt_box = $HurtBox
onready var stats = $Stats

onready var DeathEffect = preload("res://assets/Effects/EnemyDeathEffect.tscn")
onready var player_hurt_sfx = preload("res://src/Entities/Player/PlayerHurtSound.tscn")
onready var sprite           : Sprite          = $Sprite
onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var blink_animation_player : AnimationPlayer = $BlinkAnimationPlayer
onready var animation_tree : AnimationTree = $AnimationTree
onready var bat_hitbox = $HitBoxPivot/HitBox
onready var animation_state = animation_tree.get("parameters/playback")

var idle_animation = "Idle"
var run_horiz_animation  = "run_horiz"
var run_up_animation = "run_up"
var attack_animation = "Attack"

var movement_norm = Vector2.ZERO
var old_movement_norm = Vector2.ZERO
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

func _ready():
	animation_tree.active = true

func get_input():
	old_movement_norm = movement_norm
	
	movement_norm = Vector2(int(Input.is_action_pressed("RIGHT")) - int(Input.is_action_pressed("LEFT")),
								int(Input.is_action_pressed("DOWN")) - int(Input.is_action_pressed("UP")))
	
#	if movement_norm.x != 0:
#		sprite.flip_h = movement_norm.x + 1
	
	if movement_norm.length() > 0:
		movement_norm = movement_norm.normalized()
	
	if Input.is_action_just_pressed("ATTACK"):
		state = Attack
	

func update_animations():
	if movement_norm != Vector2.ZERO:
		animation_tree.set("parameters/idle/blend_position", movement_norm)
		animation_tree.set("parameters/run/blend_position", movement_norm)
		animation_tree.set("parameters/attack/blend_position", movement_norm)
		bat_hitbox.knockback_vector = movement_norm
	
	if state == Idle:
		animation_state.travel("idle")
	if state == Run:
		animation_state.travel("run")
	if state == Attack:
		animation_state.travel("attack")

func _physics_process(delta):
	match state:
		STUCK:
			pass
		Run:
			knockback = knockback.move_toward(Vector2.ZERO, Acceleration * delta)
			knockback = move_and_slide(knockback)
			
			var new_Acceleration = Acceleration
			
			movement_norm = Vector2.ZERO
			movement_norm.x = int(Input.is_action_pressed("RIGHT")) - int(Input.is_action_pressed("LEFT"))
			movement_norm.y = int(Input.is_action_pressed("DOWN")) - int(Input.is_action_pressed("UP"))
			movement_norm = movement_norm.normalized()
			
			if movement_norm != Vector2.ZERO:
				bat_hitbox.knockback_vector = movement_norm
				animation_tree.set("parameters/idle/blend_position", movement_norm)
				animation_tree.set("parameters/run/blend_position", movement_norm)
				animation_tree.set("parameters/attack/blend_position", movement_norm)
				animation_state.travel("run")
				bat_hitbox.knockback_vector = movement_norm
				velocity = velocity.move_toward(movement_norm * Max_Speed, new_Acceleration * delta)
			else:
				animation_state.travel("idle")
				velocity = velocity.move_toward(Vector2.ZERO, Friction * delta)
			
			velocity = move_and_slide(velocity)
			
			if Input.is_action_just_pressed("ATTACK"):
				state = Attack
		Attack:
			animation_state.travel("attack")

func pause():
	set_physics_process(false)

func un_pause():
	set_physics_process(true)

func _on_HurtBox_area_entered(area: Area2D) -> void:
	knockback = area.knockback_vector * Knockback_Distance
	stats.health -= area.damage
	hurt_box.start_invincibility(0.6)
	hurt_box.create_hit_effect()
	var player_hurt_sound = player_hurt_sfx.instance()
	get_tree().current_scene.add_child(player_hurt_sound)


func _on_HurtBox_invincibility_started() -> void:
	blink_animation_player.play("start")

func _on_HurtBox_invincibility_ended() -> void:
	blink_animation_player.play("stop")

func AttackAnimation_finished() -> void:
	state = Run
	velocity = Vector2.ZERO

func _on_Stats_no_health() -> void:
	queue_free()
	var player_explosiion = DeathEffect.instance()
	get_parent().add_child(player_explosiion)
	player_explosiion.global_position = global_position
