#board.gd
extends Node2D

const COLUMNAS = 7
const FILAS = 6

const COLOR_GRIS = Color(0.5, 0.5, 0.5)
const COLOR_RULETA = Color(1.0, 0.85, 0.0, 0.6)
const COLOR_BOMBA_PREVIEW = Color(1.0, 0.3, 0.0, 0.6)
const COLOR_FICHA_ELIMINAR = Color(1.0, 0.2, 0.2, 0.8)

var tablero = []
var trampas = []
var escudos = []
var juego_terminado = false
var game_manager
var columna_pendiente = -1
var fila_pendiente = -1
var animacion_activa = false
var esperando_bomba = false
var esperando_escudo = false
var escudos_restantes = 0
var bomba_preview = []

var ruleta_activa = false
var ruleta_indice = 0
var ruleta_es_columna = true
var ruleta_destino = 0
var ruleta_timer = 0.0
var ruleta_velocidad = 0.05
var ruleta_pasos_restantes = 0

var textura_azul: Texture2D
var textura_roja: Texture2D
var textura_gris: Texture2D
var sprites_fichas = []

func _ready():
	$spriteTablero.z_index = 2
	$fichas.z_index = 1
	textura_azul = load("res://assets/Captura de pantalla 2026-02-25 191835.png")
	textura_roja = load("res://assets/Captura de pantalla 2026-02-25 185600.png")
	textura_gris = load("res://assets/Captura de pantalla 2026-02-25 190012.png")
	inicializar_tablero()
	crear_sprites_fichas()
	await get_tree().process_frame
	queue_redraw()

func crear_sprites_fichas():
	var grid = $fichas
	grid.columns = 7
	sprites_fichas = []
	for fila in range(FILAS):
		var fila_sprites = []
		for col in range(COLUMNAS):
			var sprite = TextureRect.new()
			sprite.custom_minimum_size = Vector2(120, 94)
			sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			sprite.visible = true
			grid.add_child(sprite)
			fila_sprites.append(sprite)
		sprites_fichas.append(fila_sprites)

func obtener_pos_hueco(fila: int, col: int) -> Vector2:
	var grid = $fichas
	var cell_size = Vector2(90, 90)
	var x = grid.position.x + col * cell_size.x + cell_size.x / 2
	var y = grid.position.y + fila * cell_size.y + cell_size.y / 2
	return Vector2(x, y)

func inicializar_tablero():
	tablero = []
	trampas = []
	escudos = []
	for fila in range(FILAS):
		var ft = []; var ftr = []; var fe = []
		for col in range(COLUMNAS):
			ft.append(0); ftr.append(false); fe.append(false)
		tablero.append(ft); trampas.append(ftr); escudos.append(fe)
	juego_terminado = false
	colocar_trampas_aleatorias()

func colocar_trampas_aleatorias():
	var colocadas = 0
	while colocadas < 5:
		var fila = randi() % FILAS
		var col = randi() % COLUMNAS
		if not trampas[fila][col]:
			trampas[fila][col] = true
			colocadas += 1

func actualizar_sprites():
	for fila in range(FILAS):
		for col in range(COLUMNAS):
			var sprite = sprites_fichas[fila][col]
			var valor = tablero[fila][col]
			if valor == 0:
				sprite.texture = null
			elif valor == 1:
				if Global.personaje_jugador1 == "denji":
					sprite.texture = textura_azul
				else:
					sprite.texture = textura_roja
			elif valor == 2:
				if Global.personaje_jugador2 == "denji":
					sprite.texture = textura_azul
				else:
					sprite.texture = textura_roja
			elif valor == 3:
				sprite.texture = textura_gris
			if escudos[fila][col] and valor != 0:
				sprite.modulate = Color(1.0, 0.85, 0.0)
			else:
				sprite.modulate = Color(1, 1, 1)

func _get_cell_rect(fila: int, col: int) -> Rect2:
	var grid = $fichas
	var cell = Vector2(120, 94)
	var x = grid.position.x + col * cell.x
	var y = grid.position.y + fila * cell.y
	return Rect2(x, y, cell.x, cell.y)

