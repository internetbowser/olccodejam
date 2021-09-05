extends Node2D

onready var player = $YSort/Entities/Player
onready var player_detection_zone = $PlayerDetectionZone
onready var player_detection_zone_BIGBOSS = $PlayerDetectionZoneBIGBOSS
onready var dialog_box = $CanvasLayer/DialogBox
onready var boss_door = $PlayerDetectionZoneBIGBOSS/CollisionShape2D
onready var old_man = $YSort/Entities/OldMan/PlayerDetectionZone
onready var old_man_area = $YSort/Entities/OldMan/PlayerDetectionZone/CollisionShape2D
onready var old_man_dialog = $CanvasLayer/OldManDialog

func _process(delta: float) -> void:
	if player_detection_zone.can_see_player():
		get_tree().change_scene("res://src/Mini_Boss_fight.tscn")
	
	if player_detection_zone_BIGBOSS.can_see_player():
		if !Globals.has_beaten_mini_boss and dialog_box.page == 0:
			dialog_box.start()
			boss_door.disabled = true
		else:
			get_tree().change_scene("res://src/Test_Boss_fight.tscn")
	
	if old_man.can_see_player():
		old_man_area.disabled = true
		old_man_dialog.start()
		player.pause()
		old_man_dialog.connect("finished_dialog", self, "_on_OldManDialog_finished_dialog")

func _on_OldManDialog_finished_dialog():
	player.un_pause()
