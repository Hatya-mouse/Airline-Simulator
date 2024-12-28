extends Node3D

const airway_scene = preload("res://Scenes/Airport/airway.tscn")
const airline_scene = preload("res://Scenes/Airport/airline.tscn")
const info_airport_list = preload("res://Scenes/UI/InfoBox/info_airport_list.tscn")
const info_button = preload("res://Scenes/UI/InfoBox/info_button.tscn")
const info_check_box = preload("res://Scenes/UI/InfoBox/info_check_box.tscn")
const info_label = preload("res://Scenes/UI/InfoBox/info_label.tscn")
const info_label_settings = preload("res://UIResources/LabelSettings/box_property_label.tres")

@onready var game_controller: GameController = %GameController
@onready var airplane_controller: AirplaneController = %AirplaneController
@onready var airport_controller: Node3D = %AirportController
@onready var preview_parent: Node3D = $Preview
@onready var remove_airport_audio_player: AudioStreamPlayer = $SFX/RemoveAirportAudioPlayer
@onready var complete_airline_audio_player: AudioStreamPlayer = $SFX/CompleteAirlineAudioPlayer

@export var remove_airport_sound: AudioStream
@export var complete_airline_sound: AudioStream

var earth: MeshInstance3D
var info_box: InfoBox

## 0: Add airline, 1: Airline settings
var create_step := 0

# Airline making control buttons
var add_airline_button
var back_first_button
var way_back_button
var complete_airline_button
var click_label

var way_back := false

# Airway is a node that shows the path from one airport to another airport.
# Airline is a set of airway(s).
var airlines: Array[Airline] = []
var editing_airline: Array[Airport] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	earth = game_controller.earth
	info_box = game_controller.info_box
	add_airline_button = game_controller.add_airline_button

	add_airline_button.connect("toggled", _on_create_airline_button_pressed)

	# Set audio streams
	remove_airport_audio_player.stream = remove_airport_sound
	complete_airline_audio_player.stream = complete_airline_sound

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Utility functions

## Load airline from array of ICAO airport codes, and some other airline datas.
func load_airline_from_data(airport_icaos: Array[String]) -> void:
	var airports: Array[Airport] = []
	for icao in airport_icaos:
		airports.append(airport_controller.get_airport(icao))
	spawn_airline(false, airports)

# ----- [ AIRLINE EDITOR ] -----

func _on_create_airline_button_pressed(toggled_on: bool) -> void:
	if toggled_on:
		create_step = 0
		setup_infobox()
		info_box.show_animation()
		game_controller.mode = GameController.InGameMode.AIRLINE
	else: # Cancel airline creation
		info_box.hide_animation()
		game_controller.mode = GameController.InGameMode.NORMAL
		for airport in editing_airline:
			airport.set_airline_editor_selected(false)

	editing_airline.clear()

	# Remove preview childs
	var preview_childs = preview_parent.get_children()
	for child in preview_childs:
		child.queue_free()

func _on_complete_airline() -> void:
	if create_step == 0:
		way_back = way_back_button.is_pressed
		info_box.replace_information_control(set_up_preference_info_box())
		create_step = 1

	elif create_step == 1:
		# Hide all preview airlines
		var preview_childs = preview_parent.get_children()
		for child in preview_childs:
			child.queue_free()

		# Complete airline and spawn airways
		complete_airline(editing_airline)
		# If way back button is pressed, generate way back too
		if way_back:
			var inverted_airline_array = editing_airline
			inverted_airline_array.reverse()
			complete_airline(inverted_airline_array)

		game_controller.mode = GameController.InGameMode.NORMAL
		add_airline_button.button_pressed = false

# ----- [ Step 1 ] -----

