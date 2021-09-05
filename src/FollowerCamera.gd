extends Camera2D

export(float, 0.0, 1) var speed = 0.2
export(float, 0.1, 0.5) var zoom_offset : float = 0.2
export(float) var max_zoom = 1.5
export var debug_mode : bool = false

var camera_rect = Rect2()
var viewport_rect = Rect2()

var margins = Vector2(32,32)

func _ready() -> void:
	viewport_rect = get_viewport_rect()
	set_physics_process(get_child_count() > 0)

func _process(delta: float) -> void:
	camera_rect = Rect2(get_child(0).global_position - margins, Vector2() + margins)
	
	for index in get_child_count():
		if index == 0:
			continue
		camera_rect = camera_rect.expand(get_child(index).global_position + margins)
	
	offset = calculate_center(camera_rect)
	zoom = calculate_zoom(camera_rect, viewport_rect.size)
	
	if debug_mode:
		update()

func calculate_center(rect: Rect2) -> Vector2:
	return Vector2(rect.position + rect.size/2)

func calculate_zoom(rect: Rect2, viewport_size: Vector2) -> Vector2:
	var mz = max(
		max(1, min(rect.size.x / viewport_size.x + zoom_offset, max_zoom)),
		max(1, min(rect.size.y / viewport_size.y + zoom_offset, max_zoom)))
	return Vector2(mz, mz)

func _draw() -> void:
	if not debug_mode:
		return
	draw_rect(camera_rect, Color("#ffffff"), false)
	draw_circle(calculate_center(camera_rect), 2, Color("#ffffff"))
