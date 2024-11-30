extends Control
class_name InfoBox

@onready var title_label: Label = $InfoBox/VBoxContainer/PanelContainer/VBoxContainer/MarginContainer/TitleLabel

@onready var info_box: PanelContainer = $"InfoBox"
@onready var info_container: VBoxContainer = $InfoBox/VBoxContainer/MarginContainer/InfoContainer
@onready var title_container: PanelContainer = $InfoBox/VBoxContainer/PanelContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var title := ""
var information_controls: Array[Control]
var is_hidden := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in information_controls:
		info_container.add_child(node)

	title_container.material = title_container.material.duplicate()
	info_box.material = info_box.material.duplicate()

	title_label.text = title
	hide()

func add_infomation_contorol(control: Control) -> void:
	information_controls.append(control)
	info_container.add_child(control)

func remove_information_control(index: int) -> Control:
	var control = information_controls[index]
	control.queue_free()
	information_controls.remove_at(index)
	return control

func remove_all_information_controls() -> void:
	for control in information_controls:
		control.queue_free()
	information_controls.clear()

func set_title(new_title: String) -> void:
	title = new_title
	title_label.text = title

func show_animation() -> void:
	animation_player.play("show")
	is_hidden = false

func hide_animation() -> void:
	animation_player.play("hide")
	is_hidden = true
