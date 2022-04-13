extends Node2D

func _ready():
	var player1: Actor
	var player2: Actor

	if CharacterManager.player1:
		player1 = CharacterManager.load_character("res://test_characters/" + CharacterManager.player1)
		player1.player_number = 1
		player1.position = $Player1StartPos.position
		add_child(player1)
	
	if CharacterManager.player2:
		player2 = CharacterManager.load_character("res://test_characters/" + CharacterManager.player2)
		player2.player_number = 2
		player2.position = $Player2StartPos.position
		add_child(player2)
	
	if CharacterManager.player1 and CharacterManager.player2:
		player1.target_to_face = player2
		player2.target_to_face = player1
	
	player1.is_frozen = true
	player2.is_frozen = true
	
	player1.enter()
	yield(player1, "entered")
	player2.enter()
