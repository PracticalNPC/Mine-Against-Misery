extends Node2D

var room = preload("res://scenes/Room.tscn")
var map_size = 8
var rooms_texture_data = preload("res://Sprites/room_types3.png").get_data()
var spawn_texture_data = preload("res://Sprites/spawn_data.png").get_data()
var floors_texture_data = preload("res://Sprites/floors_texture_data.png").get_data()
var tiles_data = {}
var scene_root = null
var tilemap = null
var tilemap2= null
var player = null
var walkable_floor_tiles = {}
var NUM_OF_ROOM_TYPES = 24
var enemy = preload("res://scenes/Enemy.tscn")
var door = preload("res://scenes/Door.tscn")
var key = preload("res://scenes/Key.tscn")
var shovel = preload("res://scenes/pickaxe_pickup.tscn")
var exit = preload("res://scenes/Exit.tscn")
var ladder = preload("res://scenes/ladder.tscn")
onready var astar =  AStar2D.new()
var player_spawn_coords = Vector2(0, 0)
var spawn_room_dir = 0
var spawn_room_created = false
var first_room_created =  false
var astar_points_cache = {}

func generate_world():
	var player_spawn_coords = Vector2(0, 0)
	var spawn_room_dir = 0
	#var astar_points_cache = {}
	#var walkable_floor_tiles = {}
	astar.clear()
	tilemap.clear()
	tilemap2.clear()
	get_tree().call_group("enemies", "queue_free")
	get_tree().call_group("keys", "queue_free")
	get_tree().call_group("shovels", "queue_free")
	get_tree().call_group("doors", "queue_free")
	get_tree().call_group("exit", "queue_free")
	get_tree().call_group("ladder", "queue_free")
	tiles_data.clear()
	walkable_floor_tiles.clear()
	astar.clear()
	tilemap.clear()
	var rooms_data = map_generate() 
	var spawn_locations = generate_rooms(rooms_data) #generates rooms and returns spawn locations
	#print("spawn locations:" , spawn_locations["enemy_spawn_locations"])
	var world_data = generate_objects_in_world(spawn_locations) #generate_objects_in_world(spawn_locations
	world_data["astar"] = astar
	world_data["astar_points_cache"] = astar_points_cache
	#print(spawn_locations)
	#print("array of tiles", tilemap.get_used_cells())
	#print("tiles data: " , tiles_data)
	return world_data
func generate_minigame():
	spawn_room_created = false
	first_room_created =  false
	#print(map_size)
	#print(int(rand_range(0,100)))
	spawn_room_dir = 1
	#print(spawn_room_dir)
	var room_map = {}
	map_size  = 3
	#print(typeof(room_map))
	var size = 0

	room_map[Vector2(0,0)] = room.instance()
	room_map[Vector2(0,0)].coord = Vector2(0,0)
	#print("dungeon at the start  " , dungeon)
	size += 1

	while(size < map_size):
		for i in room_map.keys(): # i is the key and dungeon[i] is the node (room)
			if(1==1): #can create randomness factor if you set it to rand_range
				var direction = 1
				if !first_room_created:
					#print("happened")
					direction = spawn_room_dir
					#print(direction)
					first_room_created = true
				#print("directon: " , (direction))
				match direction:
					0:
						var new_room_position = i + Vector2(1, 0)
						if(!room_map.has(new_room_position)):
							room_map[new_room_position] = room.instance()
							room_map[new_room_position].coord = new_room_position
							size += 1
						if(room_map.get(i).adjacent_rooms.get(Vector2(1, 0)) == null):
							connect_rooms(room_map.get(i), room_map.get(new_room_position), Vector2(1, 0))
					1:
						var new_room_position = i + Vector2(-1, 0)
						if(!room_map.has(new_room_position)):
							room_map[new_room_position] = room.instance()
							room_map[new_room_position].coord = new_room_position
							size += 1
						if(room_map.get(i).adjacent_rooms.get(Vector2(-1, 0)) == null):
							connect_rooms(room_map.get(i), room_map.get(new_room_position), Vector2(-1, 0))
					2:
						var new_room_position = i + Vector2(0, 1)
						if(!room_map.has(new_room_position)):
							room_map[new_room_position] = room.instance()
							room_map[new_room_position].coord = new_room_position
							size += 1
						if(room_map.get(i).adjacent_rooms.get(Vector2(0, 1)) == null):
							connect_rooms(room_map.get(i), room_map.get(new_room_position), Vector2(0, 1))
					3:
						var new_room_position = i + Vector2(0, -1)
						if(!room_map.has(new_room_position)):
							room_map[new_room_position] = room.instance()
							room_map[new_room_position].coord = new_room_position
							size += 1
						if(room_map.get(i).adjacent_rooms.get(Vector2(0, -1)) == null):
							connect_rooms(room_map.get(i), room_map.get(new_room_position), Vector2(0, -1))
	#return room_map
	
	var rooms_data = room_map 
	var spawn_locations = generate_rooms(rooms_data) #generates rooms and returns spawn locations
	#get_tree().call_group("enemies", "queue_free")
	#print("spawn locations:" , spawn_locations["enemy_spawn_locations"])
	var world_data = generate_objects_in_world(spawn_locations) #generate_objects_in_world(spawn_locations
	world_data["astar"] = astar
	world_data["astar_points_cache"] = astar_points_cache
	#print(spawn_locations)
	#print("array of tiles", tilemap.get_used_cells())
	#print("tiles data: " , tiles_data)
	return world_data
