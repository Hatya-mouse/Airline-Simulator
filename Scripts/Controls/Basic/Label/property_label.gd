@tool
extends InfoBoxItem
class_name PropertyLabel

@onready var label: Label = $Label
@onready var content: Label = $Content

@export var label_text := ""
@export var content_text := ""
@export_category("Layout")
@export var align_content_text_to_right := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_contents()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_contents()

func update_contents():
	label.text = label_text
	if content_text.is_empty():
		content_text = "—"
	else:
		content.text = content_text

	# Set the text alignment
	if align_content_text_to_right:
		content.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	else:
		content.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
