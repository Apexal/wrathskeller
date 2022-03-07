tool
extends Control

func _handle_mouse_enter(character_preview_container: Control):
	print(character_preview_container.get_children())
	var audio_player: AudioStreamPlayer = character_preview_container.get_node("AudioStreamPlayer")
	if not audio_player.playing:
		audio_player.play()
	
func _ready():
	for character_file in CharacterManager.list_character_files():		
		var container := VBoxContainer.new()
		var character_data = CharacterManager.load_character_json(character_file)
		var animated_sprite = CharacterManager.create_character_preview(character_data)
		animated_sprite.name = "AnimatedSprite"
		container.add_child(animated_sprite)
		var label := Label.new()
		label.name = "CharacterName"
		label.text = character_data["name"]
		container.add_child(label)
		
		var buttons := HBoxContainer.new()
		buttons.name = "ActionButtons"
		var remove_button := Button.new()
		remove_button.text = "Expel"
		remove_button.size_flags_horizontal = SIZE_EXPAND
		buttons.add_child(remove_button)
		
		container.add_child(buttons)
		
		# Audio Player
		var audio_player := AudioStreamPlayer.new()
		audio_player.name = "AudioStreamPlayer"
		var b64_mp3 = character_data["hurtSoundEffects"][0]["base64EncodedAudio"]
		audio_player.stream = CharacterManager.b64_to_audio_stream(b64_mp3)
		container.add_child(audio_player)
		
		$VBoxContainer/Characters.add_child(container)
		
		container.connect("mouse_entered", self, "_handle_mouse_enter", [container])
