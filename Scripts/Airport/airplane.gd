extends Node3D
class_name Airplane

signal arrived
signal finished

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

@export var speed: float = 2.0

var game_controller: GameController

var airplane_speed: float = 0.0

var airways: Array[Airway] = []

var airway_number: int = 0
var not_yet_departed := true
var is_arrived := true

var airway_progress := 0.0

var timer_set_for: String

# For smooth rotation
#var is_first_rotation := true

var mesh_material: ShaderMaterial

# Turbulence parameters
var turbulence_amplitude: float = 0.003  # Maximum displacement in meters
var turbulence_frequency: float = 1.0  # Frequency of turbulence oscillation
var turbulence_seed: float = 0.0  # Seed for turbulence randomness

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Make PlaneMesh unique
	mesh_instance.mesh = mesh_instance.mesh.duplicate()
	var mesh = mesh_instance.mesh
	# Make ShaderMaterial unique
	mesh.material = mesh.material.duplicate()
	mesh_material = mesh.material

	# Random turbulence seed
	turbulence_seed = randf()

	# Connect signals
	timer.timeout.connect(_on_timer_timeout)
	animation_player.animation_finished.connect(_on_animation_finished)

	# Play fade-in animation
	animation_player.play("show")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_arrived:
		airway_progress += airplane_speed * delta
		# Get position on the airway, and set it to the position.
		move_forward(airway_progress)

		# Check if airplane's arrived to the destination.
		if airway_progress >= 1.0:
			is_arrived = true
			if airway_number + 1 >= len(airways):
				finish()
			else:
				# Change to the next airway.
				airway_number += 1
				arrive()

	# Pass the distance to the camera to the shader
	var distance = game_controller.camera.position.z - 100
	var depth = distance / 200
	mesh_material.set_shader_parameter("depth", depth)

func _physics_process(_delta: float) -> void:
	pass

## Depart airport
func depart(delay: float = 0.0) -> void:
	if delay > 0:
		timer_set_for = "depart"
		timer.start(delay)
	else:
		is_arrived = false
		not_yet_departed = false

		airway_progress = 0.0

		# Get airplane speed from the airway length.
		airplane_speed = speed / airways[airway_number].airway_length
		position = airways[airway_number].start_vector

		# Play the depart sfx.
		$Audio/DepartureSFX.play()

## Called when arrived at any airport
func arrive() -> void:
	$Audio/ArriveSFX.play()
	depart(5)
	arrived.emit(self)

## Called when finished the airline
func finish() -> void:
	$Audio/ArriveSFX.play()
	despawn(5)
	finished.emit(self)

## Despawn
func despawn(delay: float = 0.0) -> void:
	if delay > 0:
		timer_set_for = "despawn"
		timer.start(delay)
	else:
		animation_player.play("hide")

## Move the airplane.
func move_forward(t: float):
	var airway = airways[airway_number]

	# Smooth the value of t.
	var ease_t = smooth_progress(t, airway.airway_length)
	# Interpolate the position using spherical linear interpolation.
	var interpolated_position = airway.flight_altitude(ease_t, 0.002)
	var new_global_position = game_controller.earth.to_global(interpolated_position)
	# Get direction.
	var forward = get_forward_position(ease_t)
	var look_target = game_controller.earth.to_global(forward)
	# Calculate the offset from the earth.
	var offset_from_earth = global_position - game_controller.earth.global_position
	# Move to the new position and look at the look target.
	look_at_from_position(new_global_position, look_target, offset_from_earth)

	# Apply turbulence to look more realistic.
	apply_turbulence()

## Smooth acceleration and deceleration based on distance
func smooth_progress(t: float, _distance: float) -> float:
	return t

## Calculate the forward direction from t (0 <= t <= 1). Earth based coordinate.
func get_forward_position(t: float) -> Vector3:
	# Interpolate the position to calculate the direction.
	return airways[airway_number].flight_altitude(t + 0.05, 0.002)

## Apply turbulence to the airplane.
func apply_turbulence():
	# Generate random turbulence offset using a sine wave and a random seed
	var x_offset = turbulence_amplitude * sin(TAU * turbulence_frequency * Time.get_ticks_msec() / 1000.0 + turbulence_seed)
	var y_offset = turbulence_amplitude * cos(TAU * turbulence_frequency * Time.get_ticks_msec() / 1000.0 + turbulence_seed * 2.0)
	var z_offset = turbulence_amplitude * sin(TAU * turbulence_frequency * Time.get_ticks_msec() / 1000.0 + turbulence_seed * 3.0)

	# Apply the offset to the airplane's local transform
	var turbulence_vector = Vector3(x_offset, y_offset, z_offset)
	global_transform.origin += turbulence_vector

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		queue_free()

func _on_timer_timeout() -> void:
	if timer_set_for != null:
		call(timer_set_for)
