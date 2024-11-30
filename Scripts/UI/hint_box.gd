extends PanelContainer

@onready var title_label: Label = $HintBox/TitlePanel/VBoxContainer/TitleContainer/TitleLabel
@onready var description_label: Label = $HintBox/DescriptionContainer/DescriptionLabel

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var title_panel: PanelContainer = $HintBox/TitlePanel

@export var title_key := ""
@export var description_key := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title_label.text = tr(title_key)
	description_label.text = tr(description_key)
	title_panel.material = title_panel.material.duplicate()
	material = material.duplicate()
	hide()

func show_animation() -> void:
	animation_player.play("show")

func hide_animation() -> void:
	animation_player.play("hide")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if size.x > get_viewport_rect().size.x:
		description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		description_label.autowrap_mode = TextServer.AUTOWRAP_OFF
