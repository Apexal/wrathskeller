extends Node2D

export(PackedScene) var Player1

func _ready():
	var player1 = Player1.instance()
	add_child(player1)
	player1.position = $Player1StartPos.position
	player1.connect("health_changed", self, "_on_health_change")
	$FloatingAaronHead.connect("health_changed", self, "_on_health_change")
	
func _on_health_change(player_number, new_health):
	print("health changed", player_number, new_health)
	if player_number == 1:
		$Player1HealthBar.rect_size.x = new_health
	if player_number == -1:
		$Player2HealthBar.margin_right = 916 + new_health
