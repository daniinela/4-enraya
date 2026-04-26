extends Node2D

# ─────────────────────────────
# 🧠 REFERENCIAS PRINCIPALES
# ─────────────────────────────

var state          # Estado global del juego (turnos, bloqueo, fin, etc.)
var board_ctrl     # Controlador del tablero
var ui_view        # Interfaz de usuario


# ─────────────────────────────
# 🎭 ESCENAS DINÁMICAS
# ─────────────────────────────

var trivia_scene = preload("res://scenes/Trivia.tscn")
var comodin_scene = preload("res://scenes/Comodines.tscn")


# ─────────────────────────────
# 📍 ÚLTIMA JUGADA
# ─────────────────────────────

# Se usa para revertir jugadas si se pierde la trivia
var _ultima_fila: int = -1
var _ultima_col: int = -1


# ─────────────────────────────
# 🚀 INICIALIZACIÓN
# ─────────────────────────────

func _ready():
	# Crear estado del juego
	state = load("res://scripts/models/game_state.gd").new()
	add_child(state)

	# Referencias a nodos
	board_ctrl = $Board
	ui_view = $CanvasLayer/UI

	# El board necesita acceso al controlador
	board_ctrl.game_controller = self

	# 🔗 Conexión de señales del tablero
	board_ctrl.columna_clickeada.connect(_on_columna_clickeada)
	board_ctrl.bomba_seleccionada.connect(_on_bomba)
	board_ctrl.escudo_seleccionado.connect(_on_escudo)
	board_ctrl.accion_post_procesada.connect(_post_accion)

	# 🔗 Conexión de señales del estado
	state.turno_cambiado.connect(_on_turno_cambiado)
	state.juego_terminado.connect(_on_juego_terminado)

	# Mostrar turno inicial en UI
	ui_view.mostrar_turno(state.turno_actual)


# ─────────────────────────────
# 🎮 LÓGICA PRINCIPAL DE JUEGO
# ─────────────────────────────

func _on_columna_clickeada(col):
	# Bloqueos de seguridad
	if not state.juego_activo or state.bloqueado:
		return

	# Buscar fila disponible en la columna
	var fila = board_ctrl.board_model.obtener_fila_disponible(col)
	if fila == -1:
		return

	# Bloquear input mientras se procesa
	state.bloqueado = true

	# Colocar ficha
	board_ctrl.board_model.colocar_ficha(fila, col, state.turno_actual)

	# Guardar última jugada (por si se revierte)
	_ultima_fila = fila
	_ultima_col = col

	# Verificar victoria inmediata
	if board_ctrl.board_model.verificar_victoria(state.turno_actual):
		state.juego_activo = false
		state.juego_terminado.emit(state.turno_actual)
		return

	# 🎲 Probabilidad de trivia (50%)
	if randi() % 2 == 0:
		_iniciar_trivia(col, fila)
	else:
		state.cambiar_turno()


# ─────────────────────────────
# ❓ TRIVIA
# ─────────────────────────────

func _iniciar_trivia(col, fila):
	var trivia = trivia_scene.instantiate()
	$CanvasLayer.add_child(trivia)

	# Pasar datos a la escena
	trivia.jugador_actual = state.turno_actual
	trivia.col = col
	trivia.fila = fila
	trivia.juego = self


func resultado_trivia(gano: bool):
	if gano:
		# Si gana → obtiene comodín
		_mostrar_comodin()
	else:
		# ❌ Si pierde → se revierte jugada

		# Quitar ficha colocada
		board_ctrl.board_model.tablero[_ultima_fila][_ultima_col] = 0
		board_ctrl.board_model.tablero_cambiado.emit()

		# Convertir una ficha propia en gris (castigo)
		_colocar_ficha_gris()

		# Activar ruleta
		board_ctrl.iniciar_ruleta_visual()


# ─────────────────────────────
# ⚫ CASTIGO: FICHA GRIS
# ─────────────────────────────

func _colocar_ficha_gris():
	var ocupadas = []

	# Buscar fichas del jugador actual
	for fila in range(6):
		for col in range(7):
			if board_ctrl.board_model.tablero[fila][col] == state.turno_actual:
				ocupadas.append(Vector2i(fila, col))

	# Si no hay fichas, no hacer nada
	if ocupadas.is_empty():
		return

	# Elegir una al azar
	var celda = ocupadas[randi() % ocupadas.size()]

	# Convertirla en ficha gris (valor 3)
	board_ctrl.board_model.tablero[celda.x][celda.y] = 3
	board_ctrl.board_model.tablero_cambiado.emit()


# ─────────────────────────────
# 🎁 COMODINES
# ─────────────────────────────

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
			board_ctrl.esperando_escudo = true
			board_ctrl.escudos_restantes = 2

		"saltar_turno":
			state.turno_saltado = true
			state.cambiar_turno()
			return

	# Desbloquear input después de elegir comodín
	state.bloqueado = false


# ─────────────────────────────
# 💥 EVENTOS DEL TABLERO
# ─────────────────────────────

func _on_bomba(fila, col):
	board_ctrl.board_model.activar_bomba(fila, col)
	_post_accion()


func _on_escudo(fila, col):
	board_ctrl.board_model.poner_escudo(fila, col)


func _post_accion():
	# Verificar victoria para ambos jugadores
	for j in [1, 2]:
		if board_ctrl.board_model.verificar_victoria(j):
			state.turno_actual = j
			state.juego_activo = false
			state.juego_terminado.emit(j)
			return

	# Si no hay ganador, cambiar turno
	state.cambiar_turno()


# ─────────────────────────────
# 🖥️ UI
# ─────────────────────────────

func _on_turno_cambiado(j):
	ui_view.mostrar_turno(j)


func _on_juego_terminado(g):
	ui_view.mostrar_ganador(g)


# ─────────────────────────────
# 🔐 GETTERS / PROPIEDADES
# ─────────────────────────────

var juego_activo:
	get: return state.juego_activo

var bloqueado:
	get: return state.bloqueado
	set(v): state.bloqueado = v
