extends Node

const character_template = preload("res://src/actors/players/Character.tscn")

static func list_character_files() -> Array:
	var character_files = []
	var dir = Directory.new()
	if dir.open("user://") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(".json"):
					character_files.append(file_name)
			file_name = dir.get_next()
	return character_files

static func load_character(file_path: String):
	var character_data = load_character_json(file_path)
	var character = create_character(character_data)

static func load_character_json(file_path: String):
	var file = File.new()
	file.open("user://" + file_path, File.READ)
	var content = file.get_as_text()
	file.close()
	
	var parsed := JSON.parse(content)
	
	if parsed.error:
		print(parsed.error)
		return null
	else:
		return parsed.result

static func create_character(character_data: Dictionary):
	"""TODO"""
	
	var character_root := character_template.instance()
	character_root.name = character_data["name"]
	return character_root

static func b64_to_texture(b64_png: String, size: Vector2) -> ImageTexture:
	var buffer = Marshalls.base64_to_raw(b64_png)
	var image = Image.new()
	image.load_png_from_buffer(buffer)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	texture.set_size_override(size)
	return texture

static func create_character_preview(character_data: Dictionary, size: Vector2=Vector2(200, 200)):
	var animated_texture := AnimatedTexture.new()
	animated_texture.frames = len(character_data["previewAnimation"])
	
	# Create textures from frames
	var f = 0
	for frame_data in character_data["previewAnimation"]:
		var texture := b64_to_texture(frame_data, Vector2(150,150))
		animated_texture.set_frame_texture(f, texture)
		f += 1

	var texture_rect := TextureRect.new()
	texture_rect.texture = animated_texture
	
	return texture_rect

static func generate_character_sprite_frames(character_data: Dictionary) -> SpriteFrames:
	var sprite_frames := SpriteFrames.new()
	
	for move in character_data["moveset"]:
		var anim_name : String = move["type"]
		sprite_frames.add_animation(anim_name) # light_punch, super, etc.
		for frame in move["animation"]:
			sprite_frames.add_frame(anim_name, b64_to_texture(frame["base64EncodedImage"], Vector2(300, 300)))
	
	for state in ["block", "crouch", "walk", "dash", "grappled", "hurt", "win", "lose"]:
		sprite_frames.add_animation(state)
		for frame in character_data[state + "Animation"]:
			sprite_frames.add_frame(state, b64_to_texture(frame["base64EncodedImage"], Vector2(300, 300)))

	
	return sprite_frames
	
