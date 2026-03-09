#trivia.gd
extends Control

@onready var label_pregunta = $LabelPregunta
@onready var label_temporizador = $LabelTemporizador
@onready var opcion1 = $Opcion1
@onready var opcion2 = $Opcion2
@onready var opcion3 = $Opcion3
@onready var opcion4 = $Opcion4

var jugador_actual = 1
var juego = null
var pregunta_actual = {}
var respuesta_correcta = 0
var tiempo_restante = 10.0
var temporizador_activo = false
var fase = "eligiendo_genero"

const CATEGORIAS = ["programacion", "ciencia", "entretenimiento", "arte"]
const COLORES_CATEGORIAS = {
	"programacion": Color(0.2, 0.6, 1.0),
	"ciencia": Color(0.4, 0.9, 0.4),
	"entretenimiento": Color(1.0, 0.4, 0.8),
	"arte": Color(1.0, 0.7, 0.2)
}
const ICONOS_CATEGORIAS = {
	"programacion": "💻",
	"ciencia": "🔬",
	"entretenimiento": "🎮",
	"arte": "🎨"
}

var botones_genero = []
var titulo_genero = null
var fondo = null

var fuente_bangers: FontFile
var fuente_cinzel: FontFile

func _ready():
	fuente_bangers = load("res://assets/fonts/Bangers-Regular.ttf")
	fuente_cinzel = load("res://assets/fonts/Cinzel-Bold.ttf")

	fondo = ColorRect.new()
	fondo.color = Color(0.05, 0.05, 0.15, 0.95)
	fondo.size = Vector2(1800, 900)
	fondo.position = Vector2.ZERO
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fondo)
	move_child(fondo, 0)

	opcion1.pressed.connect(_on_opcion_presionada.bind(0))
	opcion2.pressed.connect(_on_opcion_presionada.bind(1))
	opcion3.pressed.connect(_on_opcion_presionada.bind(2))
	opcion4.pressed.connect(_on_opcion_presionada.bind(3))

	label_pregunta.position = Vector2(420, 150)
	label_pregunta.size = Vector2(760, 140)
	label_pregunta.autowrap_mode = TextServer.AUTOWRAP_WORD
	label_pregunta.add_theme_font_override("font", fuente_cinzel)
	label_pregunta.add_theme_font_size_override("font_size", 24)
	label_pregunta.add_theme_color_override("font_color", Color(1, 1, 1))

	label_temporizador.position = Vector2(820, 310)
	label_temporizador.add_theme_font_override("font", fuente_bangers)
	label_temporizador.add_theme_font_size_override("font_size", 56)
	label_temporizador.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))

	_estilizar_boton_respuesta(opcion1, Color(0.2, 0.4, 0.9))
	_estilizar_boton_respuesta(opcion2, Color(0.7, 0.2, 0.8))
	_estilizar_boton_respuesta(opcion3, Color(0.2, 0.7, 0.4))
	_estilizar_boton_respuesta(opcion4, Color(0.9, 0.5, 0.1))

	opcion1.position = Vector2(390, 460)
	opcion2.position = Vector2(760, 460)
	opcion3.position = Vector2(390, 570)
	opcion4.position = Vector2(760, 570)

	opcion1.custom_minimum_size = Vector2(330, 110)
	opcion2.custom_minimum_size = Vector2(330, 110)
	opcion3.custom_minimum_size = Vector2(330, 110)
	opcion4.custom_minimum_size = Vector2(330, 110)

	ocultar_elementos_respuesta()
	await get_tree().process_frame
	mostrar_seleccion_genero()

func _estilizar_boton_respuesta(btn: Button, color: Color):
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = color.darkened(0.2)
	style_normal.border_color = color
	style_normal.set_border_width_all(3)
	style_normal.set_corner_radius_all(12)
	btn.add_theme_stylebox_override("normal", style_normal)

	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = color
	style_hover.border_color = color.lightened(0.3)
	style_hover.set_border_width_all(3)
	style_hover.set_corner_radius_all(12)
	btn.add_theme_stylebox_override("hover", style_hover)

	btn.add_theme_font_override("font", fuente_cinzel)
	btn.add_theme_font_size_override("font_size", 17)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))

func ocultar_elementos_respuesta():
	opcion1.visible = false
	opcion2.visible = false
	opcion3.visible = false
	opcion4.visible = false
	label_temporizador.visible = false
	label_pregunta.visible = false