func init(scn_root, tilemap_ref,tilemap_ref2):
	spawn_room_created = false
	scene_root = scn_root 
	tilemap = tilemap_ref
	tilemap2 = tilemap_ref2
	
	#var whole_map = map_generate()
	#print("whole map: " , whole_map)
	#print(generate_rooms(whole_map))
func map_generate():
	spawn_room_created = false
	first_room_created =  false
	#print(map_size)
	#print(int(rand_range(0,100)))
	spawn_room_dir = randi() % 4
	#print(spawn_room_dir)
	var room_map = {}
	#print(typeof(room_map))
	var size = 0
	
	room_map[Vector2(0,0)] = room.instance()
	room_map[Vector2(0,0)].coord = Vector2(0,0)
	#print("dungeon at the start  " , dungeon)
	size += 1
	
	while(size < map_size):
		for i in room_map.keys(): # i is the key and dungeon[i] is the node (room)
			if(1==1): #can create randomness factor if you set it to rand_range
				var direction = int(rand_range(0,4)) 
				if !first_room_created:
					#print("happened")
					direction = spawn_room_dir
					#print(direction)
					first_room_created = true
				#print("directon: " , (direction))
				match direction:
					0:
						var new_room_position = i + Vector2(1, 0)
						if(!room_map.has(new_room_position)):
							room_map[new_room_position] = room.instance()
							room_map[new_room_position].coord = new_room_position
							size += 1
						if(room_map.get(i).adjacent_rooms.get(Vector2(1, 0)) == null):
							connect_rooms(room_map.get(i), room_map.get(new_room_position), Vector2(1, 0))
					1:
						var new_room_position = i + Vector2(-1, 0)
						if(!room_map.has(new_room_position)):
							room_map[new_room_position] = room.instance()
							room_map[new_room_position].coord = new_room_position
							size += 1
						if(room_map.get(i).adjacent_rooms.get(Vector2(-1, 0)) == null):
							connect_rooms(room_map.get(i), room_map.get(new_room_position), Vector2(-1, 0))
					2:
						var new_room_position = i + Vector2(0, 1)
						if(!room_map.has(new_room_position)):
							room_map[new_room_position] = room.instance()
							room_map[new_room_position].coord = new_room_position
							size += 1
						if(room_map.get(i).adjacent_rooms.get(Vector2(0, 1)) == null):
							connect_rooms(room_map.get(i), room_map.get(new_room_position), Vector2(0, 1))
					3:
						var new_room_position = i + Vector2(0, -1)
						if(!room_map.has(new_room_position)):
							room_map[new_room_position] = room.instance()
							room_map[new_room_position].coord = new_room_position
							size += 1
						if(room_map.get(i).adjacent_rooms.get(Vector2(0, -1)) == null):
							connect_rooms(room_map.get(i), room_map.get(new_room_position), Vector2(0, -1))
	return room_map


