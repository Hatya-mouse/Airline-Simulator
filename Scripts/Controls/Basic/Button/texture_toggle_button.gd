extends TextureButton
class_name TextureToggleButton

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

const hint_box_scene = preload("res://Scenes/Objects/UI/Basic/Panel/hint_box.tscn")

@export var default_texture: Texture2D
@export var focused_texture: Texture2D
@export var pressed_texture: Texture2D
@export var hide_default_texture := false
@export var click_sound: AudioStream

func _ready() -> void:
	texture_normal = default_texture
	texture_focused = focused_texture
	texture_pressed = pressed_texture
	audio_stream_player.stream = click_sound

func toggle(on: bool) -> void:
	button_pressed = on

func _on_toggled(_toggled_on: bool) -> void:
	if audio_stream_player:
		# Play sound
		if audio_stream_player.stream != null:
			audio_stream_player.play()
