extends Node

var herbs := {}
var potions := {}
var misc := {}

signal inventory_changed


func add_herb(herb_id: String, amount: int = 1) -> void:
	_add_to(herbs, herb_id, amount)


func add_potion(potion_data: Dictionary, amount: int = 1) -> void:
	# Wir speichern Tränke direkt mit ihren Daten als Key
	# Damit gleiche Tränke gestackt werden
	var key = _potion_to_key(potion_data)
	if potions.has(key):
		potions[key].count += amount
	else:
		potions[key] = {
			"data": potion_data,
			"count": amount,
		}
	inventory_changed.emit()


func remove_herb(herb_id: String, amount: int = 1) -> bool:
	return _remove_from(herbs, herb_id, amount)


func _add_to(dict: Dictionary, key: String, amount: int) -> void:
	if dict.has(key):
		dict[key] += amount
	else:
		dict[key] = amount
	inventory_changed.emit()


func _remove_from(dict: Dictionary, key: String, amount: int) -> bool:
	if not dict.has(key) or dict[key] < amount:
		return false
	dict[key] -= amount
	if dict[key] <= 0:
		dict.erase(key)
	inventory_changed.emit()
	return true


func _potion_to_key(potion_data: Dictionary) -> String:
	# Eindeutiger Key basierend auf Name und Effekten
	var effects = potion_data.get("effects", {})
	var effects_str = ""
	var keys = effects.keys()
	keys.sort()
	for k in keys:
		effects_str += "%s:%d," % [k, effects[k]]
	return potion_data.get("name", "Unknown") + "|" + effects_str
