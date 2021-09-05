extends KinematicBody2D

export var KNOCKBACK_DISTANCE = 120
export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export(int) var WANDER_RANGE = 4

enum {
	IDLE,
	WANDER,
	CHASE
}
var state = IDLE

onready var DeathEffect = preload("res://assets/Effects/EnemyDeathEffect.tscn")

onready var stats: = $Stats
onready var animated_sprite = $AnimatedSprite
onready var wander_controller = $WanderController
onready var soft_collision = $SoftCollision
onready var hurt_box = $HurtBox
onready var hit_box = $HitBox
onready var player_detection_zone = $PlayerDetectionZone
onready var blink_animation_player = $BlinkAnimationPlayer

var velocity  = Vector2.ZERO
var knockback = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	state = pick_random_state([ IDLE, WANDER ])

func _physics_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
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
			
		CHASE:
			var player : Node = player_detection_zone.player
			if player != null:
				accelerate_towards(player.global_position, delta)
			else:
				state = IDLE
	
	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector() * 400 * delta
	
	velocity = move_and_slide(velocity)

func update_wander():
	state = pick_random_state([ IDLE, WANDER ])
	wander_controller.start_wander_timer(rand_range(1,3))

func accelerate_towards(point, delta): 
	var direction: = Vector2(point - global_position).normalized()
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	animated_sprite.flip_h = velocity.x < 0

func seek_player() -> void:
	if player_detection_zone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_HurtBox_area_entered(area: Area2D) -> void:
	stats.health -= area.damage
	knockback = area.knockback_vector * KNOCKBACK_DISTANCE
	hurt_box.create_hit_effect()
	hurt_box.start_invincibility(0.4)
	

func _on_Stats_no_health() -> void:
	queue_free()
	var enemy_death_effect = DeathEffect.instance()
	get_parent().add_child(enemy_death_effect)
	enemy_death_effect.global_position = global_position

func _on_HurtBox_invincibility_started() -> void:
	blink_animation_player.play("start")

func _on_HurtBox_invincibility_ended() -> void:
	blink_animation_player.play("stop")

