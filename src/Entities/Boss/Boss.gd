extends KinematicBody2D

enum {
	Idle,
	Attack,
}

enum AttackStates {
	Floating,
	Stomping
}

var state = Idle
var attack_state = AttackStates.Floating

signal no_health

export var KNOCKBACK_DISTANCE = 120
export var ACCELERATION = 200
export var MAX_SPEED = 150
export var FRICTION = 200

onready var DeathEffect = preload("res://assets/Effects/EnemyDeathEffect.tscn")

onready var Projectile = preload("res://src/Entities/Projectiles/Ball.tscn")
onready var Bomb = preload("res://src/Entities/Projectiles/Bomb.tscn")
var projectile_timer = 0.0
const PROJECTILE_RELOAD_TIME = 2.5
var balls_thrown = 0
const MIN_BALLS_THROWN = 4

var wiggle_distance = 48.0
var wiggle_duration = 0.5
var wiggle_timer = 0.0

onready var stats = $Stats
onready var player_detection_zone = $PlayerDetectionZone
onready var player_detection_zone_closer = $PlayerDetectionZone_Closer
onready var animation_player = $AnimationPlayer
onready var blink_animation_player = $BlinkAnimationPlayer
onready var hurt_box = $HurtBox
var player : Actor = null
onready var Arm = $Arm

var player_global_pos = Vector2.ZERO

var velocity = Vector2.ZERO
var knockbock = Vector2.ZERO

func _physics_process(delta: float) -> void:
	knockbock = knockbock.move_toward(Vector2.ZERO, FRICTION * delta)
	knockbock = move_and_slide(knockbock)
	
	if player_detection_zone.can_see_player():
		if player != null:
			if player_detection_zone_closer.can_see_player():
				attack_state = AttackStates.Stomping
			else:
				attack_state = AttackStates.Floating
			
			attack_state_process(delta)
	else:
		projectile_timer = 0.0
		animation_player.play("idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = move_and_slide(velocity)

func attack_state_process(delta: float) -> void:
	match attack_state:
		AttackStates.Floating:
			animation_player.play("float")
			projectile_timer += delta
			wiggle_timer += delta
			
			if wiggle_timer >= wiggle_duration:
				wiggle_distance *= -1
				wiggle_timer = 0.0
			
			velocity.y = min((player.global_position.y - global_position.y - 64) * MAX_SPEED * delta, MAX_SPEED)
			velocity.x = min((player.global_position.x - global_position.x + wiggle_distance * wiggle_timer) * MAX_SPEED * delta, MAX_SPEED)
			
			if projectile_timer > PROJECTILE_RELOAD_TIME:
				projectile_timer = 0.0
				if rand_range(0, 1) <= 0.33 and balls_thrown > MIN_BALLS_THROWN:
					balls_thrown = 0
					var bomb = Bomb.instance()
					bomb.global_position = Arm.global_position
					bomb.path_norm  = bomb.global_position.direction_to(player.global_position)
					bomb.duration = global_position.distance_to(player.global_position) / bomb.speed
					get_parent().add_child(bomb)
				else:
					balls_thrown += 1
					var ball = Projectile.instance()
					ball.global_position = Arm.global_position
					ball.path_norm = ball.global_position.direction_to(player.global_position)
					get_parent().add_child(ball)
				
		AttackStates.Stomping:
			animation_player.play("stomp")
			velocity.y = min((player.global_position.y - global_position.y - 16) * MAX_SPEED * delta, MAX_SPEED)
			velocity.x = min((player.global_position.x - global_position.x - 16) * MAX_SPEED * delta, MAX_SPEED)

func _exit_tree() -> void:
	player = null

func set_player(body: Actor) -> void:
	player = body

func _on_HurtBox_area_entered(area: Area2D) -> void:
	stats.health -= area.damage
	knockbock = area.knockback_vector * KNOCKBACK_DISTANCE
	hurt_box.create_hit_effect()
	hurt_box.start_invincibility(0.4)

func _on_Stats_no_health() -> void:
	queue_free()
	var enemy_death_effect = DeathEffect.instance()
	get_parent().add_child(enemy_death_effect)
	enemy_death_effect.global_position = global_position
	emit_signal("no_health")

func _on_HurtBox_invincibility_started() -> void:
	blink_animation_player.play("start")

func _on_HurtBox_invincibility_ended() -> void:
	blink_animation_player.play("stop")
