extends Camera3D

@onready var camera_pivot: Node3D = %CameraPivot
@onready var game_controller: GameController = %GameController

@export var mouse_sensitivity := 1
@export var zoom_speed := 20.0
@export var info_box: InfoBox

var new_position_z := 200.0
var new_rotation := Vector3()

var old_position := Vector3()
var old_rotation := Vector3()

var is_moved := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	is_moved = old_position != global_position
	is_moved = (old_rotation != global_rotation) or is_moved
	old_position = global_position
	old_rotation = global_rotation

func _physics_process(_delta: float) -> void:
	position.z = lerp(position.z, new_position_z, 0.2)

	var interpolated_rotation = lerp(camera_pivot.rotation, new_rotation, 0.1)
	if (abs(interpolated_rotation.x - new_rotation.x) < 0.0001
		and abs(interpolated_rotation.y - new_rotation.y) < 0.0001
		and abs(interpolated_rotation.z - new_rotation.z) < 0.0001):
			new_rotation.y = fmod(new_rotation.y, PI * 2)
			interpolated_rotation = new_rotation
	interpolated_rotation.x = clampf(interpolated_rotation.x, -PI / 2, PI / 2)
	camera_pivot.rotation = interpolated_rotation

func _unhandled_input(event: InputEvent) -> void:
	# Zoom in/out movement
	if event.is_action_pressed("camera_zoom_in") or event.is_action_pressed("camera_zoom_out"):
		new_position_z = clampf(position.z + zoom_speed * (-1 if event.is_action_pressed("camera_zoom_in") else 1) * pow(position.z / 100, 3) / 5, 104, 300)
	# Rotation movement
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("camera_move"):
			var move_proportion = event.relative / Vector2(get_viewport().size)
			var zoom_multiply = pow(clampf(position.z, 100, 200) / 100, 4) * 3
			new_rotation = camera_pivot.rotation + Vector3(-move_proportion.y * mouse_sensitivity * zoom_multiply, -move_proportion.x * mouse_sensitivity * zoom_multiply, 0)
			if info_box != null:
				if (not info_box.is_hidden) and game_controller.mode == GameController.InGameMode.NORMAL:
					info_box.hide_animation()
