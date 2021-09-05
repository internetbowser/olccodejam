extends Control

onready var health_bar = $HealhBar
onready var health_bar_BG = $HealthBarBG
onready var update_tween = $UpdateTween

func update_health(health_ratio):
	health_bar.value = health_bar.max_value * health_ratio
	update_tween.interpolate_property(health_bar_BG, "value", health_bar_BG.value, health_bar_BG.max_value * health_ratio, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
	update_tween.start()

func update_max_health(max_health):
	health_bar.max_value = max_health
