extends Control
class_name InfoBoxItem

var game_controller: GameController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_controller = %GameController
