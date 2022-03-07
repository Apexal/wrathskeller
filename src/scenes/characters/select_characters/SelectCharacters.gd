extends Control


export(PackedScene) var character_choice: PackedScene
onready var character_grid = $VBoxContainer/CharacterGrid

var player_1_character_index := 0
var player_2_character_index := 0

var characters: Array = []

func _ready():
	# On ready, populate character grid
	for character_file in CharacterManager.list_character_files():
		var character = CharacterManager.load_character_json(character_file)
		characters.append(character)
	
		var container := VBoxContainer.new()
		var character_data = CharacterManager.load_character_json(character_file)
		var animated_sprite = CharacterManager.create_character_preview(character_data)
		container.add_child(animated_sprite)
		
		character_grid.add_child(container)

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
	
