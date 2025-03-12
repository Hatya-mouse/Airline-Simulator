extends PanelContainer

signal show_info(aircraft: AircraftVariant)

@onready var photo_rect: TextureRect = %PhotoRect
@onready var name_label: Label = %NameLabel
@onready var price_label: Label = %PriceLabel
@onready var capacity_label: PropertyLabel = %CapacityLabel
@onready var speed_label: PropertyLabel = %SpeedLabel
@onready var range_label: PropertyLabel = %RangeLabel

@onready var utils: Utils = %Utils

var aircraft_data: AircraftVariant

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the text.
	name_label.text = aircraft_data.name
	price_label.text = "$%s" % utils.add_commas(aircraft_data.price)
	capacity_label.label_text = tr("CAPACITY")
	capacity_label.content_text = utils.add_commas(aircraft_data.capacity)
	speed_label.label_text = tr("MAX_SPEED")
	speed_label.content_text = tr("%s kt (%s km/h)") % [
		utils.add_commas(aircraft_data.speed),
		utils.add_commas(utils.kt_to_kmph(aircraft_data.speed))
	]
	range_label.label_text = tr("RANGE")
	range_label.content_text = tr("%s nm (%s km)") % [
		utils.add_commas(aircraft_data.flight_range),
		utils.add_commas(utils.nm_to_km(aircraft_data.flight_range))
	]
	# Show the picture.
	if aircraft_data.images.size() > 0:
		photo_rect.texture = aircraft_data.images[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_more_info_button_pressed() -> void:
	show_info.emit(aircraft_data)
