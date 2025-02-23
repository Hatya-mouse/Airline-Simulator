extends Resource
class_name RouteData

## ID of the route.
var route_id: float = 0
## Array of airports.
var airports: Array[AirportData] = []
## Whether back to the first airport at the end.
var back_to_first: bool = false
## Whether this route is one way (back route will be created if false).
var one_way: bool = false
## Ticket price of this route.
var ticket_price: float = 50
## Whether this airline is being edited.
var is_editing: bool = false
## Number of passengers.
var passengers: int = 0

func _init() -> void:
	route_id = Time.get_unix_time_from_system()

## Add an airport to the route.
func add_airport(airport: AirportData) -> void:
	airports.append(airport)

## Check whether this route has the given airport.
func has_airport(airport: AirportData) -> bool:
	return airports.has(airport)

## Remove an airport from the route.
func remove_airport(airport: AirportData) -> void:
	airports.erase(airport)

func insert_airport(index: int, airport: AirportData) -> void:
	airports.insert(index, airport)

func remove_airport_at(index: int) -> void:
	var airport = airports[index]
	remove_airport(airport)

## Check if this route has any overlap with another RouteData.
func overlaps_with(other: RouteData) -> Array[RouteData]:
	var self_airports = get_expanded_route()
	var other_airports = other.get_expanded_route()

	# Check full match
	if self_airports == other_airports:
		return self_airports.duplicate()

	# Check partial match
	for i in range(self_airports.size() - 1):
		for j in range(other_airports.size() - 1):
			if self_airports[i] == other_airports[j] and self_airports[i + 1] == other_airports[j + 1]:
				return self_airports.slice(i, i + 2)

	return []

## Get the actual route array.
func get_expanded_route() -> Array[AirportData]:
	var expanded_airports = airports.duplicate()

	if not one_way:
		# Create the return trip in reverse order (except for the last airport)
		for i in range(airports.size() - 2, -1, -1):
			expanded_airports.append(airports[i])

	if back_to_first and airports.size() > 1:
		expanded_airports.append(airports[0])

	return expanded_airports
