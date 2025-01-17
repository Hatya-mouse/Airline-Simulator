extends Node

signal airport_visibility_changed(airport_type: bool)

const database_path = "res://Resources/Airport_Database/airports.txt"

const airport_scene = preload("res://Scenes/Airport/airport.tscn")

@onready var game_controller: GameController = %GameController
@onready var airline_controller: AirlineController = %AirlineController
@onready var airline_editor: AirlineEditor = %AirlineEditor

@export_category("Airport Node")
@export var airport_parent: Node3D

# Airport Icons
# Large airport
@export_category("Large Airports")
@export var large_airport_icon: Texture2D
@export var large_airport_pressed_icon: Texture2D
@export var large_airport_with_airline_icon: Texture2D
@export var large_airport_with_airline_pressed_icon: Texture2D
# Medium airport
@export_category("Medium Airports")
@export var medium_airport_icon: Texture2D
@export var medium_airport_pressed_icon: Texture2D
@export var medium_airport_with_airline_icon: Texture2D
@export var medium_airport_with_airline_pressed_icon: Texture2D
# Small airport
@export_category("Small Airports")
@export var small_airport_icon: Texture2D
@export var small_airport_pressed_icon: Texture2D
@export var small_airport_with_airline_icon: Texture2D
@export var small_airport_with_airline_pressed_icon: Texture2D

@export_category("Controls")
@export var large_airport_button: TextureButton
@export var medium_airport_button: TextureButton
@export var small_airport_button: TextureButton
@export var airport_name_label: LabelBox

var info_box: InfoBox

var large_airport_visibility := false
var medium_airport_visibility := false
var small_airport_visibility := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	info_box = game_controller.info_box

	var airports = load_database(database_path)
	for airport in airports:
		spawn_airport(airport)

	# Connect signals
	small_airport_button.pressed.connect(_small_airport_button_pressed)
	medium_airport_button.pressed.connect(_medium_airport_button_pressed)
	large_airport_button.pressed.connect(_large_airport_button_pressed)

func _process(_delta: float) -> void:
	large_airport_visibility = not large_airport_button.button_pressed
	medium_airport_visibility = not medium_airport_button.button_pressed
	small_airport_visibility = not small_airport_button.button_pressed

func _small_airport_button_pressed() -> void:
	airport_visibility_changed.emit("small_airport")

func _medium_airport_button_pressed() -> void:
	airport_visibility_changed.emit("medium_airport")

func _large_airport_button_pressed() -> void:
	airport_visibility_changed.emit("large_airport")

## Add airport node from airport data dictionary.
func spawn_airport(airport: Dictionary) -> void:
	var airport_node = airport_scene.instantiate() as Airport
	airport_node.name = airport["ident"]

	var latitude := float(airport["latitude_deg"])
	var longitude := float(airport["longitude_deg"])
	var airport_offset = game_controller.get_position_on_earth(latitude, longitude)

	airport_node.offset = airport_offset
	airport_node.label = airport_name_label
	airport_node.type = airport["type"]
	airport_node.latitude = latitude
	airport_node.longitude = longitude
	airport_node.airport_data = airport

	airport_node.earth = game_controller.earth
	airport_node.game_controller = game_controller
	airport_node.airport_controller = self

	# Connect the "clicked" signal
	airport_node.clicked.connect(_on_airport_clicked)

	if airport["type"].contains("large"):
		airport_node.normal_icon = large_airport_icon
		airport_node.normal_with_airline_icon = large_airport_with_airline_icon
		airport_node.pressed_icon = large_airport_pressed_icon
		airport_node.pressed_with_airline_icon = large_airport_with_airline_pressed_icon
	elif airport["type"].contains("medium"):
		airport_node.normal_icon = medium_airport_icon
		airport_node.normal_with_airline_icon = medium_airport_with_airline_icon
		airport_node.pressed_icon = medium_airport_pressed_icon
		airport_node.pressed_with_airline_icon = medium_airport_with_airline_pressed_icon
	elif airport["type"].contains("small"):
		airport_node.normal_icon = small_airport_icon
		airport_node.normal_with_airline_icon = small_airport_with_airline_icon
		airport_node.pressed_icon = small_airport_pressed_icon
		airport_node.pressed_with_airline_icon = small_airport_with_airline_pressed_icon

	airport_parent.add_child(airport_node)

