extends Node3D

@onready var game_controller: GameController = %GameController

var day: float = 0.0
var time: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    game_controller.tick.connect(_tick)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    day += delta * (360.0 / (365.0 * 60.0))
    time += delta / 10.0
    rotation.y = day
    game_controller.earth.rotation.y = time

func _tick() -> void:
    pass
