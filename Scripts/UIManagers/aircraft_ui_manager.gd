extends Node

const aircraft_list_ui_scene = preload("res://Scenes/Objects/UI/CenterPanelContent/AircraftManager/aircraft_list_ui.tscn")
const aircraft_shop_ui_scene = preload("res://Scenes/Objects/UI/FullscreenBoxContent/AircraftShop/aircraft_shop_ui.tscn")
const aircraft_data = preload("res://Resources/Aircraft/aircraft.tres")

@onready var game_controller: GameController = %GameController
@onready var aircraft_controller: AircraftController = %AircraftController

## A button to open aircraft manager panel.
@export var aircraft_manager_button: BasicTextureButton

var center_panel: CenterPanel
var fullscreen_box: FullscreenBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get the center panel and the fullscreen box from game controller.
	center_panel = game_controller.center_panel
	fullscreen_box = game_controller.fullscreen_box
	# Connect the aircraft manager button pressed signal.
	aircraft_manager_button.pressed.connect(_on_aircraft_manager_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_aircraft_manager_button_pressed() -> void:
	init_aircraft_list_ui()
	# Show the center panel.
	center_panel.show_animation()

func init_aircraft_list_ui() -> void:
	# Instantiate the owned aircraft list ui.
	var aircraft_list_ui = aircraft_list_ui_scene.instantiate()
	# Pass the aircraft controller.
	aircraft_list_ui.aircraft_controller = aircraft_controller
	# Connect the open shop signal.
	aircraft_list_ui.open_shop.connect(_on_open_shop)
	# Set the content of the center panel.
	center_panel.set_content(aircraft_list_ui)
	# Set the title of the center panel.
	center_panel.set_title(tr("MANAGE_AIRCRAFT"))

func _on_open_shop() -> void:
	# Instantiate the aircraft shop ui.
	var aircraft_shop_ui = aircraft_shop_ui_scene.instantiate()
	# Pass the aircraft controller and aircraft data.
	aircraft_shop_ui.aircraft_data = aircraft_data.aircraft
	# Set the fullscreen box title.
	fullscreen_box.set_title(tr("PURCHASE_AIRCRAFT"))
	# Show the shop on the fullscreen box.
	fullscreen_box.set_content(aircraft_shop_ui)
	fullscreen_box.show_animation()

func _on_shop_back_pressed() -> void:
	init_aircraft_list_ui()
