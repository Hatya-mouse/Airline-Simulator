extends PanelContainer
class_name AircraftShopListItem

signal show_info(item: ShopItem)

@onready var photo_rect: TextureRect = %PhotoRect
@onready var name_label: Label = %NameLabel
@onready var price_label: Label = %PriceLabel
@onready var capacity_label: PropertyLabel = %CapacityLabel
@onready var speed_label: PropertyLabel = %SpeedLabel
@onready var range_label: PropertyLabel = %RangeLabel

@onready var utils: Utils = %Utils

var item: ShopItem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the text.
	name_label.text = item.name
	price_label.text = "$%s" % utils.add_commas(item.price)
	
	if item.data is AircraftVariant:
		capacity_label.label_text = tr("CAPACITY")
		capacity_label.content_text = utils.add_commas(item.data.capacity)
		speed_label.label_text = tr("MAX_SPEED")
		speed_label.content_text = tr("%s kt (%s km/h)") % [
			utils.add_commas(item.data.speed),
			utils.add_commas(utils.kt_to_kmph(item.data.speed))
		]
		range_label.label_text = tr("RANGE")
		range_label.content_text = tr("%s nm (%s km)") % [
			utils.add_commas(item.data.flight_range),
			utils.add_commas(utils.nm_to_km(item.data.flight_range))
		]
	else:
		capacity_label.hide()
		speed_label.hide()
		range_label.hide()

	# Show the picture.
	if item.images.size() > 0:
		photo_rect.texture = item.images[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_more_info_button_pressed() -> void:
	show_info.emit(item)
