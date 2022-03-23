extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var text = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#print(get_tree().get_root().get_children())
	get_tree().get_root().get_child(0).victory_music()
	pass # Replace with function body.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if text!= 4:
			text += 1
	match text:
		1:
			$CanvasLayer/label1.visible = false
			$CanvasLayer/credits.visible = true
			
		2:
			$CanvasLayer/credits.visible = false
			$CanvasLayer/label2. visible = true
			$CanvasLayer/label5. visible = true
		3:
			$CanvasLayer/label1.visible = false
			$CanvasLayer/label2.visible = false
			$CanvasLayer/label5.visible = false
			$CanvasLayer/label3.visible = true
		4:
			$CanvasLayer/label4.visible = true
			$CanvasLayer/continue.visible = false
			if Input.is_action_just_pressed("yes"):
				get_tree().change_scene("res://World.tscn")
			if Input.is_action_just_pressed("no"):
				get_tree().change_scene("res://scenes/Main Menu.tscn")
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
