# scripts/views/ui_view.gd
extends Node2D

# ─────────────────────────────
# 🖥️ REFERENCIAS A UI
# ─────────────────────────────

@onready var label_turno = $LabelTurno
@onready var label_comodines_j1 = $LabelComodinesJ1
@onready var label_comodines_j2 = $LabelComodinesJ2


# ─────────────────────────────
# 🚀 INICIALIZACIÓN
# ─────────────────────────────

func _ready():
	# Permite que los clics pasen a través de los labels
	# (evita bloquear interacción con el tablero)
	label_turno.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_comodines_j1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_comodines_j2.mouse_filter = Control.MOUSE_FILTER_IGNORE


# ─────────────────────────────
# 🔁 MOSTRAR TURNO ACTUAL
# ─────────────────────────────

func mostrar_turno(jugador: int) -> void:
	var nombre = Global.Jugador1 if jugador == 1 else Global.Jugador2
	var personaje = Global.personaje_jugador1 if jugador == 1 else Global.personaje_jugador2

	label_turno.text = "Turno: " + nombre

	# Cambia color según personaje
	label_turno.modulate = _color_jugador(personaje)


# ─────────────────────────────
# 🏆 MOSTRAR GANADOR
# ─────────────────────────────

func mostrar_ganador(jugador: int) -> void:
	var nombre = Global.Jugador1 if jugador == 1 else Global.Jugador2
	var personaje = Global.personaje_jugador1 if jugador == 1 else Global.personaje_jugador2

	label_turno.text = "¡Ganó " + nombre + "!"
	label_turno.modulate = _color_jugador(personaje)


# ─────────────────────────────
# 💬 MENSAJES GENERALES
# ─────────────────────────────

func mostrar_mensaje(texto: String) -> void:
	label_turno.text = texto

	# Color amarillo para mensajes neutrales
	label_turno.modulate = Color(1.0, 1.0, 0.0)


# ─────────────────────────────
# 🎁 ACTUALIZAR COMODINES
# ─────────────────────────────

func actualizar_comodines(comodines: Dictionary) -> void:
	label_comodines_j1.text = "Comodines Azul: " + str(comodines[1])
	label_comodines_j2.text = "Comodines Rojo: " + str(comodines[2])


# ─────────────────────────────
# 🎨 COLOR POR PERSONAJE
# ─────────────────────────────

func _color_jugador(personaje: String) -> Color:
	# Si es "denji" → dorado
	# Si no → morado
	return Color(1.0, 0.85, 0.0) if personaje == "denji" else Color(0.7, 0.2, 1.0)