func setup_infobox() -> void:
	info_box.remove_all_information_controls()

	# "Click on the airport to add" label
	click_label = info_label.instantiate()
	click_label.text = tr("CLICK_ON_THE_AIRPORT")
	click_label.label_settings = info_label_settings

	# Back to the first airport button
	back_first_button = info_check_box.instantiate()
	back_first_button.text = tr("BACK_TO_FIRST_AIRPORT")
	back_first_button.toggled.connect(_on_back_to_first_toggled)
	# Add hint box
	var back_first_button_hint = info_box.get_hint_box("BACK_TO_FIRST_AIRPORT", "BACK_TO_FIRST_AIRPORT_DESCRIPTION")
	back_first_button_hint.collider = back_first_button
	game_controller.hint_box_parent.add_child(back_first_button_hint)

	# Generate way back button
	way_back_button = info_check_box.instantiate()
	way_back_button.text = tr("CREATE_WAY_BACK")
	# Add hint box
	var way_back_button_hint = info_box.get_hint_box("CREATE_WAY_BACK", "CREATE_WAY_BACK_DESCRIPTION")
	way_back_button_hint.collider = way_back_button
	game_controller.hint_box_parent.add_child(way_back_button_hint)

	# Next button
	complete_airline_button = info_button.instantiate()
	complete_airline_button.text = tr("NEXT")
	complete_airline_button.pressed.connect(_on_complete_airline)
	complete_airline_button.is_enabled = false

	info_box.set_last_controls([click_label, back_first_button, way_back_button, complete_airline_button])
	info_box.set_title(tr("CREATE_AIRLINE"))

func add_airport(airport: Airport) -> void:
	if create_step != 0:
		return

	# Set airline_editor_selected true to make it bright.
	airport.set_airline_editor_selected(true)

	var airport_data = airport.airport_data
	if back_first_button.is_pressed:
		if len(editing_airline) > 0:
			info_box.insert_information_control(get_airport_control(airport_data), len(editing_airline) - 1)
			editing_airline.insert(len(editing_airline) - 1, airport)
		else:
			info_box.add_information_control(get_airport_control(airport_data))
			# editing_airline array is an array of Airport class, so add airport as it is
			editing_airline.append(airport)
			# If "Back to the first airport" button is pressed, add the first airport
			var airport_control = get_airport_control(editing_airline[0].airport_data, true)
			info_box.add_information_control(airport_control)
			editing_airline.append(editing_airline[0])

		# Check if there are more than 1 airports
		if len(editing_airline) >= 3:
			complete_airline_button.is_enabled = true
	else:
		# Add airline info box to the list
		info_box.add_information_control(get_airport_control(airport_data))
		# editing_airline array is an array of Airport class, so add airport as it is
		editing_airline.append(airport)

		# Check if there are more than 1 airports
		if len(editing_airline) >= 2:
			complete_airline_button.is_enabled = true
	refresh_airport_index()

	# Hide the text "Click on the airport to add"
	click_label.hide()

	spawn_airline(true)

func _on_back_to_first_toggled(toggled_on: bool) -> void:
	if len(editing_airline) >= 1:
		if toggled_on:
			var airport_control = get_airport_control(editing_airline[0].airport_data, true)
			info_box.add_information_control(airport_control)
			editing_airline.append(editing_airline[0])
		else:
			# We need to remove airport from editing_airline array after removing it from info box
			# because if we remove it from editing_airline before removing it from info box,
			# length of editing_airline changes and it can decrease the readability.
			info_box.remove_information_control_index(len(editing_airline) - 1)
			editing_airline.remove_at(len(editing_airline) - 1)
		spawn_airline(true)

