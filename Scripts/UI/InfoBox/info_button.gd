extends MarginContainer
class_name InfoButton

signal pressed

@onready var button: Button = $InfoButtonControl
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var text := ""
@export var is_enabled := true
@export var click_sound: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player.stream = click_sound

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	button.text = text
	button.disabled = not is_enabled

func _on_button_pressed() -> void:
	pressed.emit()
	audio_stream_player.play()
