extends Node2D

export(PackedScene) var Player1
export(PackedScene) var Player2

func _ready():
	var player1: Player = Player1.instance()
	add_child(player1)
	player1.player_number = 1
	player1.position = $Player1StartPos.position
	player1.connect("health_changed", self, "_on_health_change")
	
	var player2: Player = Player2.instance()
	add_child(player2)
	player2.player_number = 2
	player2.position = $Player2StartPos.position
	player2.connect("health_changed", self, "_on_health_change")
	
	player1.target_to_face = player2
	player2.target_to_face = player1
	
func _on_health_change(player_number, new_health):
	print("health changed", player_number, new_health)
	if player_number == 1:
		$Player1HealthBar.rect_size.x = new_health
	if player_number == 2:
		$Player2HealthBar.margin_right = 916 + new_health