func connect_rooms(room1, room2, direction):
	room1.adjacent_rooms[direction] = room2
	room2.adjacent_rooms[-direction] = room1
	room1.num_of_adjacent_rooms += 1
	room2.num_of_adjacent_rooms += 1

func generate_rooms(rooms_data_list: Dictionary) -> Dictionary:
	#print("rooms data list : " , rooms_data_list) 
	var spawn_locations = {
		"enemy_spawn_locations": [],
		"pickup_spawn_locations": [],
		"key_coords" : [],
		"door_coords": [],
		"exit_coords": [],
		"ladder_coords" : []
	}
	var ind = 0
	#print("rooms data list values: " , rooms_data_list) 
	for room_data in rooms_data_list: #room data is the key for the values of room keys
		#print(room_data)
		var coords = room_data
		#print(coords)
		#print("coords: " , coords)
		var x_pos = room_data[0] * 8
		var y_pos = room_data[1] * 8
		var rand_room_type = (randi() % (NUM_OF_ROOM_TYPES - 1)) + 1 #all but 0 
		#var rand_room_loc = select_rand_room_location(possible_room_locations, rooms_data)
		rooms_data_list[room_data].room_type = rand_room_type# int(rand_range(0,12)) 
		rooms_data_list[Vector2(0,0)].room_type = 0
		var type = rooms_data_list[room_data].room_type
		var x_pos_img = (type % 8) * 8 
		var y_pos_img = (type / 8) * 8
		for x in range(8): #room size is 8 by 8 yeah it's just the room size but so weirdly coded
			for y in range(8):
				rooms_texture_data.lock()
				spawn_texture_data.lock()
				floors_texture_data.lock()
				var cell_data = rooms_texture_data.get_pixel(x_pos_img+x, y_pos_img+y)
				var spawn_data = spawn_texture_data.get_pixel(x_pos_img+x, y_pos_img+y)
				var floor_data = floors_texture_data.get_pixel(x_pos_img+x, y_pos_img+y)
				var cell_coords = [x_pos+x, y_pos+y]
				#print(cell_coords)
				var walk_tile = false
				if cell_data == Color.white:
					#tilemap.set_cell(x_pos+x, y_pos+y, 2, randi()%2==0,randi()%2==0)
					tiles_data[Vector2(x_pos+x, y_pos+y)] = 0 # walkable floor tile
					walk_tile = true
				elif cell_data == Color.black:
					tiles_data[Vector2(x_pos+x, y_pos+y)] = 1 #breakable
				elif cell_data == Color.red:
					tiles_data[Vector2(x_pos+x, y_pos+y)] = 2 #not breakable
					pass
				if floor_data == Color.white:
					tilemap.set_cell(x_pos+x, y_pos+y, 2, randi()%2==0,randi()%2==0)
				elif floor_data == Color.black:
					tilemap.set_cell(x_pos+x, y_pos+y, 0, randi()%2==0,randi()%2==0)
				elif floor_data == Color.red:
					tilemap2.set_cell(x_pos+x, y_pos+y, 0)#, randi()%2==0,randi()%2==0)
					#tilemap.set_cell(x_pos+x, y_pos+y, 1, randi()%2==0,randi()%2==0)
				elif floor_data == Color("a52a2a"):
					tilemap.set_cell(x_pos+x, y_pos+y, 3)
				elif floor_data == Color.blue:
					tilemap.set_cell(x_pos+x, y_pos+y, 3)
				if spawn_data == Color.red:
					spawn_locations.enemy_spawn_locations.append(cell_coords)
				elif spawn_data == Color("ff9b00"):
					spawn_locations.door_coords.append(cell_coords)
				elif spawn_data == Color.green:
					spawn_locations.pickup_spawn_locations.append(cell_coords)
				elif spawn_data == Color.blue:
					spawn_locations.key_coords.append(cell_coords)
				elif spawn_data == Color("ff00c1"):
					spawn_locations.exit_coords.append(cell_coords)
				if walk_tile:
					walkable_floor_tiles[str([x_pos+x, y_pos+y])] = [x_pos+x, y_pos+y]
		var scoords = ""
		var room_at_left = Vector2(coords[0]-1, coords[1]) in rooms_data_list #if statement if the room is at left 
		var room_at_right = Vector2(coords[0]+1, coords[1]) in rooms_data_list 
		var room_at_top = Vector2(coords[0], coords[1]-1)in rooms_data_list 
		var room_at_bottom = Vector2(coords[0], coords[1]+1) in rooms_data_list 
		#print(room_at_left)
		if !room_at_left:
			
			if(!spawn_room_created  and spawn_room_dir == 1):
				player_spawn_coords = Vector2(x_pos+5,y_pos+2) 
				spawn_locations.ladder_coords.append([x_pos+5,y_pos+2])
				#spawn_objects_at_locations(ladder, [x_pos+4,y_pos+4], 1, "ladder")
				for x in 8:
					for y in 8:
						if((x== 0 or x==7)  and (y==0 or y==7)):
							tilemap2.set_cell(x_pos+x, y_pos+y,0)
							tilemap.set_cell(x_pos+x, y_pos+y, -1)
							tiles_data[Vector2(x_pos+x, y_pos+y)] = 2
							spawn_locations.pickup_spawn_locations.erase([x_pos+x, y_pos+y])
						else: 
							tilemap2.set_cell(x_pos+x, y_pos+y, -1)
							tilemap.set_cell(x_pos+x, y_pos+y, 3)
							tiles_data[Vector2(x_pos+x, y_pos+y)] = 0
							walkable_floor_tiles[str([x_pos+x, y_pos+y])] = [x_pos+x, y_pos+y]
						spawn_locations.key_coords.erase([x_pos+x, y_pos+y])
						spawn_locations.enemy_spawn_locations.erase([x_pos+x, y_pos+y])
				#tilemap.set_cell(x_pos+4,y_pos+3,0)
				spawn_room_created = true
			for i in 8:
				tiles_data[Vector2(x_pos-1, y_pos+i)] = 2
				for _i in 8:
					tilemap2.set_cell(x_pos-1-_i, y_pos+i, 0)
				
		if !room_at_right:
			if(!spawn_room_created  and spawn_room_dir == 0):
				player_spawn_coords = Vector2(x_pos+5,y_pos+2) 
				spawn_locations.ladder_coords.append([x_pos+5,y_pos+2])
				#spawn_objects_at_locations(ladder, [x_pos+4,y_pos+4], 1, "ladder")
				for x in 8:
					for y in 8:
						if((x== 0 or x==7)  and (y==0 or y==7)):
							tilemap.set_cell(x_pos+x, y_pos+y, -1)
							tilemap2.set_cell(x_pos+x, y_pos+y,0)
							tiles_data[Vector2(x_pos+x, y_pos+y)] = 2
							spawn_locations.pickup_spawn_locations.erase([x_pos+x, y_pos+y])
						else: 
							tilemap2.set_cell(x_pos+x, y_pos+y, -1)
							tilemap.set_cell(x_pos+x, y_pos+y, 3)
							tiles_data[Vector2(x_pos+x, y_pos+y)] = 0
							walkable_floor_tiles[str([x_pos+x, y_pos+y])] = [x_pos+x, y_pos+y]
						spawn_locations.key_coords.erase([x_pos+x, y_pos+y])
						spawn_locations.enemy_spawn_locations.erase([x_pos+x, y_pos+y])
				#tilemap.set_cell(x_pos+4,y_pos+3,0)
				spawn_room_created = true
			for i in 8:
				tiles_data[Vector2(x_pos+8, y_pos+i)] = 2
				for _i in 8:
					tilemap2.set_cell(x_pos+8+_i, y_pos+i, 0)
		if !room_at_top:
			if(!spawn_room_created  and spawn_room_dir == 3):
				player_spawn_coords = Vector2(x_pos+5,y_pos+2) 
				spawn_locations.ladder_coords.append([x_pos+5,y_pos+2])
				#spawn_objects_at_locations(ladder, [x_pos+4,y_pos+4], 1, "ladder")
				for x in 8:
					for y in 8:
						if((x== 0 or x==7)  and (y==0 or y==7)):
							tilemap.set_cell(x_pos+x, y_pos+y, -1)
							tilemap2.set_cell(x_pos+x, y_pos+y,0)
							tiles_data[Vector2(x_pos+x, y_pos+y)] = 2
							spawn_locations.pickup_spawn_locations.erase([x_pos+x, y_pos+y])
						else: 
							tilemap2.set_cell(x_pos+x, y_pos+y, -1)
							tilemap.set_cell(x_pos+x, y_pos+y, 3)
							tiles_data[Vector2(x_pos+x, y_pos+y)] = 0
							walkable_floor_tiles[str([x_pos+x, y_pos+y])] = [x_pos+x, y_pos+y]
						spawn_locations.key_coords.erase([x_pos+x, y_pos+y])
						spawn_locations.enemy_spawn_locations.erase([x_pos+x, y_pos+y])
				#tilemap.set_cell(x_pos+4,y_pos+3,0)
				spawn_room_created = true
			for i in 8:
				tiles_data[Vector2(x_pos+i, y_pos-1)] = 2
				for _i in 8:
					tilemap2.set_cell(x_pos+i, y_pos-1-_i, 0)
		if !room_at_bottom:
			if(!spawn_room_created  and spawn_room_dir == 2):
				player_spawn_coords = Vector2(x_pos+5,y_pos+2) 
				spawn_locations.ladder_coords.append([x_pos+5,y_pos+2])
				#spawn_objects_at_locations(ladder, [x_pos+4,y_pos+4], 1, "ladder")
				for x in 8:
					for y in 8:
						if((x== 0 or x==7)  and (y==0 or y==7)):
							tilemap.set_cell(x_pos+x, y_pos+y, -1)
							tilemap2.set_cell(x_pos+x, y_pos+y,0)
							tiles_data[Vector2(x_pos+x, y_pos+y)] = 2
							spawn_locations.pickup_spawn_locations.erase([x_pos+x, y_pos+y])
						else: 
							tilemap2.set_cell(x_pos+x, y_pos+y, -1)
							tilemap.set_cell(x_pos+x, y_pos+y, 3)
							tiles_data[Vector2(x_pos+x, y_pos+y)] = 0
							walkable_floor_tiles[str([x_pos+x, y_pos+y])] = [x_pos+x, y_pos+y]
						spawn_locations.key_coords.erase([x_pos+x, y_pos+y])
						spawn_locations.enemy_spawn_locations.erase([x_pos+x, y_pos+y])
				#tilemap.set_cell(x_pos+4,y_pos+3,0)
				spawn_room_created = true
			for i in 8:
				#tiles_data[Vector2(x_pos+i, y_pos+8-1)] = 2
				tiles_data[Vector2(x_pos+i, y_pos+8)] = 2
				for _i in 8:
					tilemap2.set_cell(x_pos+i, y_pos+8+_i, 0)
	generate_astar_grid(walkable_floor_tiles)
	return spawn_locations
	#print("rooms_data_list: " , rooms_data_list)
	return rooms_data_list
