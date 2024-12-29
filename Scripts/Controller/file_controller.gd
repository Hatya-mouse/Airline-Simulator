extends Node
class_name FileController

@onready var airline_controller: Node = %AirlineController

@export var save_path := "user://save_data.save"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Inside the save file:
# 
# Line 1: Persistent data in Array[Dictionary]
# Line 2: Airline data in Array[Dictionary]
#         [{ "airports": Array[String] }]
#         "airports": Airports in icao code.
#
# Persistent data dictionary MUST include "filename" which contains the path of the node,
# "parent" which contains the path of the parent node, "position_x", "position_y", and "position_z".
func _save_game() -> void:
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)

	# Save persistent nodes.
	var persistent_nodes = get_tree().get_nodes_in_group("Persist")
	var node_data_array: Array[Dictionary] = []
	for node in persistent_nodes:
		if node.scene_file_path.is_empty():
			print("Node '%s' is not an instanced scene so skipped" % node.name)
			continue
		if not node.has_method("save"):
			print("Node '%s' doesn't have an 'save() -> Dictionary' method so skipped" % node.name)
			continue
		var node_data = node.call("save")
		node_data_array.append(node_data)
	save_file.store_var(node_data_array)

	# Save airlines.
	var airlines = get_tree().get_nodes_in_group("Airline")
	var airline_data_array: Array[Dictionary] = []
	for airline in airlines:
		var airline_data = airline.call("save")
		airline_data_array.append(airline_data)
	save_file.store_var(airline_data_array)

	# Close the file.
	save_file.close()

func _load_data() -> void:
	if not FileAccess.file_exists(save_path):
		print("File doesn't exist! Aborting.")
		return

	var save_file = FileAccess.open(save_path, FileAccess.READ)

	# First load the persistent data which can be found at line 1.
	var persistent_data = save_file.get_var() as Array[Dictionary]
	for node_data in persistent_data:
		var new_object = load(node_data["filename"])
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector3(node_data["position_x"], node_data["position_y"], node_data["position_z"])

		for key in node_data.keys:
			if key == "filename" or key == "parent" or key == "position_x" or key == "position_y" or key == "position_z":
				continue
			new_object.set(key, node_data[key])

	# Next load the airlines.
	var airline_data = save_file.get_var() as Array[Dictionary]
	for airline in airline_data:
		airline_controller.load_airlines(airline)
