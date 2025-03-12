extends HBoxContainer

signal open_shop

var aircraft_controller: AircraftController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_shop_button_pressed() -> void:
	open_shop.emit()
