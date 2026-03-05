extends Node2D

const NUM_BARRAS = 80
const ALTURA_MAX = 300.0
const COLOR_BASE = Color(0.5, 0.0, 0.8, 0.7) 
const COLOR_TOP = Color(1.0, 0.85, 0.0, 0.9)  

var spectrum: AudioEffectSpectrumAnalyzerInstance
var alturas_suavizadas = []

func _ready():
	spectrum = AudioServer.get_bus_effect_instance(0, 0)
	alturas_suavizadas.resize(NUM_BARRAS)
	alturas_suavizadas.fill(0.0)

func _draw():
	if not spectrum:
		return

	var vp = get_viewport_rect().size
	var ancho_total = vp.x
	var ancho_barra = ancho_total / NUM_BARRAS
	var separacion = ancho_barra * 0.15
	var w = ancho_barra - separacion
	var centro_y = vp.y / 2.0
	for i in range(NUM_BARRAS):
		var hz_min = 20.0 * pow(1000.0, float(i) / NUM_BARRAS)
		var hz_max = 20.0 * pow(1000.0, float(i + 1) / NUM_BARRAS)
		var mag = spectrum.get_magnitude_for_frequency_range(hz_min, hz_max)
		var energia = clamp((linear_to_db(mag.length()) + 60.0) / 60.0, 0.0, 1.0)
		var altura_target = energia * ALTURA_MAX

		alturas_suavizadas[i] = lerp(alturas_suavizadas[i], altura_target, 0.25)
		var h = alturas_suavizadas[i]

		var x = i * ancho_barra + separacion / 2.0

		var t = h / ALTURA_MAX
		var color = COLOR_BASE.lerp(COLOR_TOP, t)
		color.a = 0.5 + t * 0.4

		draw_rect(Rect2(x, centro_y - h, w, h), color)
		# barra hacia abajo (espejo)
		draw_rect(Rect2(x, centro_y, w, h), color)

		# línea brillante en la punta
		if h > 5:
			var brillo = Color(1.0, 1.0, 0.8, t)
			draw_rect(Rect2(x, centro_y - h - 3, w, 3), brillo)
			draw_rect(Rect2(x, centro_y + h, w, 3), brillo)

func _process(_delta):
	queue_redraw()
