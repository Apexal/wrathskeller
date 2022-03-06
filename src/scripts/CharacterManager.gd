extends Node

const character_template = preload("res://src/actors/players/Character.tscn")

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

static func create_character_preview(character_data: Dictionary, size: Vector2=Vector2(200, 200)):
	var animated_texture := AnimatedTexture.new()
	animated_texture.frames = len(character_data["frames"])
	
	# Create textures from frames
	var f = 0
	for frame_data in character_data["frames"]:
		var buffer = Marshalls.base64_to_raw(frame_data)
		var image = Image.new()
		image.load_png_from_buffer(buffer)
		var texture = ImageTexture.new()
		texture.create_from_image(image)
		texture.set_size_override(size)
		animated_texture.set_frame_texture(f, texture)
		f += 1

	var texture_rect := TextureRect.new()
	texture_rect.texture = animated_texture
	
	return texture_rect
