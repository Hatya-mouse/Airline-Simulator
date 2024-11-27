extends Node3D

@onready var icon_control: TextureRect = $Icon
@onready var collision_shape_3d: CollisionShape3D = $StaticBody3D/CollisionShape3D

var camera: Camera3D
var earth: Node3D

var label: Label
var type: String
var latitude := 0.0
var longitude := 0.0
var local_position := Vector3()

var icon: Texture

var is_behind_earth := false

func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	icon_control.texture = icon

func _process(_delta: float) -> void:
	#var airport_rotation = Vector3(deg_to_rad(latitude), deg_to_rad(longitude), 0)
	var camera_vector = camera.global_position - earth.global_position
	var normalized_position = local_position.normalized()
	var angle = normalized_position.angle_to(camera_vector)
	if angle > PI * (0.3 - (300 - camera.position.z) / 1500):
		is_behind_earth = true
	else:
		is_behind_earth = false

	icon_control.visible = not camera.is_position_behind(position) and (not is_behind_earth)
	if type == "small_airport":
		icon_control.visible = camera.position.z < 110 and (not is_behind_earth)
	if type == "medium_airport":
		icon_control.visible = camera.position.z < 120 and (not is_behind_earth)
	if type == "large_airport":
		icon_control.visible = camera.position.z < 200 and (not is_behind_earth)
	icon_control.position = camera.unproject_position(position) - Vector2(40, 40)

func _on_mouse_entered() -> void:
	if not camera.is_position_behind(position):
		label.text = name
		label.position = camera.unproject_position(position)
		label.show()

func _on_mouse_exited() -> void:
	label.hide()
