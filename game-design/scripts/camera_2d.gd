extends Camera2D

var dragging := false
var drag_start_mouse_pos := Vector2.ZERO
var drag_start_camera_pos := Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	# Maustaste gedrückt/losgelassen
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_start_mouse_pos = get_viewport().get_mouse_position()
			drag_start_camera_pos = position
		else:
			dragging = false

	# Maus bewegt sich während Drag
	elif event is InputEventMouseMotion and dragging:
		var mouse_delta = get_viewport().get_mouse_position() - drag_start_mouse_pos
		position = drag_start_camera_pos - mouse_delta / zoom
