extends Control

@export var hint_box: HintBox
@export var hint_offset := Vector2()
@export var hint_anchor := HintBox.HintAnchor.TOP
@export_category("Collision")
@export var collision_control: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if collision_control != null:
        collision_control.mouse_entered.connect(_on_mouse_entered)
        collision_control.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
    if hint_box != null:
        hint_box.node_global_position = position
        hint_box.offset = hint_offset
        hint_box.anchor = hint_anchor
        # Play show animation
        hint_box.show_animation()

func _on_mouse_exited() -> void:
    if hint_box != null:
        # Play hide animation
        hint_box.hide_animation()
