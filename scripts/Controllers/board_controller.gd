# scripts/Controllers/board_controller.gd
extends Node2D

signal columna_clickeada(col)
signal bomba_seleccionada(fila, col)
signal escudo_seleccionado(fila, col)
signal accion_post_procesada()

const COLUMNAS = 7
const FILAS = 6

var board_model = null
var board_view = null
var game_controller = null

var juego_terminado = false
var esperando_bomba = false
var esperando_escudo = false
var escudos_restantes = 0

var ruleta_activa = false
var ruleta_indice = 0
var ruleta_es_columna = true
var ruleta_destino = 0
var ruleta_timer = 0.0
var ruleta_velocidad = 0.05
var ruleta_pasos_restantes = 0
var animacion_activa = false

func _ready():
	board_model = load("res://scripts/models/board_model.gd").new()
	board_model.inicializar_tablero()
	board_model.tablero_cambiado.connect(_on_tablero_cambiado)
	print("Hola")

func _on_tablero_cambiado():
	if board_view:
		board_view.renderizar(board_model.tablero, board_model.escudos)

func _process(delta):
	if not ruleta_activa:
		return

	ruleta_timer -= delta

	if ruleta_timer <= 0:
		ruleta_timer = ruleta_velocidad

		if ruleta_es_columna:
			ruleta_indice = (ruleta_indice + 1) % COLUMNAS
		else:
			ruleta_indice = (ruleta_indice + 1) % FILAS

		if board_view:
			board_view.set_ruleta(true, ruleta_es_columna, ruleta_indice)

		ruleta_pasos_restantes -= 1

		if ruleta_pasos_restantes < 10:
			ruleta_velocidad = lerp(ruleta_velocidad, 0.25, 0.2)

		if ruleta_pasos_restantes <= 0:
			ruleta_activa = false

			if board_view:
				board_view.set_ruleta(false, ruleta_es_columna, ruleta_destino)

			await _finalizar_ruleta()

func _finalizar_ruleta():
	animacion_activa = true

	if board_view:
		await board_view.animar_ruleta_final(
			ruleta_destino,
			ruleta_es_columna,
			board_model.tablero,
			board_model.escudos
		)

	if ruleta_es_columna:
		board_model.borrar_columna(ruleta_destino)
	else:
		board_model.borrar_fila(ruleta_destino)

	animacion_activa = false
	accion_post_procesada.emit()

func iniciar_ruleta_visual():
	ruleta_es_columna = randi() % 2 == 0
	ruleta_destino = randi() % (COLUMNAS if ruleta_es_columna else FILAS)
	ruleta_pasos_restantes = 30 + randi() % 20
	ruleta_timer = 0.05
	ruleta_activa = true

func _input(event):
	if juego_terminado or ruleta_activa or animacion_activa:
		return

	if not game_controller or not game_controller.juego_activo:
		return

	if game_controller.bloqueado:
		return

	if event is InputEventMouseButton and event.pressed:
		var pos = get_global_mouse_position()

		if esperando_escudo:
			var r = board_view.obtener_hueco_click(pos)
			if r.x >= 0:
				escudo_seleccionado.emit(r.x, r.y)
			return

		if esperando_bomba:
			var r = board_view.obtener_hueco_click(pos)
			if r.x >= 0:
				bomba_seleccionada.emit(r.x, r.y)
				esperando_bomba = false
			return

		var col = board_view.obtener_columna_click(pos)
		if col >= 0:
			columna_clickeada.emit(col)
