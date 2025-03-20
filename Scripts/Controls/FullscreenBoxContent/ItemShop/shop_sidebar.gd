extends PanelContainer

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

func _ready() -> void:
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
	price_filter.prefix = "$"
	price_filter.possible_min_value = 0
	price_filter.possible_max_value = 1_000_000_000
	price_filter.step = 100_000

	capacity_filter.label_text = tr("CAPACITY")
	capacity_filter.possible_min_value = 0
	capacity_filter.possible_max_value = 1_000
	capacity_filter.step = 20

	range_filter.label_text = tr("RANGE")
	range_filter.suffix = tr("nm")
	range_filter.possible_min_value = 0
	range_filter.possible_max_value = 100_000
	range_filter.step = 200

	speed_filter.label_text = tr("MAX_SPEED")
	speed_filter.suffix = tr("kt")
	speed_filter.possible_min_value = 0
	speed_filter.possible_max_value = 1_000
	speed_filter.step = 20

	fuel_filter.label_text = tr("FUEL_CONSUMPTION")
	fuel_filter.suffix = "L/100km"
	fuel_filter.possible_min_value = 0
	fuel_filter.possible_max_value = 1_000
	fuel_filter.step = 20