func _draw():
	for casilla in bomba_preview:
		var rect = _get_cell_rect(casilla.x, casilla.y)
		draw_rect(rect, COLOR_BOMBA_PREVIEW)
		draw_rect(rect, Color(1.0, 0.1, 0.1, 1.0), false, 3.0)
	if ruleta_activa:
		var grid = $fichas
		var cell = Vector2(120, 94)
		if ruleta_es_columna:
			var x = grid.position.x + ruleta_indice * cell.x
			var rect = Rect2(x, grid.position.y, cell.x, FILAS * cell.y)
			draw_rect(rect, COLOR_RULETA)
			draw_rect(rect, Color(1.0, 0.9, 0.0, 1.0), false, 4.0)
		else:
			var y = grid.position.y + ruleta_indice * cell.y
			var rect = Rect2(grid.position.x, y, COLUMNAS * cell.x, cell.y)
			draw_rect(rect, COLOR_RULETA)
			draw_rect(rect, Color(1.0, 0.9, 0.0, 1.0), false, 4.0)

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
		queue_redraw()
		ruleta_pasos_restantes -= 1
		if ruleta_pasos_restantes < 10:
			ruleta_velocidad = lerp(ruleta_velocidad, 0.25, 0.2)
		if ruleta_pasos_restantes <= 0:
			ruleta_activa = false
			ruleta_indice = ruleta_destino
			queue_redraw()
			_finalizar_ruleta()

func _finalizar_ruleta():
	animacion_activa = true
	await _animar_ruleta_final(ruleta_destino, ruleta_es_columna)
	if ruleta_es_columna:
		borrar_columna(ruleta_destino)
	else:
		borrar_fila(ruleta_destino)
	animacion_activa = false
		
func _animar_ruleta_final(indice: int, es_columna: bool):
	for _i in range(4):
		if es_columna:
			for fila in range(FILAS):
				if tablero[fila][indice] != 0:
					sprites_fichas[fila][indice].modulate = Color(1.0, 0.15, 0.15)
		else:
			for col in range(COLUMNAS):
				if tablero[indice][col] != 0:
					sprites_fichas[indice][col].modulate = Color(1.0, 0.15, 0.15)
		await get_tree().create_timer(0.18).timeout
		actualizar_sprites()
		await get_tree().create_timer(0.18).timeout

func _input(event):
	if juego_terminado or ruleta_activa or animacion_activa:
		return
	if not game_manager or not game_manager.juego_activo:
		return
	if game_manager.bloqueado:
		return
	for hijo in game_manager.get_children():
		if hijo.name == "Trivia" or hijo.name == "Comodines":
			return
	var pos = get_global_mouse_position()
	if esperando_bomba and event is InputEventMouseMotion:
		actualizar_preview_bomba(pos)
		return
	if not (event is InputEventMouseButton and event.pressed):
		return

	if esperando_escudo:
		var resultado = obtener_hueco_click(pos)
		if resultado.x >= 0:
			var fila = resultado.x
			var col = resultado.y
			if tablero[fila][col] == game_manager.turno_actual and not escudos[fila][col]:
				escudos[fila][col] = true
				escudos_restantes -= 1
				actualizar_sprites()
				var fichas_sin_escudo = 0
				for f in range(FILAS):
					for c in range(COLUMNAS):
						if tablero[f][c] == game_manager.turno_actual and not escudos[f][c]:
							fichas_sin_escudo += 1
				if escudos_restantes <= 0 or fichas_sin_escudo == 0:
					esperando_escudo = false
					game_manager.cambiar_turno()
		return

	if esperando_bomba:
		var resultado = obtener_hueco_click(pos)
		if resultado.x >= 0:
			_limpiar_preview_fichas()
			activar_bomba(resultado.x, resultado.y)
			bomba_preview = []
			queue_redraw()
		return

	var col = obtener_columna_click(pos)
	if col >= 0:
		intentar_colocar_ficha(col)

