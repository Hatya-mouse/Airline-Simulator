extends Camera3D

const joy_rotation_multiplier = 0.1

@onready var camera_pivot: Node3D = %CameraPivot
@onready var game_controller: GameController = %GameController
@export var mouse_sensitivity := 1
@export var zoom_speed := 20.0
@export var info_box: InfoBox

var new_position_z := 200.0
var new_rotation := Vector3()

var old_position := Vector3()
var old_rotation := Vector3()

var old_mouse_movement := Vector2()

var is_moved := false

# Called every frame.
func _process(_delta: float) -> void:
	pass

# Smooth transition for position and rotation
func _physics_process(_delta: float) -> void:
	position.z = lerp(position.z, new_position_z, 0.2)

	var interpolated_rotation = lerp(camera_pivot.rotation, new_rotation, 0.1)
	if is_rotation_aligned(interpolated_rotation):
		new_rotation.y = fmod(new_rotation.y, PI * 2)
		interpolated_rotation = new_rotation

	interpolated_rotation.x = clampf(interpolated_rotation.x, -PI / 2, PI / 2)
	camera_pivot.rotation = interpolated_rotation

	# Check if the camera is moved.
	if abs(old_position.x - global_position.x) > 10:
		is_moved = true
	else:
		is_moved = false

	old_position = global_position
	old_rotation = global_rotation

# Check if the rotation is aligned with the target
func is_rotation_aligned(interpolated_rotation: Vector3) -> bool:
	return (abs(interpolated_rotation.x - new_rotation.x) < 0.0001 and
			abs(interpolated_rotation.y - new_rotation.y) < 0.0001 and
			abs(interpolated_rotation.z - new_rotation.z) < 0.0001)

# Handle input events for zoom and rotation
func _unhandled_input(event: InputEvent) -> void:
	# Zooming
	handle_zoom(event)

	# Rotation movement with mouse
	if event is InputEventMouseMotion:
		handle_mouse_rotation(event)
	elif event is InputEventJoypadMotion:
		handle_joystick_rotation(event)
	elif event is InputEventScreenTouch or event is InputEventScreenDrag:
		handle_touch_rotation(event)

# Handle zoom in and out
func handle_zoom(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoom_in") or event.is_action_pressed("camera_zoom_out"):
		var direction = -1 if event.is_action_pressed("camera_zoom_in") else 1
		new_position_z = clampf(position.z + zoom_speed * direction * pow(position.z / 100, 3) / 5, 104, 300)

	# Trackpad zoom gesture (macOS)
	if event is InputEventPanGesture:
		new_position_z = clampf(position.z + zoom_speed * event.delta.y * pow(position.z / 100, 3) / 5, 104, 300)

# Handle camera rotation with mouse movement
func handle_mouse_rotation(event: InputEventMouseMotion) -> void:
	if Input.is_action_pressed("camera_move"):
		var move_proportion = event.relative / Vector2(get_viewport().size)
		var zoom_multiply = pow(clampf(position.z, 100, 200) / 100, 4) * 3
		new_rotation = camera_pivot.rotation + Vector3(
			-move_proportion.y * mouse_sensitivity * zoom_multiply,
			-move_proportion.x * mouse_sensitivity * zoom_multiply,
			0
		)

	old_mouse_movement = event.relative

# Handle joystick rotation input
func handle_joystick_rotation(event: InputEventJoypadMotion) -> void:
	if event.is_action_pressed("camera_move_joy_x"):
		new_rotation.x += event.axis_value * joy_rotation_multiplier
	if event.is_action_pressed("camera_move_joy_y"):
		new_rotation.y += event.axis_value * joy_rotation_multiplier

# Handle touchscreen rotation input
func handle_touch_rotation(event: InputEvent) -> void:
	var touch_movement = event.position - old_mouse_movement
	var zoom_multiply = pow(clampf(position.z, 100, 200) / 100, 4) * 3
	new_rotation = camera_pivot.rotation + Vector3(
		-touch_movement.y * mouse_sensitivity * zoom_multiply,
		-touch_movement.x * mouse_sensitivity * zoom_multiply,
		0
	)
	old_mouse_movement = event.position
