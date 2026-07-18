extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

@onready var sprite: Sprite2D = $Sprite2D
@onready var blast_zone: Area2D = $ExplosionRadius

var explosion_scale: float = 1.6
#var temp_radius = 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_player.play("fuse_tick")

func trigger_explosion() -> void:
	print("BOOM!")
	
	sprite.scale = Vector2(explosion_scale, explosion_scale)
	$ExplosionRadius/CollisionShape2D.shape.radius *= explosion_scale
	#blast_zone.scale = Vector2(1.6, 1.6)
	
	var root_node = get_tree().root
	var game_manager = root_node.get_node_or_null("Game")
	if game_manager:
		var world_container = game_manager.get_node_or_null("World")
		if world_container and world_container.get_child_count() > 0:
			var current_level_map = world_container.get_child(0)
			
			var camera = current_level_map.get_node_or_null("Camera2D")
			if camera and camera.has_method("trigger_screen_shake"):
				camera.trigger_screen_shake(0.6)
	
	var hit_bodies = blast_zone.get_overlapping_bodies()
	for body in hit_bodies:
		if body.has_method("take_damage"):
			body.take_damage(1)
		elif body.has_method("take_damage_via_bomb"):
			body.take_damage_via_bomb()
	_detect_and_blast_puzzle_tiles()
	await get_tree().create_timer(0.25).timeout
	queue_free()

func _detect_and_blast_puzzle_tiles() -> void:
	var active_map = get_parent().get_parent()
	
	if active_map and active_map.has_method("shatter_tile_via_bomb"):
		var walls_layer = active_map.walls_layer
		if not walls_layer: return
		
		var impacted_cells: Array[Vector2i] = []
		var collision_shape_node = $ExplosionRadius/CollisionShape2D
		if collision_shape_node and collision_shape_node.shape is CircleShape2D:
			var radius: float = collision_shape_node.shape.radius
			print(radius)
			var center_map_pos: Vector2i = walls_layer.local_to_map(blast_zone.global_position)
			var tile_range_limit: int = ceil(radius / 16.0) + 1
			print(tile_range_limit)
			
			for x_offset in range(-tile_range_limit, tile_range_limit + 1):
				for y_offset in range(-tile_range_limit, tile_range_limit + 1):
					var test_cell: Vector2i = center_map_pos + Vector2i(x_offset, y_offset)
					var cell_world_pos: Vector2 = Vector2(test_cell * 16) + Vector2(8, 8)
					if global_position.distance_to(cell_world_pos) <= radius:
						impacted_cells.append(test_cell)
		
		print(impacted_cells)
		if not impacted_cells.is_empty():
			active_map.shatter_tile_via_bomb(impacted_cells)
