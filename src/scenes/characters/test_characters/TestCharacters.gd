extends Node2D

func _ready():
	var player1: Actor
	var player2: Actor

	if CharacterManager.player1:
		player1 = CharacterManager.load_character("res://test_characters/" + CharacterManager.player1)
		player1.player_number = 1
		player1.position = $Player1StartPos.position
		add_child(player1)
		$Control/HBoxContainer/VBoxContainer/Label.text = player1.name
	
	if CharacterManager.player2:
		player2 = CharacterManager.load_character("res://test_characters/" + CharacterManager.player2)
		player2.player_number = 2
		player2.position = $Player2StartPos.position
		add_child(player2)
		$Control/HBoxContainer/VBoxContainer2/Label.text = player2.name
		
	
	if CharacterManager.player1 and CharacterManager.player2:
		player1.target_to_face = player2
		player2.target_to_face = player1
	
	# Introduce characters
	player1.is_frozen = true
	player2.is_frozen = true
	
	player1.enter()
	yield(player1, "entered")
	player1._current_move_state = player1.MOVE_STATE.IDLE
	
	player2.enter()
	yield(player2, "entered")
	
	player1.is_frozen = false
	player2.is_frozen = false
	# ---------------------------------
	
	# Connect to health bars
	player1.connect("health_changed", self, "_on_player_health_changed", [1])
	player2.connect("health_changed", self, "_on_player_health_changed", [2])
	
	# Hurt for demo
	while true:
		yield(get_tree().create_timer(2), "timeout")
		if randf() >= 0.5:
			player1.take_damage(10)
		else:
			player2.take_damage(15)
		
	
func _on_player_health_changed(health, player_number):
	if player_number == 1:
		$Control/HBoxContainer/VBoxContainer/Player1Health.value = health
	else:
		$Control/HBoxContainer/VBoxContainer2/Player2Health.value = health
