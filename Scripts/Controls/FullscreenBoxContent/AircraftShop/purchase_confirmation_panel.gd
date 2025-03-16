extends PanelContainer

signal cancelled
signal confirmed

@onready var total_section_label: Label = $HBoxContainer/RightPanel/VBoxContainer/TotalSectionLabel
@onready var total_label: Label = $HBoxContainer/RightPanel/VBoxContainer/TotalLabel
@onready var balance_section_label: Label = $HBoxContainer/RightPanel/VBoxContainer/BalanceSectionLabel
@onready var balance_label: Label = $HBoxContainer/RightPanel/VBoxContainer/BalanceLabel
@onready var balance_after_purchase_section_label: Label = $HBoxContainer/RightPanel/VBoxContainer/BalanceAfterPurchaseSectionLabel
@onready var balance_after_purchase: Label = $HBoxContainer/RightPanel/VBoxContainer/BalanceAfterPurchase

@onready var cancel_button: TextButton = $HBoxContainer/RightPanel/VBoxContainer/ButtonBox/CancelButton
@onready var confirm_button: TextButton = $HBoxContainer/RightPanel/VBoxContainer/ButtonBox/ConfirmButton

func _ready() -> void:
	total_section_label.text = tr("TOTAL")
	balance_section_label.text = tr("CURRENT_BALANCE")
	balance_after_purchase_section_label.text = tr("BALANCE_AFTER_PURCHASE")

func _on_cancel_button_pressed() -> void:
	cancelled.emit()

func _on_confirm_button_pressed() -> void:
	confirmed.emit()
