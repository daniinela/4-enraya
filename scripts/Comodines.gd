extends Node2D

var juego = null
var jugador_actual = 1
var elegido = false  # Evitar doble clic

func _ready():
	var fondo = ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.9)
	fondo.size = Vector2(1152, 648)
	fondo.position = Vector2(0, 0)
	add_child(fondo)
	move_child(fondo, 0)

	var titulo = Label.new()
	titulo.text = "¡Elegí tu comodín!"
	titulo.position = Vector2(400, 80)
	titulo.add_theme_font_size_override("font_size", 28)
	add_child(titulo)

	var btn_bomba = Button.new()
	btn_bomba.text = "💣 BOMBA\nElimina fichas en área de 5 casillas"
	btn_bomba.position = Vector2(150, 200)
	btn_bomba.custom_minimum_size = Vector2(250, 100)
	btn_bomba.pressed.connect(_elegir_comodin.bind("bomba"))
	add_child(btn_bomba)

	var btn_saltar = Button.new()
	btn_saltar.text = "⏭ SALTAR TURNO\nEl rival pierde su próximo turno"
	btn_saltar.position = Vector2(450, 200)
	btn_saltar.custom_minimum_size = Vector2(250, 100)
	btn_saltar.pressed.connect(_elegir_comodin.bind("saltar_turno"))
	add_child(btn_saltar)

	var btn_escudo = Button.new()
	btn_escudo.text = "🛡 ESCUDO\nProtege 2 fichas tuyas de la bomba"
	btn_escudo.position = Vector2(750, 200)
	btn_escudo.custom_minimum_size = Vector2(250, 100)
	btn_escudo.pressed.connect(_elegir_comodin.bind("escudo"))
	add_child(btn_escudo)

func _elegir_comodin(tipo: String):
	if elegido:
		return
	elegido = true
	# Deshabilitar todos los botones
	for hijo in get_children():
		if hijo is Button:
			hijo.disabled = true
	juego.aplicar_comodin(tipo)
	queue_free()
