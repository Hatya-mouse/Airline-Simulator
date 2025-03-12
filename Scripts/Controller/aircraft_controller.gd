extends Node
class_name AircraftController

const aircraft_type_data: AircraftList = preload("res://Resources/Aircraft/aircraft.tres")

@onready var game_controller: GameController = %GameController

@export var airplane_parent: Node3D

var aircraft_node: Array[AirplaneNode] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
