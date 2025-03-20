extends ScrollContainer
class_name ShopDetailViewController

const property_label_scene = preload("res://Scenes/Objects/UI/Basic/Label/property_label.tscn")

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var carousel_h_box: HBoxContainer = %CarouselHBox
@onready var name_label: Label = %NameLabel
@onready var price_label: Label = %PriceLabel

@onready var aircraft_info_box: VBoxContainer = %AircraftInfoVBox
# Amount controls
@onready var amount_label: Label = %AmountLabel
@onready var amount_spin_box: SpinBox = %AmountSpinBox
# Purchase button
@onready var purchase_button: TextButton = %PurchaseButton

# Confirmation Panel
@onready var confirmation_panel: ShopConfirmationPanel = %ConfirmationPanel

@onready var utils: Utils = %Utils

var selected_item: ShopItem

func _ready() -> void:
	amount_spin_box.changed.connect(_amount_changed)
	purchase_button.pressed.connect(_on_purchase_button_pressed)

func show_info(item: ShopItem):
	# Set the selected_item.
	selected_item = item

	# Show images.
	for image in item.images:
		var texture_rect = TextureRect.new()
		texture_rect.texture = image
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		texture_rect.size_flags_vertical = Control.SIZE_FILL
		carousel_h_box.add_child(texture_rect)

	# Show some item information.
	name_label.text = item.name
	price_label.text = "$%s" % utils.add_commas(item.price)

	amount_label.text = tr("AMOUNT")
	amount_spin_box.value = 1

	purchase_button.tr_text = tr("Buy for $%s") % utils.add_commas(item.price * amount_spin_box.value)
	purchase_button.update()

	# Delete all the children of item data box.
	for child in aircraft_info_box.get_children():
		child.queue_free()

	# Get the item data.
	var item_data = item.get_data()
	for pair in item_data:
		var property_label = property_label_scene.instantiate()
		property_label.label_text = pair.get_key()
		property_label.content_text = pair.value
		property_label.align_content_text_to_right = true
		# Add the property label to the data box.
		aircraft_info_box.add_child(property_label)

	# Play the show detail animation.
	animation_player.play("show_detail")

func _amount_changed() -> void:
	purchase_button.tr_text = tr("Buy for $%s") % utils.add_commas(selected_item.price * amount_spin_box.value)
	purchase_button.update()

func _on_purchase_button_pressed() -> void:
	animation_player.play("show_confirmation")
	confirmation_panel.set_data(selected_item, int(amount_spin_box.value))
