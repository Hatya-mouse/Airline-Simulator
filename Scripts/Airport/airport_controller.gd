extends Node3D

var database_path = "res://Resources/Airport_Database/airports.csv"
const airport_scene = preload("res://Scenes/Airport/airport.tscn")

const large_airport_icon = preload("res://Textures/Airport/large_airport.png")
const medium_airport_icon = preload("res://Textures/Airport/medium_airport.png")
const small_airport_icon = preload("res://Textures/Airport/small_airport.png")

@onready var earth: MeshInstance3D = %Earth
@onready var label: Label = %Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var airports = load_database(database_path)
	for airport in airports:
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
		airport_node.local_position = airport_offset
		
		airport_node.earth = earth

		if airport["type"].contains("large"):
			airport_node.icon = large_airport_icon
		elif airport["type"].contains("medium"):
			airport_node.icon = medium_airport_icon
		elif airport["type"].contains("small"):
			airport_node.icon = small_airport_icon

		add_child(airport_node)
	print("Airport")

func load_database(path: String) -> Array:
	var file = FileAccess.open(path, FileAccess.READ)
	var airports := []
	var chart_line = file.get_line()
	var chart = read_csv_line(chart_line)

	while not file.eof_reached():
		var line_string = file.get_line()
		if not line_string.is_empty():
			var airport_data = read_airport(line_string, chart)
			var type: String = airport_data["type"]
			var scheduled_service: String = airport_data["scheduled_service"]
			if scheduled_service == "yes":
				if type.contains("airport"):
					airports.append(airport_data)

	print("Airport loaded.")
	return airports

func read_airport(data: String, chart: Array) -> Dictionary:
	var line_array = read_csv_line(data)
	var dictionary: Dictionary = {}
	var counter = 0
	for item in chart:
		dictionary.get_or_add(item, line_array[counter])
		counter += 1
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
