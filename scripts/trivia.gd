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

var botones_genero = []
var titulo_genero = null
var fondo = null

func _ready():

	# 🔥 Crear fondo UNA sola vez
	fondo = ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.85)
	fondo.size = Vector2(1152, 648)
	fondo.position = Vector2.ZERO
	add_child(fondo)
	move_child(fondo, 0)

	# Conectar botones respuesta
	opcion1.pressed.connect(_on_opcion_presionada.bind(0))
	opcion2.pressed.connect(_on_opcion_presionada.bind(1))
	opcion3.pressed.connect(_on_opcion_presionada.bind(2))
	opcion4.pressed.connect(_on_opcion_presionada.bind(3))

	# Posicionar elementos
	label_pregunta.position = Vector2(150, 130)
	label_pregunta.autowrap_mode = TextServer.AUTOWRAP_WORD
	label_pregunta.custom_minimum_size = Vector2(700, 80)

	label_temporizador.position = Vector2(500, 230)

	opcion1.position = Vector2(150, 300)
	opcion2.position = Vector2(500, 300)
	opcion3.position = Vector2(150, 370)
	opcion4.position = Vector2(500, 370)

	opcion1.custom_minimum_size = Vector2(300, 50)
	opcion2.custom_minimum_size = Vector2(300, 50)
	opcion3.custom_minimum_size = Vector2(300, 50)
	opcion4.custom_minimum_size = Vector2(300, 50)

	ocultar_elementos_respuesta()

	await get_tree().process_frame
	mostrar_seleccion_genero()


# 🔥 Ocultar todo lo de respuestas
func ocultar_elementos_respuesta():
	opcion1.visible = false
	opcion2.visible = false
	opcion3.visible = false
	opcion4.visible = false
	label_temporizador.visible = false
	label_pregunta.visible = false


func mostrar_seleccion_genero():

	fase = "eligiendo_genero"

	# 🔥 Limpiar botones anteriores
	for btn in botones_genero:
		btn.queue_free()
	botones_genero.clear()

	# 🔥 Limpiar título anterior
	if titulo_genero:
		titulo_genero.queue_free()

	titulo_genero = Label.new()
	titulo_genero.text = "¡Elige tu categoría!"
	titulo_genero.position = Vector2(400, 80)
	titulo_genero.add_theme_font_size_override("font_size", 28)
	add_child(titulo_genero)

	var cats = CATEGORIAS.duplicate()
	cats.shuffle()

	var posiciones = [
		Vector2(150, 220),
		Vector2(500, 220),
		Vector2(150, 360),
		Vector2(500, 360)
	]

	for i in range(cats.size()):
		var cat = cats[i]
		var nivel = obtener_nivel(cat)

		var btn = Button.new()
		btn.text = cat.to_upper() + "\n[" + nivel.to_upper() + "]"
		btn.position = posiciones[i]
		btn.custom_minimum_size = Vector2(250, 100)
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

	# 🔥 Eliminar botones de categoría
	for btn in botones_genero:
		btn.queue_free()
	botones_genero.clear()

	if titulo_genero:
		titulo_genero.queue_free()

	fase = "respondiendo"
	cargar_pregunta(categoria)

	# Mostrar respuestas
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

	label_pregunta.text = "[" + categoria.to_upper() + " - " + nivel.to_upper() + "]\n" + pregunta_actual["pregunta"]

	opcion1.text = pregunta_actual["opciones"][0]
	opcion2.text = pregunta_actual["opciones"][1]
	opcion3.text = pregunta_actual["opciones"][2]
	opcion4.text = pregunta_actual["opciones"][3]

	respuesta_correcta = pregunta_actual["correcta"]

	juego.incrementar_conteo_categoria(jugador_actual, categoria)


func _process(delta):

	if not temporizador_activo:
		return

	tiempo_restante -= delta
	label_temporizador.text = "⏱ " + str(ceil(tiempo_restante))

	if tiempo_restante <= 0:
		temporizador_activo = false
		tiempo_agotado()


func _on_opcion_presionada(indice: int):

	if not temporizador_activo or fase != "respondiendo":
		return

	temporizador_activo = false

	if indice == respuesta_correcta:
		label_temporizador.text = "✓ ¡Correcto!"
		terminar_trivia(true)
	else:
		label_temporizador.text = "✗ Incorrecto"
		terminar_trivia(false)


func tiempo_agotado():
	label_temporizador.text = "✗ ¡Tiempo agotado!"
	terminar_trivia(false)


func terminar_trivia(gano: bool):

	opcion1.disabled = true
	opcion2.disabled = true
	opcion3.disabled = true
	opcion4.disabled = true

	await get_tree().create_timer(1.2).timeout

	juego.resultado_trivia(gano)

	queue_free()
