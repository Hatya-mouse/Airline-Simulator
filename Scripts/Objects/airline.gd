extends Node3D
class_name Airline

const airway_scene = preload("res://Scenes/Objects/Airport/airway.tscn")
const plane_scene = preload("res://Scenes/Objects/Airport/plane.tscn")

var game_controller: GameController

var route_data: RouteData
var airways: Array[Airway] = []
var way_back_airways: Array[Airway] = []

var interval_tick = 50
var tick_counter = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add to Airline group for saving.
	add_to_group("Airline")
	# Connect tick function.
	game_controller.tick.connect(_tick)
	game_controller.airline_visibility_updated.connect(_on_airline_visibility_updated)

	# Generate airport array considering back_to_first
	spawn_airways()

func _on_airline_visibility_updated() -> void:
	update_visibility()

func update_visibility() -> void:
	if ((game_controller.route_visible and
		game_controller.mode == GameController.InGameMode.NORMAL) or
		route_data.is_editing):
		if game_controller.selected_airport:
			if route_data.has_airport(game_controller.selected_airport):
				show()
			else:
				hide()
		else:
			show()
	else:
		hide()

# Called every game tick. The game tick can be changed in GameController.
func _tick() -> void:
	tick_counter -= 1
	if tick_counter <= 0:
		if not route_data.is_editing:
			start_aircraft()
		tick_counter = interval_tick

func start_aircraft() -> void:
	# If there are more than one airways:
	if not airways.is_empty():
		var airplane = plane_scene.instantiate()
		airplane.game_controller = game_controller
		airplane.airways = airways.duplicate()
		game_controller.airplane_controller.airplane_parent.add_child(airplane)
		# Depart the airplane.
		airplane.depart()

	# For way back route
	if not way_back_airways.is_empty():
		var airplane = plane_scene.instantiate()
		airplane.game_controller = game_controller
		airplane.airways = way_back_airways.duplicate()
		game_controller.airplane_controller.airplane_parent.add_child(airplane)
		# Depart the airplane.
		airplane.depart()

func spawn_airways() -> void:
	# Clear old airways
	for airway in airways:
		airway.queue_free()

	# If airport array is empty we don't have to spawn airway, so return
	if route_data.airports.is_empty():
		return

	var all_airports = route_data.airports.duplicate()

	# If back_to_first is enabled, add the first airport at the end for return route.
	if route_data.back_to_first:
		all_airports.append(route_data.airports[0])

	# Iterate through the airports list
	var prev_airport_data = null
	for airport_data in all_airports:
		# If there is a previous airport, create the airway
		if prev_airport_data != null:
			var start = Vector2(float(prev_airport_data.latitude), float(prev_airport_data.longitude))
			var end = Vector2(float(airport_data.latitude), float(airport_data.longitude))

			# Spawn airway for the direction from prev_airport to airport
			var airway = spawn_airway(start, end, route_data.is_editing)
			airways.append(airway)

		# Set the current airport as the previous one for the next loop iteration
		prev_airport_data = airport_data

	# If one_way is disabled, reverse the airway directions for return
	if not route_data.one_way:
		prev_airport_data = null

		# Reverse the airports array to create the return route
		var reverse_airports = all_airports.duplicate()
		reverse_airports.reverse()

		# Iterate through reversed airports for the return route
		for airport_data in reverse_airports:
			# If there is a previous airport, create the airway
			if prev_airport_data != null:
				var start = Vector2(float(prev_airport_data.latitude), float(prev_airport_data.longitude))
				var end = Vector2(float(airport_data.latitude), float(airport_data.longitude))

				# Spawn airway for the return direction (reverse route)
				var airway = spawn_airway(start, end, route_data.is_editing)
				way_back_airways.append(airway)

			# Set the current airport as the previous one for the next loop iteration
			prev_airport_data = airport_data

## This is not an actually Vector. Vector2.x represents latitude, and Vector2.y represents longitude.
func spawn_airway(from: Vector2, to: Vector2, play_animation: bool = false) -> Airway:
	var airway = airway_scene.instantiate()
	airway.game_controller = game_controller
	airway.is_editing = play_animation
	# need to add as child before adding path to prevent Invalid assignment error
	add_child(airway)
	airway.color = Color(1.0, 0.0, 0.0)
	airway.add_path(from.x, from.y, to.x, to.y)
	return airway

func save() -> Dictionary:
	# Airport ICAO codes.
	var airport_gps_codes: Array[String] = []
	for airport in route_data.airports:
		airport_gps_codes.append(airport.get_icao_code())

	# Create dictionary to save.
	var save_data := {
		"airports": airport_gps_codes
	}
	return save_data
