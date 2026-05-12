extends Node2D

var state
var board_ctrl
var ui_view

var trivia_scene = preload("res://scenes/Trivia.tscn")
var comodin_scene = preload("res://scenes/Comodines.tscn")

var _ultima_fila: int = -1
var _ultima_col: int = -1

func _ready():
	state = load("res://scripts/models/game_state.gd").new()
	add_child(state)

	board_ctrl = $Board
	ui_view = $CanvasLayer/UI

	board_ctrl.game_controller = self

	board_ctrl.columna_clickeada.connect(_on_columna_clickeada)
	board_ctrl.bomba_seleccionada.connect(_on_bomba)
	board_ctrl.escudo_seleccionado.connect(_on_escudo)
	board_ctrl.ruleta_finalizada.connect(_post_accion)

	state.turno_cambiado.connect(_on_turno_cambiado)
	state.juego_terminado.connect(_on_juego_terminado)

	ui_view.mostrar_turno(state.turno_actual)

func _on_columna_clickeada(col):
	if not state.juego_activo or state.bloqueado:
		return

	var fila = board_ctrl.board_model.obtener_fila_disponible(col)
	if fila == -1:
		return

	state.bloqueado = true

	board_ctrl.board_model.colocar_ficha(fila, col, state.turno_actual)

	_ultima_fila = fila
	_ultima_col = col

	if board_ctrl.board_model.verificar_victoria(state.turno_actual):
		_terminar_juego(state.turno_actual)
		return

	if board_ctrl.board_model.tablero_lleno():
		_terminar_juego(-1)
		return

	if randi() % 2 == 0:
		_iniciar_trivia(col, fila)
	else:
		state.cambiar_turno()

func _iniciar_trivia(col, fila):
	var trivia = trivia_scene.instantiate()
	$CanvasLayer.add_child(trivia)

	trivia.jugador_actual = state.turno_actual
	trivia.col = col
	trivia.fila = fila
	trivia.juego = self

	trivia.trivia_terminada.connect(_on_trivia_terminada)

func _on_trivia_terminada(gano: bool):
	if gano:
		_mostrar_comodin()
	else:
		board_ctrl.board_model.tablero[_ultima_fila][_ultima_col] = 0
		board_ctrl.board_model.tablero_cambiado.emit()

		_colocar_piedra_aleatoria()
		board_ctrl.iniciar_ruleta_visual()

func _colocar_piedra_aleatoria():
	var columnas_validas = []

	for col in range(7):
		if board_ctrl.board_model.obtener_fila_disponible(col) != -1:
			columnas_validas.append(col)

	if columnas_validas.is_empty():
		return

	var col = columnas_validas[randi() % columnas_validas.size()]
	var fila = board_ctrl.board_model.obtener_fila_disponible(col)

	board_ctrl.board_model.tablero[fila][col] = 3
	board_ctrl.board_model.tablero_cambiado.emit()

func _mostrar_comodin():
	var comodin = comodin_scene.instantiate()
	$CanvasLayer.add_child(comodin)
	comodin.jugador_actual = state.turno_actual
	comodin.juego = self

func aplicar_comodin(tipo: String):
	match tipo:
		"bomba":
			board_ctrl.esperando_bomba = true

		"escudo":
			var jugador = state.turno_actual
			var fichas_disponibles = 0
			for fila in range(6):
				for col in range(7):
					if (board_ctrl.board_model.tablero[fila][col] == jugador
							and not board_ctrl.board_model.escudos[fila][col]):
						fichas_disponibles += 1

			if fichas_disponibles == 0:
				state.cambiar_turno()
				return

			board_ctrl.esperando_escudo = true
			board_ctrl.escudos_restantes = min(2, fichas_disponibles)

		"saltar_turno":
			state.turno_saltado = true
			state.cambiar_turno()
			return

	state.bloqueado = false

func _on_bomba(fila, col):
	state.bloqueado = true
	board_ctrl.board_model.activar_bomba(fila, col)
	_post_accion()

func _on_escudo(fila, col):
	board_ctrl.board_model.poner_escudo(fila, col)
	board_ctrl.escudos_restantes -= 1

	if board_ctrl.escudos_restantes > 0:
		var jugador = state.turno_actual
		var fichas_libres = 0
		for f in range(6):
			for c in range(7):
				if (board_ctrl.board_model.tablero[f][c] == jugador
						and not board_ctrl.board_model.escudos[f][c]):
					fichas_libres += 1

		if fichas_libres > 0:
			ui_view.mostrar_mensaje("Selecciona la 2ª ficha a proteger")
			return

	board_ctrl.esperando_escudo = false
	state.bloqueado = true
	_post_accion()

func _post_accion():
	for j in [1, 2]:
		if board_ctrl.board_model.verificar_victoria(j):
			_terminar_juego(j)
			return

	if board_ctrl.board_model.tablero_lleno():
		_terminar_juego(-1)
		return

	state.cambiar_turno()

func _terminar_juego(ganador: int):
	state.juego_activo = false
	state.bloqueado = true
	board_ctrl.juego_terminado = true
	state.juego_terminado.emit(ganador)

func _on_turno_cambiado(j):
	ui_view.mostrar_turno(j)

func _on_juego_terminado(ganador):
	ui_view.mostrar_pantalla_victoria(ganador)

var juego_activo:
	get: return state.juego_activo

var bloqueado:
	get: return state.bloqueado
	set(v): state.bloqueado = v
