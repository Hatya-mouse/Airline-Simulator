extends VBoxContainer
class_name AirlinePropertyEditorUI

signal complete_airline

@onready var complete_button: MarginContainer = $CompleteButton
@onready var complete_airline_audio_player: AudioStreamPlayer = $SFX/CompleteAirlineAudioPlayer

@export var complete_audio_stream: AudioStream

var game_controller: GameController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	complete_button.text = tr("COMPLETE")
	# Connect the signal
	complete_button.pressed.connect(_on_complete_button_pressed)

	# Set the audio
	complete_airline_audio_player.stream = complete_audio_stream

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_complete_button_pressed() -> void:
	# Emit the signal
	complete_airline.emit()
	# Play the sound
	complete_airline_audio_player.play()