func _on_airport_clicked(airport: Airport) -> void:
	if game_controller.mode == GameController.InGameMode.NORMAL:
		show_info(airport)
	elif game_controller.mode == GameController.InGameMode.AIRLINE:
		airline_editor.add_airport_to_airline(airport)

func show_info(airport: Airport) -> void:
	var airport_data = airport.airport_data

	# Add airport data text information control
	info_box.clear_information_controls()
	info_box.set_title(airport_data["name"])
	info_box.add_information_control(info_box.get_property_label("ICAO_CODE", airport.get_icao_code()))
	info_box.add_information_control(info_box.get_property_label("IATA_CODE", airport.get_iata_code()))
	info_box.add_information_control(info_box.get_property_label("LATITUDE", airport_data["latitude_deg"]))
	info_box.add_information_control(info_box.get_property_label("LONGITUDE", airport_data["longitude_deg"]))

	# Add airline list header
	var header_contents: PackedStringArray = ["Airline", "Passengers"]
	var header_alignment: Array[HorizontalAlignment] = [HORIZONTAL_ALIGNMENT_LEFT, HORIZONTAL_ALIGNMENT_RIGHT]
	info_box.add_information_control(info_box.get_list_header(header_contents, header_alignment))

	# Add airline list
	for airline in airline_controller.get_airlines_for_airport(airport.airport_data["ident"]):
		var airline_list_item = info_box.get_airline_list_node(airline, 0)
		airline_list_item.selected_airport = airport
		info_box.add_information_control(airline_list_item)

	# Play show animation
	info_box.show_animation()

## Move the airport control forward.
func move_forward(airport: Airport) -> void:
	airport_parent.move_child(airport, airport_parent.get_child_count())

# CSV reading utility functions
func load_database(path: String) -> Array:
	var file = FileAccess.open(path, FileAccess.READ)
	var airports := []
	#var chart_line = file.get_line()
	#var chart = read_csv_line(chart_line)
	var chart = file.get_csv_line()

	while not file.eof_reached():
		var line = file.get_csv_line()
		if len(line) == len(chart):
			var airport_data = read_airport(line, chart)
			var type: String = airport_data["type"]
			var scheduled_service: String = airport_data["scheduled_service"]
			if scheduled_service == "yes":
				if type.contains("airport"):
					airports.append(airport_data)

	print("Airport loaded.")
	return airports

func read_airport(data: PackedStringArray, chart: Array) -> Dictionary:
	#var csv_array := read_csv_line(data)
	var dictionary: Dictionary = {}
	var counter = 0
	for item in chart:
		dictionary.get_or_add(item, data[counter])
		counter += 1
	return dictionary

func get_airport(airport_icao: String) -> Airport:
	return get_node(airport_icao)

func get_country_code(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var table = file.get_csv_line()
	var full_name_index = table.find("country_name")
	var alpha_2_index = table.find("alpha_2")
	var dictionary: Dictionary = {}
	while not file.eof_reached():
		var line = file.get_csv_line()
		dictionary.get_or_add(line[alpha_2_index], line[full_name_index])
	return dictionary

#func read_csv_line(string: String) -> Array:
	#var counter = 0
	#var array := []
	#var delimiter_count = string.count(",")
	#while counter != delimiter_count:
		#var index = string.find(",")
		#if index == -1:
			#index = 1
		#var sliced_string = string.substr(0, index)
		#string = string.substr(index + 1)
		#array.append(remove_double_quotation(sliced_string))
		#counter += 1
	#array.append(remove_double_quotation(string))
	#return array

func remove_double_quotation(string: String) -> String:
	return string.replace("\"", "")
