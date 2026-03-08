# reglas.gd
extends Control

func _ready():
	$Button.pressed.connect(_on_volver)

func _on_volver():
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
