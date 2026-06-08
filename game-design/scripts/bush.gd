extends Area2D

@export var herb_count: int = 1
@export var outline_color: Color = Color.YELLOW
@export var outline_width: float = 2.0

var is_harvested := false
var initial_position: Vector2

@onready var visual: Sprite2D = $Sprite2D


func _ready() -> void:
	initial_position = visual.position
	
	if visual.material is ShaderMaterial:
		visual.material.set_shader_parameter("outline_color", outline_color)
		visual.material.set_shader_parameter("outline_width", outline_width)
		visual.material.set_shader_parameter("outline_enabled", false)
	
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_pickable = true


func _on_mouse_entered() -> void:
	if is_harvested:
		return
	_set_outline(true)


func _on_mouse_exited() -> void:
	_set_outline(false)


func _set_outline(enabled: bool) -> void:
	if visual.material is ShaderMaterial:
		visual.material.set_shader_parameter("outline_enabled", enabled)


func _on_input_event(viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_harvested:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_set_outline(false)
			_shake_and_harvest()
			viewport.set_input_as_handled()


func _shake_and_harvest() -> void:
	is_harvested = true
	
	var tween = create_tween()
	var shake_amount = 4.0
	var shake_duration = 0.05
	
	for i in range(4):
		tween.tween_property(visual, "position:x", initial_position.x + shake_amount, shake_duration)
		tween.tween_property(visual, "position:x", initial_position.x - shake_amount, shake_duration)
	tween.tween_property(visual, "position:x", initial_position.x, shake_duration)
	
	tween.tween_callback(_drop_herb)
	
	# Ausgrauen via Shader-Parameter
	tween.tween_method(_set_gray, 0.0, 1.0, 0.3)


func _set_gray(amount: float) -> void:
	if visual.material is ShaderMaterial:
		visual.material.set_shader_parameter("gray_amount", amount)


func _drop_herb() -> void:
	for i in range(herb_count):
		var herb_id = Herbs.get_random_herb()
		Inventory.add_herb(herb_id)
		_spawn_floating_herb(herb_id, i)


func _spawn_floating_herb(herb_id: String, index: int) -> void:
	var herb_data = Herbs.HERBS[herb_id]
	
	var container = Node2D.new()
	# Leicht zufällige Startposition, damit sich mehrere Herbs nicht überlagern
	var offset = Vector2(randf_range(-15, 15), randf_range(-5, 5))
	container.position = visual.position + offset
	add_child(container)
	
	var herb_sprite = Sprite2D.new()
	herb_sprite.texture = herb_data.sprite
	herb_sprite.scale = Vector2(0.25, 0.25)  # doppelt so groß
	container.add_child(herb_sprite)
	
	var label = Label.new()
	label.text = "+1 " + herb_data.name
	label.position = Vector2(20, -10)
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	container.add_child(label)
	
	# Kleines Delay zwischen den Herbs, damit sie sequenziell starten
	await get_tree().create_timer(index * 0.1).timeout
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(container, "position:y", container.position.y - 40, 0.8)
	tween.tween_property(container, "modulate:a", 0.0, 0.8).set_delay(0.2)
	tween.chain().tween_callback(container.queue_free)
		
func reset() -> void:
	is_harvested = false
	visual.position = initial_position
	_set_gray(0.0)
