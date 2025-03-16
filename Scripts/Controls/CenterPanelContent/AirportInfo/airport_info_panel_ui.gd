extends VBoxContainer

const tab_button_group: ButtonGroup = preload("res://Styles/ButtonGroups/airport_info_panel_tab_view.tres")

@onready var basic_airport_info_button: BasicTextureButton = $VBoxContainer/MarginContainer/TabButtonGroup/BasicAirportInfoButton
@onready var airline_list_button: BasicTextureButton = $VBoxContainer/MarginContainer/TabButtonGroup/AirlineListButton

@onready var basic_info_ui: HBoxContainer = $BasicAirportInfoUI

@export var airport_preview: SubViewport

var center_panel: CenterPanel
var airport: AirportData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	basic_info_ui.airport_preview = airport_preview
	basic_info_ui.center_panel = center_panel
	basic_info_ui.airport = airport
	basic_info_ui.show_info()

	basic_airport_info_button.button_group = tab_button_group
	airline_list_button.button_group = tab_button_group

	basic_airport_info_button.button_pressed = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_basic_airport_info_button_toggled(toggled_on: bool) -> void:
	basic_info_ui.visible = toggled_on

func _on_airline_list_button_toggled(_toggled_on: bool) -> void:
	pass
