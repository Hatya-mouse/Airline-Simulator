extends Node3D
class_name Airway

const shader_material = preload("res://Materials/Airway/airway.tres")
const airway_texture = preload("res://Textures/Model/Airline/airline_alpha.svg")
const arrow_texture = preload("res://Textures/Model/Airline/airline_arrow.svg")

const airline_texture_strech = 3.0
const mesh_width = 16.0

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var airway_mesh: ArrayMesh
var mesh_material: ShaderMaterial

var game_controller: GameController

# Start and end position in degrees
var start_latitude: float = 0.0
var start_longitude: float = 0.0
var end_latitude: float = 0.0
var end_longitude: float = 0.0

# Start and end position in vector 3d
var start_vector: Vector3
var end_vector: Vector3

var airway_length: float = 0.0

var path_texture: Texture2D

@export var is_editing := false

var edit_animation: float = 0.0

var color := Color()

# Flight information
var cruise_start_t: float
var descent_start_t: float
var cruise_altitude: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mesh_material != null:
		# Blink animation
		if is_editing:
			mesh_material.set_shader_parameter("alpha", smooth_step(edit_animation, 0.5))
			edit_animation += delta
			if edit_animation > 1:
				edit_animation = 0
		# Pass the distance to the camera to the shader
		var distance = game_controller.camera.position.z - 100
		var depth = distance / 500
		mesh_material.set_shader_parameter("depth", depth)

# /\/\/\/\/\/\
func smooth_step(t: float, t_max: float) -> float:
	var t_mod := fmod(t, t_max * 2)
	if t_mod < t_max:
		return t_mod / t_max
	return (t_max * 2 - t_mod) / t_max

func add_path(start_lat: float, start_lon: float, end_lat: float, end_lon: float) -> void:
	# Script below is based on this tutorial:
	# https://docs.godotengine.org/en/stable/tutorials/3d/procedural_geometry/arraymesh.html
	var mesh = ArrayMesh.new()
	var surface_array := []
	surface_array.resize(Mesh.ARRAY_MAX)
	var verts := PackedVector3Array()
	var uvs := PackedVector2Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()

	# Set arguments to local variables
	start_latitude = start_lat
	start_longitude = start_lon
	end_latitude = end_lat
	end_longitude = end_lon

	# Define vectors
	start_vector = game_controller.get_position_on_earth(start_lat, start_lon)
	end_vector = game_controller.get_position_on_earth(end_lat, end_lon)

	# Calculate the mesh subdivision amount
	var mesh_subdivision = ceil(slerp_distance(start_vector, end_vector, game_controller.earth_radius) / mesh_width) * 4
	if mesh_subdivision < 2:
		mesh_subdivision = 2

	var previous_uv_y = 0.0
	var uv_step: float = 1.0 / airline_texture_strech

	var idx = 0

	for counter in range(mesh_subdivision):
		var t = counter / (mesh_subdivision - 1)
		var height_multiply = 1.000 + simple_oscillation(0.02 * (start_vector - end_vector).length() / 150, t)
		var v = start_vector.slerp(end_vector, t) * height_multiply
		var spread_dir = calculate_cross_normal(start_vector, end_vector, t)
		var v0 = v + (spread_dir * mesh_width) / 2
		var v1 = v - (spread_dir * mesh_width) / 2
		verts.append_array([v1, v0, v0, v1])

		var normal = calculate_normal(start_vector, end_vector, t)
		for _i in range(4):
			normals.append(normal)

		uvs.append_array([Vector2(1, previous_uv_y), Vector2(0, previous_uv_y)])
		if previous_uv_y >= 1.0:
			previous_uv_y = 0.0
		uvs.append_array([Vector2(0, previous_uv_y), Vector2(1, previous_uv_y)])
		previous_uv_y += uv_step

		# Define triangles
		if idx > 0:
			indices.append_array([idx - 2, idx - 1, idx])
			indices.append_array([idx - 2, idx, idx + 1])
		idx = len(verts)

	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	# Set surface array
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

	# Set up the shader material
	var material = shader_material.duplicate()
	material.set_shader_parameter("line_texture", airway_texture)
	material.set_shader_parameter("arrow_texture", arrow_texture)
	material.set_shader_parameter("color", color)
	material.set_shader_parameter("move_direction", Vector2(0.0, 0.15))
	material.set_shader_parameter("is_preview", is_editing)
	mesh_material = material

	# Commit the material
	for c in mesh.get_surface_count():
		mesh.surface_set_material(c, material)

	# Commit the mesh to the MeshInstance
	mesh_instance.mesh = mesh
	airway_mesh = mesh

	# Set airway length
	airway_length = get_length()
	# Calculate flight data
	calculate_flight_data(0.2, 0.02 * airway_length / 150, 0.2)

# Flight route processing
func flight_altitude(t: float, height_addition: float = 0.0) -> Vector3:
	var height_multiply = 1.0 + height_addition + flight_oscillation(t)
	return start_vector.slerp(end_vector, t) * height_multiply

# Calculate some flight data (cruise altitude, etc.)
func calculate_flight_data(climb_rate: float = 0.5, cruise: float = 10000.0, descent_rate: float = 0.5, length: float = 1.0):
	# Cruising starts (Climbing ends) at
	cruise_start_t = cruise / climb_rate
	# Descending starts at
	descent_start_t = length - (cruise / descent_rate)
	cruise_altitude = cruise
	if cruise_start_t > 0.5:
		cruise_start_t = 0.5
		descent_start_t = 0.5
		cruise_altitude = climb_rate * cruise_start_t

# Realistic flight oscilation
func flight_oscillation(t: float) -> float:
	if t < cruise_start_t:
		return cruise_altitude * ease_in_out(t / cruise_start_t)
	elif t < descent_start_t:
		return cruise_altitude
	else:
		var descent_distance = 1 - descent_start_t
		return cruise_altitude * ease_in_out((1 - t) / descent_distance)

func get_length() -> float:
	return slerp_distance(start_vector, end_vector, game_controller.earth_radius)

# Utility functions
func quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float) -> Vector3:
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r

func calculate_normal(p0: Vector3, p1: Vector3, t: float, delta: float = 0.01) -> Vector3:
	var v = p0.slerp(p1, t)
	var shifted_v = p0.slerp(p1, t + delta)
	# Calculate the tangent vector
	var tangent = (shifted_v - v).normalized()
	# Calculate the normal vector
	var n = v.cross(tangent).normalized()
	# Rotate the vector
	#n = n.rotated(tangent, PI / 2)
	return n

func calculate_cross_normal(p0: Vector3, p1: Vector3, t: float, delta: float = 0.01) -> Vector3:
	var v = p0.slerp(p1, t)
	var shifted_v = p0.slerp(p1, t + delta)
	# Calculate the tangent vector
	var tangent = (shifted_v - v).normalized()
	# Calculate the normal vector
	var n = v.cross(tangent).normalized()
	return n

func slerp_distance(a: Vector3, b: Vector3, radius: float) -> float:
	var a_n = a.normalized()
	var b_n = b.normalized()
	var angle = acos(a_n.dot(b_n))
	return angle * radius

# Simple ease in out with t (0 <= t <= 1)
func ease_in_out(t: float) -> float:
	return (sin((t - 0.5) * PI) / 2) + 0.5

# Oscilation functions
func simple_oscillation(maximum: float, t: float) -> float:
	return maximum * sin(PI * t)
