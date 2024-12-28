extends Node3D
class_name GameController

signal tick

const earth_radius = 100.0

@onready var hint_box_parent: Node = $"../HUD/HintBox"

@export_category("Scene")
@export var earth: MeshInstance3D
@export var info_box: InfoBox
@export var camera: Camera3D

@export_category("Game System")
@export_range(0.1, 10.0) var game_tick_duration: float = 1.0

@export_category("Basic UI Elements")
@export var money_label: Label

@export_category("Airport Controller")
@export var large_airport_button: TextureButton
@export var medium_airport_button: TextureButton
@export var small_airport_button: TextureButton
@export var airport_name_label: LabelBox

@export_category("Airline Controller")
@export var add_airline_button: TextureToggleButton

var mode: InGameMode = InGameMode.NORMAL

enum InGameMode { NORMAL, AIRLINE }

var delta_counter: float = 0.0

var money: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	money_label.text = str(money)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	delta_counter += delta
	if delta_counter >= game_tick_duration:
		tick.emit()
		delta_counter = 0.0

func earn(amount: float) -> void:
	money += amount
	money_label.text = str(money)

func get_position_from_degrees(lat: float, lon: float) -> Vector3:
	var vector = Vector3(0, 0, -earth_radius)
	vector = vector.rotated(Vector3.RIGHT, deg_to_rad(lat))
	vector = vector.rotated(Vector3.UP, deg_to_rad(lon))
	vector = vector.rotated(Vector3.RIGHT, deg_to_rad(23.4))
	return vector

func get_position_on_earth(lat: float, lon: float) -> Vector3:
	var vector = Vector3(0, 0, -earth_radius)
	vector = vector.rotated(Vector3.RIGHT, deg_to_rad(lat))
	vector = vector.rotated(Vector3.UP, deg_to_rad(lon))
	return vector
