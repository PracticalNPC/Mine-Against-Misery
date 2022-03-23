extends Node2D
onready var tilemap = $TileMap
onready var player = $Player
onready var tiles_data = $DungeonGenerator.tiles_data
onready var player_pos = world_pos_to_map_coord(player.global_position)

var enemies = null
var doors = null
var keys = null
var shovels = null
var exit = null
var astar = null
var astar_points_cache = {}
var turn_pass = false
var min_moves = 2
var moves_left = min_moves
var player_moved = false
#onready var world_generator = $WorldGenerator

func _ready():
	randomize()
	player.player_coords = player_pos
	#$DungeonGenerator.init(self,  $TileMap, $TileMap2)
	var world_data  = $DungeonGenerator.generate_world()
	astar = world_data.astar
	astar_points_cache = world_data.astar_points_cache
	#print("astar: "  , astar)
	enemies = world_data.enemies
	doors = world_data.doors
	keys = world_data.keys
	shovels = world_data.shovels
	exit = world_data.exit
	$CanvasLayer/Label.text = "pickaxes: " +str(player.shovels) + "\n" + "keys: " + str(player.keys) + "\n" + "level: " + str($DungeonGenerator.map_size -2)
	#var tilemap_array = $TileMap.get_used_cells()
	#print($DungeonGenerator.player_spawn_coords)
	#player.set_global_position($DungeonGenerator.map_coord_to_world_pos($DungeonGenerator.player_spawn_coords))
	#player.global_position = $DungeonGenerator.map_coord_to_world_pos($DungeonGenerator.player_spawn_coords)
	player.global_position = $DungeonGenerator.map_coord_to_world_pos($DungeonGenerator.player_spawn_coords)
	#player.global_position = Vector2(0,0)
	#player_pos = world_pos_to_map_coord(player.global_position)
	#player.player_coords = player_pos

func _process(delta):
	

	if player_moved:
		#player.set_global_position($DungeonGenerator.map_coord_to_world_pos($DungeonGenerator.player_spawn_coords))
		#moves_left -= 1
		var moved = move_character(player, player.move_dir)
		player_pos = world_pos_to_map_coord(player.global_position)
		#print("player pos" , player_pos[0])
		$TileMap.update_bitmask_area(Vector2(player_pos[0],player_pos[1]))
		player.player_coords = player_pos
		for enemy in enemies.values():
			#print("did this prit")
			var enemy_pos = world_pos_to_map_coord(enemy.global_position)
			if !enemy.alerted and enemy.has_line_of_sight(player_pos, enemy_pos, tilemap):
				if enemy.global_position.distance_to(player.global_position ) < 80:
					enemy.alert()
		player_moved = false
	if moves_left == 0 or turn_pass == true:
		$Turn_Timer.start(.5)
		turn_pass = false
		moves_left = min_moves
		#update_steps_info()
		var enemies_to_move = []
		for enemy_pos_ind in enemies:
			var enemy = enemies[enemy_pos_ind]
			if enemy.alerted and !enemy.just_alerted:
				enemies_to_move.append(enemy)
			else:
				enemy.just_alerted = false
		for enemy in enemies_to_move:
			var enemy_pos = world_pos_to_map_coord(enemy.global_position)
			var player_pos = world_pos_to_map_coord(player.global_position)
			var path = enemy.get_grid_path(enemy_pos, player_pos, astar, astar_points_cache)
			#print(enemy_pos)
			if path.size() > 1:
				#print("path is greater than 1")
				if enemy_pos[0] < int(round(path[1].x)):
					move_character(enemy, Vector2(1,0))
				elif enemy_pos[0] > int(round(path[1].x)):
					move_character(enemy, Vector2(-1,0))
				elif enemy_pos[1] < int(round(path[1].y)):
					move_character(enemy, Vector2(0,1))
				elif enemy_pos[1] > int(round(path[1].y)):
					move_character(enemy, Vector2(0,-1))
func world_pos_to_map_coord(pos: Vector2):
	var vcoords = tilemap.world_to_map(pos) 
	
	#print("vcoords: " , vcoords )
	var coords = [int(round(vcoords.x)), int(round(vcoords.y))]
	return coords
