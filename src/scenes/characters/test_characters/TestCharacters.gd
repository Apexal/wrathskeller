extends Node2D

export(PackedScene) var Player1
export(PackedScene) var Player2

func _ready():
	var player1: Actor = CharacterManager.load_character("character.json")
	player1.player_number = 1
	player1.position = $Player1StartPos.position
	player1.target_to_face = $FloatingAaronHead
	add_child(player1)
	
#	var player2: Actor = Player2.instance()
#	add_child(player2)
#	player2.name = "Frank 2"
#	player2.player_number = 2
#	player2.position = $Player2StartPos.position
#	player2.modulate = Color("#ff0000")
#
#	player1.target_to_face = player2
#	player2.target_to_face = player1