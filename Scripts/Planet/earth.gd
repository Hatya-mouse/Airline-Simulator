@tool
extends MeshInstance3D

@export var sun: Node3D
@export var cloud_rotation := 0.0

@onready var cloud: MeshInstance3D = %Cloud
@onready var atmos: Node3D = %PlanetAtmosphere

const material = preload("res://Materials/Planet/earth_material.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if sun != null:
		atmos.sun_path = sun.get_path()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if material != null && sun != null:
		material.set_shader_parameter("sun_position", sun.position)
	cloud.rotation.y = cloud_rotation
