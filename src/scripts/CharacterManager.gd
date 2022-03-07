extends Node

const character_template = preload("res://src/actors/players/Character.tscn")
const state_animation_names = [
	"idle",
	"walk",
	"dash",
	"jump",
	"crouch",
	"block",
	"grappled",
	"hurt",
	"win",
	"lose"
]

static func list_character_files() -> Array:
	"""Lists all character JSON files ending in .wrath in the user:// directory."""

	var character_files = []
	var dir = Directory.new()
	if dir.open("user://") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(".wrath"):
					character_files.append(file_name)
			file_name = dir.get_next()
	return character_files

static func load_character(file_path: String):
	"""Creates a character from a given JSON character data file."""

	var character_data = load_character_json(file_path)
	var character = create_character(character_data)
	return character

static func load_character_json(file_path: String):
	"""Parses a character JSON file."""
	
	var file = File.new()
	file.open("user://" + file_path, File.READ)
	var content = file.get_as_text()
	file.close()
	
	var parsed := JSON.parse(content)
	
	# Check for failure (invalid JSON)
	if parsed.error:
		print(parsed.error)
		return null
	else:
		return parsed.result

static func create_character(character_data: Dictionary):
	"""TODO"""
	
	var character_root := character_template.instance()
	character_root.name = character_data["name"]
	
	# Set sprite frames
	var sprite: Sprite = character_root.get_node("Sprite")
	var sprite_sheet := generate_character_sprite_sheet(character_data)
	sprite.texture = sprite_sheet["texture"]
	sprite.hframes = sprite_sheet["frame_count"]
	
	# Generate actions
	var player: AnimationPlayer = character_root.get_node("AnimationPlayer")
	var state_machine: AnimationNodeStateMachine = character_root.get_node("AnimationTree").tree_root
	
	var frame_index := 0
	# Create state animations
	for state in state_animation_names:
		var anim_name: String = state
		var animation := Animation.new()
		
		if state == "walk" or state == "dash" or state == "idle" or state == "grappled":
			animation.loop = true
		
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_index, "Sprite:frame")
		var local_frame_index = 0
		var anim_length := 0.0
		for frame in character_data["stateAnimations"][state]:
			anim_length += frame["durationInS"]
			animation.track_insert_key(track_index, local_frame_index * frame["durationInS"], frame_index)
			frame_index += 1
			local_frame_index += 1
		animation.length = anim_length
		
		# Add animation in player
		player.add_animation(anim_name, animation)
		var anim_node := AnimationNodeAnimation.new()
		anim_node.animation = anim_name
		
		state_machine.add_node(anim_name, anim_node)
	
	state_machine.set_start_node("idle")
	
	var actions = character_root.get_node("Actions")
	for action in character_data["actions"]:
		var anim_name: String = action["type"]
		print("action ", anim_name)
		# Create animation
		var animation := Animation.new()
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_index, "Sprite:frame")
		var local_frame_index = 0
		for frame in action["animation"]:
			animation.track_insert_key(track_index, local_frame_index * frame["durationInS"], frame_index)
			frame_index += 1
			local_frame_index += 1
		
		# Add animation in player
		player.add_animation(anim_name, animation)
		var anim_node := AnimationNodeAnimation.new()
		anim_node.animation = anim_name
		state_machine.add_node(anim_name, anim_node)
		var transition := AnimationNodeStateMachineTransition.new()
		state_machine.add_transition(anim_name, "idle", transition)
		state_machine.add_transition("idle", anim_name, transition)
		
		var action_node: Action = Action.new()
		action_node.animation_name = anim_name
		action_node.type = action["type"]
		character_root.get_node("Actions").add_child(action_node)
		
	return character_root

static func b64_to_texture(b64_png: String, size: Vector2) -> ImageTexture:
	"""Converts a base64-encoded PNG image to an ImageTexture with the desired size."""
	
	var buffer = Marshalls.base64_to_raw(b64_png)
	var image = Image.new()
	image.load_png_from_buffer(buffer)
	image.convert(Image.FORMAT_RGBA8)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	texture.set_size_override(size)
	return texture

static func b64_to_audio_stream(b64_mp3: String) -> AudioStream:
	var audio_stream := AudioStreamMP3.new()
	var buffer = Marshalls.base64_to_raw(b64_mp3)	
	audio_stream.set_data(buffer)
	var haha := AudioStreamRandomPitch.new()
	haha.audio_stream = audio_stream
	haha.random_pitch = 1.5
	return haha

static func frame_to_texture(animation_frame: Dictionary, size: Vector2) -> ImageTexture:
	return b64_to_texture(animation_frame["base64EncodedImage"], size)

static func create_character_preview(character_data: Dictionary, size: Vector2=Vector2(200, 200)):
	var animated_texture := AnimatedTexture.new()
	animated_texture.frames = len(character_data["previewAnimation"])
	
	# Create textures from frames
	var f = 0
	for frame in character_data["previewAnimation"]:
		var texture := frame_to_texture(frame, Vector2(150,150))
		animated_texture.set_frame_texture(f, texture)
		f += 1

	var texture_rect := TextureRect.new()
	texture_rect.texture = animated_texture
	
	return texture_rect

static func generate_character_sprite_frames(character_data: Dictionary) -> SpriteFrames:
	var sprite_frames := SpriteFrames.new()
	
	# Create animations for each action
	for action in character_data["actions"]:
		var anim_name : String = action["type"]
		sprite_frames.add_animation(anim_name) # light_punch, super, etc.
		for frame in action["animation"]:
			sprite_frames.add_frame(anim_name, frame_to_texture(frame, Vector2(300, 300)))
	
	# Create animations for different states
	for state in state_animation_names:
		sprite_frames.add_animation(state)
		for frame in character_data["stateAnimations"][state]:
			sprite_frames.add_frame(state, frame_to_texture(frame, Vector2(300, 300)))

	return sprite_frames
	
static func generate_character_sprite_sheet(character_data: Dictionary) -> Dictionary:
	# First calculate number of frames so we can determine width of spritesheet
	var frame_count := 0
	
	for state in state_animation_names:
		frame_count += len(character_data["stateAnimations"][state])
	
	for action in character_data["actions"]:
		frame_count += len(action)
	
	var frame_size = 400
	var image := Image.new()
	image.create(frame_size * frame_count,frame_size,false,Image.FORMAT_RGBA8)
	image.fill(Color.white)

	
	# Copy each frame into the spritesheet image
	var frame_index = 0
	for state in state_animation_names:
		for frame in character_data["stateAnimations"][state]:
			var frame_texture := frame_to_texture(frame, Vector2(frame_size, frame_size))
			var frame_image := frame_texture.get_data()
			var frame_pos := Vector2(frame_index*frame_size, 0)
			image.blit_rect(frame_image, Rect2(0,0, frame_size, frame_size), frame_pos)
			frame_index += 1
	
	for action in character_data["actions"]:
		for frame in action["animation"]:
			var frame_texture := frame_to_texture(frame, Vector2(frame_size, frame_size))
			var frame_image := frame_texture.get_data()
			var frame_pos := Vector2(frame_index*frame_size, 0)
			image.blit_rect(frame_image, Rect2(0,0, frame_size, frame_size), frame_pos)
			frame_index += 1

	var texture := ImageTexture.new()
	texture.create_from_image(image)
	
	return {
		"texture": texture,
		"frame_count": frame_count
	}
