extends Control

@onready var herb_slots: Array = $HerbPage/HerbSlotGrid.get_children()
@onready var brew_slots: Array = $IngredientSlots.get_children()
@onready var brew_button: Button = $BrewButton
@onready var result_slot: Button = $ResultSlot
@onready var result_icon: TextureRect = $ResultSlot/Icon

# Speichere welche Kraut-IDs in den Brau-Slots sind
var current_brew_herbs: Array = ["", "", ""]


func _ready() -> void:
	Inventory.inventory_changed.connect(_refresh_herb_page)
	
	for slot in herb_slots:
		slot.ingredient_clicked.connect(_on_ingredient_clicked)
	
	for slot in brew_slots:
		slot.slot_cleared.connect(_on_brew_slot_cleared)
	
	brew_button.pressed.connect(_on_brew_pressed)
	
	_refresh_herb_page()
	_clear_result()


func _refresh_herb_page() -> void:
	var data_dict = Inventory.herbs
	var lookup_dict = Herbs.HERBS
	var item_ids = data_dict.keys()
	
	for i in range(herb_slots.size()):
		var slot = herb_slots[i]
		if i < item_ids.size():
			var id = item_ids[i]
			if lookup_dict.has(id):
				slot.set_item(id, lookup_dict[id], data_dict[id])
			else:
				slot.clear()
		else:
			slot.clear()


func _on_ingredient_clicked(item_id: String, item_data: Dictionary) -> void:
	# Check ob noch verfügbar im Inventar
	if Inventory.herbs.get(item_id, 0) <= 0:
		return
	
	# Nächsten freien Brau-Slot finden
	for i in range(brew_slots.size()):
		if brew_slots[i].is_empty():
			brew_slots[i].set_item(item_id, item_data)
			current_brew_herbs[i] = item_id
			# Vom Inventar abziehen
			Inventory.remove_herb(item_id, 1)
			return
	
	print("Alle Slots voll")


func _on_brew_slot_cleared(slot_index: int) -> void:
	# Slot leeren, Kraut zurück ins Inventar
	var herb_id = current_brew_herbs[slot_index]
	if herb_id != "":
		Inventory.add_herb(herb_id, 1)
		current_brew_herbs[slot_index] = ""
	brew_slots[slot_index].clear()


func _on_brew_pressed() -> void:
	# Check: alle 3 Slots gefüllt?
	for herb_id in current_brew_herbs:
		if herb_id == "":
			print("Du brauchst 3 Kräuter!")
			return
	
	# Trank brauen
	var potion = Potions.brew(current_brew_herbs)
	print("Gebraut: ", potion.name, " ", potion.effects)
	
	# Trank ins Inventar
	Inventory.add_potion(potion, 1)
	
	# Brau-Slots leeren (Kräuter sind weg)
	for i in range(brew_slots.size()):
		brew_slots[i].clear()
		current_brew_herbs[i] = ""
	
	# Result-Slot zeigt den Trank
	_show_result(potion)


func _show_result(potion: Dictionary) -> void:
	# Trank-Sprite reinladen
	result_icon.texture = preload("res://assets/sprites/potions/potion_generic.png")
	result_icon.modulate = potion.color
	# Du kannst auch ein Label dazupacken mit dem Trank-Namen
	# Brauchen wir später, wenn du willst


func _clear_result() -> void:
	result_icon.texture = null
	result_icon.modulate = Color.WHITE
