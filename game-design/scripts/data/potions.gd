extends Node

# Spezialrezepte: Schlüssel ist sortierte Liste der Kraut-IDs als String
# Format: "kraut1,kraut2,kraut3" (alphabetisch sortiert)
const SPECIAL_RECIPES = {
	# Beispiel: 3x Tollkirsche = Gift
	"tollkirsche,tollkirsche,tollkirsche": {
		"name": "Gift der Nacht",
		"effects": {"temperature": 0, "pain": 0, "energy": -50, "stress": 0},
		"color": Color.BLACK,
		"is_special": true,
	},
	# Hier fügst du später deine eigenen Spezialrezepte ein
}


func brew(herb_ids: Array) -> Dictionary:
	# Sortieren für konsistente Lookup
	var sorted_herbs = herb_ids.duplicate()
	sorted_herbs.sort()
	var key = ",".join(sorted_herbs)
	
	# Spezialrezept-Check
	if SPECIAL_RECIPES.has(key):
		var recipe = SPECIAL_RECIPES[key].duplicate(true)
		return recipe
	
	# Standardtrank aus Summen
	return _generate_standard_potion(herb_ids)


func _generate_standard_potion(herb_ids: Array) -> Dictionary:
	var summed_effects = {"temperature": 0, "pain": 0, "energy": 0, "stress": 0}
	
	for herb_id in herb_ids:
		if not Herbs.HERBS.has(herb_id):
			continue
		var herb_effects = Herbs.HERBS[herb_id].get("effects", {})
		for key in herb_effects:
			summed_effects[key] += herb_effects[key]
	
	var color = _calculate_color(herb_ids)
	var name = _get_color_name(color)
	
	return {
		"name": name,
		"effects": summed_effects,
		"color": color,
		"is_special": false,
	}


func _calculate_color(herb_ids: Array) -> Color:
	var r = 0.0
	var g = 0.0
	var b = 0.0
	var count = 0
	
	for herb_id in herb_ids:
		if Herbs.HERBS.has(herb_id):
			var color = Herbs.HERBS[herb_id].color
			r += color.r
			g += color.g
			b += color.b
			count += 1
	
	if count > 0:
		return Color(r / count, g / count, b / count)
	return Color.WHITE


func _get_color_name(color: Color) -> String:
	var r = color.r
	var g = color.g
	var b = color.b
	
	if r > 0.7 and g > 0.7 and b > 0.7:
		return "Heller Trank"
	if r < 0.3 and g < 0.3 and b < 0.3:
		return "Schwarzer Trank"
	if r > 0.5 and g < 0.4 and b > 0.4:
		return "Lila Trank"
	if r > 0.6 and g > 0.5 and b < 0.3:
		return "Oranger Trank"
	if r > g and r > b:
		return "Roter Trank"
	if g > r and g > b:
		return "Grüner Trank"
	if b > r and b > g:
		return "Blauer Trank"
	if r > 0.4 and g > 0.3 and b < 0.3:
		return "Brauner Trank"
	return "Trüber Trank"
