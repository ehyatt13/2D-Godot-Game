extends Node2D

@onready var world_container: Node2D = $"World"
@onready var player_scene: PackedScene = preload("res://scenes/player.tscn")

var current_level_node: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	change_level("res://scenes/test_island_level.tscn", Vector2(0.0, 0.0))

func change_level(level_path: String, spawn_position: Vector2) -> void:
	if current_level_node:
		current_level_node.queue_free()
		await current_level_node.tree_exited
	
	var new_level_resource: PackedScene = load(level_path)
	current_level_node = new_level_resource.instantiate()
	
	world_container.add_child(current_level_node)
	
	var entities_folder = current_level_node.get_node_or_null("Entities")
	if entities_folder:
		var player_instance = player_scene.instantiate()
		entities_folder.add_child(player_instance)
		player_instance.global_position = spawn_position
		#player_instance.set_collision_mask_value(3, false) #collision off for testing
		
		var camera = current_level_node.get_node_or_null("Camera2D")
		if camera:
			camera.player_target = player_instance
			camera.global_position = spawn_position
			
			camera.reset_physics_interpolation()
			camera.force_update_scroll()
			camera.reset_smoothing()
			
		var modulator = current_level_node.get_node_or_null("CanvasModulate")
		if modulator and "lighting_preset" in modulator:
			var player_light = player_instance.get_node_or_null("PointLight2D")
			if player_light and player_light.has_method("force_initial_preset"):
				player_light.force_initial_preset(modulator.lighting_preset)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
