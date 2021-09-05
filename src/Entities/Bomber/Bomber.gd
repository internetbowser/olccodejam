extends KinematicBody2D

export var KNOCKBACK_DISTANCE = 120
export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export(int) var WANDER_RANGE = 4

onready var thrower_origin_left = $ThrowerPos/Left
onready var thrower_origin_right = $ThrowerPos/Right
onready var player_detection_zone = $PlayerDetectionZone
onready var wander_controller = $WanderController
onready var hurt_box = $HurtBox
onready var stats = $Stats
onready var blink_animation_player = $BlinkAnimationPlayer
var player : Actor = null

signal no_health

enum {
	IDLE,
	WANDER,
	ATTACK
}


var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var state = WANDER

onready var DeathEffect = preload("res://assets/Effects/EnemyDeathEffect.tscn")
onready var Projectile = preload("res://src/Entities/Projectiles/Bomb.tscn")
var projectile_timer = 0.0
const PROJECTILE_RELOAD_TIME = 2.5

func _physics_process(delta: float) -> void:
	knockback = move_and_slide(knockback)
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
			if (wander_controller.get_time_left() <= 0):
				update_wander()
		WANDER:
			seek_player()
			
			if (wander_controller.get_time_left() <= 0):
				update_wander()
			
			accelerate_towards(wander_controller.target_position, delta)
			
			if global_position.distance_to(wander_controller.target_position) <= WANDER_RANGE:
				update_wander()
		ATTACK:
			if player != null && player_detection_zone.can_see_player():
				projectile_timer += delta
				if projectile_timer > PROJECTILE_RELOAD_TIME:
					projectile_timer = 0.0
					var left_ball = Projectile.instance()
					var right_ball = Projectile.instance()
					left_ball.global_position = thrower_origin_left.global_position
					right_ball.global_position = thrower_origin_right.global_position
					left_ball.path_norm  = left_ball.global_position.direction_to(player.global_position + Vector2.LEFT * 4)
					right_ball.path_norm = right_ball.global_position.direction_to(player.global_position + Vector2.RIGHT * 4)
					
					left_ball.duration = left_ball.global_position.distance_to(player.global_position + Vector2.LEFT * 4) / left_ball.speed
					right_ball.duration = right_ball.global_position.distance_to(player.global_position + Vector2.RIGHT * 4) / right_ball.speed
					
					get_parent().add_child(right_ball)
					get_parent().add_child(left_ball)
			else:
				state = IDLE
	
	velocity = move_and_slide(velocity)

func update_wander():
	state = pick_random_state([ IDLE, WANDER ])
	wander_controller.start_wander_timer(rand_range(1,3))

func accelerate_towards(point, delta): 
	var direction: = Vector2(point - global_position).normalized()
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)

func seek_player():
	if player_detection_zone.can_see_player():
				state = ATTACK

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _exit_tree() -> void:
	player = null

func set_player(body: Actor) -> void:
	player = body

func _on_HurtBox_area_entered(area: Area2D) -> void:
	stats.health -= area.damage
	knockback = area.knockback_vector * KNOCKBACK_DISTANCE
	hurt_box.create_hit_effect()
	hurt_box.start_invincibility(0.4)


func _on_HurtBox_invincibility_ended() -> void:
	blink_animation_player.play("stop")


func _on_HurtBox_invincibility_started() -> void:
	blink_animation_player.play("start")


func _on_Stats_no_health() -> void:
	queue_free()
	var enemy_death_effect = DeathEffect.instance()
	get_parent().add_child(enemy_death_effect)
	enemy_death_effect.global_position = global_position
	emit_signal("no_health")
