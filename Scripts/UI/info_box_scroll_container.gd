extends ScrollContainer

@onready var animation_player = $AnimationPlayer
@onready var info_container: VBoxContainer = $MarginContainer/InfoContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide_contents":
		queue_free()