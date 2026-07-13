extends Node2D

@onready var dark_chest: Node2D = $Interactables/Chests/Chest2
@onready var walls_layer: TileMapLayer = $ObjectLayer

@export_group("Puzzle Door Tracking Keys")
@export var puzzle_wall_unique_id: String = "hidden_dungeon_door_1"

const TARGET_TILE_1: Vector2i = Vector2i(7, -27)
const TARGET_TILE_2: Vector2i = Vector2i(7, -26)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	#dark_chest.chest_opened.connect(_dark_chest_opened)
	dark_chest.chest_opened.connect(break_puzzle_wall_via_gameplay)
	_evaluate_puzzle_wall_persistence()

func _evaluate_puzzle_wall_persistence() -> void:
	if walls_layer and puzzle_wall_unique_id != "":
		var level_name: String = name
		if GlobalPlayerData.has_been_triggered(level_name, puzzle_wall_unique_id):
			print("Persistence Engine: Restoring broken wall path natively on load pass.")
			walls_layer.set_cell(TARGET_TILE_1, -1)
			walls_layer.set_cell(TARGET_TILE_2, -1)

func break_puzzle_wall_via_gameplay() -> void:
	if puzzle_wall_unique_id != "":
		var level_name: String = name
		GlobalPlayerData.register_world_trigger(level_name, puzzle_wall_unique_id)
	
	if walls_layer:
		walls_layer.set_cell(TARGET_TILE_1, -1)
		walls_layer.set_cell(TARGET_TILE_2, -1)
		
		#var camera = find_child("Camera2D", true, false)
		#if camera and camera.has_method("trigger_screen_shake"):
			#camera.trigger_screen_shake(0.5)

func _dark_chest_opened() -> void:
	print("Upon opening the chest, the way has been cleared.")
	
	var target_tile_1: Vector2i = Vector2i(7, -27)
	var target_tile_2: Vector2i = Vector2i(7, -26)
	
	if walls_layer:
		walls_layer.set_cell(target_tile_1, -1)
		walls_layer.set_cell(target_tile_2, -1)
		
		## Erase a whole horizontal line of 4 wall tiles in one go!
		#for x_offset in range(4):
			#walls_layer.set_cell(Vector2i(starting_x + x_offset, starting_y), -1)
		
		#_spawn_doorway_explosion_visuals(target_tile_1)
		#print("Way opened cleanly. Physics boundaries cleared natively in RAM.")

#func _spawn_doorway_explosion_visuals(grid_coord: Vector2i) -> void:
	#var world_pixel_pos: Vector2 = Vector2(grid_coord * 16) + Vector2(8, 8)
	#var overlay = get_tree().get_first_node_in_group("TransitionEngine")
	#var camera = find_child("Camera2D", true, false)
	#if camera and camera.has_method("trigger_screen_shake"):
		#camera.trigger_screen_shake(0.4)

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
