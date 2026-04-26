# scripts/views/board_view.gd
extends Node2D

# ─────────────────────────────
# 📏 CONSTANTES
# ─────────────────────────────

const COLUMNAS = 7
const FILAS = 6

# Colores de efectos visuales
const COLOR_RULETA = Color(1.0, 0.85, 0.0, 0.6)
const COLOR_BOMBA_PREVIEW = Color(1.0, 0.3, 0.0, 0.6)


# ─────────────────────────────
# 🎨 RECURSOS VISUALES
# ─────────────────────────────

var sprites_fichas = []       # Matriz de sprites (TextureRect)
var textura_azul: Texture2D
var textura_roja: Texture2D
var textura_gris: Texture2D


# ─────────────────────────────
# 🎰 ESTADOS VISUALES
# ─────────────────────────────

var ruleta_activa: bool = false
var ruleta_es_columna: bool = true
var ruleta_indice: int = 0

var bomba_preview: Array = []


# ─────────────────────────────
# 🧱 NODOS
# ─────────────────────────────

var sprite_tablero
var grid


# ─────────────────────────────
# 🚀 INICIALIZACIÓN
# ─────────────────────────────

func _ready():
	sprite_tablero = get_parent().get_node("spriteTablero")
	grid = get_parent().get_node("fichas")

	# Asegura orden de render
	sprite_tablero.z_index = 2
	grid.z_index = 1

	# Cargar texturas
	textura_azul = load("res://assets/Captura de pantalla 2026-02-25 191835.png")
	textura_roja = load("res://assets/Captura de pantalla 2026-02-25 185600.png")
	textura_gris = load("res://assets/Captura de pantalla 2026-02-25 190012.png")

	# Crear sprites dinámicamente
	_crear_sprites_fichas()

	await get_tree().process_frame
	queue_redraw()


# ─────────────────────────────
# 🧩 CREACIÓN DE GRID VISUAL
# ─────────────────────────────

func _crear_sprites_fichas() -> void:
	grid.columns = 7
	sprites_fichas = []

	for fila in range(FILAS):
		var fila_sprites = []

		for col in range(COLUMNAS):
			var sprite = TextureRect.new()

			# Configuración visual
			sprite.custom_minimum_size = Vector2(120, 94)
			sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			sprite.visible = true

			grid.add_child(sprite)
			fila_sprites.append(sprite)

		sprites_fichas.append(fila_sprites)


# ─────────────────────────────
# 🎨 RENDER PRINCIPAL
# ─────────────────────────────

func renderizar(tablero: Array, escudos: Array) -> void:
	for fila in range(FILAS):
		for col in range(COLUMNAS):

			var sprite = sprites_fichas[fila][col]
			var valor = tablero[fila][col]

			# Selección de textura según tipo
			if valor == 0:
				sprite.texture = null

			elif valor == 1:
				sprite.texture = textura_azul if Global.personaje_jugador1 == "denji" else textura_roja

			elif valor == 2:
				sprite.texture = textura_azul if Global.personaje_jugador2 == "denji" else textura_roja

			elif valor == 3:
				sprite.texture = textura_gris

			# Efecto visual de escudo
			if escudos[fila][col] and valor != 0:
				sprite.modulate = Color(1.0, 0.85, 0.0)
			else:
				sprite.modulate = Color(1, 1, 1)


# ─────────────────────────────
# 💣 PREVIEW DE BOMBA
# ─────────────────────────────

func resaltar_bomba_preview(casillas: Array, tablero: Array, escudos: Array) -> void:
	_limpiar_tintes(tablero, escudos)

	bomba_preview = casillas

	for c in casillas:
		if tablero[c.x][c.y] != 0:
			sprites_fichas[c.x][c.y].modulate = Color(1.0, 0.2, 0.2)

	queue_redraw()


func limpiar_preview(tablero: Array, escudos: Array) -> void:
	bomba_preview = []
	_limpiar_tintes(tablero, escudos)
	queue_redraw()


# ─────────────────────────────
# 🎰 RULETA VISUAL
# ─────────────────────────────

func set_ruleta(activa: bool, es_columna: bool, indice: int) -> void:
	ruleta_activa = activa
	ruleta_es_columna = es_columna
	ruleta_indice = indice
	queue_redraw()


func animar_ruleta_final(indice: int, es_columna: bool, tablero: Array, escudos: Array) -> void:
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

		renderizar(tablero, escudos)

		await get_tree().create_timer(0.18).timeout


# ─────────────────────────────
# 🖱️ DETECCIÓN DE INPUT
# ─────────────────────────────

func get_cell_rect(fila: int, col: int) -> Rect2:
	var cell = Vector2(120, 94)
	return Rect2(
		grid.position.x + col * cell.x,
		grid.position.y + fila * cell.y,
		cell.x,
		cell.y
	)


func obtener_columna_click(pos: Vector2) -> int:
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


func obtener_hueco_click(pos: Vector2) -> Vector2i:
	for fila in range(FILAS):
		for col in range(COLUMNAS):
			if get_cell_rect(fila, col).has_point(pos):
				return Vector2i(fila, col)

	return Vector2i(-1, -1)


# ─────────────────────────────
# 🧹 LIMPIEZA VISUAL
# ─────────────────────────────

func _limpiar_tintes(tablero: Array, escudos: Array) -> void:
	for fila in range(FILAS):
		for col in range(COLUMNAS):
			if escudos[fila][col] and tablero[fila][col] != 0:
				sprites_fichas[fila][col].modulate = Color(1.0, 0.85, 0.0)
			else:
				sprites_fichas[fila][col].modulate = Color(1, 1, 1)


# ─────────────────────────────
# 🎨 DIBUJO CUSTOM (OVERLAY)
# ─────────────────────────────

func _draw():
	# Preview bomba
	for casilla in bomba_preview:
		var rect = get_cell_rect(casilla.x, casilla.y)
		draw_rect(rect, COLOR_BOMBA_PREVIEW)
		draw_rect(rect, Color(1.0, 0.1, 0.1, 1.0), false, 3.0)

	# Highlight ruleta
	if ruleta_activa:
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
