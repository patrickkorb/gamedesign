extends Control

@export var patient_name: String = "Bauer Heinrich"
@export var disease_id: String = "fieber"

@onready var patient_view: Control = $Patient


func _ready() -> void:
	var p = Patient.new(patient_name, disease_id)
	print("Patient erstellt: ", p.patient_name, " | Werte: ", p.values)
	print("Symptome: ", p.get_active_symptoms())
	
	patient_view.set_patient(p)
	patient_view.treatment_ended.connect(_on_treatment_ended)


func _on_treatment_ended() -> void:
	print("Behandlung beendet")
