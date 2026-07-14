class_name BaseLevel
extends Node2D

@onready var walls_layer: TileMapLayer = $TileMapLayers/PuzzleLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_evaluate_all_tilemap_puzzle_persistence()

func _evaluate_all_tilemap_puzzle_persistence() -> void:
	if not walls_layer: return
	
	var level_name: String = name
	var active_cells: Array[Vector2i] = walls_layer.get_used_cells()
	var cells_to_erase: Array[Vector2i] = []
	
	for cell_coords in active_cells:
		var tile_data: TileData = walls_layer.get_cell_tile_data(cell_coords)
		if tile_data:
			var puzzle_tag: String = tile_data.get_custom_data("puzzle_id")
			if puzzle_tag != "":
				var coord_unique_key: String = puzzle_tag + "_X" + str(cell_coords.x) + "_Y" + str(cell_coords.y)
				if GlobalPlayerData.has_been_triggered(level_name, coord_unique_key):
					cells_to_erase.append(cell_coords)
	
	for cell in cells_to_erase:
		walls_layer.set_cell(cell, -1)

func shatter_tile_via_bomb(impact_coords: Vector2i) -> void:
	if not walls_layer: return
	
	var epicenter_data: TileData = walls_layer.get_cell_tile_data(impact_coords)
	if not epicenter_data or epicenter_data.get_custom_data("puzzle_id") == "": return
	
	var puzzle_tag: String = epicenter_data.get_custom_data("puzzle_id")
	var level_name: String = name
	
	var tiles_to_check: Array[Vector2i] = [impact_coords]
	var tiles_to_destroy: Array[Vector2i] = []
	
	while not tiles_to_check.is_empty():
		var current_cell: Vector2i = tiles_to_check.pop_front()
		if current_cell in tiles_to_destroy: continue
		tiles_to_destroy.append(current_cell)
		
		var neighbors: Array[Vector2i] = [
			current_cell + Vector2i.UP,
			current_cell + Vector2i.DOWN,
			current_cell + Vector2i.LEFT,
			current_cell + Vector2i.RIGHT
		]
		
		for neighbor_coords in neighbors:
			var neighbor_data: TileData = walls_layer.get_cell_tile_data(neighbor_coords)
			if neighbor_data and neighbor_data.get_custom_data("puzzle_id") == puzzle_tag:
				if not neighbor_coords in tiles_to_destroy and not neighbor_coords in tiles_to_check:
					tiles_to_check.append(neighbor_coords)
	
	for cell in tiles_to_destroy:
		var cell_unique_key: String = puzzle_tag + "_X" + str(cell.x) + "_Y" + str(cell.y)
		GlobalPlayerData.register_world_trigger(level_name, cell_unique_key)
		walls_layer.set_cell(cell, -1)
	
	_trigger_screen_shake(0.5)

func shatter_tiles_via_trigger(target_puzzle_tag: String) -> void:
	if not walls_layer or target_puzzle_tag == "": return
	
	var level_name: String = name
	var active_cells: Array[Vector2i] = walls_layer.get_used_cells()
	var cells_to_destroy: Array[Vector2i] = []
	
	for cell in active_cells:
		var tile_data = walls_layer.get_cell_tile_data(cell)
		if tile_data and tile_data.get_custom_data("puzzle_id") == target_puzzle_tag:
			cells_to_destroy.append(cell)
	
	for cell in cells_to_destroy:
		var cell_unique_key: String = target_puzzle_tag + "_X" + str(cell.x) + "_Y" + str(cell.y)
		GlobalPlayerData.register_world_trigger(level_name, cell_unique_key)
		walls_layer.set_cell(cell, -1)
	
	_trigger_screen_shake(0.4)

func _trigger_screen_shake(intensity: float) -> void:
	var camera = find_child("Camera2D", true, false)
	if camera and camera.has_method("trigger_screen_shake"):
		camera.trigger_screen_shake(intensity)
