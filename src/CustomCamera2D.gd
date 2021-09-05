extends Camera2D

onready var tl = $TL
onready var br = $BR

func _ready() -> void:
	limit_top = tl.global_position.y
	limit_left = tl.global_position.x
	limit_bottom = br.global_position.y
	limit_right = br.global_position.x
