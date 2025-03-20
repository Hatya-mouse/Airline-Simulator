extends VBoxContainer
class_name ShopFilterGroup

## -1 means no filter is applied.
signal value_changed

@onready var filter_checkbox: CheckboxButton = %FilterCheckbox
@onready var input_group: VBoxContainer = $InputGroup
@onready var min_spin: SpinBox = %MinSpin
@onready var max_spin: SpinBox = %MaxSpin

@export var label_text: String = "":
	set(value):
		label_text = value
		if filter_checkbox:
			filter_checkbox.text = label_text

@export_category("Value")
@export var possible_min_value: float = 0.0:
	set(value):
		possible_min_value = value
		if min_spin and max_spin:
			min_spin.min_value = possible_min_value
			max_spin.min_value = possible_min_value
			min_spin.value = possible_min_value

@export var possible_max_value: float = 1_000_000_000.0:
	set(value):
		possible_max_value = value
		if min_spin and max_spin:
			min_spin.max_value = possible_max_value
			max_spin.max_value = possible_max_value
			max_spin.value = possible_max_value

@export var step: float = 1:
	set(value):
		step = value
		if min_spin and max_spin:
			min_spin.custom_arrow_step = step
			max_spin.custom_arrow_step = step

@export_category("Appearance")
@export var prefix: String = "":
	set(value):
		prefix = value
		if min_spin and max_spin:
			min_spin.prefix = prefix
			max_spin.prefix = prefix

@export var suffix: String = "":
	set(value):
		suffix = value
		if min_spin and max_spin:
			min_spin.suffix = suffix
			max_spin.suffix = suffix

var minimum := -1.0
var maximum := -1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_properties()

	input_group.visible = filter_checkbox.is_pressed

	filter_checkbox.toggled.connect(_on_checkbox_toggled)
	min_spin.value_changed.connect(_on_min_changed)
	max_spin.value_changed.connect(_on_max_changed)

func _update_properties():
	filter_checkbox.text = label_text

	min_spin.min_value = possible_min_value
	max_spin.min_value = possible_min_value
	min_spin.value = possible_min_value

	min_spin.max_value = possible_max_value
	max_spin.max_value = possible_max_value
	max_spin.value = possible_max_value

	min_spin.custom_arrow_step = step
	max_spin.custom_arrow_step = step

	min_spin.prefix = prefix
	max_spin.prefix = prefix

	min_spin.suffix = suffix
	max_spin.suffix = suffix

func _on_checkbox_toggled(toggled_on: bool) -> void:
	input_group.visible = toggled_on
	# Change the value.
	if toggled_on:
		minimum = min_spin.value
		maximum = max_spin.value
	else:
		minimum = -1
		maximum = -1
	value_changed.emit()

func _on_min_changed(value: float) -> void:
	minimum = value
	value_changed.emit()

func _on_max_changed(value: float) -> void:
	maximum = value
	value_changed.emit()
