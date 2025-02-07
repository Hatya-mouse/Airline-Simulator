extends InfoBoxItem

const normal_label_style = preload("res://UIResources/LabelSettings/normal_label.tres")

@onready var begin: HBoxContainer = $HBox/Begin
@onready var last: HBoxContainer = $HBox/Last

@export var contents: PackedStringArray = []
@export var alignment_array: Array[HorizontalAlignment] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for counter in range(len(contents)):
		var alignment = alignment_array[counter]
		if alignment == null:
			add_label(contents[counter])
		else:
			add_label(contents[counter], alignment_array[counter])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func add_label(content: String, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> void:
	var label = Label.new()
	# Set the text
	label.text = tr(content)
	# Set label settings and set alignment
	label.label_settings = normal_label_style
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = alignment

	# Add label as children of HBoxContainer
	if alignment == HORIZONTAL_ALIGNMENT_RIGHT:
		last.add_child(label)
	else:
		begin.add_child(label)
