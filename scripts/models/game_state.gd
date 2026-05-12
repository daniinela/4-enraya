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
	if not juego_activo:
		return

	bloqueado = false

	if turno_saltado:
		turno_saltado = false
		# FIX: "saltar turno" significa el rival pierde su turno, así que
		# turno_actual NO cambia — el mismo jugador vuelve a jugar.
		# Eliminamos el await y el doble emit que causaban el flash de 1 segundo.
		turno_saltado_signal.emit()
		turno_cambiado.emit(turno_actual)
	else:
		turno_actual = 2 if turno_actual == 1 else 1
		turno_cambiado.emit(turno_actual)

# ─────────────────────────────
# 🏆 FIN DEL JUEGO
# ─────────────────────────────

func registrar_victoria():
	# FIX #3: Esta función es el único punto de entrada para terminar el
	# juego por victoria. Garantiza que juego_activo=false y bloqueado=true
	# se establezcan ANTES de emitir la señal, sin importar desde dónde
	# se llame. Antes game_controller.gd hacía esto inline de forma
	# inconsistente (a veces sin poner bloqueado=true).
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
