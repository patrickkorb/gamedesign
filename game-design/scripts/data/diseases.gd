extends Node

const HEALTHY_ZONES = {
	"temperature": {"min": 40, "max": 60},  # Mitte: zu kalt und zu heiß schlecht
	"pain": {"min": 0, "max": 20},          # Unten: kein Schmerz ist gut
	"energy": {"min": 40, "max": 70},       # Mitte-hoch: kraftlos und überdreht schlecht
	"stress": {"min": 0, "max": 30},        # Unten: wenig Stress ist gut
}

# Krankheiten: Startwerte für die vier Werte
const DISEASES = {
	"fieber": {
		"name": "Das Fieber",
		"start_values": {"temperature": 85, "pain": 10, "energy": 20, "stress": 20},
	},
	"wundbrand": {
		"name": "Der Wundbrand",
		"start_values": {"temperature": 70, "pain": 90, "energy": 50, "stress": 30},
	},
	"schwindsucht": {
		"name": "Die Schwindsucht",
		"start_values": {"temperature": 50, "pain": 20, "energy": 15, "stress": 75},
	},
	"kolik": {
		"name": "Die Kolik",
		"start_values": {"temperature": 50, "pain": 80, "energy": 75, "stress": 70},
	},
	"schuettelfrost": {
		"name": "Der Schüttelfrost",
		"start_values": {"temperature": 15, "pain": 50, "energy": 45, "stress": 65},
	},
	"burnout": {
		"name": "Burnout",
		"start_values": {"temperature": 40, "pain": 10, "energy": 25, "stress": 90},
	},
	"pest": {
		"name": "Burnout",
		"start_values": {"temperature": 80, "pain": 80, "energy": 20, "stress": 80},
	},
}

# Hilfsfunktionen
func is_in_healthy_zone(stat: String, value: int) -> bool:
	if not HEALTHY_ZONES.has(stat):
		return false
	var zone = HEALTHY_ZONES[stat]
	return value >= zone.min and value <= zone.max

func get_zone(stat: String) -> Dictionary:
	return HEALTHY_ZONES.get(stat, {"min": 40, "max": 60})
	
func get_random_disease() -> String:
	return DISEASES.keys().pick_random()
