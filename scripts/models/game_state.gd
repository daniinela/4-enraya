#game_state.gd
extends Node

# ─────────────────────────────
# 📡 SEÑALES
# ─────────────────────────────

# Se emite cuando cambia el turno
signal turno_cambiado(jugador)

# Se emite cuando termina el juego (ganador o empate)
signal juego_terminado(ganador)

# Se emite cuando un turno es saltado
signal turno_saltado_signal()


# ─────────────────────────────
# 🎮 ESTADO DEL JUEGO
# ─────────────────────────────

var turno_actual = 1          # Jugador actual (1 o 2)
var juego_activo = true       # Indica si el juego sigue en curso
var turno_saltado = false     # Si el próximo turno será saltado
var bloqueado = false         # Bloquea input durante animaciones/eventos
var jugador_inmune = 0        # Jugador inmune (no usado aún)


# ─────────────────────────────
# 📊 TRIVIA: CONTEO POR CATEGORÍA
# ─────────────────────────────

var conteo_categorias = {
	1: {"programacion": 0, "ciencia": 0, "entretenimiento": 0, "arte": 0},
	2: {"programacion": 0, "ciencia": 0, "entretenimiento": 0, "arte": 0}
}


# ─────────────────────────────
# 🔄 CAMBIO DE TURNO
# ─────────────────────────────

func cambiar_turno():
	# No hacer nada si el juego terminó
	if not juego_activo:
		return

	# Desbloquear input
	bloqueado = false

	# Cambiar jugador (ternario)
	turno_actual = 2 if turno_actual == 1 else 1
	turno_cambiado.emit(turno_actual)

	# ─── MECÁNICA: SALTAR TURNO ───
	if turno_saltado:
		turno_saltado = false

		# Bloquear mientras se procesa el salto
		bloqueado = true
		turno_saltado_signal.emit()

		# Pequeño delay visual
		await get_tree().create_timer(1.0).timeout

		if not juego_activo:
			return

		# Saltar turno → cambia otra vez
		turno_actual = 2 if turno_actual == 1 else 1
		bloqueado = false
		turno_cambiado.emit(turno_actual)


# ─────────────────────────────
# 🏆 FIN DEL JUEGO
# ─────────────────────────────

func registrar_victoria():
	if not juego_activo:
		return

	juego_activo = false
	bloqueado = true

	juego_terminado.emit(turno_actual)


func registrar_empate():
	if not juego_activo:
		return

	juego_activo = false
	bloqueado = true

	# -1 representa empate
	juego_terminado.emit(-1)


# ─────────────────────────────
# 📊 TRIVIA: UTILIDADES
# ─────────────────────────────

func obtener_conteo_categoria(jugador: int, categoria: String) -> int:
	return conteo_categorias[jugador][categoria]


func incrementar_conteo_categoria(jugador: int, categoria: String):
	conteo_categorias[jugador][categoria] += 1
