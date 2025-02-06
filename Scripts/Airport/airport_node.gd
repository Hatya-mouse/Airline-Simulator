extends Node3D
class_name Airport

signal clicked(Airport)

@onready var icon_control: TextureButton = $Icon
@onready var animation_player: AnimationPlayer = $Icon/AnimationPlayer
@onready var add_airport_audio_player: AudioStreamPlayer = $AddAirport
@onready var airport_info_audio_player: AudioStreamPlayer = $AirportInfo

@export var airport_info_sound: AudioStream
@export var add_airport_sound: AudioStream

@export var normal_icon: Texture2D
@export var normal_with_airline_icon: Texture2D
@export var pressed_icon: Texture2D
@export var pressed_with_airline_icon: Texture2D

@export var texture_click_mask: BitMap

var airport_controller: Node
var game_controller: GameController
var camera: Camera3D
var earth: Node3D

var label: LabelBox
var type: String
var latitude := 0.0
var longitude := 0.0
var offset := Vector3()
# Could the airport seen last frame?
var old_visibility := false
var airport_data: Dictionary = {}

var old_mouse_movement := Vector2()
var is_dragging := false

var has_airlines = false

var has_visibility_changed := false
var viewport_size_just_changed := false
# If this is true, make brighter:
var airline_editor_selected := false

func _ready() -> void:
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

	position = offset

	# Set sounds
	add_airport_audio_player.stream = add_airport_sound
	airport_info_audio_player.stream = airport_info_sound

	# Update airline state
	update_icon()

func _process(_delta: float) -> void:
	if should_update_visibility():
		_update_position()
		var camera_vector = to_local(camera.global_position)
		_update_visibility(camera_vector)

	viewport_size_just_changed = false

	is_dragging = camera.is_moved

## Check if visibility needs to be updated based on various conditions.
func should_update_visibility() -> bool:
	return has_visibility_changed or should_update_due_to_camera()

## Check if the camera rotation or viewport size changes require an update.
func should_update_due_to_camera() -> bool:
	return (camera.is_moved or viewport_size_just_changed) and requires_visibility_update()

## Check if this airport needs visibility updates based on its state.
func requires_visibility_update() -> bool:
	return is_airport_type_visible() or animation_player.is_playing() or has_airlines

func _airport_visibility_changed(airport_type: String) -> void:
	if type == airport_type:
		has_visibility_changed = true

## Check if this type of airport is set visible.
func is_airport_type_visible() -> bool:
	if type == "small_airport":
		return airport_controller.small_airport_visibility
	elif type == "medium_airport":
		return airport_controller.medium_airport_visibility
	return airport_controller.large_airport_visibility

# Process functions
func _update_visibility(camera_vector: Vector3):
	# Check if the airport is behind or front of the earth.
	var angle = offset.angle_to(camera_vector)
	var is_in_front = angle < PI * (0.0001 * camera.position.z + 0.45)

	# Set airport visibility
	var visibility = (not camera.is_position_behind(global_position)) and is_in_front

	# If there's any airline in this airport, show the airport
	if not has_airlines:
		if type == "small_airport":
			visibility = is_in_front and airport_controller.small_airport_visibility
		if type == "medium_airport":
			visibility = is_in_front and airport_controller.medium_airport_visibility
		if type == "large_airport":
			visibility = is_in_front and airport_controller.large_airport_visibility

	# If visibility has changed, play show/hide animation
	if old_visibility != visibility:
		animation_player.play("show" if visibility else "hide")
	old_visibility = visibility

func _update_position():
	# Set position
	icon_control.position = camera.unproject_position(global_position) - Vector2(50, 50)

## Change has_airlines
func update_airline_state(value: bool) -> void:
	has_airlines = value
	update_icon()

func set_airline_editor_selected(value: bool) -> void:
	airline_editor_selected = value
	update_icon()

## Make brighter (which means selected) if this airport is a part of the airline(s).
func update_icon() -> void:
	if has_airlines or airline_editor_selected:
		icon_control.texture_normal = normal_with_airline_icon
		icon_control.texture_pressed = pressed_with_airline_icon
		airport_controller.move_forward(self)
	else:
		icon_control.texture_normal = normal_icon
		icon_control.texture_pressed = pressed_icon

## Return IATA code.
## Fallback to ICAO code if IATA code is unavailable.
func get_iata_code() -> String:
	# Use ICAO code if IATA code is unavailable
	var code = airport_data.get("iata_code", "")
	if code.is_empty():
		code = airport_data.get("gps_code", "")
	if code.is_empty():
		code = airport_data.get("ident", "")
	return code

## Return airport's ICAO code.
## Fallback to ident if ICAO code is unavailable.
func get_icao_code() -> String:
	var code = airport_data.get("gps_code", "")
	if code.is_empty():
		code = airport_data.get("ident", "")
	return code

## Return airport's ident.
func get_ident() -> String:
	return airport_data.get("ident", "")

func _on_mouse_entered() -> void:
	if not camera.is_position_behind(global_position):
		label.text = airport_data["name"]
		label.position = camera.unproject_position(global_position) + Vector2(50, -30)
		label.show_animation()

func _on_mouse_exited() -> void:
	label.hide_animation()

func _on_pressed() -> void:
	if not is_dragging:
		clicked.emit(self)
		airport_info_audio_player.play()

func _viewport_size_changed() -> void:
	viewport_size_just_changed = true
