extends Control

@onready var patient_sprite: TextureRect = $PatientSprite
@onready var symptom_label: Label = $SymptomLabel
@onready var give_item_button: Button = $TreatmentButtons/GiveItemButton
@onready var end_treatment_button: Button = $TreatmentButtons/EndTreatmentButton

# Die vier Balken
@onready var stat_bars: Array = $StatBars.get_children()

var patient_data: Patient = null

# Reihenfolge muss zu den Balken passen!
var stat_order = ["temperature", "pain", "energy", "stress"]
var stat_names = {
	"temperature": "Temperatur",
	"pain": "Schmerz",
	"energy": "Energie",
	"stress": "Stress",
}

signal treatment_ended


func _ready() -> void:
	give_item_button.pressed.connect(_on_give_item_pressed)
	end_treatment_button.pressed.connect(_on_end_treatment_pressed)


func set_patient(p: Patient) -> void:
	patient_data = p
	_refresh()


func _refresh() -> void:
	if patient_data == null:
		symptom_label.text = ""
		return
	
	# Symptome
	var symptoms = patient_data.get_active_symptoms()
	if symptoms.is_empty():
		symptom_label.text = "Der Patient wirkt wohlauf."
	else:
		symptom_label.text = "\n".join(symptoms)
	
	# Balken aktualisieren
	for i in range(stat_bars.size()):
		if i < stat_order.size():
			var stat = stat_order[i]
			var value = patient_data.values[stat]
			stat_bars[i].set_stat(stat_names[stat], value)


func _on_give_item_pressed() -> void:
	# Buch im Treatment-Modus öffnen
	var book = _get_book()
	if book == null:
		print("FEHLER: Buch nicht gefunden")
		return
	
	# Signal verbinden (nur einmal)
	if not book.item_given.is_connected(_on_item_given):
		book.item_given.connect(_on_item_given)
	
	book.open_for_treatment(patient_data)


func _on_item_given(item_id: String, item_data: Dictionary) -> void:
	if patient_data == null:
		return
	
	# Effekt anwenden
	patient_data.apply_item(item_data)
	
	# Item aus Inventar entfernen
	_remove_item_from_inventory(item_id, item_data)
	
	# Anzeige aktualisieren
	_refresh()

func _remove_item_from_inventory(item_id: String, item_data: Dictionary) -> void:
	if Herbs.HERBS.has(item_id):
		Inventory.remove_herb(item_id, 1)
	elif Inventory.potions.has(item_id):
		Inventory.potions[item_id].count -= 1
		if Inventory.potions[item_id].count <= 0:
			Inventory.potions.erase(item_id)
		Inventory.inventory_changed.emit()


func _on_end_treatment_pressed() -> void:
	treatment_ended.emit() 


func _get_book():
	# Pass das an deine HUD-Struktur an!
	# Beispiel falls HUD Autoload ist und das Buch als Kind hat:
	return HUD.get_node_or_null("BookInventory")
