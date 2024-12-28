extends Node3D

signal airport_visibility_changed(airport_type: bool)

const database_path = "res://Resources/Airport_Database/airports.txt"

const airport_scene = preload("res://Scenes/Airport/airport.tscn")
const info_property_scene = preload("res://Scenes/UI/InfoBox/info_property.tscn")

# Airport Icons
# Large airport
const large_airport_icon = preload("res://Textures/Icon/Airport/large_airport.png")
const large_airport_pressed_icon = preload("res://Textures/Icon/Airport/large_airport_pressed.png")
const large_airport_with_airline_icon = preload("res://Textures/Icon/Airport/large_airport_with_airline.png")
const large_airport_pressed_with_airline_icon = preload("res://Textures/Icon/Airport/large_airport_with_airline_pressed.png")
# Medium airport
const medium_airport_icon = preload("res://Textures/Icon/Airport/medium_airport.png")
const medium_airport_pressed_icon = preload("res://Textures/Icon/Airport/medium_airport_pressed.png")
const medium_airport_with_airline_icon = preload("res://Textures/Icon/Airport/medium_airport_with_airline.png")
const medium_airport_pressed_with_airline_icon = preload("res://Textures/Icon/Airport/medium_airport_with_airline_pressed.png")
# Small airport
const small_airport_icon = preload("res://Textures/Icon/Airport/small_airport.png")
const small_airport_pressed_icon = preload("res://Textures/Icon/Airport/small_airport_pressed.png")
const small_airport_with_airline_icon = preload("res://Textures/Icon/Airport/small_airport_with_airline.png")
const small_airport_pressed_with_airline_icon = preload("res://Textures/Icon/Airport/small_airport_with_airline_pressed.png")

@onready var earth: MeshInstance3D = %Earth
@onready var airline_controller: Node3D = %AirlineController
@onready var game_controller: GameController = %GameController

var large_airport_button: TextureButton
var medium_airport_button: TextureButton
var small_airport_button: TextureButton
var info_box: InfoBox
var airport_name_label: LabelBox

var large_airport_visibility := false
var medium_airport_visibility := false
var small_airport_visibility := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	large_airport_button = game_controller.large_airport_button
	medium_airport_button = game_controller.medium_airport_button
	small_airport_button = game_controller.small_airport_button
	info_box = game_controller.info_box
	airport_name_label = game_controller.airport_name_label

	var airports = load_database(database_path)
	for airport in airports:
		add_airport(airport)

	# Connect signals
	small_airport_button.pressed.connect(_small_airport_button_pressed)
	medium_airport_button.pressed.connect(_medium_airport_button_pressed)
	large_airport_button.pressed.connect(_large_airport_button_pressed)

func _small_airport_button_pressed() -> void:
	airport_visibility_changed.emit("small_airport")

func _medium_airport_button_pressed() -> void:
	airport_visibility_changed.emit("medium_airport")

func _large_airport_button_pressed() -> void:
	airport_visibility_changed.emit("large_airport")

func _process(_delta: float) -> void:
	large_airport_visibility = not large_airport_button.button_pressed
	medium_airport_visibility = not medium_airport_button.button_pressed
	small_airport_visibility = not small_airport_button.button_pressed

func show_info(data: Dictionary) -> void:
	info_box.remove_all_information_controls()
	info_box.add_information_control(info_node("ICAO_CODE", data["ident"]))
	info_box.add_information_control(info_node("IATA_CODE", data["iata_code"]))
	#info_box.add_information_control(info_node("COUNTRY", get_country_name_from_alpha_2(data["iso_country"])))
	info_box.add_information_control(info_node("LATITUDE", data["latitude_deg"]))
	info_box.add_information_control(info_node("LONGITUDE", data["longitude_deg"]))
	info_box.set_title(data["name"])
	info_box.show_animation()

func info_node(tr_key: String, content: String) -> HBoxContainer:
	var node = info_property_scene.instantiate()
	node.label_text = tr(tr_key)
	node.content_text = content
	return node

func add_airway(airport: Airport) -> void:
	airline_controller.add_airport(airport)

## Add airport node from airport data dictionary.
func add_airport(airport: Dictionary) -> void:
	var airport_node = airport_scene.instantiate() as Node3D
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

	airport_node.earth = earth
	airport_node.game_controller = game_controller

	if airport["type"].contains("large"):
		airport_node.normal_icon = large_airport_icon
		airport_node.normal_with_airline_icon = large_airport_with_airline_icon
		airport_node.pressed_icon = large_airport_pressed_icon
		airport_node.pressed_with_airline_icon = large_airport_pressed_with_airline_icon
	elif airport["type"].contains("medium"):
		airport_node.normal_icon = medium_airport_icon
		airport_node.normal_with_airline_icon = medium_airport_with_airline_icon
		airport_node.pressed_icon = medium_airport_pressed_icon
		airport_node.pressed_with_airline_icon = medium_airport_pressed_with_airline_icon
	elif airport["type"].contains("small"):
		airport_node.normal_icon = small_airport_icon
		airport_node.normal_with_airline_icon = small_airport_with_airline_icon
		airport_node.pressed_icon = small_airport_pressed_icon
		airport_node.pressed_with_airline_icon = small_airport_pressed_with_airline_icon

	add_child(airport_node)

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
