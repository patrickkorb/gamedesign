extends Node

const HERBS = {
	"baldrian": {
		"name": "Baldrian",
		"color": Color.PURPLE,
		"rarity": 1.0,
		"sprite": preload("res://assets/sprites/herbs/baldrian.png"),
		"effects": {
			"temperature": -5,
			"pain": 0,
			"energy": -10,
			"stress": -15,
		},
	},
	"beinwell": {
		"name": "Beinwell",
		"color": Color.WHITE,
		"rarity": 1.0,
		"sprite": preload("res://assets/sprites/herbs/beinwell.png"),
		"effects": {
			"temperature": 0,
			"pain": -15,
			"energy": -0,
			"stress": 0,
		},
	},
	"johanniskraut": {
		"name": "Johanniskraut",
		"color": Color.YELLOW,
		"rarity": 1.0,
		"sprite": preload("res://assets/sprites/herbs/johanniskraut.png"),
		"effects": {
			"temperature": 0,
			"pain": 0,
			"energy": 15,
			"stress": -10,
		},
	},
	"schafgarbe": {
		"name": "Schafgarbe",
		"color": Color.LIGHT_GRAY,
		"rarity": 0.8,
		"sprite": preload("res://assets/sprites/herbs/schafgarbe.png"),
		"effects": {
			"temperature": -15,
			"pain": 0,
			"energy": 0,
			"stress": 0,
		},
	},
	"tollkirsche": {
		"name": "Tollkirsche",
		"color": Color.DARK_RED,
		"rarity": 0.5,
		"sprite": preload("res://assets/sprites/herbs/tollkirsche.png"),
		"effects": {
			"temperature": 10,
			"pain": -20,
			"energy": 15,
			"stress": 15,
		},
	},
}


static func get_random_herb() -> String:
	var total_weight := 0.0
	for key in HERBS:
		total_weight += HERBS[key].rarity
	
	var roll = randf() * total_weight
	var current := 0.0
	
	for key in HERBS:
		current += HERBS[key].rarity
		if roll <= current:
			return key
	
	return HERBS.keys()[0]
