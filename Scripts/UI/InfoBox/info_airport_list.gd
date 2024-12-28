extends MarginContainer

signal clicked(airport_index: int)

const large_color := Color(0.573, 0.231, 0.906, 1)
const medium_color := Color(0.106, 0.702, 0.702, 1)
const small_color := Color(0.867, 0.635, 0.00392, 1)

@onready var color: PanelContainer = $HStack/Color
@onready var number: Label = $HStack/Color/NumberMargin/Number
@onready var name_label: Label = $HStack/AirportInfo/Name
@onready var code: Label = $HStack/AirportInfo/Code
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var airport_name := ""
@export var airport_icao := ""
@export var airport_iata := ""
@export var airport_type := ""
@export var airport_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var style_box = StyleBoxFlat.new()
	if airport_type.contains("large"):
		style_box.bg_color = large_color
	if airport_type.contains("medium"):
		style_box.bg_color = medium_color
	if airport_type.contains("small"):
		style_box.bg_color = small_color
	color.add_theme_stylebox_override("panel", style_box)

	number.text = str(airport_index)
	name_label.text = airport_name

	var code_text := ""
	if not airport_icao.is_empty():
		code_text = airport_icao
	if not airport_iata.is_empty():
		code_text += " / " + airport_iata
	if code_text.is_empty():
		code.hide()
	code.text = code_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_index(index: int) -> void:
	airport_index = index
	number.text = str(airport_index)

func _on_button_pressed() -> void:
	clicked.emit(airport_index)
