extends Node2D

@onready var label_turno = $LabelTurno
@onready var label_comodines_j1 = $LabelComodinesJ1
@onready var label_comodines_j2 = $LabelComodinesJ2

func _ready():
	label_turno.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_comodines_j1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_comodines_j2.mouse_filter = Control.MOUSE_FILTER_IGNORE

func actualizar_turno(jugador: int):
	if jugador == 1:
		label_turno.text = "Turno: Jugador Azul"
		label_turno.modulate = Color(0.2, 0.4, 1.0)
	else:
		label_turno.text = "Turno: Jugador Rojo"
		label_turno.modulate = Color(1.0, 0.2, 0.2)

func actualizar_comodines(comodines: Dictionary):
	label_comodines_j1.text = "Comodines Azul: " + str(comodines[1])
	label_comodines_j2.text = "Comodines Rojo: " + str(comodines[2])

func mostrar_ganador(jugador: int):
	if jugador == 1:
		label_turno.text = "¡Ganó el Jugador Azul!"
		label_turno.modulate = Color(0.2, 0.4, 1.0)
	else:
		label_turno.text = "¡Ganó el Jugador Rojo!"
		label_turno.modulate = Color(1.0, 0.2, 0.2)

func mostrar_mensaje(texto: String):
	label_turno.text = texto
	label_turno.modulate = Color(1.0, 1.0, 0.0)
