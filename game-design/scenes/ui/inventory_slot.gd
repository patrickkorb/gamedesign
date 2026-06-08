extends Button

var item_id: String = ""
var item_data: Dictionary = {}
var item_count: int = 0
var is_selected: bool = false

@onready var icon_slot: TextureRect = $Icon
@onready var count_label: Label = $CountLabel
@onready var hover_frame: TextureRect = $HoverFrame
@onready var selected_frame: TextureRect = $SelectedFrame

signal item_selected(item_id: String, item_data: Dictionary)


func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	hover_frame.visible = false
	selected_frame.visible = false
	
	_refresh()


func set_item(p_item_id: String, p_item_data: Dictionary, p_count: int) -> void:
	item_id = p_item_id
	item_data = p_item_data
	item_count = p_count
	if is_node_ready():
		_refresh()


func clear() -> void:
	item_id = ""
	item_data = {}
	item_count = 0
	if is_node_ready():
		_refresh()


func _refresh() -> void:
	if item_data.is_empty():
		icon_slot.texture = null
		count_label.text = ""
		icon_slot.modulate = Color.WHITE
	else:
		count_label.text = "x%d" % item_count
		
		# Check ob es ein Trank ist (hat "color") oder ein Kraut (hat "sprite")
		if item_data.has("color") and not item_data.has("sprite"):
			# Trank: generisches Trank-Sprite mit Farbe modulieren
			icon_slot.texture = preload("res://assets/sprites/potions/potion_generic.png")
			icon_slot.modulate = item_data.color
		elif item_data.has("sprite"):
			# Kraut: eigenes Sprite, normale Modulate
			icon_slot.texture = item_data.sprite
			icon_slot.modulate = Color.WHITE


# --- Auswahl-Logik ---

func set_selected(value: bool) -> void:
	is_selected = value
	selected_frame.visible = value
	# Wenn ausgewählt: Hover-Frame ausblenden (sonst doppelte Frames)
	if value:
		hover_frame.visible = false


func _on_mouse_entered() -> void:
	if not is_selected:
		hover_frame.visible = true


func _on_mouse_exited() -> void:
	hover_frame.visible = false


func _on_pressed() -> void:
	if not item_data.is_empty():
		item_selected.emit(item_id, item_data)
