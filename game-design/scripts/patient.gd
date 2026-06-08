class_name Patient
extends RefCounted

var patient_name: String = ""
var disease_id: String = ""

# Aktuelle Werte
var values: Dictionary = {
	"temperature": 50,
	"pain": 50,
	"energy": 50,
	"stress": 50,
}

# Symptom-Gedächtnis: pro Wert der aktuell gezeigte Text + die Stufe
# Format: { "temperature": { "level": "high", "text": "Er glüht..." } }
var symptom_memory: Dictionary = {}


func _init(p_name: String, p_disease_id: String) -> void:
	patient_name = p_name
	disease_id = p_disease_id
	
	# Startwerte aus der Krankheit übernehmen
	if Diseases.DISEASES.has(disease_id):
		var start = Diseases.DISEASES[disease_id].start_values
		for key in start:
			values[key] = start[key]
	
	# Symptome initial würfeln
	_update_all_symptoms()


# Einen Trank anwenden: Effekte auf Werte addieren
func apply_item(item_data: Dictionary) -> void:
	var effects = item_data.get("effects", {})
	for stat in effects:
		if values.has(stat):
			values[stat] = clampi(values[stat] + effects[stat], 0, 100)
	_update_all_symptoms()


# Geht alle Werte durch und aktualisiert die Symptome
func _update_all_symptoms() -> void:
	for stat in values:
		var current_level = Symptoms.get_level(stat, values[stat])
		
		# Hatten wir schon ein Symptom für diesen Wert?
		var had_memory = symptom_memory.has(stat)
		var old_level = ""
		if had_memory:
			old_level = symptom_memory[stat].level
		
		if current_level == "":
			# Wert ist gesund → kein Symptom
			symptom_memory.erase(stat)
		elif not had_memory or old_level != current_level:
			# Neue Stufe (oder erstes Mal) → neuen Text würfeln
			symptom_memory[stat] = {
				"level": current_level,
				"text": Symptoms.get_symptom_text(stat, values[stat]),
			}
		# Sonst: gleiche Stufe wie vorher → Text behalten, nichts tun


# Liefert alle aktuellen Symptomtexte als Array
func get_active_symptoms() -> Array:
	var result = []
	for stat in symptom_memory:
		result.append(symptom_memory[stat].text)
	return result


# Sind alle Werte in der gesunden Zone?
func is_healthy() -> bool:
	for stat in values:
		if not Diseases.is_in_healthy_zone(stat, values[stat]):
			return false
	return true


# Wie viele Werte sind außerhalb der gesunden Zone?
func count_critical_values() -> int:
	var count = 0
	for stat in values:
		if not Diseases.is_in_healthy_zone(stat, values[stat]):
			count += 1
	return count
