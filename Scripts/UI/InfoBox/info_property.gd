extends HBoxContainer

@onready var label: Label = $Label
@onready var content: Label = $Content

@export var label_text := ""
@export var content_text := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = label_text
	if content_text.is_empty():
		content_text = "–"
	else:
		content.text = content_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	label.text = label_text
	if content_text.is_empty():
		content_text = "––"
	else:
		content.text = content_text
