extends Node2D


var key_type = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.set_frame(key_type)
	pass
