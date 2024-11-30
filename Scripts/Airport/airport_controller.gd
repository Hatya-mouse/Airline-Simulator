extends Node3D

const database_path = "res://Resources/Airport_Database/airports.csv"
const country_database_path = "res://Resources/Country_Database/country_code.csv"

const airport_scene = preload("res://Scenes/Airport/airport.tscn")
const info_property_scene = preload("res://Scenes/UI/InfoBox/info_property.tscn")

const large_airport_icon = preload("res://Textures/Icon/Airport/large_airport.png")
const large_airport_icon_pressed = preload("res://Textures/Icon/Airport/large_airport_pressed.png")
const medium_airport_icon = preload("res://Textures/Icon/Airport/medium_airport.png")
const medium_airport_icon_pressed = preload("res://Textures/Icon/Airport/medium_airport_pressed.png")
const small_airport_icon = preload("res://Textures/Icon/Airport/small_airport.png")
const small_airport_icon_pressed = preload("res://Textures/Icon/Airport/small_airport_pressed.png")

@onready var earth: MeshInstance3D = %Earth
@onready var label: Label = %AirportNameLabel

@export var large_airport_button: TextureButton
@export var medium_airport_button: TextureButton
@export var small_airport_button: TextureButton
@export var info_box: InfoBox

var large_airport_visibility := false
var medium_airport_visibility := false
var small_airport_visibility := false

var country_code: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var airports = load_database(database_path)
	for airport in airports:
		add_airport(airport)
	country_code = get_country_code(country_database_path)

func _process(delta: float) -> void:
	large_airport_visibility = not large_airport_button.button_pressed
	medium_airport_visibility = not medium_airport_button.button_pressed
	small_airport_visibility = not small_airport_button.button_pressed

func show_info(data: Dictionary) -> void:
	info_box.remove_all_information_controls()
	info_box.add_infomation_contorol(info_node("ICAO_CODE", data["ident"]))
	info_box.add_infomation_contorol(info_node("IATA_CODE", data["iata_code"]))
	info_box.add_infomation_contorol(info_node("COUNTRY", get_country_name_from_alpha_2(data["iso_country"])))
	info_box.add_infomation_contorol(info_node("LATITUDE", data["latitude_deg"]))
	info_box.add_infomation_contorol(info_node("LONGITUDE", data["longitude_deg"]))
	info_box.set_title(data["name"])
	info_box.show_animation()

func info_node(tr_key: String, content: String) -> HBoxContainer:
	var node = info_property_scene.instantiate()
	node.label_text = tr(tr_key)
	node.content_text = content
	return node

func get_country_name_from_alpha_2(iso_alpha_2: String) -> String:
	return country_code[iso_alpha_2]

# Add airport node from airport data dictionary
func add_airport(airport: Dictionary):
	var airport_node = airport_scene.instantiate() as Node3D
	airport_node.name = airport["name"]

	var airport_offset = Vector3(0, 0, -100)
	var latitude := float(airport["latitude_deg"])
	var longitude := float(airport["longitude_deg"])

	airport_offset = airport_offset.rotated(Vector3.RIGHT, deg_to_rad(latitude))
	airport_offset = airport_offset.rotated(Vector3.UP, deg_to_rad(longitude))
	airport_offset = airport_offset.rotated(Vector3.RIGHT, deg_to_rad(23.4))

	airport_node.position = earth.global_position + airport_offset
	airport_node.label = label
	airport_node.type = airport["type"]
	airport_node.latitude = latitude
	airport_node.longitude = longitude
	airport_node.airport_data = airport
	airport_node.local_position = airport_offset

	airport_node.earth = earth

	if airport["type"].contains("large"):
		airport_node.icon = large_airport_icon
		airport_node.pressed_icon = large_airport_icon_pressed
	elif airport["type"].contains("medium"):
		airport_node.icon = medium_airport_icon
		airport_node.pressed_icon = medium_airport_icon_pressed
	elif airport["type"].contains("small"):
		airport_node.icon = small_airport_icon
		airport_node.pressed_icon = small_airport_icon_pressed

	add_child(airport_node)

# CSV reading utility functions
func load_database(path: String) -> Array:
	var file = FileAccess.open(path, FileAccess.READ)
	var airports := []
	var chart_line = file.get_line()
	var chart = read_csv_line(chart_line)

	while not file.eof_reached():
		var line = file.get_line()
		if not line.is_empty():
			var airport_data = read_airport(line, chart)
			var type: String = airport_data["type"]
			var scheduled_service: String = airport_data["scheduled_service"]
			if scheduled_service == "yes":
				if type.contains("airport"):
					airports.append(airport_data)

	print("Airport loaded.")
	return airports

func read_airport(data: String, chart: Array) -> Dictionary:
	var csv_array := read_csv_line(data)
	var dictionary: Dictionary = {}
	var counter = 0
	for item in chart:
		dictionary.get_or_add(item, csv_array[counter])
		counter += 1
	return dictionary

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

func read_csv_line(string: String) -> Array:
	var counter = 0
	var array := []
	var delimiter_count = string.count(",")
	while counter != delimiter_count:
		var index = string.find(",")
		if index == -1:
			index = 1
		var sliced_string = string.substr(0, index)
		string = string.substr(index + 1)
		array.append(remove_double_quotation(sliced_string))
		counter += 1
	array.append(remove_double_quotation(string))
	return array

func remove_double_quotation(string: String) -> String:
	return string.replace("\"", "")
