extends Node
class_name GameController

signal tick
signal airline_visibility_updated

const earth_radius = 100.0

@onready var aircraft_controller: AircraftController = %AircraftController

@onready var timer: Timer = $Timer
@onready var utils: Utils = $Utils

@export_category("Scene")
@export var earth: MeshInstance3D
@export var info_box: InfoBox
@export var center_panel: CenterPanel
@export var fullscreen_box: FullscreenBox
@export var camera: Camera3D

@export_category("Basic UI Elements")
@export var money_label: Label
@export var hint_box_parent: Node

var mode: InGameMode = InGameMode.NORMAL:
	set(value):
		mode = value
		selected_airport = null
		airline_visibility_updated.emit()

enum InGameMode {
	NORMAL,
	AIRLINE
}

var delta_counter: float = 0.0
var money: int = 0

## Current selected (info box is shown) airport.
var selected_airport: AirportData

## Whether airlines are visible.
var route_visible := true:
	set(value):
		route_visible = value
		airline_visibility_updated.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	money_label.text = "$%s" % utils.add_commas(money)
	
	# Set the tick duration
	timer.wait_time = GameConfig.game_tick_duration

	%AirportController.large_airport_button.grab_focus()

	get_tree().root.content_scale_factor = 2.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_selected_airport(airport: AirportData) -> void:
	selected_airport = airport
	airline_visibility_updated.emit()

func earn(amount: int) -> void:
	money += amount
	money_label.text = "$%s" % utils.add_commas(money)

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

func _on_timer_timeout() -> void:
	tick.emit()

func format_money(value: float) -> String:
	var units := ["", "K", "M", "B", "T", "Q"]
	var unit_index := 0
	while value >= 1000 and unit_index < units.size() - 1:
		value /= 1000.0
		unit_index += 1
	return "$" + str(snapped(value, 0.1)) + units[unit_index]