func _on_remove_airport(airport_index: int) -> void:
	remove_airport_audio_player.play()

	# Airport index is a number that is shown at the left of the airport list, which
	# starts from 1 (not 0), so we need to substract it by 1.
	if back_first_button.is_pressed:
		# Check if the selected index doesn't exceed the length of editing_airline
		if airport_index < len(editing_airline):
			# Remove the airport from the list and the infobox.
			var removed_airport = editing_airline[airport_index - 1]
			editing_airline.remove_at(airport_index - 1)
			info_box.remove_information_control_index(airport_index - 1)
			if len(editing_airline) > 1:
				# Since back_first_button is pressed, add the first airport
				# at the end of the list.
				editing_airline[len(editing_airline) - 1] = editing_airline[0]
				info_box.remove_information_control_index(len(editing_airline) - 1)
				var airport_control = get_airport_control(editing_airline[0].airport_data, true)
				info_box.add_information_control(airport_control)
			elif len(editing_airline) == 1:
				# Since back_first_button is pressed, we have to remove
				# the last airline, too.
				# Set airline_editor_selected false.
				editing_airline.remove_at(0)
				info_box.remove_information_control_index(0)
			# Check if editing_airline doesn't have removed airport to
			# prevent setting airline_editor_selected false
			# while editing_airline has more than one same airport.
			if not (removed_airport in editing_airline):
				removed_airport.set_airline_editor_selected(false)
	else:
		var removed_airport = editing_airline[airport_index - 1]
		# Remove the airport from the list and the infobox.
		editing_airline.remove_at(airport_index - 1)
		info_box.remove_information_control_index(airport_index - 1)
		# Check if editing_airline doesn't have removed airport to
		# prevent setting airline_editor_selected false
		# while editing_airline has more than one same airport.
		if not (removed_airport in editing_airline):
			removed_airport.set_airline_editor_selected(false)
	if len(editing_airline) == 0:
		click_label.show()
	elif len(editing_airline) < 2:
		complete_airline_button.is_enabled = false

	refresh_airport_index()
	spawn_airline(true)

func refresh_airport_index() -> void:
	var index := 1
	for airport_node in info_box.information_controls:
		airport_node.set_index(index)
		index += 1

## Return airport control (which is used in airport list)
func get_airport_control(airport: Dictionary, back_first: bool = false) -> Control:
	var info_airport = info_airport_list.instantiate()
	info_airport.airport_name = airport["name"]
	info_airport.airport_type = airport["type"]
	info_airport.airport_icao = airport["gps_code"]
	info_airport.airport_iata = airport["iata_code"]
	info_airport.airport_index = len(editing_airline)
	info_airport.connect("clicked", _on_remove_airport)
	if back_first:
		info_airport.airport_index += 1
		info_airport.airport_icao = tr("ADDED_AUTOMATICALLY")
		info_airport.airport_iata = ""
	return info_airport

# ----- [ Step 2 ] -----

## Set up preference info box which contains Complete button. 
func set_up_preference_info_box() -> Array[Control]:
	complete_airline_button = info_button.instantiate()
	complete_airline_button.text = tr("COMPLETE")
	complete_airline_button.connect("pressed", _on_complete_airline)
	complete_airline_button.is_enabled = true

	return [complete_airline_button]

## Spawn airline and set up airline data.
func complete_airline(airline_array: Array[Airport]) -> void:
	complete_airline_audio_player.play()

	spawn_airline(false, airline_array)

	# Define airline data
	# First, add airport data
	var airport_data_array: Array[Dictionary] = []
	for airport in airline_array:
		airport_data_array.append(airport.airport_data)

	# Make airline data dictionary
	var airline_data = {
		"AIRPORTS": airport_data_array
	}

	# Add airline data to every airport
	for airport in airline_array:
		# Set airline_editor_selected false
		airport.set_airline_editor_selected(false)
		airport.airlines.append(airline_data)
		airport.update_airlines_state()

## Instantiate airline from airport array
func instantiate_airline(airline_array: Array[Airport], play_animation: bool) -> Airline:
	# Instantiate airline node
	var airline = airline_scene.instantiate()
	airline.game_controller = game_controller
	airline.airplane_controller = airplane_controller

	# Add airports to the airline
	airline.airports = airline_array
	airline.play_animation = play_animation

	return airline

## If is_preview is true, remove all other preview airlines, and generate the preview airline with blink animation.
## You can provide airline_array to generate airline. If nothing is provided, this will use editing_airline property
## as airport array.
func spawn_airline(is_preview: bool = false, airline_array: Array[Airport] = []) -> void:
	# If it's preview, remove all previous preview airways
	if is_preview:
		var preview_childs = preview_parent.get_children()
		for child in preview_childs:
			child.queue_free()

	if airline_array == null or airline_array.is_empty():
		airline_array = editing_airline

	var airline = instantiate_airline(airline_array, is_preview)

	# Add instantiated airline to airlines node
	if is_preview:
		preview_parent.add_child(airline)
	else:
		airlines.append(airline)
		add_child(airline)
