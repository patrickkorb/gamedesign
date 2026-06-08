extends Button

var item_id: String = ""
var item_data: Dictionary = {}
var item_count: int = 0

@onready var iconn: TextureRect = $Icon
@onready var count_label: Label = $CountLabel

signal ingredient_clicked(item_id: String, item_data: Dictionary)


func _ready() -> void:
	pressed.connect(_on_pressed)
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
		iconn.texture = null
		count_label.text = ""
	else:
		iconn.texture = item_data.sprite
		count_label.text = "x%d" % item_count


func _on_pressed() -> void:
	if not item_data.is_empty():
		ingredient_clicked.emit(item_id, item_data)
