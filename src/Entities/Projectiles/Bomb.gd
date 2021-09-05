extends KinematicBody2D

export(float) var duration = 0.0
export(float) var speed = 100.0
export var path_norm = Vector2.ZERO

onready var duration_timer = Timer.new()

onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var hitbox = $HitBox

var velocity = Vector2.ZERO

func _ready() -> void:
	animation_player.play("default")
	hitbox.set_collision_mask_bit(Globals.PhysicsLayers.PlayerHurtBox, true)
	hitbox.set_collision_mask_bit(Globals.PhysicsLayers.EnemyHurtBox, false)
	
	velocity = path_norm * speed
	hitbox.knockback_vector = velocity.normalized()
	
	duration_timer.one_shot = true
	add_child(duration_timer)
	duration_timer.start(duration - animation_player.get_animation("explode").length)
	duration_timer.connect("timeout", self, "_on_DurationTimer_timeout")

func _physics_process(delta: float) -> void:
	velocity = move_and_slide(velocity)

func _on_DurationTimer_timeout():
	animation_player.play("explode")

func _on_HurtBox_area_entered(area: Area2D) -> void:
	velocity = area.global_position.direction_to(global_position) * speed
	hitbox.knockback_vector = velocity.normalized()
	duration_timer += 2.0
	hitbox.set_collision_mask_bit(Globals.PhysicsLayers.PlayerHurtBox, false)
	hitbox.set_collision_mask_bit(Globals.PhysicsLayers.EnemyHurtBox, true)
