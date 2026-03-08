#game_manager.gd
extends Node2D

var turno_actual = 1
var juego_activo = true
var turno_saltado = false
var bloqueado = false

@onready var tablero = $Board
@onready var ui = $CanvasLayer/UI

var trivia_scene = preload("res://scenes/Trivia.tscn")
var comodines_scene = preload("res://scenes/Comodines.tscn")

var conteo_categorias = {
	1: {"programacion": 0, "ciencia": 0, "entretenimiento": 0, "arte": 0},
	2: {"programacion": 0, "ciencia": 0, "entretenimiento": 0, "arte": 0}
}

func _ready():
	tablero.game_manager = self
	actualizar_ui()

func cambiar_turno():
	if not juego_activo:
		return
	bloqueado = false
	if turno_actual == 1:
		turno_actual = 2
	else:
		turno_actual = 1
	if turno_saltado:
		turno_saltado = false
		bloqueado = true
		ui.mostrar_mensaje("¡Turno saltado!")
		await get_tree().create_timer(1.0).timeout
		if not juego_activo:
			return
		if turno_actual == 1:
			turno_actual = 2
		else:
			turno_actual = 1
		bloqueado = false
	actualizar_ui()

func iniciar_trivia():
	bloqueado = true
	var trivia = trivia_scene.instantiate()
	trivia.name = "Trivia"
	$CanvasLayer.add_child(trivia)
	trivia.jugador_actual = turno_actual
	trivia.juego = self

func resultado_trivia(gano: bool):
	if gano:
		tablero.resultado_trivia_trampa(true)
		if not tablero.juego_terminado:
			await get_tree().create_timer(0.3).timeout
			mostrar_seleccion_comodin()
	else:
		bloqueado = false
		tablero.resultado_trivia_trampa(false)

func mostrar_seleccion_comodin():
	bloqueado = true
	var comodines = comodines_scene.instantiate()
	comodines.name = "Comodines"
	$CanvasLayer.add_child(comodines)
	comodines.juego = self
	comodines.jugador_actual = turno_actual

func aplicar_comodin(tipo: String):
	match tipo:
		"bomba":
			bloqueado = false
			ui.mostrar_mensaje("¡Elige una casilla para la BOMBA!")
			tablero.esperando_bomba = true
		"saltar_turno":
			bloqueado = true
			turno_saltado = true
			cambiar_turno()
		"escudo":
			bloqueado = false
			ui.mostrar_mensaje("¡Clic en hasta 2 fichas tuyas para proteger!")
			tablero.esperando_escudo = true
			tablero.escudos_restantes = 2

func jugador_gano():
	juego_activo = false
	bloqueado = true
	ui.mostrar_ganador(turno_actual)
	await get_tree().create_timer(2.0).timeout
	mostrar_pantalla_victoria()

func mostrar_pantalla_victoria():
	var fuente_bangers = load("res://assets/fonts/Bangers-Regular.ttf")
	var fondo = ColorRect.new()
	fondo.color = Color(0.05, 0.05, 0.15, 0.95)
	fondo.size = Vector2(1800, 900)
	fondo.position = Vector2(0, 0)
	$CanvasLayer.add_child(fondo)
	var label = Label.new()
	label.position = Vector2(400, 280)
	label.add_theme_font_override("font", fuente_bangers)
	label.add_theme_font_size_override("font_size", 80)
	var nombre_ganador = Global.Jugador1 if turno_actual == 1 else Global.Jugador2
	var personaje_ganador = Global.personaje_jugador1 if turno_actual == 1 else Global.personaje_jugador2
	label.text = "🏆 ¡GANÓ " + nombre_ganador.to_upper() + "! 🏆"
	if personaje_ganador == "denji":
		label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	else:
		label.add_theme_color_override("font_color", Color(0.7, 0.2, 1.0))
	$CanvasLayer.add_child(label)
	var btn = Button.new()
	btn.text = "JUGAR DE NUEVO"
	btn.position = Vector2(600, 480)
	btn.custom_minimum_size = Vector2(300, 80)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.5)
	style.border_color = Color(0.6, 0.3, 1.0)
	style.set_border_width_all(4)
	style.set_corner_radius_all(16)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_font_override("font", fuente_bangers)
	btn.add_theme_font_size_override("font_size", 36)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.pressed.connect(_reiniciar_juego)
	$CanvasLayer.add_child(btn)
	
func _reiniciar_juego():
	get_tree().reload_current_scene()

func actualizar_ui():
	ui.actualizar_turno(turno_actual)
	var denji = $PersonajeDenji
	var reze = $PersonajeReze
	var personaje_turno_actual = Global.personaje_jugador1 if turno_actual == 1 else Global.personaje_jugador2
	if personaje_turno_actual == "denji":
		denji.activar_turno()
		reze.desactivar_turno()
	else:
		reze.activar_turno()
		denji.desactivar_turno()

func obtener_conteo_categoria(jugador: int, categoria: String) -> int:
	return conteo_categorias[jugador][categoria]

func incrementar_conteo_categoria(jugador: int, categoria: String):
	conteo_categorias[jugador][categoria] += 1
	
	
func juego_empate():
	juego_activo = false
	bloqueado = true
	await get_tree().create_timer(1.0).timeout
	var fuente_bangers = load("res://assets/fonts/Bangers-Regular.ttf")
	var fondo = ColorRect.new()
	fondo.color = Color(0.05, 0.05, 0.15, 0.95)
	fondo.size = Vector2(1800, 900)
	fondo.position = Vector2(0, 0)
	$CanvasLayer.add_child(fondo)
	var label = Label.new()
	label.text = "🤝 ¡EMPATE! 🤝"
	label.position = Vector2(500, 280)
	label.add_theme_font_override("font", fuente_bangers)
	label.add_theme_font_size_override("font_size", 80)
	label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	$CanvasLayer.add_child(label)
	var btn = Button.new()
	btn.text = "JUGAR DE NUEVO"
	btn.position = Vector2(600, 480)
	btn.custom_minimum_size = Vector2(300, 80)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.5)
	style.border_color = Color(0.4, 0.6, 1.0)
	style.set_border_width_all(4)
	style.set_corner_radius_all(16)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_font_override("font", fuente_bangers)
	btn.add_theme_font_size_override("font_size", 36)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.pressed.connect(_reiniciar_juego)
	$CanvasLayer.add_child(btn)