func obtener_hueco_click(pos: Vector2) -> Vector2i:
	for fila in range(FILAS):
		for col in range(COLUMNAS):
			var rect = _get_cell_rect(fila, col)
			if rect.has_point(pos):
				return Vector2i(fila, col)
	return Vector2i(-1, -1)

func obtener_columna_click(pos: Vector2) -> int:
	var grid = $fichas
	var cell_w = 120.0
	var top = grid.position.y
	var bottom = grid.position.y + FILAS * 94.0
	if pos.y < top or pos.y > bottom:
		return -1
	for col in range(COLUMNAS):
		var x = grid.position.x + col * cell_w
		if pos.x >= x and pos.x <= x + cell_w:
			return col
	return -1

func actualizar_preview_bomba(pos: Vector2):
	_limpiar_preview_fichas()
	bomba_preview = []
	var resultado = obtener_hueco_click(pos)
	if resultado.x < 0:
		queue_redraw()
		return
	var fila = resultado.x
	var col = resultado.y
	var candidatos = [
		Vector2i(fila, col), Vector2i(fila-1, col), Vector2i(fila+1, col),
		Vector2i(fila, col-1), Vector2i(fila, col+1)
	]
	for c in candidatos:
		if c.x >= 0 and c.x < FILAS and c.y >= 0 and c.y < COLUMNAS:
			bomba_preview.append(c)
			if tablero[c.x][c.y] != 0:
				sprites_fichas[c.x][c.y].modulate = Color(1.0, 0.2, 0.2)
	queue_redraw()

func _limpiar_preview_fichas():
	for fila in range(FILAS):
		for col in range(COLUMNAS):
			if escudos[fila][col] and tablero[fila][col] != 0:
				sprites_fichas[fila][col].modulate = Color(1.0, 0.85, 0.0)
			else:
				sprites_fichas[fila][col].modulate = Color(1, 1, 1)

func intentar_colocar_ficha(columna: int):
	if not game_manager or not game_manager.juego_activo: return
	var fila = obtener_fila_disponible(columna)
	if fila == -1: return
	if trampas[fila][columna]:
		columna_pendiente = columna
		fila_pendiente = fila
		game_manager.iniciar_trivia()
		return
	colocar_ficha_definitiva(columna, fila)

func colocar_ficha_definitiva(columna: int, fila: int):
	var jugador = game_manager.turno_actual
	tablero[fila][columna] = jugador
	trampas[fila][columna] = false
	actualizar_sprites()
	if verificar_victoria(jugador):
		juego_terminado = true
		game_manager.jugador_gano()
	elif tablero_lleno():
		game_manager.juego_activo = false
		game_manager.juego_empate()
	else:
		game_manager.cambiar_turno()

func colocar_ficha_sin_cambiar_turno(columna: int, fila: int):
	var jugador = game_manager.turno_actual
	tablero[fila][columna] = jugador
	trampas[fila][columna] = false
	actualizar_sprites()
	if verificar_victoria(jugador):
		juego_terminado = true
		game_manager.jugador_gano()

func resultado_trivia_trampa(gano: bool):
	if gano:
		colocar_ficha_sin_cambiar_turno(columna_pendiente, fila_pendiente)
	else:
		volver_ficha_gris(game_manager.turno_actual)
		iniciar_ruleta()
	columna_pendiente = -1
	fila_pendiente = -1

func volver_ficha_gris(jugador: int):
	var fichas_jugador = []
	for fila in range(FILAS):
		for col in range(COLUMNAS):
			if tablero[fila][col] == jugador and not escudos[fila][col]:
				fichas_jugador.append(Vector2i(fila, col))
	if fichas_jugador.is_empty():
		return
	var elegida = fichas_jugador[randi() % fichas_jugador.size()]
	tablero[elegida.x][elegida.y] = 3
	actualizar_sprites()

