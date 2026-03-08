# Global.gd
extends Node
var Jugador1: String = "Denji"
var Jugador2: String = "Reze"
var personaje_jugador1: String = "denji"
var personaje_jugador2: String = "reze"
var turno_inicial: int = 1

var musica_menu: AudioStreamPlayer

func _ready():
	musica_menu = AudioStreamPlayer.new()
	musica_menu.stream = load("res://assets/music/Balatro Main Theme.mp3")
	musica_menu.volume_db = -5
	musica_menu.autoplay = true
	add_child(musica_menu)
