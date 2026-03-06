extends Control

@onready var boton = $Button

var fuente_cinzel: FontFile

func _ready():
	fuente_cinzel = load("res://assets/fonts/Cinzel-Bold.ttf")
	estilizar_boton(boton, Color(0.3, 0.6, 1.0))

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
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", Color(1,1,1))


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
