extends Node

const character_template = preload("res://src/actors/players/Character.tscn")

# The recognized state animations in the exact ORDER they must be processed in
# This order ensures the spritesheet can be generated in sync with the animation tree
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

static func generate_animation(anim_name: String, frames: Array, frame_index: int) -> Dictionary:
	var animation := Animation.new()
	print(anim_name)
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Sprite:frame")
	var anim_length := 0.0
	for frame in frames:
		animation.track_insert_key(track_index, anim_length, frame_index)
		anim_length += frame["durationInS"]
		frame_index += 1
	animation.track_insert_key(track_index, anim_length, frame_index-1)	
	animation.length = anim_length
	
	var anim_node := AnimationNodeAnimation.new()
	anim_node.animation = anim_name
		
	return {"animation": animation, "frame_index": frame_index, "animation_node": anim_node}

static func create_character(character_data: Dictionary):
	"""Builds the character scene from character data."""
	
	var character_root := character_template.instance()
	character_root.name = character_data["name"]
	
	# Configure sprite with generated sprite sheet
	var sprite: Sprite = character_root.get_node("Sprite")
	var sprite_sheet := generate_character_sprite_sheet(character_data)
	sprite.texture = sprite_sheet["texture"]
	sprite.hframes = sprite_sheet["frame_count"]
	
	var player: AnimationPlayer = character_root.get_node("AnimationPlayer")
	var state_machine: AnimationNodeStateMachine = character_root.get_node("AnimationTree").tree_root
	
	# Keeps track of overall frame index to sync up with spritesheet
	var frame_index := 0
	
	# Create state animations
	for state in state_animation_names:
		var anim_name: String = state
		
		var animation_result := generate_animation(anim_name, character_data["stateAnimations"][state], frame_index)
		frame_index = animation_result["frame_index"]
		
		# Some animations should loop
		if state == "idle" or state == "walk" or state == "grappled" or state == "dash" or state == "win" or state == "lose":
			animation_result["animation"].loop = true

		# Add animation in player
		player.add_animation(anim_name, animation_result["animation"])
		state_machine.add_node(anim_name, animation_result["animation_node"])
		
		if state != "idle":
			var transition := AnimationNodeStateMachineTransition.new()
			state_machine.add_transition(anim_name, "idle", transition)
			state_machine.add_transition("idle", anim_name, transition)
	
	state_machine.set_start_node("idle") # Make idle autoplay
	
	var actions = character_root.get_node("Actions")
	
	# Create action animation and nodes
	for action in character_data["actions"]:
		var anim_name: String = action["type"]
		
		var animation_result := generate_animation(anim_name, action["animation"], frame_index)
		frame_index = animation_result["frame_index"]
		
		# Add animation in player
		player.add_animation(anim_name, animation_result["animation"])
		state_machine.add_node(anim_name, animation_result["animation_node"])
		
		# Create animation node transition
		var transition := AnimationNodeStateMachineTransition.new()
		state_machine.add_transition(anim_name, "idle", transition)
		state_machine.add_transition("idle", anim_name, transition)
		
		# Create action node
		var action_node: Action = Action.new()
		action_node.animation_name = anim_name
		action_node.type = action["type"]
		action_node.action_time = animation_result["animation"].length
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
	
	# Create the placeholder image in the correct size
	var image := Image.new()
	image.create(frame_size * frame_count,frame_size,false,Image.FORMAT_RGBA8)
	image.fill(Color.transparent)

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
			# Copy frame into correct spot in spritesheet
			image.blit_rect(frame_image, Rect2(0,0, frame_size, frame_size), frame_pos)
			frame_index += 1

	var texture := ImageTexture.new()
	texture.create_from_image(image)
	
	return {
		"texture": texture,
		"frame_count": frame_count
	}
