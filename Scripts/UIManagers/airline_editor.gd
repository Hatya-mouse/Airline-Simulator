extends Node
class_name AirlineEditor

const editor_ui_scene = preload("res://Scenes/Objects/UI/InfoBoxContent/AirlineEditor/airline_editor_ui.tscn")
const property_editor_ui_scene = preload("res://Scenes/Objects/UI/InfoBoxContent/AirlineEditor/airline_property_editor_ui.tscn")

const airline_scene = preload("res://Scenes/Objects/Objects/airline.tscn")

@onready var game_controller: GameController = %GameController
@onready var airline_controller: AirlineController = %AirlineController

@onready var remove_airport_audio_player: AudioStreamPlayer = $SFX/RemoveAirportAudioPlayer
@onready var complete_airline_audio_player: AudioStreamPlayer = $SFX/CompleteAirlineAudioPlayer

@export_category("Controls")
@export var create_airline_button: TextButton
@export_category("SFX")
@export var remove_airport_sound: AudioStream
@export var complete_airline_sound: AudioStream

var editor_ui: AirlineEditorUI
var property_editor_ui: AirlinePropertyEditorUI
## Game info box instance.
var info_box: InfoBox

## Current editing route data.
var editing_route: RouteData

## A ColorRect to show where the airport is going to drop.
var highlight_rect: ColorRect
## Last highlighted target index.
var last_highlight_index: int = -1

## Current editing phase.
var editing_step = MODE_AIRPORT

enum {
	MODE_AIRPORT,
	MODE_PROPERTY
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get info box from the GameController
	info_box = game_controller.info_box

	# Connect the button signal
	create_airline_button.pressed.connect(_on_create_airline_button_pressed)

	# Set the audio streams
	remove_airport_audio_player.stream = remove_airport_sound
	complete_airline_audio_player.stream = complete_airline_sound

	# Create a highlight rect for dragging
	highlight_rect = ColorRect.new()
	highlight_rect.color = Color("#007bd4")
	highlight_rect.size = Vector2(info_box.size.x, 4)
	highlight_rect.visible = false
	info_box.add_child(highlight_rect)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# ——— Airline Editor ———

func _on_create_airline_button_pressed() -> void:
	if game_controller.mode == GameController.InGameMode.NORMAL:
		# Set the game mode to AIRLINE
		game_controller.mode = GameController.InGameMode.AIRLINE
		# Reset
		reset()
		# Set up the info box
		setup_info_box()
		# Show the info box
		info_box.show_animation()
		# Update airport list to show "Click the airport to add"
		update_list()
		# Highlight the create airline button
		create_airline_button.toggle_highlight(true)

func reset() -> void:
	# Create a new RouteData
	editing_route = RouteData.new()
	# Set the mode
	editing_step = MODE_AIRPORT

## Set up the info box for step 1 airline editor.
func setup_info_box() -> void:
	# Instantiate the EditorUI
	editor_ui = editor_ui_scene.instantiate()

	# Connect the signals for step 1
	editor_ui.back_to_first_toggled.connect(_on_back_to_first_toggled)
	editor_ui.one_way_toggled.connect(_on_one_way_toggled)
	editor_ui.next_button_pressed.connect(_on_next_button_pressed)
	editor_ui.remove_airport.connect(_on_remove_airport)
	editor_ui.cancel_creation.connect(cancel_creation)

	# Set the game controller of editor ui
	editor_ui.game_controller = game_controller

	# Set the title of info box
	info_box.set_title(tr("CREATE_AIRLINE"))

	# Remove all information controls and add the editor ui
	info_box.clear_content()
	info_box.set_content(editor_ui)

