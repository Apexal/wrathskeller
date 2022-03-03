extends Control


export(PackedScene) var character_choice: PackedScene
onready var character_grid = $VBoxContainer/CharacterGrid

var player_1_character_index := 0
var player_2_character_index := 0

var characters: Array = []

func _deserialize_characters() -> Array:
	var characters = []
	var dir = Directory.new()
	if dir.open("user://") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(".scn"):
					var character = load("user://" + file_name).instance()
					characters.append(character)
			file_name = dir.get_next()
	
	return characters

func _ready():
	# On ready, populate character grid
	characters = _deserialize_characters()
	
	for character in characters:
		var character_grid_node := character_choice.instance()
		character_grid_node.name = character.name
		character_grid_node.find_node("CharacterName").text = character.name
		character_grid.add_child(character_grid_node)

func _process(delta):
	if Input.is_action_just_pressed("player_1_move_left"):
		player_1_character_index -= 1
	elif Input.is_action_just_pressed("player_1_move_right"):
		player_1_character_index += 1
	elif Input.is_action_just_pressed("player_2_move_left"):
		player_2_character_index -= 1
	elif Input.is_action_just_pressed("player_2_move_right"):
		player_2_character_index += 1
	
	player_1_character_index = player_1_character_index % len(characters)
	player_2_character_index = player_2_character_index % len(characters)
	
