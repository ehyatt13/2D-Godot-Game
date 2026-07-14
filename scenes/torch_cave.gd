extends IndoorLevel

@onready var dark_chest: Node2D = $Interactables/Chests/Chest2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	dark_chest.chest_opened.connect(func(): shatter_tiles_via_trigger("secret_wall1"))

#func _dark_chest_opened() -> void:
	#print("Upon opening the chest, the way has been cleared.")
	#
	#var target_tile_1: Vector2i = Vector2i(7, -27)
	#var target_tile_2: Vector2i = Vector2i(7, -26)
	#
	#if walls_layer:
		#walls_layer.set_cell(target_tile_1, -1)
		#walls_layer.set_cell(target_tile_2, -1)
		#
		### Erase a whole horizontal line of 4 wall tiles in one go!
		##for x_offset in range(4):
			##walls_layer.set_cell(Vector2i(starting_x + x_offset, starting_y), -1)
		#
		##_spawn_doorway_explosion_visuals(target_tile_1)
		##print("Way opened cleanly. Physics boundaries cleared natively in RAM.")
