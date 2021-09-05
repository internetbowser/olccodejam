extends Area2D
var player : Node = null
var player_global_pos = Vector2.ZERO

func can_see_player() -> bool:
	return player != null

func get_player_global_position() -> Vector2:
	return player_global_pos

func _on_PlayerDetectionZone_body_entered(body: Node) -> void:
	player = body
	player_global_pos = body.global_position

func _on_PlayerDetectionZone_body_exited(body: Node) -> void:
	player = null
	
