extends Resource
class_name ShopItemData

var tr_key: String
var value: String

func _init(_key: String, _value: String):
	tr_key = _key
	value = _value

func get_key() -> String:
	return tr(tr_key)
