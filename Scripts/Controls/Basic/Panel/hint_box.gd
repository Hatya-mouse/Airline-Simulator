extends PanelContainer
class_name HintBox

const screen_margin = 20

@onready var title_label: Label = $HintBox/TitlePanel/VBoxContainer/TitleContainer/TitleLabel
@onready var description_label: Label = $HintBox/DescriptionContainer/DescriptionLabel

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var title_panel: PanelContainer = $HintBox/TitlePanel

@export_category("Contents")
@export var title_key := ""
@export var description_key := ""
@export_category("Collision")
## If mouse hit the collider, hint box will be shown.
## Leave this property null to set parent control of hint box as collider.
@export var collider: Control
@export_category("Position")
## Position of the anchor. If null, collider's center position will be used.
@export var change_anchor_x := false
@export var anchor_x: float
@export var change_anchor_y := false
@export var anchor_y: float
@export var offset := Vector2()
@export var anchor := HintAnchor.TOP

enum HintAnchor {TOP, RIGHT, BOTTOM, LEFT}

var old_parent_position := Vector2(0.0, 0.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title_label.text = tr(title_key)
	description_label.text = tr(description_key)
	title_panel.material = title_panel.material.duplicate()
	material = material.duplicate()
	hide()

	if collider == null:
		collider = get_parent_control()

	if collider != null:
		collider.mouse_entered.connect(show_animation)
		collider.mouse_exited.connect(hide_animation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if size.x > get_viewport_rect().size.x:
		description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		description_label.autowrap_mode = TextServer.AUTOWRAP_OFF

	if collider == null:
		queue_free()
		return
	if old_parent_position != collider.global_position:
		position_hint_box()
	old_parent_position = collider.global_position

func show_animation() -> void:
	position_hint_box()
	animation_player.play("show")

func hide_animation() -> void:
	animation_player.play("hide")

func position_hint_box() -> void:
	# Get the position of the collider node
	var node_global_position = collider.global_position

	# Get the position of hint box from button position and anchor
	var center = node_global_position + size / 2
	if change_anchor_x:
		center.x = anchor_x
	if change_anchor_y:
		center.y = anchor_y

	var hint_position = center + offset

	if anchor == HintAnchor.TOP:
		hint_position -= Vector2(size.x / 2, 0)
	if anchor == HintAnchor.RIGHT:
		hint_position -= Vector2(size.x, size.y / 2)
	if anchor == HintAnchor.BOTTOM:
		hint_position -= Vector2(size.x / 2, size.y)
	if anchor == HintAnchor.LEFT:
		hint_position -= Vector2(0, size.y / 2)

	# Adjust the position if the hint box is out of the screen
	var top_position = hint_position.y
	var right_position = hint_position.x + size.x
	var bottom_position = hint_position.y + size.y
	var left_position = hint_position.x
	var screen_size = get_viewport_rect().size
	if top_position < screen_margin:
		hint_position.y = screen_margin
	if right_position > screen_size.x - screen_margin:
		hint_position.x = screen_size.x - size.x - screen_margin
	if bottom_position > screen_size.y - screen_margin:
		hint_position.y = screen_size.y - size.y - screen_margin
	if left_position < screen_margin:
		hint_position.x = screen_margin

	# Set the position
	set_global_position(hint_position)
