extends CanvasLayer

@onready var top_bar: Control = $TopBar
@onready var back_button: Button = $TopBar/BackButton
@onready var inventory_button: Button = $TopBar/InventoryButton
@onready var book: Control = $BookInventory

# Pfad zur Map-Szene, damit "Zurück" weiß wo es hin soll
@export var map_scene: PackedScene


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	inventory_button.pressed.connect(_toggle_book)
	
	# Wenn die Szene wechselt, prüfen ob Top Bar versteckt werden soll
	get_tree().node_added.connect(_on_scene_changed)
	_update_top_bar_visibility()


func _on_back_pressed() -> void:
	if map_scene:
		get_tree().change_scene_to_packed(map_scene)


func _toggle_book() -> void:
	if book.visible:
		book._deselect_all()
		book._show_empty_state()
		if book.in_treatment_mode:
			book.close_treatment()
		else:
			book.visible = false
	else:
		book.visible = true
		book._refresh()
	


func _update_top_bar_visibility() -> void:
	# Top Bar verstecken wenn aktuelle Szene die Map ist
	var current_scene = get_tree().current_scene
	if current_scene == null:
		return
	
	# Check ob aktuelle Szene "Map" heißt – pass das deinem Map-Namen an
	if current_scene.name == "Map":
		top_bar.visible = false
	else:
		top_bar.visible = true


func _on_scene_changed(node: Node) -> void:
	# Wird aufgerufen wenn neue Nodes hinzugefügt werden
	# Wir prüfen, ob es die neue Hauptszene ist
	if node == get_tree().current_scene:
		_update_top_bar_visibility()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_I:
			_toggle_book()
		elif event.keycode == KEY_ESCAPE and book.visible:
			book.visible = false

func refresh_top_bar() -> void:
	_update_top_bar_visibility()
