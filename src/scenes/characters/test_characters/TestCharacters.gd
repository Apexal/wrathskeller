extends Node2D

export(PackedScene) var Player1
export(PackedScene) var Player2

func _ready():
	var player1: Actor = CharacterManager.load_character("Character.wrath")
	player1.player_number = 1
	player1.position = $Player1StartPos.position
	player1.target_to_face = $FloatingAaronHead
	add_child(player1)
