extends MarginContainer

@onready var color_panel: PanelContainer = $HBox/Begin/Color
@onready var airport_label: Label = $HBox/Begin/VBox/AirportName
@onready var airline_route_label: Label = $HBox/Begin/VBox/AirlineRoute
@onready var number_label: Label = $HBox/Last/Number

@export var normal_airport_label: LabelSettings
## If this list is shown in the information panel of the same airport as
## airline's last airport, this LabelSettings will be used.
@export var same_airport_label: LabelSettings

## If this list is shown in the information panel of the same airport as
## airline's last airport, set selected_airport variable.
var selected_airport: Airport
var airline: Airline
var passenger_number: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _update_ui() -> void:
	if airline == null:
		return
	if airline.airports.is_empty():
		return

	var airport_iata = []
	var last_airport_name = ""
	var smallest_airport_type = ""

	# Get airport IATA
	for airport in airline.airports:
		# Use ICAO code if IATA code is unavailable
		var code = airport.get_iata_code()
		airport_iata.append(code)
		last_airport_name = airport.airport_data["name"]

		# Update smallest airport type directly in loop
		var airport_type = airport.airport_data["type"]
		match smallest_airport_type:
			"large_airport":
				if airport_type in ["medium_airport", "small_airport"]:
					smallest_airport_type = airport_type
			"medium_airport":
				if airport_type == "small_airport":
					smallest_airport_type = airport_type
			"small_airport":
				pass
			_:
				smallest_airport_type = airport_type

	# Set up the passenger number label
	number_label.text = str(passenger_number)

	# Generate route string
	# Example: ["ITM", "HND"] -> "ITM — HND"
	# "—" is em dash
	var route_string = airport_iata.duplicate()
	if airline.back_to_first:
		route_string.append(airport_iata[0])

	# Set up the airport name label
	airport_label.text = last_airport_name
	# Adjust label color if selected and last airport match
	if selected_airport and (last_airport_name == selected_airport.airport_data["name"]):
		if airline.one_way:
			airport_label.label_settings = same_airport_label
			airport_label.text += " (%s)" % tr("THIS_AIRPORT")
		else:
			# If one_way is false, show reversed airline's last airport.
			airport_label.text = airline.airports[0].airport_data["name"]
			# Of course change the route string's order.
			route_string.reverse()
	else:
		airport_label.label_settings = normal_airport_label

	airline_route_label.text = " — ".join(route_string)

	# Set the style of color panel
	var panel_style = StyleBoxFlat.new()
	match smallest_airport_type:
		"small_airport": # Small airport
			panel_style.bg_color = GameConfig.small_color
		"medium_airport": # Medium airport
			panel_style.bg_color = GameConfig.medium_color
		_: # Large airport
			panel_style.bg_color = GameConfig.large_color
	color_panel.add_theme_stylebox_override("panel", panel_style)
