extends Node2D

onready var door_pos = get_parent().world_pos_to_map_coord(self.get_global_position())
onready var tiles_data = get_parent().tiles_data
onready var tilemap = get_parent().tilemap
onready var world = get_parent()
var locked = true


# Called when the node enters the scene tree for the first time.
func _ready():
	#print("door pos: " , self.get_global_position())
	pass # Replace with function body.
func open_door(target_cell):
	if locked == true:
		var strm = $Open_sound.stream as AudioStreamOGGVorbis
		strm.set_loop(false)
		$Open_sound.play()
		locked = false
	tilemap.set_cell(target_cell[0],target_cell[1], 2 )
	tiles_data[target_cell] = 0
	$Sprite.set_frame(30)
	#$Open_sound.stop()
	#print("astar: " , world.astar)
	#print("cache:"  , world.astar_points_cache)
	edit_map(target_cell)
func edit_map(_target_cell):
	#print("cache before:"  , world.astar_points_cache)
	var tile_id = world.astar.get_available_point_id()
	#print(tile_id)
	world.astar.add_point(tile_id, _target_cell)
	
	world.astar_points_cache[str("[" , _target_cell[0],", " , _target_cell[1] , "]")] = tile_id
	
	#var tile_id2 = astar_points_cache[str([_target_cell[0], _target_cell[1]])]
	var left_x_key = str([_target_cell[0]-1, _target_cell[1]])
	if left_x_key in world.astar_points_cache:
		world.astar.connect_points(world.astar_points_cache[left_x_key], tile_id)
	var up_y_key = str([_target_cell[0], _target_cell[1]-1])
	if up_y_key in world.astar_points_cache:
		world.astar.connect_points(world.astar_points_cache[up_y_key], tile_id)
	var right_x_key = str([_target_cell[0]+1, _target_cell[1]])
	if right_x_key in world.astar_points_cache:
		world.astar.connect_points(world.astar_points_cache[right_x_key], tile_id)
	var down_y_key = str([_target_cell[0], _target_cell[1]+1])
	if down_y_key in world.astar_points_cache:
		world.astar.connect_points(world.astar_points_cache[down_y_key], tile_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
