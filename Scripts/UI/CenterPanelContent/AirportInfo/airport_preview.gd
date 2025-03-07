extends SubViewport

@onready var earth_offset: Node3D = $EarthOffset
@onready var airport_camera: Camera3D = $EarthOffset/AirportCamera
@onready var game_controller: GameController = %GameController
@onready var airport_icon_rect: TextureRect = $IconLayer/AirportIcon

@export var large_airport_icon: Texture2D
@export var medium_airport_icon: Texture2D
@export var small_airport_icon: Texture2D

var selected_airport: AirportData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Move to the earth.
	earth_offset.global_position = game_controller.earth.global_position
	earth_offset.global_rotation = game_controller.earth.global_rotation

func set_selected_airport(airport: AirportData) -> void:
	selected_airport = airport
	if selected_airport:
		# Move right above the airport, and look at the center of the earth.
		var airport_position = game_controller.get_position_on_earth(selected_airport.latitude, selected_airport.longitude)
		airport_camera.position = airport_position * 1.1
		airport_camera.look_at(game_controller.earth.global_position)
		airport_camera.rotation.z = 0

		match selected_airport.type:
			AirportData.AirportType.LARGE_AIRPORT:
				airport_icon_rect.texture = large_airport_icon
			AirportData.AirportType.MEDIUM_AIRPORT:
				airport_icon_rect.texture = medium_airport_icon
			AirportData.AirportType.SMALL_AIRPORT:
				airport_icon_rect.texture = small_airport_icon
