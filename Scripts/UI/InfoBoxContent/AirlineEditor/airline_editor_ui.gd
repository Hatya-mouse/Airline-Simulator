extends VBoxContainer
class_name AirlineEditorUI

signal back_to_first_toggled(toggled_on: bool)
signal one_way_toggled(toggled_on: bool)
signal next_button_pressed
signal remove_airport(index: int)
signal cancel_creation

const airport_list_item_scene = preload("res://Scenes/Objects/UI/InfoBoxContent/AirlineEditor/airport_list_item.tscn")

@onready var airport_list: VBoxContainer = $AirportList
@onready var back_to_first_checkbox: HBoxContainer = $BackToFirstAirport
@onready var one_way_checkbox: HBoxContainer = $OneWay
## A button that lets player go to the next step.
@onready var next_button: TextButton = $NextButton
## A button that hides the info box.
@onready var cancel_button: TextButton = $CancelButton
## Click to add label.
@onready var click_label: Label = $ClickLabel

var game_controller: GameController
var info_box: InfoBox

## List of airport list item added to the list.
var airport_list_items: Array[InfoAirportListItem] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	info_box = game_controller.info_box
	info_box.hide_button_disabled = true

	# Set up the UI controls
	back_to_first_checkbox.text = tr("BACK_TO_FIRST_AIRPORT")
	one_way_checkbox.text = tr("ONE_WAY")
	next_button.text = tr("NEXT")
	cancel_button.text = tr("CANCEL")
	click_label.text = tr("CLICK_ON_THE_AIRPORT")
	# Add hint box of back to first checkbox
	var back_to_first_checkbox_hint = info_box.get_hint_box("BACK_TO_FIRST_AIRPORT", "BACK_TO_FIRST_AIRPORT_DESCRIPTION")
	back_to_first_checkbox_hint.collider = back_to_first_checkbox
	game_controller.hint_box_parent.add_child(back_to_first_checkbox_hint)
	# Add hint box of one way checkbox
	var one_way_checkbox_hint = info_box.get_hint_box("ONE_WAY", "ONE_WAY_DESCRIPTION")
	one_way_checkbox_hint.collider = one_way_checkbox
	game_controller.hint_box_parent.add_child(one_way_checkbox_hint)

	# Connect signals
	back_to_first_checkbox.toggled.connect(_on_back_to_first_toggled)
	one_way_checkbox.toggled.connect(_on_one_way_toggled)
	next_button.pressed.connect(_on_next_button_pressed)
	cancel_button.pressed.connect(_on_cancel_creation)

	# Clear the airport list
	clear_list()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_back_to_first_toggled(toggled_on: bool) -> void:
	back_to_first_toggled.emit(toggled_on)

func _on_one_way_toggled(toggled_on: bool) -> void:
	one_way_toggled.emit(toggled_on)

func _on_next_button_pressed() -> void:
	next_button_pressed.emit()

func _on_remove_airport(idx: int) -> void:
	remove_airport.emit(idx)

func _on_airport_item_dragged(sender: InfoAirportListItem):
	var index = airport_list_items.find(sender)
	airport_list_items.remove_at(index)

func _on_cancel_creation() -> void:
	cancel_creation.emit()

## Adds a new airport list item to the airport list.
func add_airport(airline_editor: AirlineEditor, airport: AirportData, index: int, auto_added: bool = false) -> void:
	# Since an airport is added, hide the "Click to add" label.
	click_label.hide()
	# Get airport list item
	var airport_list_item = get_airport_list_item(airline_editor, airport, index, auto_added)
	# Add it to the list
	airport_list.add_child(airport_list_item)
	airport_list_items.append(airport_list_item)
	# Connect the dragged signal.
	airport_list_item.dragged.connect(_on_airport_item_dragged)

## Clears the airport list.
func clear_list() -> void:
	# Clear the airport_list_items array.
	airport_list_items.clear()
	# Free the list item, one by one.
	var list_items = airport_list.get_children()
	for item in list_items:
		item.queue_free()
	# Show the "Click to add" label.
	click_label.show()

## Returns an initialized airport control (which is used in airport list).
func get_airport_list_item(airline_editor: AirlineEditor, airport: AirportData, index: int, auto_added: bool = false) -> Control:
	# Instantiate the airport list scene
	var airport_list_item = airport_list_item_scene.instantiate()
	airport_list_item.airport = airport
	airport_list_item.airport_index = index
	airport_list_item.auto_added = auto_added
	airport_list_item.info_box = info_box
	# Pass the airline editor instance
	airport_list_item.airline_editor = airline_editor
	# Connect the clicked signal
	airport_list_item.connect("removed", _on_remove_airport)
	# Return the generated airport
	return airport_list_item
