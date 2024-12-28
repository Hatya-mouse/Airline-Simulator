extends Node3D
class_name Airline

const airway_scene = preload("res://Scenes/Airport/airway.tscn")
const plane_scene = preload("res://Scenes/Airport/plane.tscn")

var game_controller: GameController
var airplane_controller: AirplaneController

var airways: Array[Airway] = []
var airports: Array[Airport] = []

var play_animation: bool

var ticket_price: float = 50.0

var interval_tick = 50
var tick_counter = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add to Airline group for saving.
	add_to_group("Airline")
	# Connect tick function.
	game_controller.connect("tick", _tick)

	spawn_all_airways()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Called every game tick. The game tick can be changed in GameController.
func _tick() -> void:
	tick_counter -= 1
	if tick_counter <= 0:
		if not play_animation:
			start_aircraft()
		tick_counter = interval_tick

func start_aircraft() -> void:
	# If there are more than one airways:
	if len(airways) > 0:
		var airplane = plane_scene.instantiate()
		airplane.game_controller = game_controller
		airplane.airways = airways
		airplane_controller.add_child(airplane)
		# Depart the airplane.
		airplane.depart()

func spawn_all_airways() -> void:
	var prev_airport: Airport = null
	for airport in airports:
		if prev_airport != null:
			var prev_airport_data = prev_airport.airport_data
			var airport_data = airport.airport_data
			var start = Vector2(float(prev_airport_data["latitude_deg"]), float(prev_airport_data["longitude_deg"]))
			var end = Vector2(float(airport_data["latitude_deg"]), float(airport_data["longitude_deg"]))
			# If it's preview, add airway directly to the node. If not, add airway to the airline node.
			spawn_airway(start, end, play_animation)
		prev_airport = airport

## This is not an actually Vector. Vector2.x represents latitude, and Vector2.y represents longitude.
func spawn_airway(from: Vector2, to: Vector2, is_preview: bool = false) -> Airway:
	var airway = airway_scene.instantiate()
	airway.game_controller = game_controller
	airway.is_editing = is_preview
	add_child(airway)
	airways.append(airway)
	airway.color = Color(1.0, 0.0, 0.0)
	airway.add_path(from.x, from.y, to.x, to.y)
	return airway

func save() -> Dictionary:
	# Airport ICAO codes.
	var airport_idents: Array[String] = []
	for airport in airports:
		airport_idents.append(airport.airport_data["gps_code"])

	# Create dictionary to save.
	var save_data := {
		"airports": airport_idents
	}
	return save_data