func move_character(character, dir):
	var is_player = character == player
	#print("isplayer" ,  is_player)
	var coords = world_pos_to_map_coord(character.global_position)
	#print("coords: " ,  coords)
	var old_coords = coords.duplicate()
	coords[0] += dir[0]
	coords[1] += dir[1]
	
	if(can_move_to_coords(coords,is_player)):
		character.global_position = $DungeonGenerator.map_coord_to_world_pos(coords)
		if(is_player):
			#print("player_global:" , player.global_position)
			moves_left -= 1
			$CanvasLayer/Label.text = "pickaxes: " +str(player.shovels) + "\n" + "keys: " + str(player.keys) + "\n" + "level: " + str($DungeonGenerator.map_size -2)
			if enemies.has(str(coords)):
				kill_player()
				return
		else:
			enemies.erase(str(old_coords))
			enemies[str(coords)] = character
			print("enemy coords: " , coords)
			print("player coords: " , player_pos)
			if character.global_position ==player.global_position and player.dead== false:
				#print("died")
				kill_player()
				return
		#print(moves_left)
func kill_player():
	player.dead=true
	$CanvasLayer/sound_effects/death.play()
	$CanvasLayer/sound_effects/evil_laugh.play()
	$Timer.start(2.5)

func can_move_to_coords(coords, is_player):
	#print("tilemap get cell: " , tilemap.get_cell(coords[0],coords[1]))
	#print("coords: " , coords)
	var can_move = false
	if is_player:
		if(tiles_data[Vector2(coords[0], coords[1])] == 0):
			can_move = true
			if(keys.has(str(coords))):
				#player.position = Vector2(9,9)
				player.keys += 1
				keys[str(coords)].queue_free()
				keys.erase(str(coords))
				var strm = $CanvasLayer/Item_sounds/key.stream as AudioStreamOGGVorbis
				strm.set_loop(false)
				$CanvasLayer/Item_sounds/key.play()
			elif(shovels.has(str(coords))):
				player.shovels += 1
				shovels[str(coords)].queue_free()
				shovels.erase(str(coords))
				$CanvasLayer/Item_sounds/pickaxe.play()
			elif(exit.has(str(coords))):
				change_level(true)
				return
		elif(doors.has(str(coords)) and player.keys!= 0):
			#print("123")
			doors[str(coords)].open_door(Vector2(coords[0], coords[1]))
			can_move = true
		else:
			can_move =  false
		return can_move
	else:
		
		if enemies.has(str("[" , coords[0] , ", " , coords[1] , "]")):
			#print(Vector2(0,0))
			return false
		elif tiles_data[Vector2(coords[0], coords[1])] == 0:
			#print(coords)
			#print(enemies)
			#print(str("[" , coords[0] , ", " , coords[1] , "]"))
			#print(enemies)
			return true
	
	return false
		
	#if(tilemap.get_cell(coords[0],coords[1]) <= 1 ):
	#	return false
	#return true
func change_level(didnt_die):
	#randomize()
	#player.global_position = Vector2(24,24)
	#print("player position after level" , player.global_position)
	#player.player_coords = player_pos
	if didnt_die:
		$CanvasLayer/sound_effects/exit.play()
		$DungeonGenerator.map_size += 1
	else:
		$DungeonGenerator.map_size =3
		player.dead= false
		player.shovels = 10
	$DungeonGenerator.init(self,  $TileMap, $TileMap2)
	var world_data  = $DungeonGenerator.generate_world()
	astar = world_data.astar
	astar_points_cache = world_data.astar_points_cache
	#print("astar: "  , astar)
	enemies = world_data.enemies
	doors = world_data.doors
	keys = world_data.keys
	shovels = world_data.shovels
	exit = world_data.exit
	$CanvasLayer/Label.text = "pickaxes: " +str(player.shovels) + "\n" + "keys: " + str(player.keys) + "\n" + "level: " + str($DungeonGenerator.map_size -2)
	#var tilemap_array = $TileMap.get_used_cells()
	#player_pos = world_pos_to_map_coord(player.global_position)
	player.global_position = $DungeonGenerator.map_coord_to_world_pos($DungeonGenerator.player_spawn_coords)
	player_pos = world_pos_to_map_coord(player.global_position)
	player.keys = 0
	#print("player_global:" , player.global_position)
	#player.global_position = Vector2(24,24)
	#player.player_coords = player_pos
	#player.set_global_position((Vector2(9,9)))
	#print(player.global_position)
func _on_Turn_Timer_timeout():
	turn_pass = true
	$Turn_Timer.stop()


func _on_AudioStreamPlayer2D_finished():
	$CanvasLayer/AudioStreamPlayer2D.play()
	pass # Replace with function body.


func _on_AudioStreamPlayer2D2_finished():
	$CanvasLayer/AudioStreamPlayer2D2.play()
	pass # Replace with function body.


func _on_Timer_timeout():
	change_level(false)
	pass # Replace with function body.
