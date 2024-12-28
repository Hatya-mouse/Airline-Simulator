extends Control
class_name InfoBox

const hint_box_scene = preload("res://Scenes/UI/hint_box.tscn")
const scroll_container_scene = preload("res://Scenes/UI/info_box_scroll_container.tscn")

@onready var title_label: Label = $InfoBox/VBoxContainer/PanelContainer/VBoxContainer/MarginContainer/TitleLabel

@onready var info_box: PanelContainer = $"InfoBox"
@onready var title_container: PanelContainer = $InfoBox/VBoxContainer/PanelContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var scroll_container_parent: VBoxContainer = $InfoBox/VBoxContainer
@onready var scroll_container: ScrollContainer = $InfoBox/VBoxContainer/ScrollContainer
@onready var blue_panel: Panel = $InfoBox/VBoxContainer/Panel

var info_container: VBoxContainer

var title := ""
## Controls except last_controls
var information_controls: Array[Control] = []
var is_hidden := true

## Controls always shown in the bottom of the info box
var last_controls: Array[Control] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	info_container = scroll_container.info_container

	for node in information_controls:
		info_container.add_child(node)
	if not last_controls.is_empty():
		for last_control in last_controls:
			info_container.add_child(last_control)

	title_container.material = title_container.material.duplicate()
	info_box.material = info_box.material.duplicate()

	title_label.text = title
	hide()

## Replate information control with new controls and play transition animation.
## Removes all last controls.
func replace_information_control(controls: Array[Control]) -> void:
	# Create new scroll container
	var new_scroll_container = scroll_container_scene.instantiate()

	# Get old position of old scroll container
	var old_position = scroll_container.global_position
	var old_size = scroll_container.size

	# Move scroll container and set position and size
	scroll_container_parent.remove_child(scroll_container)
	add_child(scroll_container)
	scroll_container.global_position = old_position
	scroll_container.size = old_size

	# Remove all items from information_controls array
	information_controls.clear()
	last_controls.clear()

	# Play hide contents animation in old scroll container
	scroll_container.animation_player.play("hide_contents")

	# Set new scroll container as scroll container
	scroll_container_parent.add_child(new_scroll_container)
	scroll_container = new_scroll_container
	info_container = scroll_container.info_container

	# Move blue panel at last of the node list
	scroll_container_parent.move_child(blue_panel, 2)

	# Remove all children of the old info container and add controls to the new one
	for child in info_container.get_children():
		child.queue_free()
	for control in controls:
		add_information_control(control)

	# Add all controls to the array
	information_controls.append_array(controls)

	# Play show contents animation in new scroll container
	scroll_container.animation_player.play("show_contents")

func add_information_control(control: Control) -> void:
	information_controls.append(control)
	info_container.add_child(control)
	var index = len(information_controls)
	info_container.move_child(control, index)
	for counter in range(len(last_controls)):
		index += 1
		info_container.move_child(last_controls[counter], index)

func insert_information_control(control: Control, index: int) -> void:
	information_controls.insert(index, control)
	info_container.add_child(control)
	info_container.move_child(control, index)
	var last_control_index = len(information_controls)
	for counter in range(len(last_controls)):
		last_control_index += 1
		info_container.move_child(last_controls[counter], last_control_index)

func remove_information_control_index(index: int) -> Control:
	var control = information_controls[index]
	info_container.remove_child(control)
	control.queue_free()
	information_controls.remove_at(index)
	return control

func remove_information_control(control: Control) -> Control:
	control.queue_free()
	return control

func remove_all_information_controls() -> void:
	for control in information_controls:
		control.queue_free()
	information_controls.clear()
	for last_control in last_controls:
		last_control.queue_free()
	last_controls.clear()

func set_last_controls(controls: Array[Control]) -> void:
	for last_control in last_controls:
		if not controls.has(last_control):
			info_container.remove_child(last_control)
			last_control.queue_free()
	last_controls.clear()
	last_controls = controls
	var index = len(information_controls)
	for last_control in last_controls:
		if last_control.get_parent() != info_container:
			info_container.add_child(last_control)
		info_container.move_child(last_control, index)
		index += 1

func set_title(new_title: String) -> void:
	title = new_title
	title_label.text = title

func show_animation() -> void:
	if animation_player.is_playing():
		animation_player.stop(true)
	animation_player.play("show")
	is_hidden = false

## After this function called and animation finished, all the controls will be removed.
func hide_animation() -> void:
	animation_player.play("hide")
	is_hidden = true

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		remove_all_information_controls()

func get_hint_box(title_key: String, description_key: String) -> HintBox:
	var hint_box = hint_box_scene.instantiate()
	hint_box.anchor = HintBox.HintAnchor.LEFT
	hint_box.title_key = title_key
	hint_box.description_key = description_key
	hint_box.change_anchor_x = true
	hint_box.anchor_x = global_position.x + info_box.size.x / 2
	hint_box.offset = Vector2(size.x / 2.0 + 20.0, 0.0)
	hint_box.anchor = HintBox.HintAnchor.LEFT
	return hint_box
