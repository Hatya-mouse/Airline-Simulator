extends MeshInstance3D

@export var sun: Node3D
@export var cloud_rotation := 0.0

@onready var cloud: MeshInstance3D = %Cloud
@onready var atmos: Node3D = %PlanetAtmosphere
@onready var game_controller: GameController = %GameController

const material = preload("res://Materials/Planet/earth_material.tres")

var day: float = 0.0
var time: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if sun != null:
		atmos.sun_path = sun.get_path()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if material != null && sun != null:
		material.set_shader_parameter("sun_position", sun.position)
	cloud.rotation.y = cloud_rotation

	day += delta * (360.0 / (365.0 * 30.0))
	time += delta / 10.0
	var revolution_position = Vector3(0, 0, 23156)
	revolution_position = revolution_position.rotated(Vector3.UP, deg_to_rad(day))
	position = revolution_position
	rotation.y = fmod(time, 360.0)