func generate_objects_in_world(spawn_locations: Dictionary) -> Dictionary:
	#player.global_position = map_coord_to_world_pos(Vector2.ONE)
	#exit.global_position = map_coord_to_world_pos(spawn_locations.exit_coords)
	
	var enemy_count = map_size
	var enemies = spawn_objects_at_locations(enemy, spawn_locations.enemy_spawn_locations, enemy_count, "enemies")
	var doors = spawn_objects_at_locations(door, spawn_locations.door_coords, 4, "doors")
	#print("enemies" , enemies)
	var pickup_spawn_locations = spawn_locations.pickup_spawn_locations
	var keys = spawn_objects_at_locations(key, spawn_locations.key_coords, 1, "keys")
	var shovels = spawn_objects_at_locations(shovel, spawn_locations.pickup_spawn_locations, map_size, "shovels")
	var exits =spawn_objects_at_locations(exit, spawn_locations.exit_coords, 2, "exit")
	var ladders =spawn_objects_at_locations(ladder, spawn_locations.ladder_coords, 1, "ladder")
	var treasure = {}
	#if treasure_ind < treasures.size() and randi() % CHANCE_OF_TREASURE_SPAWNING == 0:
	#	treasure["object_data"] = spawn_objects_at_locations(treasures[treasure_ind].scene_object, spawn_locations.pickup_spawn_locations, 1, "treasure")
	#	treasure["header"] = treasures[treasure_ind].header
	#	treasure["message"] = treasures[treasure_ind].message
	#	treasure["image"]  = treasures[treasure_ind].image
	
	#var potion_count = START_POTION_COUNT + cur_level * POTION_COUNT_INCREASE_PER_LEVEL
	#var potions = spawn_objects_at_locations(potion, spawn_locations.pickup_spawn_locations, potion_count, "potions")
	#var doors = spawn_objects_at_locations(door, spawn_locations.door_coords, DOOR_COUNT, "doors", false)
	
	var data = {
		"enemies": enemies,
		"keys": keys,
		"shovels" : shovels,
		"potions": null,
		"doors": doors,
		"player": null,
		"exit": exits,
		"treasure_data": null,
		"ladder" : ladders
	}
	return data
