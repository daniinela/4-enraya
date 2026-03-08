# seleccion_personaje.gd
extends Control

# Referencias a nodos
@onready var label_titulo = $Label
@onready var label_jugador = $Label2
@onready var label_vs = $Label3
@onready var label_nombre = $Label4
@onready var sprite_denji = $denji
@onready var sprite_reze = $reze
@onready var line_edit = $LineEdit
@onready var boton_continuar = $Button

# Estado del juego
var fase = 1  # 1 = J1 eligiendo, 2 = J2 escribiendo nombre, 3 = listo
var personaje_j1 = ""
var personaje_j2 = ""
var nombre_j1 = ""
var nombre_j2 = ""

const ESCALA_NORMAL = Vector2(1.0, 1.0)
const ESCALA_GRANDE = Vector2(1.4, 1.4)
const COLOR_DENJI = Color(1.0, 0.85, 0.0)
const COLOR_REZE = Color(0.7, 0.2, 1.0)
const COLOR_APAGADO = Color(0.4, 0.4, 0.4)

func _ready():
	# Iniciar animaciones
	sprite_denji.play("idle")
	sprite_reze.play("idle")
	
	# Estado inicial
	label_jugador.text = "JUGADOR 1 — ¿Quién eres?"
	label_vs.visible = false
	label_nombre.visible = false
	line_edit.visible = false
	boton_continuar.visible = false
	
	# Conectar botón
	boton_continuar.pressed.connect(_on_continuar)
	
func _input(event: InputEvent):
	if not (event is InputEventMouseButton and event.pressed):
		return
	if fase != 1:
		return
	var mouse = get_global_mouse_position()
	var dist_denji = mouse.distance_to(sprite_denji.global_position)
	var dist_reze = mouse.distance_to(sprite_reze.global_position)
	if dist_denji < 150:
		_j1_eligio("denji")
	elif dist_reze < 150:
		_j1_eligio("reze")




func _j1_eligio(personaje: String):
	personaje_j1 = personaje
	personaje_j2 = "reze" if personaje == "denji" else "denji"
	
	# Agrandar el elegido, achicar el otro
	if personaje == "denji":
		_animar_escala(sprite_denji, ESCALA_GRANDE)
		_animar_escala(sprite_reze, ESCALA_NORMAL)
		sprite_denji.modulate = Color(1, 1, 1)
		sprite_reze.modulate = COLOR_APAGADO
		label_jugador.text = "JUGADOR 1 — DENJI"
		label_jugador.add_theme_color_override("font_color", COLOR_DENJI)
	else:
		_animar_escala(sprite_reze, ESCALA_GRANDE)
		_animar_escala(sprite_denji, ESCALA_NORMAL)
		sprite_reze.modulate = Color(1, 1, 1)
		sprite_denji.modulate = COLOR_APAGADO
		label_jugador.text = "JUGADOR 1 — REZE"
		label_jugador.add_theme_color_override("font_color", COLOR_REZE)
	
	# Mostrar campo de nombre para J1
	label_nombre.text = "JUGADOR 1 — escribe tu nombre:"
	label_nombre.visible = true
	line_edit.visible = true
	line_edit.placeholder_text = "Nombre del Jugador 1..."
	line_edit.clear()
	boton_continuar.text = "CONFIRMAR →"
	boton_continuar.visible = true
	fase = 2

func _on_continuar():
	if fase == 2:
		nombre_j1 = line_edit.text.strip_edges()
		if nombre_j1 == "":
			nombre_j1 = personaje_j1.capitalize()
		
		fase = 3
		label_jugador.text = "JUGADOR 2 — " + personaje_j2.to_upper()
		if personaje_j2 == "denji":
			label_jugador.add_theme_color_override("font_color", COLOR_DENJI)
			_animar_escala(sprite_denji, ESCALA_GRANDE)
			_animar_escala(sprite_reze, ESCALA_NORMAL)
			sprite_denji.modulate = Color(1, 1, 1)
			sprite_reze.modulate = COLOR_APAGADO
		else:
			label_jugador.add_theme_color_override("font_color", COLOR_REZE)
			_animar_escala(sprite_reze, ESCALA_GRANDE)
			_animar_escala(sprite_denji, ESCALA_NORMAL)
			sprite_reze.modulate = Color(1, 1, 1)
			sprite_denji.modulate = COLOR_APAGADO
		
		label_nombre.text = "JUGADOR 2 — escribe tu nombre:"
		line_edit.placeholder_text = "Nombre del Jugador 2..."
		line_edit.clear()
		boton_continuar.text = "⚔  ¡ JUGAR !"
		
	elif fase == 3:
		nombre_j2 = line_edit.text.strip_edges()
		if nombre_j2 == "":
			nombre_j2 = personaje_j2.capitalize()
		
		Global.Jugador1 = nombre_j1
		Global.Jugador2 = nombre_j2
		Global.personaje_jugador1 = personaje_j1
		Global.personaje_jugador2 = personaje_j2
		Global.musica_menu.stop()
		get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _animar_escala(sprite: AnimatedSprite2D, escala: Vector2):
	var tween = create_tween()
	tween.tween_property(sprite, "scale", escala, 0.3).set_ease(Tween.EASE_OUT)
