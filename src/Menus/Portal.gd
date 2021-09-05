extends AnimatedSprite

export(float) var TimerDestructionTime = 1.0

onready var PortalTimer = Timer.new()

signal finished

func _ready() -> void:
	PortalTimer.one_shot = true
	PortalTimer.wait_time = TimerDestructionTime
	PortalTimer.connect("timeout", self, "on_PortalTimer_timeout")
	
	add_child(PortalTimer)

func set_visibility(enabled: bool = true) -> void:
	visible = enabled

func start_terminate() -> void:
	PortalTimer.start()

func _physics_process(delta: float) -> void:
	rotation_degrees += 90 * delta

func on_PortalTimer_timeout() -> void:
	emit_signal("finished")
	queue_free()
