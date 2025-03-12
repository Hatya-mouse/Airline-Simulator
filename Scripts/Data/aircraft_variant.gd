extends Resource
class_name AircraftVariant

## Unique ID of the aircraft.
@export var id: String = ""
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
## Base price of the aircraft.
@export var price: int = 0
## Pictures of this aircraft.
@export var images: Array[Texture2D] = []
## Scene of the aircraft.
@export var aircraft_scene: PackedScene