func iniciar_ruleta():
	ruleta_es_columna = (randi() % 2 == 0)
	ruleta_destino = randi() % (COLUMNAS if ruleta_es_columna else FILAS)
	ruleta_indice = 0
	ruleta_velocidad = 0.05
	ruleta_pasos_restantes = 30 + randi() % 20
	ruleta_activa = true
	var tipo = "columna" if ruleta_es_columna else "fila"
	game_manager.ui.mostrar_mensaje("¡Ruleta! Va a borrar una " + tipo + "...")

func borrar_columna(col: int):
	for fila in range(FILAS):
		if not escudos[fila][col] and tablero[fila][col] != 3:
			tablero[fila][col] = 0
			escudos[fila][col] = false
	aplicar_gravedad()
	actualizar_sprites()
	verificar_victoria_post_accion()

func borrar_fila(fila: int):
	for col in range(COLUMNAS):
		if not escudos[fila][col] and tablero[fila][col] != 3:
			tablero[fila][col] = 0
	aplicar_gravedad()
	actualizar_sprites()
	verificar_victoria_post_accion()

func activar_bomba(fila: int, col: int):
	esperando_bomba = false
	var casillas = [
		Vector2i(fila, col), Vector2i(fila-1, col), Vector2i(fila+1, col),
		Vector2i(fila, col-1), Vector2i(fila, col+1)
	]
	for c in casillas:
		if c.x >= 0 and c.x < FILAS and c.y >= 0 and c.y < COLUMNAS:
			if not escudos[c.x][c.y] and tablero[c.x][c.y] != 3:
				tablero[c.x][c.y] = 0
	aplicar_gravedad()
	actualizar_sprites()
	verificar_victoria_post_accion()

func aplicar_gravedad():
	for col in range(COLUMNAS):
		var fichas_col = []; var escudos_col = []
		for fila in range(FILAS):
			if tablero[fila][col] != 0:
				fichas_col.append(tablero[fila][col])
				escudos_col.append(escudos[fila][col])
			tablero[fila][col] = 0
			escudos[fila][col] = false
		var fila_dest = FILAS - 1
		for i in range(fichas_col.size() - 1, -1, -1):
			tablero[fila_dest][col] = fichas_col[i]
			escudos[fila_dest][col] = escudos_col[i]
			fila_dest -= 1

func obtener_fila_disponible(columna: int) -> int:
	if columna < 0 or columna >= COLUMNAS:
		return -1
	for fila in range(FILAS - 1, -1, -1):
		if tablero[fila][columna] == 0:
			return fila
	return -1

func verificar_victoria(jugador: int) -> bool:
	for fila in range(FILAS):
		for col in range(COLUMNAS - 3):
			if tablero[fila][col] == jugador and tablero[fila][col+1] == jugador and tablero[fila][col+2] == jugador and tablero[fila][col+3] == jugador:
				return true
	for fila in range(FILAS - 3):
		for col in range(COLUMNAS):
			if tablero[fila][col] == jugador and tablero[fila+1][col] == jugador and tablero[fila+2][col] == jugador and tablero[fila+3][col] == jugador:
				return true
	for fila in range(FILAS - 3):
		for col in range(COLUMNAS - 3):
			if tablero[fila][col] == jugador and tablero[fila+1][col+1] == jugador and tablero[fila+2][col+2] == jugador and tablero[fila+3][col+3] == jugador:
				return true
	for fila in range(FILAS - 3):
		for col in range(3, COLUMNAS):
			if tablero[fila][col] == jugador and tablero[fila+1][col-1] == jugador and tablero[fila+2][col-2] == jugador and tablero[fila+3][col-3] == jugador:
				return true
	return false

func tablero_lleno() -> bool:
	for col in range(COLUMNAS):
		if tablero[0][col] == 0:
			return false
	return true

func verificar_victoria_post_accion():
	for jugador in [1, 2]:
		if verificar_victoria(jugador):
			juego_terminado = true
			game_manager.turno_actual = jugador
			game_manager.jugador_gano()
			return
	game_manager.cambiar_turno()
