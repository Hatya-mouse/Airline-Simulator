extends Node
class_name AirportUIManager

const airport_info_scene = preload("res://Scenes/Objects/UI/InfoBoxContent/AirportInfo/airport_info_ui.tscn")
const airport_info_panel_scene = preload("res://Scenes/Objects/UI/CenterPanelContent/AirportInfo/airport_info_panel_ui.tscn")

@onready var game_controller: GameController = %GameController
@onready var airline_controller: AirlineController = %AirlineController
@onready var airport_preview: SubViewport = %AirportPreview

var info_box: InfoBox
var center_panel: CenterPanel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	info_box = game_controller.info_box
	center_panel = game_controller.center_panel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func show_info(airport_data: AirportData) -> void:
	# If the airport hasn't already selected
	if game_controller.selected_airport != airport_data:
		# Set the selected airport
		game_controller.set_selected_airport(airport_data)

		# Add airport data text information control
		info_box.set_title(airport_data.name)
		var airport_info_ui = airport_info_scene.instantiate()
		airport_info_ui.airport_data = airport_data
		airport_info_ui.airline_controller = airline_controller
		airport_info_ui.show_airport_details.connect(show_more_details)
		info_box.set_content(airport_info_ui)

		# Connect the signal which is emitted when the info box
		# is closed (which means the airport is deselected)
		if not info_box.closed.is_connected(_on_airport_deselected):
			info_box.closed.connect(_on_airport_deselected)

		# Play show animation
		info_box.hide_button_disabled = false
		info_box.show_animation()

## Called when the "More Details" button pressed.
func show_more_details(airport_data: AirportData) -> void:
	# Instantiate the panel content.
	var airport_info_panel = airport_info_panel_scene.instantiate()
	airport_info_panel.airport_preview = airport_preview
	airport_info_panel.airport = airport_data
	# Set the panel content.
	center_panel.set_content(airport_info_panel)
	# Show the center panel.
	center_panel.show_animation()

## Called when the airport is deselected. (info box is hidden)
func _on_airport_deselected() -> void:
	# Deselect the airport.
	game_controller.set_selected_airport(null)
	# Disconnect the signal.
	info_box.closed.disconnect(_on_airport_deselected)
