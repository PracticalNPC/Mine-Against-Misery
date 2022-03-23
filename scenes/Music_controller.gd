extends Node2D
var start = true
var level = 0
var high_score = 0
var win = false
func _ready():
	
	pass # Replace with function body.


func victory_music():
	$music.stop()
	$ambience.stop()
	$Victory.play()
func _on_music_finished():
	#$music.play()
	pass # Replace with function body.
func _on_ambience_finished():
	$ambience.play()
	pass # Replace with function body.
func _on_Victory_finished():
	$ambience.play()
	#$music.play()
	pass # Replace with function body.
