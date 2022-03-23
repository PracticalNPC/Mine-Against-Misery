# note: to change font size, you need to import a custom font and change the size through the import. 
extends Label
onready var node = get_node("text_box")
var text1 = ["You win \n if you enjoyed my game and want to learn more about \n game dev check me out on youtube or \n any social media at practicalnpc \n also check out my website my game design"]
var page = 0
func _ready():
	set_bbcode(text1[page])
	set_visible_characters(0)
	set_process_input(true)
	
func _input(event):
	if Input.is_action_pressed("player_interact"): # && event.is_pressed():
		if get_visible_characters() > get_total_character_count():
			if page < text1.size() -1:
				page += 1
				set_bbcode(text1[page])
				set_visible_characters(0)
				#get_tree().get_root().get_child(0).conversation_happening 
				#get_parent().remove_child(self)
				#print(get_tree().get_root().get_node("Node2D").find_node("text_box"))
				#print(get_parent())
				
			else:
				if get_parent() != null:
					#get_parent().get_parent().get_parent().dialog_visible = false
					#print(get_parent().get_parent().get_parent())
					
					#get_tree().get_root().get_node("text_box").queue_free()
					#queue_free()
					get_parent().queue_free()
					#get_tree().get_root().get_child(0).conversation_happening = false
		else:
			set_visible_characters(get_total_character_count())

func _on_Timer_timeout():
	set_visible_characters(get_visible_characters()+1)
	
