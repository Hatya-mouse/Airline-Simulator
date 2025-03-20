extends Control

const GRID_ITEM_WIDTH = 300

const shop_list_item = preload("res://Scenes/Objects/UI/FullscreenBoxContent/ItemShop/item_shop_list_item.tscn")

@onready var browser: HBoxContainer = $Browser
@onready var detail: ScrollContainer = $Detail
@onready var animation_player: AnimationPlayer = $AnimationPlayer
#@onready var utils: Utils = $Utils

@onready var click_sound: AudioStreamPlayer = $ClickSoundStreamPlayer

# Browser view
@onready var item_list: GridContainer = %ItemList
@onready var side_bar: PanelContainer = $Browser/SideBar

# Detail view
# Detail view controller
@onready var detail_view: ShopDetailViewController = %Detail

# Confirmation Panel
@onready var confirmation_panel: ShopConfirmationPanel = %ConfirmationPanel

var items: Array[ShopItem]
var filtered_items: Array[ShopItem]

var game_controller: GameController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Show the browser panel.
	browser.show()
	detail.hide()

	# Connect filter signals.
	side_bar.price_filter.value_changed.connect(_on_filter_changed)
	side_bar.capacity_filter.value_changed.connect(_on_filter_changed)
	side_bar.range_filter.value_changed.connect(_on_filter_changed)
	side_bar.speed_filter.value_changed.connect(_on_filter_changed)
	side_bar.fuel_filter.value_changed.connect(_on_filter_changed)

	# Connect all the signals.
	side_bar.search_bar.text_changed.connect(_on_search_text_changed)
	side_bar.sort_button.item_selected.connect(_on_sort_selected)
	side_bar.sort_reverse_checkbox.toggled.connect(_on_sort_selected)

	# Show all aircraft.
	apply_filters()

	confirmation_panel.game_controller = game_controller

func _process(_delta: float) -> void:
	pass

func _on_show_info(item: ShopItem):
	# Pass the aircraft information to the detail view.
	detail_view.show_info(item)

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
	var search_text = side_bar.search_bar.text.to_lower()

	# Filter items based on the search query.
	filtered_items = items.filter(
		func(item):
			if item.data is AircraftVariant:
				return search_text.is_empty() or search_text in item.name.to_lower() or search_text in item.data.manufacturer.to_lower()
			else:
				return search_text.is_empty() or search_text in item.name.to_lower()
	)

	# Sort the aircraft.
	match side_bar.sort_button.selected:
		# Aircraft variant name
		0: filtered_items.sort_custom(func(a, b): return a.name < b.name)
		# Price
		1: filtered_items.sort_custom(func(a, b): return a.price < b.price)
		# Range
		2: filtered_items.sort_custom(func(a, b):
			if a.data is AircraftVariant and b.data is AircraftVariant:
				return a.flight_range < b.flight_range
			else:
				return a.name < b.name
		)
		# Maximum speed
		3: filtered_items.sort_custom(func(a, b):
			if a.data is AircraftVariant and b.data is AircraftVariant:
				return a.speed < b.speed
			else:
				return a.name < b.name
		)

	filtered_items = filtered_items.filter(func(item):
		# Apply the price filter.
		var price_filter = (
			(side_bar.price_filter.minimum == -1 or item.price >= side_bar.price_filter.minimum) and
			(side_bar.price_filter.maximum == -1 or item.price <= side_bar.price_filter.maximum)
		)

		# Apply other filter only for aircraft.
		if item.data is AircraftVariant:
			return (
				price_filter and
				(side_bar.capacity_filter.minimum == -1 or item.data.capacity >= side_bar.capacity_filter.minimum) and
				(side_bar.capacity_filter.maximum == -1 or item.data.capacity <= side_bar.capacity_filter.maximum) and
				(side_bar.range_filter.minimum == -1 or item.data.flight_range >= side_bar.range_filter.minimum) and
				(side_bar.range_filter.maximum == -1 or item.data.flight_range <= side_bar.range_filter.maximum) and
				(side_bar.speed_filter.minimum == -1 or item.data.speed >= side_bar.speed_filter.minimum) and
				(side_bar.speed_filter.maximum == -1 or item.data.speed <= side_bar.speed_filter.maximum) and
				(side_bar.fuel_filter.minimum == -1 or item.data.fuel_consumption >= side_bar.fuel_filter.minimum) and
				(side_bar.fuel_filter.maximum == -1 or item.data.fuel_consumption <= side_bar.fuel_filter.maximum)
			)
		else:
			return (
				price_filter and
				# If the player has applied filters that are only for aircraft,
				# Hide non-aircraft items.
				side_bar.capacity_filter.minimum == -1 and
				side_bar.capacity_filter.maximum == -1 and
				side_bar.range_filter.minimum == -1 and
				side_bar.range_filter.maximum == -1 and
				side_bar.speed_filter.minimum == -1 and
				side_bar.speed_filter.maximum == -1 and
				side_bar.fuel_filter.minimum == -1 and
				side_bar.fuel_filter.maximum == -1
			)
	)

	# If invert checkbox is checked, reverse the array.
	if side_bar.sort_reverse_checkbox.is_pressed:
		filtered_items.reverse()

	# Update the list.
	update_aircraft_list()

func update_aircraft_list():
	# Free all the list items.
	for child in item_list.get_children():
		child.queue_free()

	# List filtered items.
	for item in filtered_items:
		var list_item = shop_list_item.instantiate()
		list_item.item = item
		list_item.show_info.connect(_on_show_info)
		item_list.add_child(list_item)

func _on_cancel_purchase() -> void:
	animation_player.play("hide_confirmation")

func _on_confirm_purchase() -> void:
	print("Purchase Confirmed!")
