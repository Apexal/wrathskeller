extends Control

export(Vector2) var character_texture_size := Vector2(200, 200)
export(Texture) var player1_overlay_texture
export(Texture) var player1_overlay_selected_texture
export(Texture) var player2_overlay_texture
export(Texture) var player2_overlay_selected_texture

onready var player1_overlay = $Player1Overlay
onready var player2_overlay = $Player2Overlay
onready var character_grid = $VBoxContainer/GridContainer

var _character_files
var _character_count := 0

var _is_player1_selected := false
var _is_player2_selected := false
var _player1_index = null
var _player2_index = null

func _generate_animated_texture(character_data: Dictionary, size: Vector2) -> AnimatedTexture:
	"""Given a character dictionary, generates an AnimatedTexture of the character's idle animation in the given size."""
	var anim_texture := AnimatedTexture.new()
	
	# Iterate through frames and set texture and delay
	var frame_index := 0
	for frame in character_data["stateAnimations"]["idle"]:
		var texture := CharacterManager.frame_to_texture(frame, size)
		anim_texture.set_frame_texture(frame_index, texture)
		anim_texture.set_frame_delay(frame_index, frame["durationInS"])
		frame_index += 1
	
	# Set the number of frames
	anim_texture.frames = frame_index + 1
	return anim_texture

func _ready():
	CharacterManager.player1 = null
	CharacterManager.player2 = null

	player1_overlay.texture = player1_overlay_texture
	player1_overlay.expand = true
	player1_overlay.rect_size = character_texture_size

	player2_overlay.texture = player2_overlay_texture
	player2_overlay.expand = true
	player2_overlay.rect_size = character_texture_size

	# Iterate through character files
	_character_files = CharacterManager.list_character_files()
	_character_count = _character_files.size()
	for character_file in _character_files:
		var character_data = CharacterManager.load_character_json("res://test_characters/" + character_file)
		var anim_texture := _generate_animated_texture(character_data, character_texture_size)

		var texture_rect := TextureRect.new()
		texture_rect.name = character_data["name"]
		texture_rect.texture = anim_texture
		
		var audio_player := AudioStreamPlayer.new()
		audio_player.name = "Enter"
		if len(character_data["stateSoundEffects"]["enter"]) > 0:
			audio_player.stream = CharacterManager.b64_to_audio_stream_mp3(character_data["stateSoundEffects"]["enter"][0]["base64EncodedAudio"])
		texture_rect.add_child(audio_player)
		
		var audio_player2 := AudioStreamPlayer.new()
		audio_player2.name = "Win"
		if len(character_data["stateSoundEffects"]["win"]) > 0:
			audio_player2.stream = CharacterManager.b64_to_audio_stream_mp3(character_data["stateSoundEffects"]["win"][0]["base64EncodedAudio"])
		texture_rect.add_child(audio_player2)

		character_grid.add_child(texture_rect)

func _handle_player_input(player_num: int, change: int):
	if player_num == 1:
		if _player1_index == null:
			_player1_index = 0
		else:
			_player1_index = (_player1_index + change) % _character_count

		player1_overlay.visible = true	
		player1_overlay.rect_global_position = character_grid.get_children()[_player1_index].rect_global_position
		character_grid.get_children()[_player1_index].get_child(0).play()
	elif player_num == 2:
		if _player2_index == null:
			_player2_index = 0
		else:
			_player2_index = (_player2_index + change) % _character_count

		player2_overlay.visible = true	
		player2_overlay.rect_global_position = character_grid.get_children()[_player2_index].rect_global_position
		character_grid.get_children()[_player2_index].get_child(0).play()

func _handle_player_select(player_num: int):
	if player_num == 1:
		player1_overlay.texture = player1_overlay_selected_texture
		CharacterManager.player1 = _character_files[_player1_index]
		_is_player1_selected = true
		character_grid.get_children()[_player1_index].get_child(1).play()
	elif player_num == 2:
		player2_overlay.texture = player2_overlay_selected_texture
		CharacterManager.player2 = _character_files[_player2_index]
		_is_player2_selected = true
		character_grid.get_children()[_player2_index].get_child(1).play()

func _process(delta):
	if not _is_player1_selected:
		if Input.is_action_just_pressed("player_1_move_left"):
			_handle_player_input(1, -1)
		elif Input.is_action_just_pressed("player_1_move_right"):
			_handle_player_input(1, 1)

	if not _is_player2_selected:
		if Input.is_action_just_pressed("player_2_move_left"):
			_handle_player_input(2, -1)
		elif Input.is_action_just_pressed("player_2_move_right"):
			_handle_player_input(2, 1)

	# Handle selections
	if not _is_player1_selected and Input.is_action_just_pressed("player_1_light_punch") and _player1_index != null:
		_handle_player_select(1)

	if not _is_player2_selected and Input.is_action_just_pressed("player_2_light_punch") and _player2_index != null:
		_handle_player_select(2)

	# When both characters are chosen, go to next scene
	if CharacterManager.player1 and CharacterManager.player2:
		yield(get_tree().create_timer(2.0), "timeout")
		get_tree().change_scene("res://src/scenes/characters/test_characters/TestCharacters.tscn")
