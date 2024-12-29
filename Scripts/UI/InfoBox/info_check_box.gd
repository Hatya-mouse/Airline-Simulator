extends HBoxContainer

signal toggled(toggled_on: bool)

@onready var label: Label = $Label
@onready var toggle_button: TextureToggleButton = $TextureToggleButton

@export var text := ""
@export var click_sound: AudioStream

var is_pressed := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = text
	toggle_button.click_sound = click_sound

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	label.text = text
	

func toggle(on: bool) -> void:
	toggle_button.toggle(on)

func _gui_input(event: InputEvent) -> void:
	if event == InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			toggle_button.button_pressed = not toggle_button.button_pressed

func _on_button_toggled(toggled_on: bool) -> void:
	is_pressed = toggled_on
	toggled.emit(toggled_on)
