extends Control

export(PackedScene) var character_template: PackedScene

func _create_character(character_data: Dictionary):
	"""TODO"""
	
	var character_root := character_template.instance()
	character_root.name = character_data["name"]
	return character_root

func _serialize_character(character_node):
	var scene = PackedScene.new()
	var result = scene.pack(character_node)
	if result == OK:
		var error := ResourceSaver.save("user://" + character_node.name + ".scn", scene)
		if error != OK:
			print(error)
			push_error("An error occurred while saving the character to disk.")

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

func _on_Import_pressed():
	_serialize_character(_create_character({ 
		"name": "No"
	}))
