extends Resource
class_name AircraftVariant

## Name of the aircraft.
@export var name: String = ""
## Manufacturer of the aircraft.
@export var manufacturer: String = ""
## Max range of the aircraft, in nautical miles.
@export var flight_range: float = 0
## How many seats can this aircraft have.
@export var capacity: int = 0
## Fuel consuption in L/100km.
@export var fuel_consumption: float = 0.0
## Max speed in knots.
@export var speed: float = 0
## Scene of the aircraft.
@export var aircraft_scene: PackedScene

var utils = Utils.new()

func _get_data() -> Array[ShopItemData]:
	return [
		ShopItemData.new("AIRCRAFT_TYPE", name),
		ShopItemData.new("RANGE", tr("%s nm (%s km)") % [
			utils.add_commas(flight_range),
			utils.add_commas(utils.nm_to_km(flight_range))
		]),
		ShopItemData.new("CAPACITY", utils.add_commas(capacity)),
		ShopItemData.new("FUEL_CONSUMPTION", "%s L/100km" % utils.add_commas(fuel_consumption)),
		ShopItemData.new("MAX_SPEED", tr("%s kt (%s km/h)") % [
			utils.add_commas(speed),
			utils.add_commas(utils.kt_to_kmph(speed))
		])
	]
