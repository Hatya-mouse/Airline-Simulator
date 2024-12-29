extends TextureButton
class_name TextureToggleButton

@onready var texture_rect: TextureRect = $Pressed_texture
@onready var animation_player: AnimationPlayer = $Pressed_texture/AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

const hint_box_scene = preload("res://Scenes/Control/hint_box.tscn")

@export var default_texture: Texture2D
@export var pressed_texture: Texture2D
@export var hide_default_texture := false
@export var click_sound: AudioStream

func _ready() -> void:
	texture_normal = default_texture
	texture_rect.texture = pressed_texture
	texture_rect.visible = button_pressed
	audio_stream_player.stream = click_sound

func toggle(on: bool) -> void:
	button_pressed = on

func _on_toggled(toggled_on: bool) -> void:
	if animation_player != null:
		var animation_name = ("toggle_on" if toggled_on else "toggle_off") + ("_default" if hide_default_texture else "")
		animation_player.play(animation_name)
		# Play sound
		if audio_stream_player.stream != null:
			audio_stream_player.play()
