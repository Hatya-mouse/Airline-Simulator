@tool
extends TextureButton

@onready var texture_rect: TextureRect = $Pressed_texture
@onready var animation_player: AnimationPlayer = $Pressed_texture/AnimationPlayer

const hint_box_scene = preload("res://Scenes/UI/hint_box.tscn")
const screen_margin = 20

@export var default_texture: Texture2D
@export var pressed_texture: Texture2D
@export_category("Button Hint")
@export var hint_box: PanelContainer
@export var hint_offset := Vector2()
@export var hint_anchor: HintAnchor = HintAnchor.TOP

enum HintAnchor { TOP, RIGHT, BOTTOM, LEFT }

func _ready() -> void:
	texture_normal = default_texture
	texture_rect.texture = pressed_texture
	texture_rect.visible = button_pressed

func _on_toggled(toggled_on: bool) -> void:
	if animation_player != null:
		animation_player.play("toggle_on" if toggled_on else "toggle_off")

func _on_mouse_entered() -> void:
	if hint_box != null:
		position_hint_box()
		# Play show animation
		hint_box.show_animation()

func position_hint_box() -> void:
	# Get the position of hint box from button position and anchor
	var center = global_position + size / 2
	var hint_position = center + hint_offset
	if hint_anchor == HintAnchor.TOP:
		hint_position -= Vector2(hint_box.size.x / 2, 0)
	if hint_anchor == HintAnchor.RIGHT:
		hint_position -= Vector2(hint_box.size.x, hint_box.size.y / 2)
	if hint_anchor == HintAnchor.BOTTOM:
		hint_position -= Vector2(hint_box.size.x / 2, hint_box.size.y)
	if hint_anchor == HintAnchor.LEFT:
		hint_position -= Vector2(0, hint_box.size.y / 2)
	# Adjust the position if the hint box is out of the screen
	var top_position = hint_position.y
	var right_position = hint_position.x + hint_box.size.x
	var bottom_position = hint_position.y + hint_box.size.y
	var left_position = hint_position.x
	var screen_size = get_viewport_rect().size
	if top_position < screen_margin:
		hint_position.y = screen_margin
	if right_position > screen_size.x - screen_margin:
		hint_position.x = screen_size.x - hint_box.size.x - screen_margin
	if bottom_position > screen_size.y - screen_margin:
		hint_position.y = screen_size.y - hint_box.size.y - screen_margin
	if left_position < screen_margin:
		hint_position.x = screen_margin
	# Set the position
	hint_box.set_global_position(hint_position)

func _on_mouse_exited() -> void:
	if hint_box != null:
		# Play hide animation
		hint_box.hide_animation()
