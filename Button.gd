extends Sprite

signal pressed
signal released

onready var player_detection_zone = $PlayerDetectionZone
onready var animation_player = $AnimationPlayer
onready var audio_stream_player_2d = $AudioStreamPlayer2D

var can_see_player = false

func _process(delta: float) -> void:
	var could_see_player = can_see_player
	if player_detection_zone.can_see_player():
		can_see_player = true
	else:
		can_see_player = false
	
	if !could_see_player and can_see_player:
		emit_signal("pressed")
	
	if could_see_player and !can_see_player:
		emit_signal("released")


func _on_Button_pressed() -> void:
	animation_player.play("pressed")
	audio_stream_player_2d.play()

func _on_Button_released() -> void:
	animation_player.play("released")
