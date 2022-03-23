extends Node2D



func _ready():
	pass # Replace with function body.
func _process(delta):

	if Input.is_action_just_pressed("ui_accept"):
		if get_tree().get_root().get_child(0).start == true:
			$world_menu.visible = true
			$CanvasLayer/Title_Screen.visible = false
			$CanvasLayer/Title_Screen2.visible = false
			$CanvasLayer/Title_Screen3.visible = false
			$CanvasLayer/instructions.visible = true
			$CanvasLayer/Headers.visible = true
			get_tree().get_root().get_child(0).start = false
		else:
			get_tree().change_scene("res://World.tscn")
	if Input.is_action_just_pressed("credits"):
		get_tree().change_scene("res://scenes/credits.tscn")
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		#$"world menu").change_scene("res://World.tscn")
	#if Input.is_action_just_pressed()


func _on_Timer_timeout():
	get_tree().change_scene("res://World.tscn")
	pass # Replace with function body.
