extends PanelContainer
class_name ShopConfirmationPanel

signal cancelled
signal confirmed

# Left pane
@onready var item_name_label: Label = $HBoxContainer/LeftPanel/PanelContainer/MarginContainer/VBoxContainer/ItemNameLabel
@onready var item_price_label: Label = $HBoxContainer/LeftPanel/PanelContainer/MarginContainer/VBoxContainer/ItemPriceLabel
@onready var amount_section_label: Label = $HBoxContainer/LeftPanel/PanelContainer/MarginContainer/VBoxContainer/AmountSectionLabel
@onready var amount_label: Label = $HBoxContainer/LeftPanel/PanelContainer/MarginContainer/VBoxContainer/AmountLabel
@onready var left_total_section_label: Label = $HBoxContainer/LeftPanel/PanelContainer/MarginContainer/VBoxContainer/LeftTotalSectionLabel
@onready var left_total_label: Label = $HBoxContainer/LeftPanel/PanelContainer/MarginContainer/VBoxContainer/LeftTotalLabel

# Right pane
@onready var right_total_section_label: Label = $HBoxContainer/RightPanel/VBoxContainer/RightTotalSectionLabel
@onready var right_total_label: Label = $HBoxContainer/RightPanel/VBoxContainer/RightTotalLabel
@onready var balance_section_label: Label = $HBoxContainer/RightPanel/VBoxContainer/BalanceSectionLabel
@onready var balance_label: Label = $HBoxContainer/RightPanel/VBoxContainer/BalanceLabel
@onready var balance_after_purchase_section_label: Label = $HBoxContainer/RightPanel/VBoxContainer/BalanceAfterPurchaseSectionLabel
@onready var balance_after_purchase: Label = $HBoxContainer/RightPanel/VBoxContainer/BalanceAfterPurchase

@onready var cancel_button: TextButton = $HBoxContainer/RightPanel/VBoxContainer/ButtonBox/CancelButton
@onready var confirm_button: TextButton = $HBoxContainer/RightPanel/VBoxContainer/ButtonBox/ConfirmButton

var item_data: ShopItem
var item_amount: int
var game_controller: GameController

var utils: Utils = Utils.new()

func _ready() -> void:
	pass

func _on_cancel_button_pressed() -> void:
	cancelled.emit()

func _on_confirm_button_pressed() -> void:
	confirmed.emit()

func set_data(item: ShopItem, amount: int) -> void:
	# Set the item_data and the amount.
	item_data = item
	item_amount = amount

	# Show left pane.
	item_name_label.text = item_data.name
	item_price_label.text = "$%s" % utils.add_commas(item_data.price)
	amount_section_label.text = tr("AMOUNT")
	amount_label.text = utils.add_commas(item_amount)
	left_total_section_label.text = tr("TOTAL")
	left_total_label.text = "$%s" % utils.add_commas(item_data.price * item_amount)

	# Show right pane.
	right_total_section_label.text = tr("TOTAL")
	right_total_label.text = "$%s" % utils.add_commas(item_data.price * item_amount)
	balance_section_label.text = tr("CURRENT_BALANCE")
	balance_label.text = "$%s" % utils.add_commas(game_controller.money)
	balance_after_purchase_section_label.text = tr("BALANCE_AFTER_PURCHASE")
	balance_after_purchase.text = "$%s" % utils.add_commas(game_controller.money - item_data.price * amount)
