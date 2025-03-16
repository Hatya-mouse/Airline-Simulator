extends Control
class_name InfoBox

signal closed

const hint_box_scene = preload("res://Scenes/Objects/UI/Basic/Panel/hint_box.tscn")
const scroll_container_scene = preload("res://Scenes/Objects/UI/Basic/Panel/info_box_scroll_container.tscn")

const button_scene = preload("res://Scenes/Objects/UI/Basic/Button/text_button.tscn")
const checkbox_scene = preload("res://Scenes/Objects/UI/Basic/Button/check_box.tscn")
const property_scene = preload("res://Scenes/Objects/UI/Basic/Label/property_label.tscn")
const spacer_scene = preload("res://Scenes/Objects/UI/Basic/InfoBox/info_box_spacer.tscn")
const label_scene = preload("res://Scenes/Objects/UI/Basic/InfoBox/info_box_label.tscn")

@onready var title_label: Label = %TitleLabel
@onready var hide_button: TextureButton = %HideButton

@onready var info_box: PanelContainer = $InfoBox
@onready var title_container: PanelContainer = $InfoBox/VBoxContainer/PanelContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var scroll_container_parent: VBoxContainer = $InfoBox/VBoxContainer
@onready var scroll_container: ScrollContainer = $InfoBox/VBoxContainer/ScrollContainer
@onready var blue_panel: Panel = $InfoBox/VBoxContainer/Panel

@onready var cancel_audio_player: AudioStreamPlayer = $CancelAudioPlayer

var info_container: VBoxContainer
var last_info_container: VBoxContainer

var title := ""
## Info content.
var content: Control
var is_hidden := true

var hide_button_disabled := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	info_container = scroll_container.info_container

	title_container.material = title_container.material.duplicate()
	info_box.material = info_box.material.duplicate()

	title_label.text = title
	hide()

## Replace content with new content, and play transition animation.
func replace_content_animation(new_content: Control) -> void:
	# Create new scroll container
	var new_scroll_container = scroll_container_scene.instantiate()
	# Reparent the scroll container
	scroll_container.reparent(self)

	# Play hide contents animation in old scroll container
	scroll_container.animation_player.play("hide_contents")

	# Set new scroll container as scroll container
	scroll_container_parent.add_child(new_scroll_container)
	scroll_container = new_scroll_container
	info_container = scroll_container.info_container
	# Move blue panel at last of the node list
	scroll_container_parent.move_child(blue_panel, 2)

	## Set the content.
	set_content(new_content)

	# Play show contents animation in new scroll container
	scroll_container.animation_player.play("show_contents")

## Clear the content and replace it with new content (Control).
func set_content(new_content: Control) -> void:
	clear_content()
	info_container.add_child(new_content)
	content = new_content

## Clear the content.
func clear_content() -> void:
	# Remove the content.
	var children = info_container.get_children()
	for child in children:
		child.queue_free()
	# Set content to null.
	content = null

func set_title(new_title: String) -> void:
	title = new_title
	title_label.text = title

func show_animation() -> void:
	# Set hide button visible.
	hide_button.disabled = hide_button_disabled
	hide_button.visible = not hide_button_disabled
	# Play the show animation.
	if animation_player.is_playing():
		animation_player.stop(true)
	animation_player.play("show")
	is_hidden = false
	# Accept all events.
	mouse_filter = MOUSE_FILTER_STOP

## After this function called and animation finished, all the controls will be removed.
func hide_animation() -> void:
	animation_player.play("hide")
	is_hidden = true
	# Ignore all inputs from now.
	mouse_filter = MOUSE_FILTER_IGNORE

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		clear_content()

# Scene instantiating functions

func get_hint_box(title_key: String, description_key: String) -> HintBox:
	var hint_box = hint_box_scene.instantiate()
	hint_box.anchor = HintBox.HintAnchor.LEFT
	hint_box.title_key = title_key
	hint_box.description_key = description_key
	hint_box.change_anchor_x = true
	hint_box.anchor_x = global_position.x + info_box.size.x / 2
	hint_box.offset = Vector2(size.x / 2.0 + 10.0, 0.0)
	hint_box.anchor = HintBox.HintAnchor.LEFT
	return hint_box

func get_property_label(tr_key: String, tr_value: String) -> HBoxContainer:
	var node = property_scene.instantiate()
	node.label_text = tr(tr_key)
	node.content_text = tr(tr_value)
	return node

func get_info_label(tr_key: String) -> Label:
	var node = label_scene.instantiate()
	node.text = tr(tr_key)
	return node

func get_checkbox(tr_key: String) -> HBoxContainer:
	var node = checkbox_scene.instantiate()
	node.text = tr(tr_key)
	return node

func get_button(tr_key: String) -> MarginContainer:
	var node = button_scene.instantiate()
	node.text = tr(tr_key)
	return node

func get_spacer() -> Control:
	var spacer = spacer_scene.instantiate()
	return spacer

func _on_hide_button_pressed() -> void:
	closed.emit()
	cancel_audio_player.play()
	hide_animation()
