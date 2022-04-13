extends Panel

var versionNum = 1.1

# Called when the node enters the scene tree for the first time.
func _ready():
	$VersionLabel.text = "Version " + str(versionNum).pad_decimals(2)
