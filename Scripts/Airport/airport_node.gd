extends Node3D

@onready var icon_control: TextureButton = $Icon
@onready var animation_player: AnimationPlayer = $Icon/AnimationPlayer

var airport_controller: Node3D
var camera: Camera3D
var earth: Node3D

var label: Label
var type: String
var latitude := 0.0
var longitude := 0.0
var local_position := Vector3()
var old_visibility := false
var airport_data: Dictionary = {}

var icon: Texture
var pressed_icon: Texture

var old_mouse_movement := Vector2()
var is_dragging := false

func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	icon_control.texture_normal = icon
	icon_control.texture_pressed = pressed_icon
	icon_control.hide()
	airport_controller = get_parent_node_3d()

func _process(_delta: float) -> void:
	# Check is the airport is behind or front of the earth.
	var is_behind_earth := false
	var camera_vector = camera.global_position - earth.global_position
	var normalized_position = local_position.normalized()
	# Get the angle between camera position and airport position.
	var angle = normalized_position.angle_to(camera_vector)
	if angle > PI * (0.3 - (300 - camera.position.z) / 1500):
		is_behind_earth = true
	else:
		is_behind_earth = false

	# Set airport visibility
	var is_in_front = not is_behind_earth
	var visibility = false
	visibility = not camera.is_position_behind(position) and is_in_front
	if type == "small_airport":
		visibility = is_in_front and airport_controller.small_airport_visibility
	if type == "medium_airport":
		visibility = is_in_front and airport_controller.medium_airport_visibility
	if type == "large_airport":
		visibility = is_in_front and airport_controller.large_airport_visibility

	if old_visibility != visibility:
		animation_player.play("show" if visibility else "hide")
	old_visibility = visibility

	icon_control.position = camera.unproject_position(position) - Vector2(40, 40)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if abs(event.relative - old_mouse_movement) < Vector2(5, 5):
			is_dragging = false
		else:
			is_dragging = true
		old_mouse_movement = event.relative

func _on_mouse_entered() -> void:
	if not camera.is_position_behind(position):
		label.text = name
		label.position = camera.unproject_position(position)
		label.show()

func _on_mouse_exited() -> void:
	label.hide()

func _on_pressed() -> void:
	if not is_dragging:
		airport_controller.show_info(airport_data)
