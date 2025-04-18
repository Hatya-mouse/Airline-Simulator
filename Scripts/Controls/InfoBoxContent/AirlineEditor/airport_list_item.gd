extends InfoBoxItem
class_name InfoAirportListItem

## Index starts from 0.
signal removed(airport_index: int)
## Emitted when this started to be dragged.
signal dragged(sender: InfoAirportListItem)

@onready var color: PanelContainer = %ColorPanel
@onready var number: Label = %NumberLabel
@onready var name_label: Label = %NameLabel
@onready var code: Label = %CodeLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var remove_button: Button = %RemoveButton

# For drag preview
@onready var preview_background: PanelContainer = %PreviewBackground
@onready var preview_margin: MarginContainer = %PreviewMargin

@export var airport: AirportData
@export var auto_added := false
@export var airport_index: int = 0

var airline_editor: AirlineEditor
var info_box: InfoBox
var hud_parent: CanvasLayer

var is_editing: bool = false
var color_bar_style_box: StyleBoxFlat

var dragging: bool = false
var drag_offset: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get some informations from the airport
	var airport_name = airport.name
	var airport_type = airport.type
	var airport_icao = airport.get_icao_code()
	var airport_iata = airport.get_iata_code()

	var style_box = StyleBoxFlat.new()
	if airport_type == AirportData.AirportType.SMALL_AIRPORT:
		style_box.bg_color = GameConfig.small_color
	if airport_type == AirportData.AirportType.MEDIUM_AIRPORT:
		style_box.bg_color = GameConfig.medium_color
	if airport_type == AirportData.AirportType.LARGE_AIRPORT:
		style_box.bg_color = GameConfig.large_color
	color.add_theme_stylebox_override("panel", style_box)
	color_bar_style_box = style_box

	# Set the airport name and index label text
	if airport_index < 0:
		number.text = ""
	else:
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

	# Get the parent of the info_box
	hud_parent = info_box.get_parent()
	# Set the self modulate of preview background
	preview_background.self_modulate = Color("FFFFFF", 0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_index(index: int) -> void:
	airport_index = index
	number.text = str(airport_index)

func setup_preview() -> void:
	var old_position = global_position
	# Move the item to outside of the container.
	get_parent().remove_child(self)
	hud_parent.add_child(self)
	global_position = old_position

	dragged.emit(self)

	# Adjust z_index in order to show the list item forward.
	z_index = 1
	# Set is_editing true
	is_editing = true
	# Add background
	preview_background.show()
	preview_margin.add_theme_constant_override("margin_right", 5)
	# Set the corner radius of color panel
	color_bar_style_box.corner_radius_top_left = 5
	color_bar_style_box.corner_radius_bottom_left = 5
	# Hide remove button
	remove_button.hide()

func _on_button_pressed() -> void:
	removed.emit(airport_index)

func _gui_input(event: InputEvent) -> void:
	# Start of dragging
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			setup_preview()
			dragging = true
			drag_offset = event.position

func _input(event: InputEvent) -> void:
	# Called while dragging.
	if dragging and event is InputEventMouseMotion:
		if not is_queued_for_deletion():
			var mouse_position = get_global_mouse_position()
			# Move to the cursor.
			global_position = mouse_position - drag_offset
			# Show the drop highlight.
			airline_editor.highlight_drop_target(mouse_position)
			# Mark the event as handled.
			accept_event()

	# Called at the end of dragging.
	if dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			airline_editor.item_dropped(airport_index, get_global_mouse_position())
			# Remove this list item.
			queue_free()
