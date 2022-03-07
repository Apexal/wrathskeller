extends Node2D

func _ready():
	var player1: Actor = CharacterManager.load_character("character.wrath")
	player1.player_number = 1
	player1.position = $Player1StartPos.position
	add_child(player1)
	
	
	var player2: Actor = CharacterManager.load_character("character2.wrath")
	player2.player_number = 2
	player2.position = $Player2StartPos.position
	add_child(player2)
