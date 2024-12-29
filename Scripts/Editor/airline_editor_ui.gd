extends VBoxContainer
class_name AirlineEditorUI

signal back_to_first_toggled(toggled_on: bool)
signal one_way_toggled(toggled_on: bool)
signal next_button_pressed

@onready var back_to_first_checkbox: HBoxContainer = $BackToFirstAirport
@onready var one_way_checkbox: HBoxContainer = $OneWay
@onready var next_button: InfoButton = $NextButton

var game_controller: GameController

var info_box: InfoBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	info_box = game_controller.info_box

	# Set up the UI controls
	back_to_first_checkbox.text = tr("BACK_TO_FIRST_AIRPORT")
	one_way_checkbox.text = tr("ONE_WAY")
	next_button.text = tr("NEXT")

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_back_to_first_toggled(toggled_on: bool) -> void:
	back_to_first_toggled.emit(toggled_on)

func _on_one_way_toggled(toggled_on: bool) -> void:
	one_way_toggled.emit(toggled_on)

func _on_next_button_pressed() -> void:
	next_button_pressed.emit()
