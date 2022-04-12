extends Node

###########################

var player1 = null

var player2 = null

###########################

const character_template = preload("res://src/actors/players/CharacterTemplate.tscn")

# The recognized character state in the exact ORDER they must be processed in
# This order ensures the spritesheet can be generated in sync with the animation tree
const STATES = [
	"idle",
	"enter",
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
	if dir.open("res://test_characters") == OK:
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
	file.open(file_path, File.READ)
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
	
	# Add animation track for the sprite frame
	var frame_track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(frame_track_index, "Sprite:frame")
	
	var body_collider_extents_track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(body_collider_extents_track_index, "BodyCollider:scale")
	
	var body_collider_pos_track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(body_collider_pos_track_index, "BodyCollider:position")
	
	var hit_collider_disabled_track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(hit_collider_disabled_track_index, "HitArea/HitCollider:disabled")
	
	var hit_collider_extents_track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(hit_collider_extents_track_index, "HitArea/HitCollider:scale")
	
	var hit_collider_pos_track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(hit_collider_pos_track_index, "HitArea/HitCollider:position")
	
	
	var anim_length := 0.0
	for frame in frames:
		animation.track_insert_key(frame_track_index, anim_length, frame_index)

		var body_coll_size := Vector2(frame["bodyCollider"]["size"]["x"], frame["bodyCollider"]["size"]["y"])
		var body_coll_pos := Vector2(frame["bodyCollider"]["position"]["x"], frame["bodyCollider"]["position"]["y"])
		animation.track_insert_key(body_collider_extents_track_index, anim_length, body_coll_size)
		animation.track_insert_key(body_collider_pos_track_index, anim_length, body_coll_pos)
		
		if frame["hitCollider"]["isEnabled"]:
			animation.track_insert_key(hit_collider_disabled_track_index, anim_length, false)
			var hit_coll_size := Vector2(frame["hitCollider"]["size"]["x"], frame["hitCollider"]["size"]["y"])
			var hit_coll_pos := Vector2(frame["hitCollider"]["position"]["x"], frame["hitCollider"]["position"]["y"])
			animation.track_insert_key(hit_collider_extents_track_index, anim_length, hit_coll_size)
			animation.track_insert_key(hit_collider_pos_track_index, anim_length, hit_coll_pos)
		else:
			animation.track_insert_key(hit_collider_disabled_track_index, anim_length, true)
		
		anim_length += frame["durationInS"]
		frame_index += 1

	animation.track_insert_key(frame_track_index, anim_length, frame_index-1)	
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
	sprite.hframes = sprite_sheet["hframes"]
	sprite.vframes = sprite_sheet["vframes"]
	
	var player: AnimationPlayer = character_root.get_node("AnimationPlayer")
	var state_machine: AnimationNodeStateMachine = character_root.get_node("AnimationTree").tree_root
	
	# Keeps track of overall frame index to sync up with spritesheet
	var frame_index := 0
	
	# Create state animations
	for state in STATES:
		var anim_name: String = state
		
		var animation_result := generate_animation(anim_name, character_data["stateAnimations"][state], frame_index)
		frame_index = animation_result["frame_index"]
		
		# Some animations should loop
		if state == "idle" or state == "walk" or state == "grappled" or state == "dash" or state == "win":
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
		action_node.name = action["name"]
		action_node.animation_name = anim_name
		action_node.type = action["type"]
		action_node.action_time = animation_result["animation"].length
		if "soundEffect" in action and action["soundEffect"]:
			action_node.sound_effect = b64_to_audio_stream_mp3(action["soundEffect"]["base64EncodedAudio"])
		character_root.get_node("Actions").add_child(action_node)
		
	return character_root

static func b64_to_audio_stream_mp3(b64_mp3: String) -> AudioStreamMP3:
	var stream := AudioStreamMP3.new()
	var buffer := Marshalls.base64_to_raw(b64_mp3)
	stream.data = buffer
	return stream

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

static func frame_to_texture(animation_frame: Dictionary, size: Vector2) -> ImageTexture:
	return b64_to_texture(animation_frame["base64EncodedImage"], size)

static func generate_character_sprite_sheet(character_data: Dictionary) -> Dictionary:
	# First calculate number of frames so we can determine width of spritesheet
	var frame_count := 0
	
	var state_frame_count := 0
	var action_frame_count := 0
	
	for state in STATES:
		frame_count += len(character_data["stateAnimations"][state])
		state_frame_count += len(character_data["stateAnimations"][state])
	
	for action in character_data["actions"]:
		frame_count += len(action)
		action_frame_count += len(action)
	
	var frame_size = 400
	
	# Create the placeholder image in the correct size
	var image := Image.new()
	image.create(frame_size * max(state_frame_count, action_frame_count), frame_size * 2, false, Image.FORMAT_RGBA8)
	image.fill(Color.transparent)

	# Copy each frame into the spritesheet image
	var frame_index = 0
	for state in STATES:
		for frame in character_data["stateAnimations"][state]:
			var frame_texture := frame_to_texture(frame, Vector2(frame_size, frame_size))
			var frame_image := frame_texture.get_data()
			var frame_pos := Vector2(frame_index*frame_size, 0)
			image.blit_rect(frame_image, Rect2(0, 0, frame_size, frame_size), frame_pos)
			frame_index += 1	
	
	frame_index = 0
	for action in character_data["actions"]:
		for frame in action["animation"]:
			var frame_texture := frame_to_texture(frame, Vector2(frame_size, frame_size))
			var frame_image := frame_texture.get_data()
			var frame_pos := Vector2(frame_index*frame_size, frame_size)
			# Copy frame into correct spot in spritesheet
			image.blit_rect(frame_image, Rect2(0, 0, frame_size, frame_size), frame_pos)
			frame_index += 1

	var texture := ImageTexture.new()
	texture.create_from_image(image)
	
	return {
		"texture": texture,
		"hframes": max(state_frame_count, action_frame_count),
		"vframes": 2
	}
