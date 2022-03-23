extends Node2D

var dungeon = {}
var node_sprite = load("res://map_nodes1.png")
var branch_sprite = load("res://map_nodes3.png")
var map_size = 10
onready var map_node = $MapNode

func _ready():
	$Label.text = "" + str(map_size)
	pass
	randomize()
	dungeon = $Map.generate(map_size)
	#print("dungeon" , dungeon)
	load_map()

func load_map():
	var tracker = 1
	for i in range(0, map_node.get_child_count()):
		map_node.get_child(i).queue_free()
		
	for i in dungeon.keys():
		
		var temp = dungeon.get(i)
		#temp.texture = node_sprite
		map_node.add_child(temp)
		#map_node.add_child(dungeon.get(i))
		#print(dungeon.get(i))
		var test = Label.new()
		#test.set_text(String(tracker))
		temp.add_child(test)
		tracker -= .05
		temp.modulate = Color(tracker,1,tracker)
		temp.z_index = 1
		temp.position = i * 10
		var c_rooms = dungeon.get(i).adjacent_rooms
		if(c_rooms.get(Vector2(1, 0)) != null):
			temp = Sprite.new()
			temp.texture = branch_sprite
			map_node.add_child(temp)
			temp.z_index = 0
			temp.position = i * 10 + Vector2(5, 0.5)
		if(c_rooms.get(Vector2(0, 1)) != null):
			temp = Sprite.new()
			temp.texture = branch_sprite
			map_node.add_child(temp)
			temp.z_index = 0
			temp.rotation_degrees = 90
			temp.position = i * 10 + Vector2(-0.5, 5)

func _on_Button_pressed():
	randomize()
	dungeon = $Map.generate(map_size)
	load_map()


func _on_Button2_pressed():
	map_size -=1
	$Label.text =str(map_size)


func _on_Button3_pressed():
	map_size +=1
	$Label.text =str(map_size)
	pass # Replace with function body.
