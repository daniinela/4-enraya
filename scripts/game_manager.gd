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
	var fondo = ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.9)
	fondo.size = Vector2(1152, 648)
	fondo.position = Vector2(0, 0)
	$CanvasLayer.add_child(fondo)

	var label = Label.new()
	label.position = Vector2(350, 200)
	label.add_theme_font_size_override("font_size", 48)
	if turno_actual == 1:
		label.text = "¡Ganó el Jugador Azul!"
		label.modulate = Color(0.2, 0.4, 1.0)
	else:
		label.text = "¡Ganó el Jugador Rojo!"
		label.modulate = Color(1.0, 0.2, 0.2)
	$CanvasLayer.add_child(label)

	var btn = Button.new()
	btn.text = "Jugar de nuevo"
	btn.position = Vector2(450, 350)
	btn.custom_minimum_size = Vector2(200, 60)
	btn.pressed.connect(_reiniciar_juego)
	$CanvasLayer.add_child(btn)

func _reiniciar_juego():
	get_tree().reload_current_scene()

func actualizar_ui():
	ui.actualizar_turno(turno_actual)

func obtener_conteo_categoria(jugador: int, categoria: String) -> int:
	return conteo_categorias[jugador][categoria]

func incrementar_conteo_categoria(jugador: int, categoria: String):
	conteo_categorias[jugador][categoria] += 1
