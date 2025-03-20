extends Node3D
class_name Airport

signal clicked(airport_data: AirportData)

@onready var icon_control: TextureButton = %Icon
@onready var add_airport_audio_player: AudioStreamPlayer = $AddAirport
@onready var airport_info_audio_player: AudioStreamPlayer = $AirportInfo

@onready var visible_notifier: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D

@export var airport_info_sound: AudioStream
@export var add_airport_sound: AudioStream

@export var normal_icon: Texture2D
@export var normal_with_airline_icon: Texture2D
@export var pressed_icon: Texture2D
@export var pressed_with_airline_icon: Texture2D

@export var texture_click_mask: BitMap

@onready var multi_mesh_instance: MultiMeshInstance3D = $MultiMeshInstance

var airport_controller: Node
var game_controller: GameController
var camera: Camera3D
var earth: Node3D

var tween: Tween

var label: LabelBox
var offset := Vector3()
# Could the airport seen last frame?
var old_visibility := false

var airport_data: AirportData

var old_mouse_movement := Vector2()

var should_update_visibility := false
var is_airport_visible := false
var viewport_size_just_changed := false
var airport_type_visibility := false

var is_airport_in_screen := false

func _ready() -> void:
	# Connect the visibility notifier signal
	visible_notifier.screen_entered.connect(_on_screen_entered)
	visible_notifier.screen_exited.connect(_on_screen_exited)

	# Set textures
	icon_control.texture_normal = normal_icon
	icon_control.texture_pressed = pressed_icon
	icon_control.texture_click_mask = texture_click_mask

	# Hide the control
	icon_control.hide()

	# Set controller and camera
	camera = get_viewport().get_camera_3d()

	# Connect viewport size signal
	get_viewport().size_changed.connect(_viewport_size_changed)
	# Connect airport visibility change signal
	airport_controller.airport_visibility_changed.connect(_airport_visibility_changed)
	game_controller.airline_visibility_updated.connect(_route_visibility_changed)
	# Connect airline state change signal
	airport_data.state_changed.connect(_airline_state_changed)

	position = offset

	# Set sounds
	add_airport_audio_player.stream = add_airport_sound
	airport_info_audio_player.stream = airport_info_sound

	# Update airline state
	_airline_state_changed()

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	if is_airport_visible or should_update_airport():
		should_update_visibility = false
		update_position()
		var camera_vector = to_local(camera.global_position)
		_update_visibility(camera_vector)

	viewport_size_just_changed = false

## Check if visibility needs to be updated based on various conditions.
func should_update_airport() -> bool:
	return (
		should_update_visibility or 
		(is_airport_visible and should_update_due_to_camera())
	)

## Check if the camera rotation or viewport size changes require an update.
func should_update_due_to_camera() -> bool:
	return camera.is_moved or viewport_size_just_changed

## Check if this airport needs visibility updates based on its state.
func update_is_airport_visible() -> void:
	is_airport_visible = (
		airport_type_visibility or
		(game_controller.route_visible and airport_data.has_airlines)
	)
	should_update_visibility = true

func _airport_visibility_changed(airport_type: AirportData.AirportType) -> void:
	if airport_data.type == airport_type:
		airport_type_visibility = _cache_airport_type_visible()
		update_is_airport_visible()

func _route_visibility_changed() -> void:
	update_is_airport_visible()

## Check if this type of airport is set visible.
func _cache_airport_type_visible() -> bool:
	if airport_data.type == AirportData.AirportType.SMALL_AIRPORT:
		return airport_controller.small_airport_visibility
	elif airport_data.type == AirportData.AirportType.MEDIUM_AIRPORT:
		return airport_controller.medium_airport_visibility
	return airport_controller.large_airport_visibility

# Process functions
func _update_visibility(camera_vector: Vector3):
	# Check if the airport is behind or front of the earth.
	var angle = offset.angle_to(camera_vector)
	var is_in_front = angle < PI * (0.0001 * camera.position.z + 0.45)

	# Set airport visibility
	var visibility = (
		(not camera.is_position_behind(global_position)) and
		is_in_front and
		is_airport_visible
	)

	# If visibility has changed, play show/hide animation
	if old_visibility != visibility:
		# Play show / hide animation using Tween :)
		if tween:
			tween.kill()
		tween = create_tween()
		if visibility:
			icon_control.show()
			tween.tween_property(icon_control, "modulate:a", 1.0, 0.1)
		else:
			tween.tween_property(icon_control, "modulate:a", 0.0, 0.1)
			tween.tween_property(icon_control, "visible", false, 0.1)
	old_visibility = visibility

## Called from the Airport Controller.
func update_position():
	icon_control.global_position = _calculate_position()

func _calculate_position() -> Vector2:
	var center = icon_control.custom_minimum_size / 2
	return camera.unproject_position(global_position) - center

## Make brighter (which means selected) if this airport is a part of the airline(s).
func _airline_state_changed() -> void:
	update_is_airport_visible()

	if airport_data.has_airlines or airport_data.airline_editor_selected:
		icon_control.texture_normal = normal_with_airline_icon
		icon_control.texture_pressed = pressed_with_airline_icon
		airport_controller.move_forward(self)

		# Make this able to be shown on the AirportPreview camera.
		
	else:
		icon_control.texture_normal = normal_icon
		icon_control.texture_pressed = pressed_icon

func _on_mouse_entered() -> void:
	if not camera.is_position_behind(global_position):
		label.text = airport_data.name
		label.position = camera.unproject_position(global_position) + Vector2(25, -15)
		label.show_animation()

func _on_mouse_exited() -> void:
	label.hide_animation()

func _on_pressed() -> void:
	if not camera.is_moved:
		clicked.emit(airport_data)
		airport_info_audio_player.play()

func _viewport_size_changed() -> void:
	viewport_size_just_changed = true

func _on_screen_entered() -> void:
	is_airport_in_screen = true

func _on_screen_exited() -> void:
	is_airport_in_screen = false
