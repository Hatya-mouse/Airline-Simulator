extends Node
class_name AirlineEditor

const editor_ui_scene = preload("res://Scenes/UI/airline_editor_ui.tscn")
const property_editor_ui_scene = preload("res://Scenes/UI/airline_property_editor_ui.tscn")

const airport_list_scene = preload("res://Scenes/Control/InfoBox/info_airport_list.tscn")
const airline_scene = preload("res://Scenes/Airport/airline.tscn")

@onready var game_controller: GameController = %GameController
@onready var airline_controller: AirlineController = %AirlineController

@onready var remove_airport_audio_player: AudioStreamPlayer = $SFX/RemoveAirportAudioPlayer
@onready var complete_airline_audio_player: AudioStreamPlayer = $SFX/CompleteAirlineAudioPlayer

@export_category("Controls")
@export var create_airline_button: TextureToggleButton
@export_category("SFX")
@export var remove_airport_sound: AudioStream
@export var complete_airline_sound: AudioStream

var editor_ui: AirlineEditorUI
var property_editor_ui: AirlinePropertyEditorUI

var info_box: InfoBox

var editing_airline: Array[Airport] = []

# Properties
var back_to_first: bool = false
var one_way: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get info box from the GameController
	info_box = game_controller.info_box

	# Connect the button signal
	create_airline_button.toggled.connect(_on_create_airline_button_pressed)

	# Set the audio streams
	remove_airport_audio_player.stream = remove_airport_sound
	complete_airline_audio_player.stream = complete_airline_sound

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# ——— Airline Editor ———

func _on_create_airline_button_pressed(toggled_on: bool) -> void:
	if toggled_on: # Start creating the airline
		# Set the game mode to AIRLINE
		game_controller.mode = GameController.InGameMode.AIRLINE
		# Reset
		reset()
		# Set up the info box
		setup_infobox()
		# Show the info box
		info_box.show_animation()
		# Update airport list to show "Click the airport to add"
		update_list()
	else: # Creation canceled
		# Set the game mode to NORMAL
		game_controller.mode = GameController.InGameMode.NORMAL
		# Hide the info box
		info_box.hide_animation()

func reset() -> void:
	# Clear the editing_airline array
	editing_airline.clear()
	# Set properties
	back_to_first = false
	one_way = false

## Set up the info box for step 1 airline editor.
func setup_infobox() -> void:
	# Instantiate the EditorUI
	editor_ui = editor_ui_scene.instantiate()

	# Connect the signals for step 1
	editor_ui.back_to_first_toggled.connect(_on_back_to_first_toggled)
	editor_ui.one_way_toggled.connect(_on_one_way_toggled)
	editor_ui.next_button_pressed.connect(_on_next_button_pressed)

	# Set the game controller of editor ui
	editor_ui.game_controller = game_controller

	# Set the title of info box
	info_box.set_title(tr("CREATE_AIRLINE"))

	# Remove all information controls and add the editor ui
	info_box.clear_information_controls()
	info_box.set_last_controls([editor_ui])

# ——— Step 1 (Airline Editor) ———

func add_airport_to_airline(airport: Airport) -> void:
	# Add the airort to the editing airline array
	editing_airline.append(airport)
	# Update the airline state
	airport.set_airline_editor_selected(true)
	# Update the airline list
	update_list()
	# Update the preview airline
	update_preview()

func remove_airport_from_airline(index: int) -> void:
	if editing_airline.size() > index:
		# Update the airline state before removing it from the editing_airline array
		editing_airline[index].set_airline_editor_selected(false)
		# Remove the airport from the editing airline array
		editing_airline.remove_at(index)
	# Update the airline list
	update_list()
	# Update the preview airline
	update_preview()

## Clear old preview airlines and add a updated preview airline.
func update_preview() -> void:
	# Instantiate airline
	var airline = create_airline()
	if airline:
		# Set is_preview true to blink airline
		# and prevent airline from spawning airport
		airline.is_preview = true
		# Add airline as a preview
		airline_controller.set_preview(airline)

