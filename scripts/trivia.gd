extends Node2D

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
var fase = "eligiendo_genero"  # "eligiendo_genero" o "respondiendo"

const CATEGORIAS = ["programacion", "ciencia", "entretenimiento", "arte"]
const NIVELES = ["facil", "media", "dificil"]

# Botones de género (se crean dinámicamente)
var botones_genero = []
var btn_label_genero = null

func _ready():
	var fondo = ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.85)
	fondo.size = Vector2(1152, 648)
	fondo.position = Vector2(0, 0)
	add_child(fondo)
	move_child(fondo, 0)

	# Conectar botones de respuesta
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
	opcion1.custom_minimum_size = Vector2(300, 50)
	opcion2.position = Vector2(500, 300)
	opcion2.custom_minimum_size = Vector2(300, 50)
	opcion3.position = Vector2(150, 370)
	opcion3.custom_minimum_size = Vector2(300, 50)
	opcion4.position = Vector2(500, 370)
	opcion4.custom_minimum_size = Vector2(300, 50)

	# Ocultar botones de respuesta al inicio
	opcion1.visible = false
	opcion2.visible = false
	opcion3.visible = false
	opcion4.visible = false
	label_temporizador.visible = false
	label_pregunta.visible = false

	await get_tree().process_frame
	mostrar_seleccion_genero()

func mostrar_seleccion_genero():
	fase = "eligiendo_genero"

	var titulo = Label.new()
	titulo.text = "¡Elige tu categoría!"
	titulo.position = Vector2(400, 80)
	titulo.add_theme_font_size_override("font_size", 28)
	add_child(titulo)

	# Mezclar categorías al azar para que salgan en orden diferente
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
	# Deshabilitar todos los botones de género
	for btn in botones_genero:
		btn.disabled = true

	fase = "respondiendo"
	cargar_pregunta(categoria)

	# Mostrar elementos de respuesta
	opcion1.visible = true
	opcion2.visible = true
	opcion3.visible = true
	opcion4.visible = true
	label_temporizador.visible = true
	label_pregunta.visible = true
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

	# Registrar que eligió esta categoría
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
