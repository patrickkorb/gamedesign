extends Area2D

@export var target_scene: PackedScene
@export var area_name: String = "Bereich"
@export var outline_color: Color = Color.YELLOW
@export var outline_width: float = 3.0
@export var glow_layers: int = 4         # Anzahl der Glow-Schichten
@export var glow_spread: float = 8.0     # Wie weit der Glow nach außen geht

@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D
@onready var outline: Line2D = $Outline
@onready var name_label: Label = $NameLabel

var glow_lines: Array[Line2D] = []
var is_hovered := false


func _ready() -> void:
	var points = collision_polygon.polygon
	
	# Haupt-Outline (scharf, oben drauf)
	outline.points = points
	if points.size() > 0:
		outline.add_point(points[0])
	outline.default_color = outline_color
	outline.width = outline_width
	outline.visible = false
	
	# Glow-Layer drunter erzeugen
	for i in range(glow_layers):
		var glow = Line2D.new()
		glow.points = outline.points
		# Jede Schicht ist breiter und transparenter
		var factor = float(i + 1) / glow_layers
		glow.width = outline_width + glow_spread * (i + 1)
		glow.default_color = Color(outline_color.r, outline_color.g, outline_color.b, 0.15 * (1.0 - factor))
		glow.visible = false
		# Wichtig: Glow muss UNTER der Haupt-Outline gezeichnet werden
		add_child(glow)
		move_child(glow, outline.get_index())  # Vor outline einsortieren
		glow_lines.append(glow)
	
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
		input_event.connect(_on_input_event)
		
			# Label vorbereiten
		name_label.text = area_name
		name_label.visible = false
		
		# Label in der Mitte des Polygons platzieren
		name_label.position = _get_polygon_center(collision_polygon.polygon)
		# Label-Größe schätzen und um halbe Breite/Höhe verschieben
		# Da Label.size erst nach einem Frame korrekt ist, machen wir's anders:
		name_label.pivot_offset = name_label.size / 2
		name_label.position -= name_label.size / 2


func _on_mouse_entered() -> void:
	is_hovered = true
	outline.visible = true
	for glow in glow_lines:
		glow.visible = true
	
	name_label.visible = true
	name_label.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(name_label, "modulate:a", 1.0, 0.15)



func _on_mouse_exited() -> void:
	is_hovered = false
	outline.visible = false
	for glow in glow_lines:
		glow.visible = false
	
	var tween = create_tween()
	tween.tween_property(name_label, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func(): name_label.visible = false)

func _on_input_event(viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_clicked()
			viewport.set_input_as_handled()


func _on_clicked() -> void:
	if target_scene:
		get_tree().change_scene_to_packed(target_scene)
		HUD.refresh_top_bar()
		
func _get_polygon_center(points: PackedVector2Array) -> Vector2:
	if points.is_empty():
		return Vector2.ZERO
	var sum = Vector2.ZERO
	for p in points:
		sum += p
	return sum / points.size()