func update_list() -> void:
	# Clear the airport list
	info_box.clear_controls_except_last()

	# Check if editing_airline is empty
	if editing_airline.is_empty():
		info_box.add_information_control(info_box.get_info_label("CLICK_ON_THE_AIRPORT"))
	else:
		var counter = 0
		for airport in editing_airline:
			# Get airport list item
			var airport_list_item = get_airport_control(airport, counter)
			# Add it to the info box
			info_box.add_information_control(airport_list_item)
			# Increase the counter
			counter += 1

		if back_to_first:
			# Add first airport at last if back_to_first if true
			var last_airport_list_item = get_airport_control(editing_airline[0], counter, true)
			info_box.add_information_control(last_airport_list_item)

# Signals

func _on_remove_airport(index: int) -> void:
	# Remove the airport
	remove_airport_from_airline(index)
	# Play the remove sound
	remove_airport_audio_player.play()

func _on_back_to_first_toggled(toggled_on: bool) -> void:
	back_to_first = toggled_on
	# Update the preview airline
	update_list()
	update_preview()

func _on_one_way_toggled(toggled_on: bool) -> void:
	one_way = toggled_on
	# Update the preview airline
	update_preview()

func _on_next_button_pressed() -> void:
	# Move to the step 2
	# Instantiate the controls of step 2
	property_editor_ui = property_editor_ui_scene.instantiate()
	# Connect the signal
	property_editor_ui.complete_airline.connect(_on_complete_button_pressed)
	# Set the game controller of property editor ui
	property_editor_ui.game_controller = game_controller
	# Play the replace animation
	info_box.animate_information_control([property_editor_ui])

# ——— Step 2 (Property Editor) ———

## Add the airline and exit the airline editing mode.
func complete_airline() -> void:
	# Clear preview airlines
	airline_controller.clear_preview()

	# Instantiate the airline scene
	var airline = create_airline()
	if airline:
		# Add the airline to the airline controller
		airline_controller.add_airline(airline)

	# Set the mode to NORMAL
	game_controller.mode = GameController.InGameMode.NORMAL
	# ...and hide the info box
	info_box.hide_animation()
	# Play airline complete sound
	complete_airline_audio_player.play()

	# Toggle create airline button
	create_airline_button.toggle(false)

# Signals

func _on_complete_button_pressed() -> void:
	complete_airline()

# Utility functions

## Generate airline node from the editing_airline array.
## Doesn't add airline as a child of a node, so you need to
## add it yourself.
func create_airline() -> Airline:
	if editing_airline.is_empty():
		return

	# Instantiate the airline scene.
	var airline = airline_scene.instantiate()

	# Set the node name of the airline.
	# Example: HND_ITM
	var route_string = []
	for airport in editing_airline:
		route_string.append(airport.get_ident())
	airline.name = "_".join(route_string)

	# Set some properties of airline node.
	airline.game_controller = game_controller

	# Pass the airports.
	# We need to duplicate the array in order to
	# preserve Airline.airports from modified by
	# modifying editing_airline.
	airline.airports = editing_airline.duplicate()

	# Set some properties.
	airline.back_to_first = back_to_first
	airline.one_way = one_way

	return airline

## Return airport control (which is used in airport list).
func get_airport_control(airport: Airport, index: int, auto_added: bool = false) -> Control:
	# Instantiate the airport list scene
	var airport_list = airport_list_scene.instantiate()

	# Set the properties
	airport_list.airport_name = airport.airport_data["name"]
	airport_list.airport_type = airport.airport_data["type"]
	airport_list.airport_icao = airport.get_icao_code()
	airport_list.airport_iata = airport.get_iata_code()
	airport_list.auto_added = auto_added
	airport_list.airport_index = index

	# Connect the clicked signal
	airport_list.connect("clicked", _on_remove_airport)

	# Return the generated airport
	return airport_list
