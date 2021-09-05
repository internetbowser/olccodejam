extends KinematicBody2D

export(float) var duration = 5.0
export(float) var speed = 100.0
export var path_norm = Vector2.ZERO

onready var duration_timer = Timer.new()

onready var hitbox = $HitBox

var velocity = Vector2.ZERO

func _ready() -> void:
	hitbox.set_collision_mask_bit(Globals.PhysicsLayers.PlayerHurtBox, true)
	hitbox.set_collision_mask_bit(Globals.PhysicsLayers.EnemyHurtBox, false)
	
	velocity = path_norm * speed
	hitbox.knockback_vector = velocity.normalized()
	
	duration_timer.one_shot = true
	add_child(duration_timer)
	duration_timer.start(duration)
	duration_timer.connect("timeout", self, "_on_DurationTimer_timeout")

func _physics_process(delta: float) -> void:
	rotation_degrees += 360 * delta
	velocity = move_and_slide(velocity)

func _on_DurationTimer_timeout():
	queue_free()

func _on_HurtBox_area_entered(area: Area2D) -> void:
	velocity = area.global_position.direction_to(global_position) * speed
	hitbox.knockback_vector = velocity.normalized()
	
	hitbox.set_collision_mask_bit(Globals.PhysicsLayers.PlayerHurtBox, false)
	hitbox.set_collision_mask_bit(Globals.PhysicsLayers.EnemyHurtBox, true)