	# Set the focus to the back_to_first button
	editor_ui.back_to_first_checkbox.grab_focus()
	# Set the focus neighbor
	editor_ui.back_to_first_checkbox.toggle_button.focus_neighbor_top = create_airline_button.get_path()
	create_airline_button.focus_neighbor_bottom = editor_ui.back_to_first_checkbox.get_path()

# ——— Step 1 (Airline Editor) ———

func add_airport_to_airline(airport_data: AirportData) -> void:
	if editing_step == MODE_AIRPORT:
		# Add the airport to the editing airline array
		editing_route.add_airport(airport_data)
		# Update the airline state
		airport_data.set_airline_editor_selected(true)
		# Update the airline list
		update_list()
		# Update the preview airline
		update_preview()

func remove_airport_from_airline(index: int) -> void:
	if editing_step == MODE_AIRPORT:
		if editing_route.airports.size() > index:
			# Update the airline state before removing it from the editing_route.airports array
			editing_route.airports[index].set_airline_editor_selected(false)
			# Remove the airport from the editing airline array
			editing_route.remove_airport_at(index)
		# Update the airline list
		update_list()
		# Update the preview airline
		update_preview()

## Clear old preview airlines and add a updated preview airline.
func update_preview() -> void:
	# Instantiate airline
	var airline = create_airline()
	if airline:
		# Set is_editing true to blink airline
		# and prevent airline from spawning airport
		airline.route_data.is_editing = true
		# Add airline as a preview
		airline_controller.set_preview(airline)

func update_list() -> void:
	# Clear the airport list
	editor_ui.clear_list()

	# Check if editing_route.airports is empty
	if not editing_route.airports.is_empty():
		var counter = 0
		for airport in editing_route.airports:
			editor_ui.add_airport(self, airport, counter)
			# Increase the counter
			counter += 1

		if editing_route.back_to_first:
			# Add first airport at last if back_to_first if true
			editor_ui.add_airport(self, editing_route.airports[0], counter, true)

## Called during dragging. Highlight the drop position
func highlight_drop_target(mouse_position: Vector2):
	# Get the index from the drop position.
	var index = get_index_from_position(mouse_position)
	if index != last_highlight_index and index < editing_route.airports.size():
		last_highlight_index = index
		# Get the position of the airport list item at the index.
		if editor_ui.airport_list_items.size() > 0:
			var target_item = editor_ui.airport_list_items[max(0, index - 1)]
			if target_item.is_editing:
				highlight_rect.hide()
				return
			# Position just underneath the list item.
			if index == 0:
				highlight_rect.global_position.y = target_item.global_position.y - 5
			else:
				highlight_rect.global_position.y = target_item.global_position.y + target_item.size.y
			highlight_rect.show()

## Change the airport order by dragging
func item_dropped(old_index: int, mouse_position: Vector2):
	# Reset the last highlight index.
	last_highlight_index = -1
	# Get the index from the drop position.
	var index = get_index_from_position(mouse_position)
	# If index is out of bounds, then don't reorder.
	# This can happen when the item added by
	# "Back to the first airport" is being dragged.
	if (old_index >= 0 and old_index < editing_route.airports.size() and
		index >= 0 and index < editing_route.airports.size()):
		# Move the item in editing_route.airports array
		var dropped_airport = editing_route.airports[old_index]
		editing_route.remove_airport_at(old_index)
		editing_route.insert_airport(index, dropped_airport)

	# Update UIs.
	update_list()
	update_preview()

