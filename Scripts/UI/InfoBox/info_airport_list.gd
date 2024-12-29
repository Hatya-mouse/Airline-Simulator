extends MarginContainer

## Index starts from 0.
signal clicked(airport_index: int)

@onready var color: PanelContainer = $HStack/Color
@onready var number: Label = $HStack/Color/NumberMargin/Number
@onready var name_label: Label = $HStack/AirportInfo/Name
@onready var code: Label = $HStack/AirportInfo/Code
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var airport_name := ""
@export var airport_icao := ""
@export var airport_iata := ""
@export var airport_type := ""
@export var auto_added := false
@export var airport_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var style_box = StyleBoxFlat.new()
	if airport_type.contains("large"):
		style_box.bg_color = GameConfig.large_color
	if airport_type.contains("medium"):
		style_box.bg_color = GameConfig.medium_color
	if airport_type.contains("small"):
		style_box.bg_color = GameConfig.small_color
	color.add_theme_stylebox_override("panel", style_box)

	# Set the airport name and index label text
	number.text = str(airport_index + 1)
	name_label.text = airport_name

	var code_text = ""
	if auto_added:
		code_text = tr("ADDED_AUTOMATICALLY")
	else:
		# Generate the code string using StringBuilder
		# Example: RJTT / HND
		var code_text_builder = []
		if not airport_icao.is_empty():
			code_text_builder.append(airport_icao)
		if not airport_iata.is_empty():
			code_text_builder.append(airport_iata)
		code_text = " / ".join(code_text_builder)

	# Set the code text
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
