extends Panel
class_name CenterPanel

signal custom_button_pressed

@onready var hide_audio_player: AudioStreamPlayer = $HideAudioPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var custom_button: TextButton = $CenterPanelContainer/VBoxContainer/Header/VBoxContainer/MarginContainer/HBoxContainer/CustomButton
@onready var title_label: Label = %TitleLabel
@onready var content: Control = %Content

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide the custom button.
	custom_button.hide()

## Set the panel title.
func set_title(title: String) -> void:
	title_label.text = title

## Replace the content with a new content.
func set_content(new_content: Control) -> void:
	# Clear the contents.
	var children = content.get_children()
	for child in children:
		child.queue_free()
	# Pass the center panel instance to the new content.
	new_content.set("center_panel", self)
	# Set a new content.
	content.add_child(new_content)
	# Hide the custom button.
	custom_button.hide()
	# Disconnect all connections.
	for connection in custom_button_pressed.get_connections():
		custom_button_pressed.disconnect(connection["callable"])

func set_button(text: String) -> void:
	custom_button.show()
	custom_button.text = text

func show_animation() -> void:
	animation_player.play("show")

func hide_animation() -> void:
	animation_player.play("hide")

func _on_hide_button_pressed() -> void:
	hide_audio_player.play()
	hide_animation()

func _on_custom_button_pressed() -> void:
	custom_button_pressed.emit()
