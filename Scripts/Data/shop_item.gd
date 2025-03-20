extends Resource
class_name ShopItem

## Unique ID of the item.
@export var id: String = ""
## Name of the item.
@export var name: String = ""
## Price of the item.
@export var price: int = 0
## Pictures of the item.
@export var images: Array[Texture2D] = []
## Item data of the item.
@export var data: Resource

func get_data() -> Array[ShopItemData]:
	return data.call("_get_data") if data.has_method("_get_data") else []
