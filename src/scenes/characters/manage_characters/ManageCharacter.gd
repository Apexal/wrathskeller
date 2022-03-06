tool
extends Control

export(PackedScene) var character_template: PackedScene

func _ready():
	for character_file in CharacterManager.list_character_files():		
		var container := VBoxContainer.new()
		var character_data = CharacterManager.load_character_json(character_file)
		var animated_sprite = CharacterManager.create_character_preview(character_data)
		container.add_child(animated_sprite)
		var label := Label.new()
		label.text = character_data["name"]
		container.add_child(label)
		
		var buttons := HBoxContainer.new()
		var remove_button := Button.new()
		remove_button.text = "Remove"
		remove_button.size_flags_horizontal = SIZE_EXPAND
		buttons.add_child(remove_button)
		
		container.add_child(buttons)
		
		$VBoxContainer/Characters.add_child(container)
