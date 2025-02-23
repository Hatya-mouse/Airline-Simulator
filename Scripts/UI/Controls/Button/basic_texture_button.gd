extends TextureButton
class_name BasicTextureButton

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var default_texture: Texture2D
@export var focused_texture: Texture2D
@export var pressed_texture: Texture2D
@export var click_sound: AudioStream

@export var highlighted: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the pressed signal.
	pressed.connect(_on_pressed)
	# Set audio stream.
	audio_stream_player.stream = click_sound
	# Set textures.
	texture_normal = default_texture
	texture_focused = focused_texture
	texture_pressed = pressed_texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_pressed() -> void:
	audio_stream_player.play()

func toggle_highlight(value: bool) -> void:
	highlighted = value
	if highlighted:
		texture_normal = focused_texture
	else:
		texture_normal = default_texture
