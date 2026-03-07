extends AnimatedSprite2D

var silueta: AnimatedSprite2D = null

func _ready():
	play("idle")
	silueta = AnimatedSprite2D.new()
	silueta.sprite_frames = sprite_frames
	silueta.play("idle")
	silueta.scale = Vector2(1.28, 1.28)
	silueta.modulate = Color(0.7, 0.2, 1.0, 0.0)  # morado como Reze
	silueta.z_index = z_index - 1
	get_parent().call_deferred("add_child", silueta)
	await get_tree().process_frame
	silueta.global_position = global_position + Vector2(20, 4)  # a la derecha porque Reze está al otro lado

func _process(_delta):
	if silueta and is_instance_valid(silueta):
		silueta.global_position = global_position + Vector2(20, 4)
		silueta.frame = frame

func cambiar_turno(activo: bool):

	if silueta == null:
		return

	var tween = create_tween()

	if activo:
		tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.4)
		tween.parallel().tween_property(
			silueta,
			"modulate",
			Color(0.7, 0.2, 1.0, 0.7),
			0.4
		)
	else:
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.4)
		tween.parallel().tween_property(
			silueta,
			"modulate",
			Color(0.7, 0.2, 1.0, 0.0),
			0.4
		)
