extends Control

@onready var jugador1_input = $VBoxContainer/Jugador1
@onready var jugador2_input = $VBoxContainer/Nombre2/Jugador2
@onready var boton_empezar = $VBoxContainer/Nombre2/Empezar

var fuente_cinzel: FontFile


func _ready():
	fuente_cinzel = load("res://assets/fonts/Cinzel-Bold.ttf")
	estilizar_boton(boton_empezar, Color(0.3, 0.6, 1.0))


func estilizar_boton(btn: Button, color: Color):

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
	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color", Color(1,1,1))



func _on_button_reze_pressed() -> void:
	Global.personaje_jugador1 = "reze"
	Global.personaje_jugador2 = "denji"
	print("Elegiste Reze")
	



func _on_button_denji_pressed() -> void:
	Global.personaje_jugador1 = "denji"
	Global.personaje_jugador2 = "reze"
	print("Elegiste denji")

func _on_empezar_pressed() -> void:
	if Global.personaje_jugador1 == "":
		print("Debes elegir un personaje antes de empezar")
		return

	Global.Jugador1 = jugador1_input.text
	Global.Jugador2 = jugador2_input.text

	print("Jugador 1:", Global.Jugador1)
	print("Jugador 2:", Global.Jugador2)
	print("Personaje elegido:", Global.personaje_jugador1)

	get_tree().change_scene_to_file("res://scenes/Main.tscn")
