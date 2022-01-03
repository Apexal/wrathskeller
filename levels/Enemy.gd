extends StaticBody2D

export(Vector2) var start_pos = Vector2()
export(Vector2) var end_pos = Vector2()
export(float) var step = 0.1

var destination := Vector2()

var rng = RandomNumberGenerator.new()

func _physics_process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	position.x = lerp(position.x, mouse_pos.x, delta)	
	position.y = lerp(position.y, mouse_pos.y, delta)
