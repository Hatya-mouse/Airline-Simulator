extends Node
class_name AirlineController

@export_category("Airline Node")
@export var airline_parent: Node3D
@export var preview_airline_parent: Node3D

# <Airport ident (String)> : <Array[Airline]>
var airport_to_airlines: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## Add a new airline node.
func add_airline(airline: Airline) -> void:
	# Add to the airline parent as a child
	airline_parent.add_child(airline)

	# Add airport_to_airlines for easier access
	# from a airport name.
	for airport in airline.route_data.airports:
		var airport_ident = airport.get_ident()

		# Initialize the airline list for the airport if not present
		if not airport_to_airlines.has(airport_ident):
			airport_to_airlines[airport_ident] = []

		# Get the existing list of airlines for the airport
		var old_airline_list = airport_to_airlines[airport_ident]

		# Ensure the airline is not already in the list to avoid duplicates
		if not old_airline_list.has(airline):
			old_airline_list.append(airline)

		# Update the airline state of the airport
		airport.set_has_airlines(true)

## Return all airlines with given airport.
func get_airlines_for_airport(airport_ident: String) -> Array:
	return airport_to_airlines.get(airport_ident, [])

## Remove all the old preview airlines and set the preview airline.
## Automatically set Airline.is_editing true.
func set_preview(airline: Airline) -> void:
	clear_preview()
	airline.route_data.is_editing = true
	preview_airline_parent.add_child(airline)

## Remove all preview airlines.
func clear_preview() -> void:
	var preview_airlines = preview_airline_parent.get_children()
	for airline in preview_airlines:
		airline.queue_free()
