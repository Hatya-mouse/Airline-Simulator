extends Resource
class_name AirportData

signal state_changed

enum AirportType {
	SMALL_AIRPORT,
	MEDIUM_AIRPORT,
	LARGE_AIRPORT
}

## Readable name of the airport.
var name: String = ""
## IATA code of the airport.
var iata: String = ""
## ICAO code of the airport.
var icao: String = ""
## Identifier of the airport from the database.
var identifier: String = ""
## Latitude of the airport, in degrees.
var latitude: float = 0.0
## Longitude of the airport, in degrees.
var longitude: float = 0.0
## Type of the airport.
## Small, medium, or large.
var type: AirportType

## Whether this airport has any airlines.
var has_airlines: bool = false
## Whether this airport is selected in the airline editor.
var airline_editor_selected: bool = false
## Whether this airport's info is showed.
var info_selected: bool = false

## Change has_airlines and fire state_changed signal.
func set_has_airlines(value: bool) -> void:
	if has_airlines != value:
		has_airlines = value
		state_changed.emit()

## Set is this airport is selected.
func set_airline_editor_selected(value: bool) -> void:
	if airline_editor_selected != value:
		airline_editor_selected = value
		state_changed.emit()

## Change info_selected and fire state_changed signal.
func set_info_selected(value: bool) -> void:
	if info_selected != value:
		info_selected = value
		state_changed.emit()

## Return IATA code.
## Fallback to ICAO code if IATA code is unavailable.
func get_iata_code() -> String:
	# Use ICAO code if IATA code is unavailable
	var code = iata
	if code.is_empty():
		code = icao
	if code.is_empty():
		code = identifier
	return code

## Return airport's ICAO code.
## Fallback to ident if ICAO code is unavailable.
func get_icao_code() -> String:
	var code = icao
	if code.is_empty():
		code = identifier
	return code

## Return airport's ident.
func get_ident() -> String:
	return identifier
