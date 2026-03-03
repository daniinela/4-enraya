extends Node2D

var juego = null
var jugador_actual = 1
var elegido = false

var fuente_bangers: FontFile
var fuente_cinzel: FontFile

func _ready():
	fuente_bangers = load("res://assets/fonts/Bangers-Regular.ttf")
	fuente_cinzel = load("res://assets/fonts/Cinzel-Bold.ttf")

	var fondo = ColorRect.new()
	fondo.color = Color(0.05, 0.05, 0.15, 0.95)
	fondo.size = Vector2(1800, 900)
	fondo.position = Vector2.ZERO
	add_child(fondo)
	move_child(fondo, 0)

	var titulo = Label.new()
	titulo.text = "⚡ ELIGE TU COMODÍN ⚡"
	titulo.position = Vector2(480, 80)
	titulo.add_theme_font_override("font", fuente_bangers)
	titulo.add_theme_font_size_override("font_size", 58)
	titulo.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	add_child(titulo)

	_crear_boton("💣 BOMBA\n\nElimina fichas\nen área de 5 casillas", "bomba", Vector2(280, 260), Color(1.0, 0.3, 0.1))
	_crear_boton("⏭ SALTAR\nTURNO\n\nEl rival pierde\nsu próximo turno", "saltar_turno", Vector2(680, 260), Color(0.2, 0.6, 1.0))
	_crear_boton("🛡 ESCUDO\n\nProtege 2 fichas\ntuyas de la bomba", "escudo", Vector2(1080, 260), Color(0.4, 0.9, 0.4))

func _crear_boton(texto: String, tipo: String, pos: Vector2, color: Color):
	var btn = Button.new()
	btn.text = texto
	btn.position = pos
	btn.custom_minimum_size = Vector2(340, 350)

	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = color.darkened(0.3)
	style_normal.border_color = color
	style_normal.set_border_width_all(4)
	style_normal.set_corner_radius_all(20)
	btn.add_theme_stylebox_override("normal", style_normal)

	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = color
	style_hover.border_color = color.lightened(0.4)
	style_hover.set_border_width_all(4)
	style_hover.set_corner_radius_all(20)
	btn.add_theme_stylebox_override("hover", style_hover)

	btn.add_theme_font_override("font", fuente_bangers)
	btn.add_theme_font_size_override("font_size", 28)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))

	btn.pressed.connect(_elegir_comodin.bind(tipo))
	add_child(btn)

func _elegir_comodin(tipo: String):
	if elegido:
		return
	elegido = true
	for hijo in get_children():
		if hijo is Button:
			hijo.disabled = true
	juego.aplicar_comodin(tipo)
	queue_free()
