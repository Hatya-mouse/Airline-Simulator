extends Node

signal airport_visibility_changed(airport_type: bool)

const database_path = "res://Resources/Airport_Database/airports.txt"

const airport_shader: Shader = preload("res://Shaders/Objects/airport_mesh.gdshader")

@onready var game_controller: GameController = %GameController
@onready var airline_controller: AirlineController = %AirlineController
@onready var airline_editor: AirlineEditor = %AirlineEditor
@onready var airport_ui: AirportUIManager = %AirportUIManager

@export_category("Airport Node")
@export var airport_parent: Node3D

# MultiMeshInstance3D and RayCast3D
var large_multimesh_instance := MultiMeshInstance3D.new()
var large_multimesh := MultiMesh.new()
var medium_multimesh_instance := MultiMeshInstance3D.new()
var medium_multimesh := MultiMesh.new()
var small_multimesh_instance := MultiMeshInstance3D.new()
var small_multimesh := MultiMesh.new()

var raycast := RayCast3D.new()

# Icons
@export_category("Icons")
@export_category("Normal Icons")
@export var large_airport_icon: Texture2D
@export var medium_airport_icon: Texture2D
@export var small_airport_icon: Texture2D

@export_category("Selected Icons")
@export var large_airport_selected_icon: Texture2D
@export var medium_airport_selected_icon: Texture2D
@export var small_airport_selected_icon: Texture2D

# Controls
@export_category("Controls")
@export var large_airport_button: TextureButton
@export var medium_airport_button: TextureButton
@export var small_airport_button: TextureButton
@export var airport_name_label: LabelBox

@onready var camera_pivot: Node3D = %CameraPivot

var large_airport_visibility := false
var medium_airport_visibility := false
var small_airport_visibility := false

# Array of the airport data
var airport_data_map := {}

# Airport materials
var large_material: ShaderMaterial
var medium_material: ShaderMaterial
var small_material: ShaderMaterial

func _ready() -> void:
	# Initialize all multimeshes, multimesh instances
	# and the raycast.
	# I really love Raycast launcher ;)
	_init_all_multimesh()
	_init_raycast()

	# Initialize the materials and the airports.
	_init_materials()
	_load_airports()

	# Add the multimesh instances and the raycast to the airport_parent.
	airport_parent.add_child(large_multimesh_instance)
	large_multimesh_instance.name = "LargeAirports"
	airport_parent.add_child(medium_multimesh_instance)
	medium_multimesh_instance.name = "MediumAirports"
	airport_parent.add_child(small_multimesh_instance)
	small_multimesh_instance.name = "SmallAirports"
	airport_parent.add_child(raycast)

func _init_all_multimesh() -> void:
	setup_multimesh(large_multimesh_instance, large_multimesh)
	setup_multimesh(medium_multimesh_instance, medium_multimesh)
	setup_multimesh(small_multimesh_instance, small_multimesh)

func setup_multimesh(multimesh_instance: MultiMeshInstance3D, multimesh: MultiMesh) -> void:
	# Create a PlaneMesh instance.
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(10, 10)

	# Set up the multimesh.
	multimesh.mesh = quad_mesh
	# Configure the multimesh to use Transform3D.
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	# Set the multimesh property of the multimesh instance
	# to the multimesh that has just set up.
	multimesh_instance.multimesh = multimesh

func _init_raycast() -> void:
	# Set up the raycast.
	raycast.collide_with_areas = true
	raycast.collide_with_bodies = false

func _init_materials() -> void:
	large_material = _create_material(large_airport_icon, large_airport_selected_icon)
	large_multimesh.mesh.surface_set_material(0, large_material)
	medium_material = _create_material(medium_airport_icon, medium_airport_selected_icon)
	medium_multimesh.mesh.surface_set_material(0, medium_material)
	small_material = _create_material(small_airport_icon, small_airport_selected_icon)
	small_multimesh.mesh.surface_set_material(0, small_material)

func _create_material(texture: Texture2D, selected_texture: Texture2D) -> ShaderMaterial:
	var material = ShaderMaterial.new()
	material.shader = airport_shader
	material.set_shader_parameter("normal_texture", texture)
	material.set_shader_parameter("selected_texture", selected_texture)
	return material

## Load all the airports.
## Create multimesh instances and get the airport data from the database.
func _load_airports() -> void:
	# Load the airport database.
	var airports = load_database(database_path)
		
	# Set the instance count.
	small_multimesh.instance_count = airports.size()
	medium_multimesh.instance_count = airports.size()
	large_multimesh.instance_count = airports.size()

	for i in range(airports.size()):
		var airport = airports[i]
		var latitude := float(airport["latitude_deg"])
		var longitude := float(airport["longitude_deg"])
		var airport_offset := game_controller.get_position_on_earth(latitude, longitude) * 1.02

		# Set the multimesh transform.
		var transform = Transform3D(Basis(), airport_offset)

		# Apply the material depending on the airort type, and get the airport type.
		var airport_type: AirportData.AirportType
		match airport["type"]:
			"small_airport":
				small_multimesh.set_instance_transform(i, transform)
				# Pass the airport type.
				airport_type = AirportData.AirportType.SMALL_AIRPORT
			"medium_airport":
				medium_multimesh.set_instance_transform(i, transform)
				# Pass the airport type.
				airport_type = AirportData.AirportType.MEDIUM_AIRPORT
			"large_airport":
				large_multimesh.set_instance_transform(i, transform)
				# Pass the airport type.
				airport_type = AirportData.AirportType.LARGE_AIRPORT

		# Append the airport data to the airport_data_map.
		var airport_data = AirportData.new()
		airport_data.name = airport["name"]
		airport_data.latitude = latitude
		airport_data.longitude = longitude
		airport_data.iata = airport["iata_code"]
		airport_data.icao = airport["gps_code"]
		airport_data.identifier = airport["ident"]
		airport_data.type = airport_type
		airport_data_map[i] = airport_data

func _physics_process(_delta: float) -> void:
	var cam_transform = camera_pivot.transform
	large_material.set_shader_parameter("camera_transform", cam_transform)
	medium_material.set_shader_parameter("camera_transform", cam_transform)
	small_material.set_shader_parameter("camera_transform", cam_transform)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var from = game_controller.camera.project_ray_origin(event.position)
		var to = from + game_controller.camera.project_ray_normal(event.position) * 1000

		raycast.global_transform.origin = from
		raycast.target_position = to
		raycast.force_raycast_update()

		if raycast.is_colliding():
			var instance_id = raycast.get_collider_shape()
			if instance_id != -1 and instance_id in airport_data_map:
				_on_airport_clicked(airport_data_map[instance_id])

func _on_airport_clicked(airport_data: AirportData) -> void:
	print(airport_data.name)
	if game_controller.mode == GameController.InGameMode.NORMAL:
		airport_ui.show_info(airport_data)
	elif game_controller.mode == GameController.InGameMode.AIRLINE:
		airline_editor.add_airport_to_airline(airport_data)

func _small_airport_button_pressed() -> void:
	small_airport_visibility = not small_airport_button.button_pressed
	airport_visibility_changed.emit(AirportData.AirportType.SMALL_AIRPORT)

func _medium_airport_button_pressed() -> void:
	medium_airport_visibility = not medium_airport_button.button_pressed
	airport_visibility_changed.emit(AirportData.AirportType.MEDIUM_AIRPORT)

func _large_airport_button_pressed() -> void:
	large_airport_visibility = not large_airport_button.button_pressed
	airport_visibility_changed.emit(AirportData.AirportType.LARGE_AIRPORT)

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
