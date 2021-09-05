extends ColorRect

onready var default_size_x = rect_size.x

func set_health_percent(ratio: float):
	rect_size.x = ratio * default_size_x
	print(self.rect_position)
