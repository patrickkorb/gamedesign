extends TextureButton

@export var texture_small: Texture2D
@export var texture_large: Texture2D
@export var category: String = ""

var is_active: bool = false

signal bookmark_pressed(category: String)


func _ready() -> void:
	pressed.connect(_on_pressed)
	_apply_state()


func set_active(active: bool) -> void:
	is_active = active
	_apply_state()


func _apply_state() -> void:
	if is_active:
		texture_normal = texture_large
	else:
		texture_normal = texture_small


func _on_pressed() -> void:
	bookmark_pressed.emit(category)
