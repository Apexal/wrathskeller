extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var rand_num = 0
	var reg_title = "Wrathskeller"
	var easter_eggs = ["Wrathsmeller", "Wrathsekller", "Wrathmueller", "WrashSlingingHasher"]
	
	# get random number from 1-50 (1 in 50 chance to get easter egg title)
	randomize()
	rand_num = randi() % 50
	
	# if number is 1, easter egg title
	if rand_num == 1:
		randomize()
		rand_num = randi() % easter_eggs.size()
		text = easter_eggs[rand_num]
	# else, regular title
	else:
		text = reg_title


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