func mostrar_seleccion_genero():
	fase = "eligiendo_genero"

	for btn in botones_genero:
		btn.queue_free()
	botones_genero.clear()

	if titulo_genero:
		titulo_genero.queue_free()

	titulo_genero = Label.new()
	titulo_genero.text = "✨ ELIGE TU CATEGORÍA ✨"
	titulo_genero.position = Vector2(480, 90)
	titulo_genero.add_theme_font_override("font", fuente_bangers)
	titulo_genero.add_theme_font_size_override("font_size", 58)
	titulo_genero.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	add_child(titulo_genero)

	var cats = CATEGORIAS.duplicate()
	cats.shuffle()

	var posiciones = [
		Vector2(380, 230),
		Vector2(740, 230),
		Vector2(380, 470),
		Vector2(740, 470)
	]

	for i in range(cats.size()):
		var cat = cats[i]
		var nivel = obtener_nivel(cat)
		var color = COLORES_CATEGORIAS[cat]
		var icono = ICONOS_CATEGORIAS[cat]

		var btn = Button.new()
		btn.text = icono + " " + cat.to_upper() + "\n[" + nivel.to_upper() + "]"
		btn.position = posiciones[i]
		btn.custom_minimum_size = Vector2(310, 190)

		var style_normal = StyleBoxFlat.new()
		style_normal.bg_color = color.darkened(0.3)
		style_normal.border_color = color
		style_normal.set_border_width_all(4)
		style_normal.set_corner_radius_all(16)
		btn.add_theme_stylebox_override("normal", style_normal)

		var style_hover = StyleBoxFlat.new()
		style_hover.bg_color = color
		style_hover.border_color = color.lightened(0.4)
		style_hover.set_border_width_all(4)
		style_hover.set_corner_radius_all(16)
		btn.add_theme_stylebox_override("hover", style_hover)

		btn.add_theme_font_override("font", fuente_bangers)
		btn.add_theme_font_size_override("font_size", 30)
		btn.add_theme_color_override("font_color", Color(1, 1, 1))

		btn.pressed.connect(_on_genero_elegido.bind(cat))
		add_child(btn)
		botones_genero.append(btn)

func obtener_nivel(categoria: String) -> String:
	var conteo = juego.obtener_conteo_categoria(jugador_actual, categoria)
	if conteo <= 1:
		return "facil"
	elif conteo <= 3:
		return "media"
	else:
		return "dificil"

func _on_genero_elegido(categoria: String):
	for btn in botones_genero:
		btn.queue_free()
	botones_genero.clear()

	if titulo_genero:
		titulo_genero.queue_free()

	fase = "respondiendo"
	cargar_pregunta(categoria)

	opcion1.visible = true
	opcion2.visible = true
	opcion3.visible = true
	opcion4.visible = true
	label_temporizador.visible = true
	label_pregunta.visible = true

	opcion1.disabled = false
	opcion2.disabled = false
	opcion3.disabled = false
	opcion4.disabled = false

	tiempo_restante = 10.0
	temporizador_activo = true

func cargar_pregunta(categoria: String):
	var archivo = FileAccess.open("res://data/preguntas.json", FileAccess.READ)
	var contenido = archivo.get_as_text()
	archivo.close()

	var datos = JSON.parse_string(contenido)
	var nivel = obtener_nivel(categoria)
	var preguntas = datos["categorias"][categoria][nivel]

	pregunta_actual = preguntas[randi() % preguntas.size()]

	var color = COLORES_CATEGORIAS[categoria]
	label_pregunta.add_theme_color_override("font_color", color.lightened(0.4))
	label_pregunta.text = ICONOS_CATEGORIAS[categoria] + "  [" + categoria.to_upper() + " - " + nivel.to_upper() + "]\n\n" + pregunta_actual["pregunta"]

	opcion1.text = "A)  " + pregunta_actual["opciones"][0]
	opcion2.text = "B)  " + pregunta_actual["opciones"][1]
	opcion3.text = "C)  " + pregunta_actual["opciones"][2]
	opcion4.text = "D)  " + pregunta_actual["opciones"][3]

	respuesta_correcta = pregunta_actual["correcta"]
	juego.incrementar_conteo_categoria(jugador_actual, categoria)

func _process(delta):
	if not temporizador_activo:
		return
	tiempo_restante -= delta
	var t = ceil(tiempo_restante)
	label_temporizador.text = "⏱ " + str(t)
	if t <= 3:
		label_temporizador.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	else:
		label_temporizador.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	if tiempo_restante <= 0:
		temporizador_activo = false
		tiempo_agotado()

func _on_opcion_presionada(indice: int):
	if not temporizador_activo or fase != "respondiendo":
		return
	temporizador_activo = false
	if indice == respuesta_correcta:
		label_temporizador.text = "✅ ¡CORRECTO!"
		label_temporizador.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
		terminar_trivia(true)
	else:
		label_temporizador.text = "❌ INCORRECTO"
		label_temporizador.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
		terminar_trivia(false)

func tiempo_agotado():
	label_temporizador.text = "⏰ ¡TIEMPO!"
	label_temporizador.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	terminar_trivia(false)

func terminar_trivia(gano: bool):
	opcion1.disabled = true
	opcion2.disabled = true
	opcion3.disabled = true
	opcion4.disabled = true
	await get_tree().create_timer(1.5).timeout
	juego.resultado_trivia(gano)
	queue_free()
