# scripts/views/ui_view.gd
extends Node2D

@onready var label_turno = $LabelTurno
@onready var label_comodines_j1 = $LabelComodinesJ1
@onready var label_comodines_j2 = $LabelComodinesJ2

# Referencia al canvas de victoria para poder destruirlo
var _canvas_victoria: CanvasLayer = null


func _ready():
	label_turno.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_comodines_j1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_comodines_j2.mouse_filter = Control.MOUSE_FILTER_IGNORE


func mostrar_turno(jugador: int) -> void:
	var nombre = Global.Jugador1 if jugador == 1 else Global.Jugador2
	var personaje = Global.personaje_jugador1 if jugador == 1 else Global.personaje_jugador2
	label_turno.text = "Turno: " + nombre
	label_turno.modulate = _color_jugador(personaje)


func mostrar_ganador(jugador: int) -> void:
	if jugador == -1:
		label_turno.text = "¡Empate!"
		label_turno.modulate = Color(1.0, 1.0, 0.0)
	else:
		var nombre = Global.Jugador1 if jugador == 1 else Global.Jugador2
		var personaje = Global.personaje_jugador1 if jugador == 1 else Global.personaje_jugador2
		label_turno.text = "¡Ganó " + nombre + "!"
		label_turno.modulate = _color_jugador(personaje)


func mostrar_pantalla_victoria(ganador: int) -> void:
	mostrar_ganador(ganador)

	# FIX: se guarda referencia al canvas para poder destruirlo
	# antes de cambiar de escena. Antes se creaba y se olvidaba,
	# quedando pegado a root indefinidamente.
	_canvas_victoria = CanvasLayer.new()
	_canvas_victoria.layer = 10
	get_tree().root.add_child(_canvas_victoria)

	var fondo = ColorRect.new()
	fondo.color = Color(0.0, 0.0, 0.1, 0.88)
	fondo.size = Vector2(1800, 900)
	fondo.position = Vector2.ZERO
	fondo.mouse_filter = Control.MOUSE_FILTER_STOP
	_canvas_victoria.add_child(fondo)

	var fuente_bangers = load("res://assets/fonts/Bangers-Regular.ttf")
	var fuente_cinzel  = load("res://assets/fonts/Cinzel-Bold.ttf")

	var titulo = Label.new()
	titulo.position = Vector2(0, 180)
	titulo.size = Vector2(1800, 120)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_override("font", fuente_bangers)
	titulo.add_theme_font_size_override("font_size", 96)

	if ganador == -1:
		titulo.text = "¡EMPATE!"
		titulo.add_theme_color_override("font_color", Color(1.0, 1.0, 0.3))
	else:
		var nombre = Global.Jugador1 if ganador == 1 else Global.Jugador2
		var personaje = Global.personaje_jugador1 if ganador == 1 else Global.personaje_jugador2
		titulo.text = "¡" + nombre + " GANÓ!"
		titulo.add_theme_color_override("font_color", _color_jugador(personaje))

	_canvas_victoria.add_child(titulo)

	var sub = Label.new()
	sub.position = Vector2(0, 310)
	sub.size = Vector2(1800, 60)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_override("font", fuente_cinzel)
	sub.add_theme_font_size_override("font_size", 30)
	sub.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	sub.text = "¡Partida finalizada!"
	_canvas_victoria.add_child(sub)

	# Tres botones centrados horizontalmente
	# 1800 / 4 = 450 por sección → posiciones: 75, 525, 975
	var btn_menu = _boton_victoria("🏠  Menú", Vector2(75, 500), Color(0.2, 0.5, 1.0), fuente_bangers)
	btn_menu.pressed.connect(_ir_a_menu)
	_canvas_victoria.add_child(btn_menu)

	var btn_rev = _boton_victoria("⚔️  Revancha", Vector2(525, 500), Color(1.0, 0.3, 0.15), fuente_bangers)
	btn_rev.pressed.connect(_ir_a_revancha)
	_canvas_victoria.add_child(btn_rev)

	var btn_salir = _boton_victoria("🚪  Salir", Vector2(975, 500), Color(0.4, 0.4, 0.4), fuente_bangers)
	btn_salir.pressed.connect(_salir)
	_canvas_victoria.add_child(btn_salir)


func _ir_a_menu():
	# FIX: destruir el canvas ANTES de cambiar escena.
	# Si se cambia primero, el canvas queda en root y se ve
	# encima del menú porque no pertenece a la escena que se destruye.
	if _canvas_victoria:
		_canvas_victoria.queue_free()
		_canvas_victoria = null
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")


func _ir_a_revancha():
	# Igual: destruir canvas antes de recargar la escena del juego.
	# Sin esto el canvas del juego anterior se superpone al nuevo.
	if _canvas_victoria:
		_canvas_victoria.queue_free()
		_canvas_victoria = null
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _salir():
	get_tree().quit()


func _boton_victoria(texto: String, pos: Vector2, color: Color, fuente: FontFile) -> Button:
	var btn = Button.new()
	btn.text = texto
	btn.position = pos
	btn.custom_minimum_size = Vector2(340, 90)

	var sn = StyleBoxFlat.new()
	sn.bg_color = color.darkened(0.3)
	sn.border_color = color
	sn.set_border_width_all(4)
	sn.set_corner_radius_all(16)
	btn.add_theme_stylebox_override("normal", sn)

	var sh = StyleBoxFlat.new()
	sh.bg_color = color
	sh.border_color = color.lightened(0.4)
	sh.set_border_width_all(4)
	sh.set_corner_radius_all(16)
	btn.add_theme_stylebox_override("hover", sh)

	btn.add_theme_font_override("font", fuente)
	btn.add_theme_font_size_override("font_size", 32)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))

	return btn


func mostrar_mensaje(texto: String) -> void:
	label_turno.text = texto
	label_turno.modulate = Color(1.0, 1.0, 0.0)


func actualizar_comodines(comodines: Dictionary) -> void:
	label_comodines_j1.text = "Comodines Azul: " + str(comodines[1])
	label_comodines_j2.text = "Comodines Rojo: " + str(comodines[2])


func _color_jugador(personaje: String) -> Color:
	return Color(1.0, 0.85, 0.0) if personaje == "denji" else Color(0.7, 0.2, 1.0)
