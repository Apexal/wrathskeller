extends Panel


# Declare member variables here. Examples:
var versionNum = 1.1
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$VersionLabel.text = "Version " + str(versionNum).pad_decimals(2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
