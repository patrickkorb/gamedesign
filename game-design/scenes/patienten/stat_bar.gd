extends VBoxContainer

@onready var name_label: Label = $NameLabel
@onready var progress_bar: ProgressBar = $BarContainer/ProgressBar


func set_stat(display_name: String, value: int) -> void:
	name_label.text = display_name
	# Echter Wert, kein Runden auf Stufen mehr
	progress_bar.value = value


func _value_to_level(value: int) -> int:
	if value <= 14:
		return 0
	elif value <= 39:
		return 1
	elif value <= 60:
		return 2
	elif value <= 85:
		return 3
	else:
		return 4
