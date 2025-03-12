extends Control

const aircraft_shop_list_item = preload("res://Scenes/Objects/UI/FullscreenBoxContent/AircraftShop/aircraft_shop_list_item.tscn")

@onready var browser: HBoxContainer = $Browser
@onready var detail: ScrollContainer = $Detail
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var utils: Utils = $Utils

@onready var click_sound: AudioStreamPlayer = $ClickSoundStreamPlayer

# Browser view
@onready var aircraft_list: GridContainer = %AircraftList
# Filter & Sort menu
@onready var search_bar: LineEdit = %SearchBar
# Sorting section
@onready var sort_section_label: Label = %SortSectionLabel
@onready var sort_button: OptionButton = %SortOptionButton
@onready var sort_reverse_checkbox: CheckboxButton = %SortReverseCheckbox
# Filter section
@onready var filter_section_label: Label = %FilterSectionLabel
@onready var price_filter: ShopFilterGroup = %PriceFilter
@onready var capacity_filter: ShopFilterGroup = %CapacityFilter
@onready var range_filter: ShopFilterGroup = %RangeFilter
@onready var speed_filter: ShopFilterGroup = %SpeedFilter
@onready var fuel_filter: ShopFilterGroup = %FuelFilter

# Detail view
@onready var carousel_h_box: HBoxContainer = %CarouselHBox
@onready var name_label: Label = %NameLabel
@onready var price_label: Label = %PriceLabel
# Property labels
@onready var name_prop_label: PropertyLabel = %NamePropLabel
@onready var range_prop_label: PropertyLabel = %RangePropLabel
@onready var capacity_prop_label: PropertyLabel = %CapacityPropLabel
@onready var fuel_prop_label: PropertyLabel = %FuelPropLabel
@onready var speed_prop_label: PropertyLabel = %SpeedPropLabel
# Purchase button
@onready var purchase_button: TextButton = %PurchaseButton

var aircraft_data: Array[AircraftVariant]
var filtered_aircraft: Array[AircraftVariant]
var selected_aircraft: AircraftVariant

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Show the browser panel.
	browser.show()
	detail.hide()

	# Set up filter UI elements.
	# Set the placeholder text of the search bar/
	search_bar.placeholder_text = tr("SEARCH")
	
	# Set the section label.
	sort_section_label.text = tr("SORTING")

	# Set up the sort button.
	sort_button.add_item(tr("NAME"))
	sort_button.add_item(tr("PRICE"))
	sort_button.add_item(tr("RANGE"))
	sort_button.add_item(tr("MAX_SPEED"))
	sort_button.select(0)

	# Set up the invert sort checkbox.
	sort_reverse_checkbox.text = tr("REVERSE_SORT")
	
	# Set the section label.
	filter_section_label.text = tr("FILTER")

	# Set up the filters.
	price_filter.label_text = tr("PRICE")
	price_filter.value_changed.connect(_on_filter_changed)
	price_filter.prefix = "$"
	price_filter.possible_min_value = 0
	price_filter.possible_max_value = 1_000_000_000
	price_filter.step = 100_000

	capacity_filter.label_text = tr("CAPACITY")
	capacity_filter.value_changed.connect(_on_filter_changed)
	capacity_filter.possible_min_value = 0
	capacity_filter.possible_max_value = 1_000
	capacity_filter.step = 20

	range_filter.label_text = tr("RANGE")
	range_filter.value_changed.connect(_on_filter_changed)
	range_filter.suffix = tr("nm")
	range_filter.possible_min_value = 0
	range_filter.possible_max_value = 100_000
	range_filter.step = 200

	speed_filter.label_text = tr("MAX_SPEED")
	speed_filter.value_changed.connect(_on_filter_changed)
	speed_filter.suffix = tr("kt")
	speed_filter.possible_min_value = 0
	speed_filter.possible_max_value = 1_000
	speed_filter.step = 20

	fuel_filter.label_text = tr("FUEL_CONSUMPTION")
	fuel_filter.value_changed.connect(_on_filter_changed)
	fuel_filter.suffix = "L/100km"
	fuel_filter.possible_min_value = 0
	fuel_filter.possible_max_value = 1_000
	fuel_filter.step = 20

	# Connect all the signals.
	search_bar.text_changed.connect(_on_search_text_changed)
	sort_button.item_selected.connect(_on_sort_selected)
	sort_reverse_checkbox.toggled.connect(_on_sort_selected)

	# Show all aircraft.
	apply_filters()

