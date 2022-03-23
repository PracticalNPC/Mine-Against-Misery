extends Node

var room = preload("res://scenes/Room.tscn")
var map_size = 30
func set_size(size):
	map_size = size
func generate(size2):
	map_size = size2
	var room_map = {}
	print(typeof(room_map))
	var size = 0
	
	room_map[Vector2(0,0)] = room.instance()
	#print("dungeon at the start  " , dungeon)
	size += 1
	
	while(size < map_size):
		for i in room_map.keys(): # i is the key and dungeon[i] is the node (room)
			if(1==1): #can create randomness factor if you set it to rand_range
				var direction = int(rand_range(0,4)) 
				#print("directon: " , (direction))
				match direction:
					0:
						var new_room_position = i + Vector2(1, 0)
						if(!room_map.has(new_room_position)):
							room_map[new_room_position] = room.instance()
							size += 1
						if(room_map.get(i).adjacent_rooms.get(Vector2(1, 0)) == null):
							connect_rooms(room_map.get(i), room_map.get(new_room_position), Vector2(1, 0))
					1:
						var new_room_position = i + Vector2(-1, 0)
						if(!room_map.has(new_room_position)):
							room_map[new_room_position] = room.instance()
							size += 1
						if(room_map.get(i).adjacent_rooms.get(Vector2(-1, 0)) == null):
							connect_rooms(room_map.get(i), room_map.get(new_room_position), Vector2(-1, 0))
					2:
						var new_room_position = i + Vector2(0, 1)
						if(!room_map.has(new_room_position)):
							room_map[new_room_position] = room.instance()
							size += 1
						if(room_map.get(i).adjacent_rooms.get(Vector2(0, 1)) == null):
							connect_rooms(room_map.get(i), room_map.get(new_room_position), Vector2(0, 1))
					3:
						var new_room_position = i + Vector2(0, -1)
						if(!room_map.has(new_room_position)):
							room_map[new_room_position] = room.instance()
							size += 1
						if(room_map.get(i).adjacent_rooms.get(Vector2(0, -1)) == null):
							connect_rooms(room_map.get(i), room_map.get(new_room_position), Vector2(0, -1))
	return room_map


func connect_rooms(room1, room2, direction):
	room1.adjacent_rooms[direction] = room2
	room2.adjacent_rooms[-direction] = room1
	room1.num_of_adjacent_rooms += 1
	room2.num_of_adjacent_rooms += 1
