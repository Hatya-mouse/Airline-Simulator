extends VBoxContainer
class_name AirportInfoUI

signal show_airport_details(airport_data: AirportData)

const airline_list_item_scene = preload("res://Scenes/Objects/UI/InfoBoxContent/AirportInfo/airline_list_item.tscn")

# Airport info labels
@onready var icao_label: HBoxContainer = $ICAOLabel
@onready var iata_label: HBoxContainer = $IATALabel
@onready var latitude_label: HBoxContainer = $LatitudeLabel
@onready var longitude_label: HBoxContainer = $LongitudeLabel
# A label which is shown if not airline reaches this airport.
@onready var no_airline_label: Label = $NoAirlineLabel
# List of airlines reaches this airport.
@onready var list_header: PanelContainer = $ListHeader
@onready var airline_list: VBoxContainer = $AirlineList
# A button that let player view airline list in bigger window.
@onready var more_details_button: TextButton = $MoreDetailsButton

var airport_data: AirportData
var airline_controller: AirlineController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the label text of the label.
	icao_label.label_text = tr("ICAO_CODE")
	iata_label.label_text = tr("IATA_CODE")
	latitude_label.label_text = tr("LATITUDE")
	longitude_label.label_text = tr("LONGITUDE")
	# Set the label contents.
	icao_label.content_text = airport_data.icao
	iata_label.content_text = airport_data.iata
	latitude_label.content_text = str(airport_data.latitude)
	longitude_label.content_text = str(airport_data.longitude)

	# Set the text of no airline label.
	no_airline_label.text = tr("NO_AIRLINE_FOR_THIS_AIRPORT")
	# Set the list header.
	list_header.add_label("AIRLINES", HORIZONTAL_ALIGNMENT_LEFT)
	list_header.add_label("PASSENGERS", HORIZONTAL_ALIGNMENT_RIGHT)

	# Set the text of view airports button.
	more_details_button.text = tr("MORE_DETAILS")
	more_details_button.pressed.connect(_on_more_details_clicked)

	# Show the list of airlines reaches this airport.
	update_airline_list()

func _on_more_details_clicked() -> void:
	show_airport_details.emit(airport_data)

## Reload the list of airlines reaches this airport.
func update_airline_list() -> void:
	# Clear the airline list.
	var children = airline_list.get_children()
	for child in children:
		child.queue_free()

	# Check if airline_controller is not null.
	if not airline_controller:
		return
	# Add airline info item to the airline list.
	var airlines_for_airport = airline_controller.get_airlines_for_airport(airport_data.identifier)
	if airlines_for_airport.is_empty():
		list_header.hide()
		no_airline_label.show()
	else:
		list_header.show()
		no_airline_label.hide()
		for airline in airlines_for_airport:
			add_airline_info(airline)

func add_airline_info(airline: RouteData) -> void:
	var airline_list_item = get_airline_list_item(airline)
	airline_list.add_child(airline_list_item)

func get_airline_list_item(route_data: RouteData) -> MarginContainer:
	var node = airline_list_item_scene.instantiate()
	node.airline = route_data
	node.selected_airport = airport_data
	return node
