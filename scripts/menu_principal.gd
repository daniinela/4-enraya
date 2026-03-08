# menu_principal.gd
extends Control

func _ready():
	$Button.pressed.connect(_on_jugar)
	$Button2.pressed.connect(_on_reglas)
	$Button3.pressed.connect(_on_salir)

func _on_jugar():
	get_tree().change_scene_to_file("res://scenes/seleccion_personaje.tscn")

func _on_reglas():
	get_tree().change_scene_to_file("res://scenes/reglas.tscn")

func _on_salir():
	get_tree().quit()
