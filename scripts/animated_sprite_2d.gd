extends AnimatedSprite2D

var silueta: AnimatedSprite2D = null

func _ready():
	play("idle")
	silueta = AnimatedSprite2D.new()
	silueta.sprite_frames = sprite_frames
	silueta.play("idle")
	silueta.scale = Vector2(1.25, 1.25)
	silueta.modulate = Color(1.0, 0.85, 0.0, 0.0)
	silueta.z_index = z_index - 1
	get_parent().call_deferred("add_child", silueta)
	await get_tree().process_frame
	silueta.global_position = global_position + Vector2(-20, 4)
