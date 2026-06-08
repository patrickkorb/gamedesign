extends Button

var item_id: String = ""
var item_data: Dictionary = {}

@onready var iconn: TextureRect = $Icon

signal slot_cleared(slot_index: int)
@export var slot_index: int = 0


func _ready() -> void:
	pressed.connect(_on_pressed)
	_refresh()


func set_item(p_item_id: String, p_item_data: Dictionary) -> void:
	item_id = p_item_id
	item_data = p_item_data
	_refresh()


func clear() -> void:
	item_id = ""
	item_data = {}
	_refresh()


func is_empty() -> bool:
	return item_data.is_empty()


func _refresh() -> void:
	if item_data.is_empty():
		iconn.texture = null
	else:
		iconn.texture = item_data.sprite


func _on_pressed() -> void:
	# Klick auf gefüllten Slot leert ihn
	if not item_data.is_empty():
		slot_cleared.emit(slot_index)
