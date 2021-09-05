extends Area2D
func is_colliding():
	var areas: = get_overlapping_areas()
	return areas.size() > 0

func get_push_vector():
	var areas: = get_overlapping_areas()
	var push_vector: = Vector2.ZERO
	if is_colliding():
		var area : Area2D = areas[0]
		push_vector = global_position - area.global_position
		push_vector = push_vector.normalized()
	return push_vector
	