func spawn_objects_at_locations(object_to_spawn, location_list: Array, num_to_spawn: int, group_name: String, flip_randomly=true) -> Dictionary:
	# data is in dict with format "coords": obj, e.g. "(0, 3)": <obj_ref>
	var spawned_objs = {}
	for _i in range(num_to_spawn):
		if location_list.size() == 0:
			break
		#print(object_to_spawn)
		var inst = object_to_spawn.instance()
		scene_root.add_child(inst)
		var rand_loc_ind = randi() % location_list.size()
		var coord = location_list[rand_loc_ind]
		inst.global_position = map_coord_to_world_pos(coord)
		location_list.remove(rand_loc_ind)
		spawned_objs[str(coord)] = inst
		inst.add_to_group(group_name)
		if flip_randomly and inst.has_node("Sprite") and randi() % 2 == 0:
			inst.get_node("Sprite").flip_h = true
	return spawned_objs
func generate_astar_grid(walkable_floor_tilspawes):
	astar_points_cache = {}
	#print("walkable floor tiles: ", walkable_floor_tiles) #basically dictionary of walkable tiles 
	for tile_coord in walkable_floor_tiles.values():
		var tile_id = astar.get_available_point_id()
		#print("tile_id" , tile_id)
		astar.add_point(tile_id, Vector2(tile_coord[0], tile_coord[1]))
		astar_points_cache[str([tile_coord[0], tile_coord[1]])] = tile_id
	
	for tile_coord in walkable_floor_tiles.values():
		var tile_id = astar_points_cache[str([tile_coord[0], tile_coord[1]])]
		var left_x_key = str([tile_coord[0]-1, tile_coord[1]])
		if left_x_key in astar_points_cache:
			astar.connect_points(astar_points_cache[left_x_key], tile_id)
		var up_y_key = str([tile_coord[0], tile_coord[1]-1])
		if up_y_key in astar_points_cache:
			astar.connect_points(astar_points_cache[up_y_key], tile_id)
	#print(astar_points_cache)
func map_coord_to_world_pos(coord):
	return tilemap.map_to_world(Vector2(coord[0], coord[1])) + Vector2(16 / 2, 16 / 2)
