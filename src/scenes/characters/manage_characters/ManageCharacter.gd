extends Control

export(PackedScene) var character_template: PackedScene




func _deserialize_characters():
	var characters = []
	var dir = Directory.new()
	if dir.open("user://") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(".scn"):
					var character = load("user://" + file_name).instance()
					characters.append(character)
			file_name = dir.get_next()
	
	return characters

func _ready():
	var animated_sprite = CharacterManager.create_character_preview(CharacterManager.load_character_json("out.json"))
	$GridContainer.add_child(animated_sprite)
