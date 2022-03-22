extends Node2D

func _ready():
	var player1: Actor = CharacterManager.load_character("res://test_characters/character.wrath")
	player1.player_number = 1
	player1.position = $Player1StartPos.position
	add_child(player1)
	
	var player2: Actor = CharacterManager.load_character("res://test_characters/character2.wrath")
	player2.player_number = 2
	player2.position = $Player2StartPos.position
	add_child(player2)
	
	player1.target_to_face = player2
	player2.target_to_face = player1
#	yield(get_tree().create_timer(3.0), "timeout")
#	player1.take_damage(10.0)
