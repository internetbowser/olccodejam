extends Polygon2D

export(Array) var dialog = ["Hey! I just Created a dialog box!!","Can you believe it?"]
export(bool) var enable_back_page = false
export(bool) var auto_start = true

signal moved_to_next_page 
signal moved_to_previous_page
signal finished_page
signal finished_dialog

onready var rich_text_label = $RichTextLabel
onready var helpers = $Helpers
onready var backward = $Helpers/back

var page = -1

func _ready() -> void:
	next_page()
	helpers.visible = false
	backward.visible = enable_back_page
	
	set_process(auto_start)
	visible = auto_start


func _process(delta: float) -> void:
	if rich_text_label.visible_characters > dialog[page].length():
			emit_signal("finished_page")
			helpers.visible = true
	
	if Input.is_action_just_released("ui_accept"):
		if rich_text_label.visible_characters > dialog[page].length():
			if page < dialog.size() - 1:
				next_page()
			else:
				close_dialog_box()
		else:
			rich_text_label.visible_characters = dialog[page].length()
	
	if Input.is_action_just_released("LEFT") && enable_back_page:
		if page > 0:
			previous_page()

func start() -> void:
	set_process(true)
	visible = true

func next_page() -> void:
	page += 1
	rich_text_label.bbcode_text = dialog[page]
	rich_text_label.visible_characters = 0
	helpers.visible = false
	emit_signal("moved_to_next_page")

func previous_page() -> void:
	page -= 1
	rich_text_label.bbcode_text = dialog[page]
	rich_text_label.visible_characters = 0
	helpers.visible = false
	emit_signal("moved_to_previous_page")

func close_dialog_box() -> void:
	queue_free()
	emit_signal("finished_dialog")

func _on_Timer_timeout() -> void:
	rich_text_label.visible_characters += 1
