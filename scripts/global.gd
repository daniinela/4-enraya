# global.gd
extends Node

# ─────────────────────────────
# 👤 DATOS DE JUGADORES
# ─────────────────────────────

var Jugador1: String = "Denji"
var Jugador2: String = "Reze"

# Identificadores de personaje (para lógica/colores)
var personaje_jugador1: String = "denji"
var personaje_jugador2: String = "reze"

# Define quién empieza la partida
var turno_inicial: int = 1


# ─────────────────────────────
# 🏆 PUNTAJE GLOBAL
# ─────────────────────────────

# Se mantiene entre partidas
var puntaje_jugador1: int = 0
var puntaje_jugador2: int = 0


# ─────────────────────────────
# 🎵 MÚSICA
# ─────────────────────────────

var musica_menu: AudioStreamPlayer


# ─────────────────────────────
# 🚀 INICIALIZACIÓN
# ─────────────────────────────

func _ready():
	# Crear reproductor de música
	musica_menu = AudioStreamPlayer.new()

	# Cargar canción
	musica_menu.stream = load("res://assets/music/Balatro Main Theme.mp3")

	# Volumen moderado
	musica_menu.volume_db = -5

	# Reproducción automática
	musica_menu.autoplay = true

	add_child(musica_menu)
