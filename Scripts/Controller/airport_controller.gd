extends Node

signal airport_visibility_changed(airport_type: bool)

const database_path = "res://Resources/Airport_Database/airports.txt"

const airport_scene = preload("res://Scenes/Objects/Objects/airport.tscn")

@onready var game_controller: GameController = %GameController
@onready var airline_controller: AirlineController = %AirlineController
@onready var airline_editor: AirlineEditor = %AirlineEditor
@onready var airport_ui: AirportUIManager = %AirportUIManager

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

var large_airport_visibility := false
var medium_airport_visibility := false
var small_airport_visibility := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var airports = load_database(database_path)
	for airport in airports:
		spawn_airport(airport)

	# Connect signals
	small_airport_button.pressed.connect(_small_airport_button_pressed)
	medium_airport_button.pressed.connect(_medium_airport_button_pressed)
	large_airport_button.pressed.connect(_large_airport_button_pressed)

func _small_airport_button_pressed() -> void:
	small_airport_visibility = not small_airport_button.button_pressed
	airport_visibility_changed.emit(AirportData.AirportType.SMALL_AIRPORT)

func _medium_airport_button_pressed() -> void:
	medium_airport_visibility = not medium_airport_button.button_pressed
	airport_visibility_changed.emit(AirportData.AirportType.MEDIUM_AIRPORT)

func _large_airport_button_pressed() -> void:
	large_airport_visibility = not large_airport_button.button_pressed
	airport_visibility_changed.emit(AirportData.AirportType.LARGE_AIRPORT)

## Add airport node from airport data dictionary.
func spawn_airport(airport: Dictionary) -> void:
	var airport_node = airport_scene.instantiate() as Airport
	airport_node.name = airport["ident"]

	var latitude := float(airport["latitude_deg"])
	var longitude := float(airport["longitude_deg"])
	var airport_offset := game_controller.get_position_on_earth(latitude, longitude)

	var airport_data := AirportData.new()

	airport_data.name = airport["name"]
	airport_data.latitude = latitude
	airport_data.longitude = longitude
	airport_data.iata = airport["iata_code"]
	airport_data.icao = airport["gps_code"]
	airport_data.identifier = airport["ident"]

	var airport_type: AirportData.AirportType
	match airport["type"]:
		"small_airport":
			airport_type = AirportData.AirportType.SMALL_AIRPORT
		"medium_airport":
			airport_type = AirportData.AirportType.MEDIUM_AIRPORT
		"large_airport":
			airport_type = AirportData.AirportType.LARGE_AIRPORT
	airport_data.type = airport_type

	airport_node.offset = airport_offset
	airport_node.label = airport_name_label
	airport_node.airport_data = airport_data

	airport_node.earth = game_controller.earth
	airport_node.game_controller = game_controller
	airport_node.airport_controller = self

	# Connect the "clicked" signal
	airport_node.clicked.connect(_on_airport_clicked)

	# Set the button icon.
	if airport_data.type == AirportData.AirportType.SMALL_AIRPORT:
		# Small airports
		airport_node.normal_icon = small_airport_icon
		airport_node.normal_with_airline_icon = small_airport_with_airline_icon
		airport_node.pressed_icon = small_airport_pressed_icon
		airport_node.pressed_with_airline_icon = small_airport_with_airline_pressed_icon
	elif airport_data.type == AirportData.AirportType.MEDIUM_AIRPORT:
		# Medium airports
		airport_node.normal_icon = medium_airport_icon
		airport_node.normal_with_airline_icon = medium_airport_with_airline_icon
		airport_node.pressed_icon = medium_airport_pressed_icon
		airport_node.pressed_with_airline_icon = medium_airport_with_airline_pressed_icon
	elif airport_data.type == AirportData.AirportType.LARGE_AIRPORT:
		# Large airports
		airport_node.normal_icon = large_airport_icon
		airport_node.normal_with_airline_icon = large_airport_with_airline_icon
		airport_node.pressed_icon = large_airport_pressed_icon
		airport_node.pressed_with_airline_icon = large_airport_with_airline_pressed_icon

	airport_parent.add_child(airport_node)

func _on_airport_clicked(airport_data: AirportData) -> void:
	if game_controller.mode == GameController.InGameMode.NORMAL:
		airport_ui.show_info(airport_data)
	elif game_controller.mode == GameController.InGameMode.AIRLINE:
		airline_editor.add_airport_to_airline(airport_data)

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
		if line.size() == chart.size():
			var airport_data = read_airport(line, chart)
			var type: String = airport_data["type"]
			var scheduled_service: String = airport_data["scheduled_service"]
			if scheduled_service == "yes":
				if type.contains("airport"):
					airports.append(airport_data)

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

func remove_double_quotation(string: String) -> String:
	return string.replace("\"", "")
