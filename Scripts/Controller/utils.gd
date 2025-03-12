extends Node
class_name Utils

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func add_commas(number: float, force_decimal: bool = false) -> String:
	var str_num = "%.2f" % number
	# Split
	var parts = str_num.split(".")
	var int_part = parts[0]
	var decimal_part = parts[1] if parts.size() > 1 else ""

	var int_len = int_part.length()
	var result = ""
	for i in int_len:
		var substr = int_part.substr(int_len - i - 1, 1)
		if i % 3 == 0 and i != 0:
			result = "%s,%s" % [substr, result]
		else:
			result = substr + result

	# Join the separated part
	if force_decimal or ((not decimal_part.is_empty) and decimal_part != "00"):
		result += "." + decimal_part
	
	return result

func nm_to_km(nm: float) -> float:
	return nm * 1.852

func kt_to_kmph(kt: float) -> float:
	return kt * 1.852
