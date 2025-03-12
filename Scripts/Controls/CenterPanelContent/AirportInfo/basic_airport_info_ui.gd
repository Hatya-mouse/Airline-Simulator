extends HBoxContainer

# Content parents
@onready var scroll_container: ScrollContainer = $ScrollContainer

# Airport Info Labels
@onready var airport_name_label: Label = %AirportNameLabel
# Basic Informations
@onready var basic_information_section: Label = %BasicInformationSection
@onready var icao_code_label: PropertyLabel = %ICAOCodeLabel
@onready var iata_code_label: PropertyLabel = %IATACodeLabel
@onready var latitude_label: PropertyLabel = %LatitudeLabel
@onready var longitude_label: PropertyLabel = %LongitudeLabel
# Airline Informations
@onready var airline_information_section: Label = %AirlineInformationSection
@onready var has_airline_label: PropertyLabel = %HasAirlineLabel

# Airport Preview
@onready var airport_preview_rect: TextureRect = $AirportPreviewRect

@export var airport_preview: SubViewport

var center_panel: CenterPanel
var airport: AirportData

func show_info() -> void:
	airport_preview.set_selected_airport(airport)
	var viewport_texture = airport_preview.get_texture()
	airport_preview_rect.texture = viewport_texture

	# Set the panel title.
	var panel_title = "{0} – {1}".format([tr("AIRPORT_INFORMATION"), airport.name])
	get_parent().center_panel.set_title(panel_title)

	# Show the informations.
	airport_name_label.text = airport.name

	basic_information_section.text = tr("BASIC_INFORMATION")
	icao_code_label.label_text = tr("ICAO_CODE")
	icao_code_label.content_text = airport.icao
	iata_code_label.label_text = tr("ICAO_CODE")
	iata_code_label.content_text = airport.iata
	latitude_label.label_text = tr("LATITUDE")
	latitude_label.content_text = str(airport.latitude)
	longitude_label.label_text = tr("LONGITUDE")
	longitude_label.content_text = str(airport.longitude)

	airline_information_section.text = tr("AIRLINE_INFORMATION")
	has_airline_label.label_text = tr("HAS_AIRLINE")
	has_airline_label.content_text = (
		tr("YES_HAS_AIRLINE")
		if airport.has_airlines
		else tr("DOESNT_HAVE_AIRLINE")
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var preview_size = Vector2(
		get_viewport_rect().size.x * 0.3,
		get_viewport_rect().size.y * 0.7
	)
	airport_preview.size = preview_size
