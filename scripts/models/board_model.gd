# scripts/models/board_model.gd
extends Object

# ─────────────────────────────
# 📏 CONSTANTES DEL TABLERO
# ─────────────────────────────

const COLUMNAS = 7
const FILAS = 6


# ─────────────────────────────
# 🧠 DATOS DEL TABLERO
# ─────────────────────────────

var tablero = []   # Matriz principal (0 = vacío, 1/2 = jugadores, 3 = gris)
var trampas = []   # Casillas con trampa (true/false)
var escudos = []   # Casillas protegidas (true/false)


# Señal para notificar cambios a la vista
signal tablero_cambiado()


# ─────────────────────────────
# 🚀 INICIALIZACIÓN
# ─────────────────────────────

func inicializar_tablero() -> void:
	tablero = []
	trampas = []
	escudos = []

	# Crear matrices vacías
	for fila in range(FILAS):
		var ft = []   # fila tablero
		var ftr = []  # fila trampas
		var fe = []   # fila escudos

		for col in range(COLUMNAS):
			ft.append(0)
			ftr.append(false)
			fe.append(false)

		tablero.append(ft)
		trampas.append(ftr)
		escudos.append(fe)

	# Colocar trampas aleatorias
	_colocar_trampas_aleatorias()


# ─────────────────────────────
# ⚠️ TRAMPAS
# ─────────────────────────────

func _colocar_trampas_aleatorias() -> void:
	var colocadas = 0

	# Coloca 20 trampas en posiciones aleatorias
	while colocadas < 20:
		var fila = randi() % FILAS
		var col = randi() % COLUMNAS

		if not trampas[fila][col]:
			trampas[fila][col] = true
			colocadas += 1


# ─────────────────────────────
# 🎯 ACCIONES BÁSICAS
# ─────────────────────────────

func colocar_ficha(fila: int, columna: int, jugador: int) -> void:
	tablero[fila][columna] = jugador

	# Si había trampa, se desactiva al colocar ficha
	trampas[fila][columna] = false

	tablero_cambiado.emit()


func marcar_gris(fila: int, col: int) -> void:
	tablero[fila][col] = 3
	tablero_cambiado.emit()


func poner_escudo(fila: int, col: int) -> void:
	escudos[fila][col] = true
	tablero_cambiado.emit()


# ─────────────────────────────
# 🔍 CONSULTAS
# ─────────────────────────────

func obtener_fila_disponible(columna: int) -> int:
	if columna < 0 or columna >= COLUMNAS:
		return -1

	# Busca desde abajo hacia arriba (gravedad)
	for fila in range(FILAS - 1, -1, -1):
		if tablero[fila][columna] == 0:
			return fila

	return -1


func tiene_trampa(fila: int, col: int) -> bool:
	return trampas[fila][col]


func tiene_escudo(fila: int, col: int) -> bool:
	return escudos[fila][col]


# ─────────────────────────────
# 🏆 VERIFICAR VICTORIA
# ─────────────────────────────

func verificar_victoria(jugador: int) -> bool:

	# Horizontal →
	for fila in range(FILAS):
		for col in range(COLUMNAS - 3):
			if tablero[fila][col] == jugador \
			and tablero[fila][col+1] == jugador \
			and tablero[fila][col+2] == jugador \
			and tablero[fila][col+3] == jugador:
				return true

	# Vertical ↓
	for fila in range(FILAS - 3):
		for col in range(COLUMNAS):
			if tablero[fila][col] == jugador \
			and tablero[fila+1][col] == jugador \
			and tablero[fila+2][col] == jugador \
			and tablero[fila+3][col] == jugador:
				return true

	# Diagonal ↘
	for fila in range(FILAS - 3):
		for col in range(COLUMNAS - 3):
			if tablero[fila][col] == jugador \
			and tablero[fila+1][col+1] == jugador \
			and tablero[fila+2][col+2] == jugador \
			and tablero[fila+3][col+3] == jugador:
				return true

	# Diagonal ↙
	for fila in range(FILAS - 3):
		for col in range(3, COLUMNAS):
			if tablero[fila][col] == jugador \
			and tablero[fila+1][col-1] == jugador \
			and tablero[fila+2][col-2] == jugador \
			and tablero[fila+3][col-3] == jugador:
				return true

	return false


# ─────────────────────────────
# 📦 ESTADO GENERAL
# ─────────────────────────────

func tablero_lleno() -> bool:
	for col in range(COLUMNAS):
		if tablero[0][col] == 0:
			return false
	return true


# ─────────────────────────────
# ⬇️ GRAVEDAD
# ─────────────────────────────

func aplicar_gravedad() -> void:
	for col in range(COLUMNAS):

		var fichas_col = []
		var escudos_col = []

		# Extraer fichas existentes
		for fila in range(FILAS):
			if tablero[fila][col] != 0:
				fichas_col.append(tablero[fila][col])
				escudos_col.append(escudos[fila][col])

			tablero[fila][col] = 0
			escudos[fila][col] = false

		# Recolocar desde abajo
		var fila_dest = FILAS - 1

		for i in range(fichas_col.size() - 1, -1, -1):
			tablero[fila_dest][col] = fichas_col[i]
			escudos[fila_dest][col] = escudos_col[i]
			fila_dest -= 1

	tablero_cambiado.emit()


# ─────────────────────────────
# 💥 EFECTOS (RULETA / BOMBA)
# ─────────────────────────────

func borrar_columna(col: int) -> void:
	for fila in range(FILAS):
		# No borra si hay escudo o ficha gris
		if not escudos[fila][col] and tablero[fila][col] != 3:
			tablero[fila][col] = 0
			escudos[fila][col] = false

	aplicar_gravedad()


func borrar_fila(fila: int) -> void:
	for col in range(COLUMNAS):
		if not escudos[fila][col] and tablero[fila][col] != 3:
			tablero[fila][col] = 0

	aplicar_gravedad()


func activar_bomba(fila: int, col: int) -> void:
	var casillas = [
		Vector2i(fila, col),
		Vector2i(fila-1, col),
		Vector2i(fila+1, col),
		Vector2i(fila, col-1),
		Vector2i(fila, col+1)
	]

	for c in casillas:
		if c.x >= 0 and c.x < FILAS and c.y >= 0 and c.y < COLUMNAS:
			if not escudos[c.x][c.y] and tablero[c.x][c.y] != 3:
				tablero[c.x][c.y] = 0

	aplicar_gravedad()


# ─────────────────────────────
# 🎯 UTILIDADES
# ─────────────────────────────

func elegir_ficha_aleatoria_jugador(jugador: int) -> Vector2i:
	var fichas = []

	for fila in range(FILAS):
		for col in range(COLUMNAS):
			if tablero[fila][col] == jugador and not escudos[fila][col]:
				fichas.append(Vector2i(fila, col))

	if fichas.is_empty():
		return Vector2i(-1, -1)

	return fichas[randi() % fichas.size()]


func fichas_sin_escudo_de(jugador: int) -> int:
	var count = 0

	for fila in range(FILAS):
		for col in range(COLUMNAS):
			if tablero[fila][col] == jugador and not escudos[fila][col]:
				count += 1

	return count
