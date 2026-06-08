extends Node

# Stufen-Grenzen (gesunde Zone ist 40-60)
# kritisch_niedrig: 0-14
# niedrig:          15-39
# (gesund:          40-60 → kein Symptom)
# hoch:             61-85
# kritisch_hoch:    86-100

const SYMPTOMS = {
	"temperature": {
		"critical_low": [
			"Die Lippen sind blau, er rührt sich kaum noch.",
			"Eiskalt ist die Haut, als läge er schon im Grab.",
			"Er ist starr vor Kälte und antwortet nicht mehr.",
		],
		"low": [
			"Er zittert und klappert mit den Zähnen.",
			"Fröstelnd zieht er die Decke enger um sich.",
			"Die Hände sind kalt wie Flusssteine im Winter.",
		],
		"high": [
			"Er glüht und der Schweiß steht ihm auf der Stirn.",
			"Heiß ist die Haut, das Hemd klebt ihm am Leib.",
			"Sein Gesicht ist rot und brennt unter der Hand.",
		],
		"critical_high": [
			"Er glüht wie ein Schmiedeofen, die Augen sind glasig.",
			"Das Fieber kocht in ihm, er faselt wirres Zeug.",
			"So heiß, dass man meint, Wasser auf ihm verdampfe.",
		],
	},
	"pain": {
		"critical_low": [
			"Er spürt rein gar nichts mehr, kein Kneifen, kein Stechen.",
			"Wie betäubt liegt er da, als gehöre der Körper nicht ihm.",
			"Man könnte ihn zwicken und er merkte es nicht.",
		],
		"low": [
			"Die Schmerzen sind erträglich, er wirkt gelöst.",
			"Nur ein dumpfes Ziehen plagt ihn noch.",
			"Er seufzt, aber es scheint auszuhalten.",
		],
		"high": [
			"Er presst die Zähne zusammen und stöhnt leise.",
			"Jede Bewegung lässt ihn zusammenzucken.",
			"Mit verzerrtem Gesicht hält er sich die Seite.",
		],
		"critical_high": [
			"Er schreit und krümmt sich, kaum zu bändigen.",
			"Vor Schmerz wirft er sich hin und her wie ein Besessener.",
			"Tränen schießen ihm in die Augen, er fleht um Erlösung.",
		],
	},
	"energy": {
		"critical_low": [
			"Er liegt wie tot, kein Finger rührt sich.",
			"So kraftlos, dass er den Kopf nicht heben kann.",
			"Die Lider fallen ihm zu, er gleitet weg.",
		],
		"low": [
			"Müde und matt sinkt er in die Kissen.",
			"Jedes Wort kostet ihn sichtlich Mühe.",
			"Schlapp hängt er in den Seilen, als hätte er tagelang gepflügt.",
		],
		"high": [
			"Unruhig zappelt er herum, findet keine Ruhe.",
			"Seine Augen flackern, er ist seltsam aufgekratzt.",
			"Er redet zu schnell und fuchtelt mit den Armen.",
		],
		"critical_high": [
			"Er springt fast vom Lager, völlig überdreht.",
			"Wild zuckt er umher, als hätte er Glut verschluckt.",
			"Kaum zu halten, er schwatzt ohne Punkt und Komma.",
		],
	},
	"stress": {
		"critical_low": [
			"Stumpf starrt er ins Leere, nichts berührt ihn mehr.",
			"Teilnahmslos liegt er da, als wäre die Seele schon fort.",
			"Er nimmt die Welt nicht mehr wahr, ganz in sich versunken.",
		],
		"low": [
			"Er wirkt ruhig und gefasst.",
			"Friedlich atmet er, die Stirn ist geglättet.",
			"Gelassen blickt er dich an, ohne Furcht.",
		],
		"high": [
			"Nervös zupft er an der Decke und blickt sich um.",
			"Seine Hände zittern, er kann nicht still liegen.",
			"Ängstlich fragt er immer wieder, ob er sterben müsse.",
		],
		"critical_high": [
			"Panisch krallt er sich an dir fest und schreit.",
			"Von Sinnen vor Angst will er fliehen und stürzt fast.",
			"Er wimmert und fleht, die Augen weit aufgerissen.",
		],
	},
}



func get_level(stat: String, value: int) -> String:
	var zone = Diseases.get_zone(stat)
	var zone_min = zone.min
	var zone_max = zone.max
	
	if value >= zone_min and value <= zone_max:
		return ""  # gesund
	
	if value < zone_min:
		# Drunter – wie weit?
		var distance = zone_min - value
		if distance > 25:
			return "critical_low"
		else:
			return "low"
	else:
		# Drüber – wie weit?
		var distance = value - zone_max
		if distance > 25:
			return "critical_high"
		else:
			return "high"


# Liefert einen zufälligen Symptomtext für einen Wert.
# Gibt "" zurück wenn der Wert gesund ist.
func get_symptom_text(stat: String, value: int) -> String:
	var level = get_level(stat, value)
	if level == "":
		return ""
	if not SYMPTOMS.has(stat):
		return ""
	var texts: Array = SYMPTOMS[stat][level]
	return texts.pick_random()
