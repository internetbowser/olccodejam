extends Node
class_name Stats

export(int) var max_health = 1 setget set_max_health
var health = max_health setget set_health
var health_ratio : float = 1.0

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func set_max_health(value) -> void:
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)

func set_health(value: int) -> void:
	health = value
	health_ratio = float(health) / float(max_health)
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func get_health_ratio() -> float:
	return health_ratio

func _ready() -> void:
	self.health = max_health
