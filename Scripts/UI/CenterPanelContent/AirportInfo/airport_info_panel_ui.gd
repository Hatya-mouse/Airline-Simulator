extends HBoxContainer

@onready var texture_rect: TextureRect = $TextureRect

@export var airport_preview: SubViewport

var center_panel: CenterPanel
var airport: AirportData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	airport_preview.set_selected_airport(airport)
	var viewport_texture = airport_preview.get_texture()
	texture_rect.texture = viewport_texture
	# Set the panel title.
	var panel_title = "{0} — {1}".format([tr("AIRPORT_INFORMATION"), airport.name])
	center_panel.set_title(panel_title)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var preview_size = Vector2(
		get_viewport_rect().size.x * 0.3,
		get_viewport_rect().size.y * 0.7
	)
	airport_preview.size = preview_size
