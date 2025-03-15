extends Button
class_name TextButton

# Button color.
const normal_color = Color("101010", 0.7)
const blue_color = Color("007bd4", 1.0)
const red_color = Color("ba1a1a", 1.0)
const green_color = Color("1aa617", 1.0)

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var tr_text: String = ""
@export var click_sound: AudioStream
@export var button_type: ButtonType = ButtonType.NORMAL
## Color for hover
@export var highlight_color: HighlightColor = HighlightColor.DEFAULT
@export var corner_radius := 5

@export var border: bool = true

var is_highlighted: bool = false

enum ButtonType {
	NORMAL,
	DESTRUCTIVE,
	HIGHLIGHTED,
	ONLY_TEXT
}

enum HighlightColor {
	DEFAULT,
	NORMAL,
	BLUE,
	RED,
	GREEN
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_button_color(button_type)
	if text.is_empty():
		text = tr(tr_text)

func _process(_delta: float) -> void:
	audio_stream_player.stream = click_sound

func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED or what == NOTIFICATION_RESIZED:
		adjust_button_size()

func _on_pressed() -> void:
	audio_stream_player.play()

func toggle_highlight(value: bool) -> void:
	is_highlighted = value
	if is_highlighted:
		update_button_color(ButtonType.HIGHLIGHTED)
	else:
		update_button_color(button_type)

func update() -> void:
	update_button_color(button_type)
	if text.is_empty():
		text = tr(tr_text)

func adjust_button_size():
	var min_width = 10

	# If the button type is ONLY_TEXT, add no margin.
	if button_type == ButtonType.ONLY_TEXT:
		min_width = 6

	# Calculate the text width (32 is a horizontal content margin defined below)
	var font: Font = get_theme_font("font")
	var font_size: int = get_theme_font_size("font_size")
	min_width += font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x

	if icon:
		var icon_ratio = float(icon.get_width()) / icon.get_height()
		# Calculate the height of the icon (16 is a vertical content margin defined below)
		var icon_width = (size.y - 8) * icon_ratio
		min_width += icon_width

	# Add a space between text and the icon
	if not text.is_empty():
		min_width += 4

	custom_minimum_size.x = min_width

func update_button_color(type: ButtonType) -> void:
	# Create a StyleBoxFlat instance.
	var normal_style_box = StyleBoxFlat.new()
	# Set the corner radius.
	normal_style_box.set_corner_radius_all(corner_radius)
	normal_style_box.content_margin_top = 4
	normal_style_box.content_margin_left = 8
	normal_style_box.content_margin_bottom = 4
	normal_style_box.content_margin_right = 8

	# Set the button color based on button type.
	match type:
		ButtonType.NORMAL:
			normal_style_box.bg_color = normal_color
		ButtonType.DESTRUCTIVE:
			normal_style_box.bg_color = red_color
		ButtonType.ONLY_TEXT:
			normal_style_box.bg_color = Color.TRANSPARENT
			normal_style_box.set_content_margin_all(0)

	# Add outline.
	if border:
		normal_style_box.set_border_width_all(1)
		normal_style_box.border_color = normal_style_box.bg_color.lightened(0.3)

	# Set the highlight color.
	var highlight_style_box: StyleBoxFlat = normal_style_box.duplicate()
	match highlight_color:
		HighlightColor.NORMAL:
			highlight_style_box.bg_color = normal_color
		HighlightColor.BLUE:
			highlight_style_box.bg_color = blue_color
		HighlightColor.RED:
			highlight_style_box.bg_color = red_color
		HighlightColor.GREEN:
			highlight_style_box.bg_color = green_color

	# If button style is HIGHLIGHTED, set the normal style box color as same as highlight style box color.
	if type == ButtonType.HIGHLIGHTED:
		normal_style_box.bg_color = highlight_style_box.bg_color

	# Create the pressed and disabled theme box from the normal color.
	var pressed_style_box: StyleBoxFlat = highlight_style_box.duplicate()
	pressed_style_box.bg_color = highlight_style_box.bg_color.darkened(0.3)
	var disabled_style_box: StyleBoxFlat = highlight_style_box.duplicate()
	disabled_style_box.bg_color = highlight_style_box.bg_color.darkened(0.7)

	# Create an empty style box to remove line from the focused style box.
	var focus_style_box = StyleBoxFlat.new()
	focus_style_box.bg_color = Color(0, 0, 0, 0)
	focus_style_box.set_corner_radius_all(corner_radius)
	focus_style_box.border_color = Color(1, 1, 1)
	focus_style_box.set_border_width_all(5)

	# Set the theme box.
	add_theme_stylebox_override("focus", focus_style_box)
	add_theme_stylebox_override("disabled", disabled_style_box)
	add_theme_stylebox_override("hover_pressed", pressed_style_box)
	add_theme_stylebox_override("hover", highlight_style_box)
	add_theme_stylebox_override("pressed", pressed_style_box)
	add_theme_stylebox_override("normal", normal_style_box)

	# Set the theme box for mirrored styles.
	add_theme_stylebox_override("disabled_mirrored", disabled_style_box)
	add_theme_stylebox_override("hover_pressed_mirrored", pressed_style_box)
	add_theme_stylebox_override("hover_mirrored", normal_style_box)
	add_theme_stylebox_override("pressed_mirrored", pressed_style_box)
	add_theme_stylebox_override("normal_mirrored", normal_style_box)
