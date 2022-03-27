extends Control

export(Vector2) var character_texture_size := Vector2(200, 200)

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
	# Iterate through character files
	var character_files = CharacterManager.list_character_files()
	for character_file in character_files:
		var character_data = CharacterManager.load_character_json("res://test_characters/" + character_file)
		var anim_texture := _generate_animated_texture(character_data, character_texture_size)
		
		var texture_rect := TextureRect.new()
		texture_rect.name = character_data["name"]
		texture_rect.texture = anim_texture
		texture_rect
		
		$GridContainer.add_child(texture_rect)
