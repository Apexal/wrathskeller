extends StaticBody2D
signal health_changed

export(float) var max_health := 100.0
var health = max_health

func _physics_process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	position.x = lerp(position.x, mouse_pos.x, delta)	
	position.y = lerp(position.y, mouse_pos.y, delta)


func _on_HitArea_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(10.0)

func take_damage(damage_amount: float):
	print("floating aaron header takes " + String(damage_amount) + " damage")
	health -= damage_amount
	$AnimationPlayer.play("shake")
	if health < 0:
		health = 0
	emit_signal("health_changed", -1, health)
