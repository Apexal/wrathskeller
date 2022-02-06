extends Label

func _choose_random_file(path: String) -> String:
	"""Given a path to a directory, choose a random file from it and return it's name."""

	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	
	dir.list_dir_end()
	return path + "/" + files[randi() % files.size()]

func _read_file(path: String) -> String:
	"""Reads a text file and returns its content as a string."""

	var f = File.new()
	f.open(path, File.READ)
	var content = f.get_as_text()
	f.close()
	return content

func _ready():
	"""On startup, choose a random subtitle and set the label."""

	randomize()
	
	var random_subtitle_file := _choose_random_file("res://src/subtitles")
	
	# text refers to the text property of the label this script is on
	text = _read_file(random_subtitle_file)
