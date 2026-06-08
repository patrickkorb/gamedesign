extends Control

enum Category { HERBS, POTIONS, MISC }
var current_category: Category = Category.HERBS
var in_treatment_mode: bool = false
var current_patient = null  # Wird vom Patienten gesetzt


@onready var slots: Array = $Book/LeftPage/ItemSlots.get_children()
@onready var bookmarks: Array = $Book/LeftPage/Bookmarks.get_children()
@onready var name_label: Label = $Book/RightPage/DetailsContainer/NameLabel
@onready var count_label: Label = $Book/RightPage/DetailsContainer/CountLabel
@onready var effects_header: Label = $Book/RightPage/DetailsContainer/EffectsHeader
@onready var effects_list: VBoxContainer = $Book/RightPage/DetailsContainer/EffectsList
@onready var give_button: Button = $Book/RightPage/DetailsContainer/GiveButton

var selected_slot = null

signal item_given(item_id: String, item_data: Dictionary)

func _ready() -> void:
	Inventory.inventory_changed.connect(_refresh)
	
	for slot in slots:
		slot.item_selected.connect(_on_item_selected)
	
	for bookmark in bookmarks:
		bookmark.bookmark_pressed.connect(_on_bookmark_pressed)
	
	_apply_category(Category.HERBS)
	_refresh()
	_show_empty_state()
	give_button.pressed.connect(_on_give_pressed)
	give_button.visible = false

	



func _on_give_pressed() -> void:
	if current_patient == null or selected_slot == null:
		return
	if selected_slot.item_data.is_empty():
		return
	
	var item_id = selected_slot.item_id
	var item_data = selected_slot.item_data
	
	item_given.emit(item_id, item_data)
	
	# Buch NICHT schließen – offen lassen für weitere Items
	# Aber Anzeige aktualisieren, da sich die Anzahl geändert hat
	_refresh()
	_update_selection_after_give(item_id)

func open_for_treatment(patient) -> void:
	current_patient = patient
	in_treatment_mode = true
	# Buch sichtbar machen
	visible = true
	_refresh()

func _update_selection_after_give(item_id: String) -> void:
	# Prüfen ob das Item noch im Inventar ist
	var still_exists = false
	match current_category:
		Category.HERBS:
			still_exists = Inventory.herbs.has(item_id)
		Category.POTIONS:
			still_exists = Inventory.potions.has(item_id)
		Category.MISC:
			still_exists = Inventory.misc.has(item_id)
	
	if still_exists:
		# Item noch da → Details neu anzeigen mit aktualisierter Anzahl
		var count = 0
		var item_data = {}
		match current_category:
			Category.HERBS:
				count = Inventory.herbs[item_id]
				item_data = Herbs.HERBS[item_id]
			Category.POTIONS:
				count = Inventory.potions[item_id].count
				item_data = Inventory.potions[item_id].data
		_show_item_details(item_id, item_data, count)
	else:
		# Item aufgebraucht → Auswahl zurücksetzen
		_deselect_all()
		_show_empty_state()

func close_treatment() -> void:
	current_patient = null
	in_treatment_mode = false
	visible = false

func _on_bookmark_pressed(category_string: String) -> void:
	match category_string:
		"herbs":
			_apply_category(Category.HERBS)
		"potions":
			_apply_category(Category.POTIONS)
		"misc":
			_apply_category(Category.MISC)


func _apply_category(cat: Category) -> void:
	current_category = cat
	
	for bookmark in bookmarks:
		var active = false
		match cat:
			Category.HERBS:
				active = bookmark.category == "herbs"
			Category.POTIONS:
				active = bookmark.category == "potions"
			Category.MISC:
				active = bookmark.category == "misc"
		bookmark.set_active(active)
	
	_deselect_all()
	_refresh()
	_show_empty_state()


func _refresh() -> void:
	match current_category:
		Category.HERBS:
			_refresh_herbs()
		Category.POTIONS:
			_refresh_potions()
		Category.MISC:
			_refresh_misc()


func _refresh_herbs() -> void:
	var data_dict = Inventory.herbs
	var lookup_dict = Herbs.HERBS
	var item_ids = data_dict.keys()
	
	for i in range(slots.size()):
		var slot = slots[i]
		if i < item_ids.size():
			var id = item_ids[i]
			if lookup_dict.has(id):
				slot.set_item(id, lookup_dict[id], data_dict[id])
			else:
				slot.clear()
		else:
			slot.clear()
			
			

func _refresh_potions() -> void:
	var potion_keys = Inventory.potions.keys()
	
	for i in range(slots.size()):
		var slot = slots[i]
		if i < potion_keys.size():
			var key = potion_keys[i]
			var potion_entry = Inventory.potions[key]
			var potion_data = potion_entry.data
			var count = potion_entry.count
			slot.set_item(key, potion_data, count)
		else:
			slot.clear()


func _refresh_misc() -> void:
	var data_dict = Inventory.misc
	var item_ids = data_dict.keys()
	
	for i in range(slots.size()):
		var slot = slots[i]
		if i < item_ids.size():
			var id = item_ids[i]
			# Misc hat noch keinen Lookup
			slot.clear()
		else:
			slot.clear()

func _on_item_selected(item_id: String, item_data: Dictionary) -> void:
	for slot in slots:
		if slot.item_id == item_id:
			_select_slot(slot)
			break
	
	var count = 0
	match current_category:
		Category.HERBS:
			count = Inventory.herbs.get(item_id, 0)
		Category.POTIONS:
			# Bei Tränken ist item_id der generierte Key
			if Inventory.potions.has(item_id):
				count = Inventory.potions[item_id].count
		Category.MISC:
			count = Inventory.misc.get(item_id, 0)
	
	_show_item_details(item_id, item_data, count)


func _select_slot(slot) -> void:
	if selected_slot != null and selected_slot != slot:
		selected_slot.set_selected(false)
	selected_slot = slot
	slot.set_selected(true)


func _deselect_all() -> void:
	if selected_slot != null:
		selected_slot.set_selected(false)
		selected_slot = null
		
func _show_empty_state() -> void:
	name_label.text = "Wähle ein Kraut aus..."
	count_label.text = ""
	effects_header.text = ""
	_clear_effects_list()
	give_button.visible = false


func _show_item_details(item_id: String, item_data: Dictionary, count: int) -> void:
	name_label.text = "Name: " + item_data.get("name", "Unbekannt")
	count_label.text = "Anzahl: %d" % count
	effects_header.text = "Bekannte Effekte:"
	
	_clear_effects_list()
	_populate_effects(item_data)
	give_button.visible = in_treatment_mode and not item_data.is_empty()


func _clear_effects_list() -> void:
	for child in effects_list.get_children():
		child.queue_free()


func _populate_effects(item_data: Dictionary) -> void:
	var effects: Dictionary = item_data.get("effects", {})
	
	# Alte Labels löschen
	for child in effects_list.get_children():
		child.queue_free()
	
	if effects.is_empty():
		var label = Label.new()
		label.text = "  Noch keine bekannt"
		effects_list.add_child(label)
		return
	
	# Lesbare Namen für die Werte
	var labels = {
		"temperature": "Temperatur",
		"pain": "Schmerz",
		"energy": "Energie",
		"stress": "Stress",
	}
	
	# Pro Wert einen Eintrag machen
	for key in effects:
		var value = effects[key]
		if value == 0:
			continue  # Werte mit 0 nicht anzeigen
		
		var label = Label.new()
		var label_name = labels.get(key, key)
		var prefix = "+" if value > 0 else ""
		label.text = "• %s: %s%d" % [label_name, prefix, value]
		effects_list.add_child(label)
