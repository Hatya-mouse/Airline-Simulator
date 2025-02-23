extends PanelContainer
class_name LabelBox

@onready var label: Label = $TitleContainer/TitleLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var text := ""
@export var translate := false
@export var is_hidden := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = tr(text) if translate else text
	size.x = label.size.x + 24
	material = material.duplicate()
	# Set the visibility.
	visible = not is_hidden

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	label.text = tr(text) if translate else text
	size.x = label.size.x + 24

func show_animation() -> void:
	if is_hidden:
		animation_player.play("show")
		is_hidden = false

func hide_animation() -> void:
	if not is_hidden:
		animation_player.play("hide")
		is_hidden = true