func _on_show_info(aircraft: AircraftVariant):
	# Set the selected aircraft.
	selected_aircraft = aircraft
	# Show images.
	for image in aircraft.images:
		var texture_rect = TextureRect.new()
		texture_rect.texture = image
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		texture_rect.size_flags_vertical = Control.SIZE_FILL
		carousel_h_box.add_child(texture_rect)
	# Show some aircraft informations.
	var price_string = utils.add_commas(aircraft.price)
	name_label.text = aircraft.name
	price_label.text = "$%s" % price_string

	# Aircraft type
	name_prop_label.label_text = tr("AIRCRAFT_TYPE")
	name_prop_label.content_text = aircraft.name
	# Range
	range_prop_label.label_text = tr("RANGE")
	range_prop_label.content_text = tr("%s nm (%s km)") % [
		utils.add_commas(aircraft.flight_range),
		utils.add_commas(utils.nm_to_km(aircraft.flight_range))
	]
	# Aircraft capacity
	capacity_prop_label.label_text = tr("CAPACITY")
	capacity_prop_label.content_text = utils.add_commas(aircraft.capacity)
	# Fuel consumption per 100km
	fuel_prop_label.label_text = tr("FUEL_CONSUMPTION")
	fuel_prop_label.content_text = "%s L/100km" % utils.add_commas(aircraft.fuel_consumption)
	# Maximum cruise speed
	speed_prop_label.label_text = tr("MAX_SPEED")
	speed_prop_label.content_text = tr("%s kt (%s km/h)") % [
		utils.add_commas(aircraft.speed),
		utils.add_commas(utils.kt_to_kmph(aircraft.speed))
	]

	purchase_button.tr_text = tr("Buy for $%s") % price_string
	purchase_button.update()

	# Play the show detail animation.
	animation_player.play("show_detail")

func _on_search_text_changed(_new_text: String) -> void:
	apply_filters()

func _on_sort_selected(index: int = -1) -> void:
	if index > -1:
		click_sound.play()
	apply_filters()

func _on_filter_changed() -> void:
	apply_filters()

func apply_filters():
	# Get the search query. Convert to lower to
	# make it easier to compare.
	var search_text = search_bar.text.to_lower()

	# Filter aircraft based on the search query.
	filtered_aircraft = aircraft_data.filter(
		func(aircraft):
			return search_text.is_empty() or search_text in aircraft.name.to_lower() or search_text in aircraft.manufacturer.to_lower()
	)

	# Sort the aircraft.
	match sort_button.selected:
		# Aircraft variant name
		0: filtered_aircraft.sort_custom(func(a, b): return a.name < b.name)
		# Price
		1: filtered_aircraft.sort_custom(func(a, b): return a.price < b.price)
		# Range
		2: filtered_aircraft.sort_custom(func(a, b): return a.flight_range < b.flight_range)
		# Maximum speed
		3: filtered_aircraft.sort_custom(func(a, b): return a.speed < b.speed)

	filtered_aircraft = filtered_aircraft.filter(func(aircraft):
		return (
			(price_filter.minimum == -1 or aircraft.price >= price_filter.minimum) and
			(price_filter.maximum == -1 or aircraft.price <= price_filter.maximum) and
			(capacity_filter.minimum == -1 or aircraft.capacity >= capacity_filter.minimum) and
			(capacity_filter.maximum == -1 or aircraft.capacity <= capacity_filter.maximum) and
			(range_filter.minimum == -1 or aircraft.flight_range >= range_filter.minimum) and
			(range_filter.maximum == -1 or aircraft.flight_range <= range_filter.maximum) and
			(speed_filter.minimum == -1 or aircraft.speed >= speed_filter.minimum) and
			(speed_filter.maximum == -1 or aircraft.speed <= speed_filter.maximum) and
			(fuel_filter.minimum == -1 or aircraft.fuel_consumption >= fuel_filter.minimum) and
			(fuel_filter.maximum == -1 or aircraft.fuel_consumption <= fuel_filter.maximum)
		)
	)

	# If invert checkbox is checked, reverse the array.
	if sort_reverse_checkbox.is_pressed:
		filtered_aircraft.reverse()

	# Update the list.
	update_aircraft_list()

func update_aircraft_list():
	# Free all the list items.
	for child in aircraft_list.get_children():
		child.queue_free()

	# List filtered aircraft variants.
	for aircraft in filtered_aircraft:
		var list_item = aircraft_shop_list_item.instantiate()
		list_item.aircraft_data = aircraft
		list_item.show_info.connect(_on_show_info)
		aircraft_list.add_child(list_item)