	# Hide the drop highlight.
	highlight_rect.hide()

func get_index_from_position(mouse_position: Vector2) -> int:
	# Get the vertical scroll position from the scroll bar
	var vertical_scroll = info_box.scroll_container.get_v_scroll_bar().value
	# Adjust the mouse Y position by considering the scroll amount
	var adjusted_y = (mouse_position.y - info_box.scroll_container.global_position.y) + vertical_scroll
	# Variable to track the cumulative height of all items
	var total_height = 0.0
	# Loop through all items in the list
	var counter = 0
	for item in editor_ui.airport_list_items:
		if item.is_editing or item.auto_added:
			continue
		# Add half of the item height to total_height
		total_height += item.size.y / 2
		# If the adjusted mouse Y position is less than the total height, return the current item index
		if adjusted_y < total_height and not item.is_editing:
			return counter
		# Add the other half of the item height (completing the item's full height in total_height)
		total_height += item.size.y / 2
		# Increment the counter
		counter += 1
	# If no index was found, return the last index (i.e., the last item in the list)
	return editing_route.airports.size() - 1

# Signals

func _on_remove_airport(index: int) -> void:
	# Remove the airport
	remove_airport_from_airline(index)
	# Play the remove sound
	remove_airport_audio_player.play()

func _on_back_to_first_toggled(toggled_on: bool) -> void:
	editing_route.back_to_first = toggled_on
	# Update the preview airline
	update_list()
	update_preview()

func _on_one_way_toggled(toggled_on: bool) -> void:
	editing_route.one_way = toggled_on
	# Update the preview airline
	update_preview()

func _on_next_button_pressed() -> void:
	# Move to the step 2
	editing_step = MODE_PROPERTY
	# Instantiate the controls of step 2
	property_editor_ui = property_editor_ui_scene.instantiate()
	# Connect the signal
	property_editor_ui.complete_airline.connect(_on_complete_button_pressed)
	property_editor_ui.cancel_creation.connect(cancel_creation)
	# Set the game controller of property editor ui
	property_editor_ui.game_controller = game_controller
	# Play the replace animation
	info_box.replace_content_animation(property_editor_ui)
	# Focus the button
	property_editor_ui.complete_button.grab_focus()
	# Set the focus neighbor
	property_editor_ui.complete_button.focus_neighbor_top = create_airline_button.get_path()
	create_airline_button.focus_neighbor_bottom = property_editor_ui.complete_button.get_path()

func cancel_creation() -> void:
	# Set the game mode to NORMAL
	game_controller.mode = GameController.InGameMode.NORMAL
	# Hide the info box
	info_box.hide_animation()
	# De-highlight the create airline button
	create_airline_button.toggle_highlight(false)
	# Deselect all airports
	for airport in editing_route.airports:
		airport.set_airline_editor_selected(false)
	# Remove all preview airports
	airline_controller.clear_preview()
	# Focus on create airline button
	create_airline_button.grab_focus()

# ——— Step 2 (Property Editor) ———

## Add the airline and exit the airline editing mode.
func complete_airline() -> void:
	# Clear preview airlines
	airline_controller.clear_preview()

	# Instantiate the airline scene
	var airline = create_airline()
	if airline:
		# Add the airline to the airline controller
		airline_controller.add_airline(airline)

	# Set the mode to NORMAL
	game_controller.mode = GameController.InGameMode.NORMAL
	# De-highlight the create airline button
	create_airline_button.toggle_highlight(false)
	# ...and hide the info box
	info_box.hide_animation()
	# Play airline complete sound
	complete_airline_audio_player.play()
	
	# Focus on create airline button
	create_airline_button.grab_focus()

# Signals

func _on_complete_button_pressed() -> void:
	complete_airline()

# Utility functions

## Generate airline node from the editing_route.airports array.
## Doesn't add airline as a child of a node, so you need to
## add it yourself.
func create_airline() -> Airline:
	if editing_route.airports.is_empty():
		return

	# Instantiate the airline scene.
	var airline = airline_scene.instantiate()

	# Set the node name of the airline.
	# Example: HND_ITM
	var route_string = []
	for airport in editing_route.airports:
		route_string.append(airport.get_ident())
	airline.name = "_".join(route_string)

	# Set some properties of airline node.
	airline.game_controller = game_controller

	# Pass the route data.
	# We need to duplicate the airports array in order to
	# preserve Airline.route_data.airports from being modified
	# by editing AirlineEditor.route_data.airports.
	airline.route_data = RouteData.new()

	airline.route_data.airports = editing_route.airports.duplicate(true)
	airline.route_data.back_to_first = editing_route.back_to_first
	airline.route_data.one_way = editing_route.one_way
	airline.route_data.ticket_price = editing_route.ticket_price

	airline.route_data.is_editing = false

	return airline
