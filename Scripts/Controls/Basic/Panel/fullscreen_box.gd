extends Control
class_name FullscreenBox

signal custom_button_pressed

@onready var content_parent: Control = $VBoxContainer/Content

@onready var custom_button: TextButton = %CustomButton
@onready var title_label: Label = %TitleLabel
@onready var hide_button: TextureButton = %HideButton

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hide_audio_player: AudioStreamPlayer = $HideAudioPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide the custom button.
	custom_button.hide()

## Set the panel title.
func set_title(title: String) -> void:
	title_label.text = title

## Set the panel content.
func set_content(control: Control) -> void:
	# Free all the children.
	for child in content_parent.get_children():
		child.queue_free()
	# Add the control as a child.
	content_parent.add_child(control)
	# Hide the custom button.
	custom_button.hide()
	# Disconnect all connections.
	for connection in custom_button_pressed.get_connections():
		custom_button_pressed.disconnect(connection["callable"])

func set_button(text: String) -> void:
	custom_button.show()
	custom_button.text = text

## Show the fullscreen box with animation.
func show_animation() -> void:
	animation_player.play("show")

## Hide the fullscreen box with animation.
func hide_animation() -> void:
	animation_player.play("hide")

func _on_hide_button_pressed() -> void:
	hide_audio_player.play()
	hide_animation()

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		# Free all the children.
		for child in content_parent.get_children():
			child.queue_free()

func _on_custom_button_pressed() -> void:
	custom_button_pressed.emit()
