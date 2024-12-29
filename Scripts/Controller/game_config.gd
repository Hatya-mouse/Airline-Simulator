extends Node

@export_category("Theme Color")
@export var large_color := Color(0.573, 0.231, 0.906, 1)
@export var medium_color := Color(0.106, 0.702, 0.702, 1)
@export var small_color := Color(0.867, 0.635, 0.00392, 1)

@export_category("Game System")
@export_range(0.1, 10.0) var game_tick_duration: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
