extends Panel
class_name CenterPanel

@onready var hide_audio_player: AudioStreamPlayer = $HideAudioPlayer
@onready var title_label: Label = %TitleLabel
@onready var content: Control = %Content
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

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

func show_animation() -> void:
	animation_player.play("show")

func hide_animation() -> void:
	animation_player.play("hide")

func _on_hide_button_pressed() -> void:
	hide_audio_player.play()
	hide_animation()
