extends Node
class_name GameData

## Array of routes.
var routes: Array[RouteData] = []
## Array of aircraft data.
var aircraft_data: Array[AircraftData] = []
## Array of already used registration ids.
var used_registrations := {}

## Set of possible alphabets.
const ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

func add_aircraft():
	var aircraft = AircraftData.new()
	aircraft.id = generate_unique_registration()
	aircraft_data.append(aircraft)

func remove_aircraft(aircraft: AircraftData):
	var index = aircraft_data.find(aircraft)
	aircraft_data.remove_at(index)
	aircraft.free()

## Generate a unique aircraft registration id.
func generate_unique_registration() -> String:
	# Defaut id length.
	var id_length: int = 4
	# Calculate the possible id count.
	var total_possible_ids = pow(ALPHABET.length() + 10, id_length) # 36^4 = 1,679,616 possible ids
	# Calculate the length of the id if 80% of id is already reserved.
	while used_registrations.size() > total_possible_ids * 0.8:
		id_length += 1
		total_possible_ids = pow(ALPHABET.length() + 10, id_length) # 36^n possible ids

	var registration: String = ""
	while true:
		registration = get_random_alphanumeric(id_length)
		if not used_registrations.has(registration):
			used_registrations[registration] = true
			break
	return registration

## Generate a new alphanumeric id with given length.
func get_random_alphanumeric(length: int) -> String:
	var result = ""
	for i in range(length):
		if randi() % 2 == 0:
			result += str(randi_range(0, 9))
		else:
			result += ALPHABET[randi_range(0, ALPHABET.length() - 1)]
	return result
