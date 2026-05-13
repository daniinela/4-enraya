#comodines.gd
extends Node2D

# ─────────────────────────────
# 🧠 REFERENCIAS
# ─────────────────────────────

var juego = null           # Referencia al GameController
var jugador_actual = 1     # Jugador que elige el comodín
var elegido = false        # Evita múltiples selecciones


# ─────────────────────────────
# 🔤 FUENTES
# ─────────────────────────────

var fuente_bangers: FontFile
var fuente_cinzel: FontFile


# ─────────────────────────────
# 🚀 INICIALIZACIÓN
# ─────────────────────────────

func _ready():
	# Cargar fuentes
	fuente_bangers = load("res://assets/fonts/Bangers-Regular.ttf")
	fuente_cinzel = load("res://assets/fonts/Cinzel-Bold.ttf")

	# Fondo oscuro semi-transparente
	var fondo = ColorRect.new()
	fondo.color = Color(0.05, 0.05, 0.15, 0.95)
	fondo.size = Vector2(1800, 900)
	fondo.position = Vector2.ZERO
	add_child(fondo)

	# Asegurar que el fondo quede detrás
	move_child(fondo, 0)

	# Título
	var titulo = Label.new()
	titulo.text = "⚡ ELIGE TU COMODÍN ⚡"
	titulo.position = Vector2(480, 80)

	titulo.add_theme_font_override("font", fuente_bangers)
	titulo.add_theme_font_size_override("font_size", 58)
	titulo.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))

	add_child(titulo)

	# Botones de selección
	_crear_boton(
		"💣 BOMBA\n\nElimina fichas\nen área de 5 casillas",
		"bomba",
		Vector2(280, 260),
		Color(1.0, 0.3, 0.1)
	)

	_crear_boton(
		"⏭ SALTAR\nTURNO\n\nEl rival pierde\nsu próximo turno",
		"saltar_turno",
		Vector2(680, 260),
		Color(0.2, 0.6, 1.0)
	)

	_crear_boton(
		"🛡 ESCUDO\n\nProtege 2 fichas\ntuyas de la bomba",
		"escudo",
		Vector2(1080, 260),
		Color(0.4, 0.9, 0.4)
	)


# ─────────────────────────────
# 🔘 CREAR BOTÓN
# ─────────────────────────────

func _crear_boton(texto: String, tipo: String, pos: Vector2, color: Color):
	var btn = Button.new()

	btn.text = texto
	btn.position = pos
	btn.custom_minimum_size = Vector2(340, 350)

	# Estilo normal
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = color.darkened(0.3)
	style_normal.border_color = color
	style_normal.set_border_width_all(4)
	style_normal.set_corner_radius_all(20)
	btn.add_theme_stylebox_override("normal", style_normal)

	# Estilo hover
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = color
	style_hover.border_color = color.lightened(0.4)
	style_hover.set_border_width_all(4)
	style_hover.set_corner_radius_all(20)
	btn.add_theme_stylebox_override("hover", style_hover)

	# Texto
	btn.add_theme_font_override("font", fuente_bangers)
	btn.add_theme_font_size_override("font_size", 28)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))

	# Evento click
	btn.pressed.connect(_elegir_comodin.bind(tipo))

	add_child(btn)


# ─────────────────────────────
# 🎯 SELECCIÓN DE COMODÍN
# ─────────────────────────────

func _elegir_comodin(tipo: String):
	# Evita doble clic
	if elegido:
		return

	elegido = true

	# Desactivar todos los botones
	for hijo in get_children():
		if hijo is Button:
			hijo.disabled = true

	# Aplicar efecto en el juego
	juego.aplicar_comodin(tipo)

	# Cerrar pantalla
	queue_free()
