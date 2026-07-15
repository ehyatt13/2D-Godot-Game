extends CanvasLayer

@onready var rect: ColorRect = $ShaderRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rect.material.set_shader_parameter("progress", 0.0)


func play_diamond_cut_transition(player_node: CharacterBody2D, camera_node: Camera2D, teleport_offset: Vector2, next_room: ReferenceRect) -> void:
	player_node.set_physics_process(false)
	if "is_attacking" in player_node: player_node.is_attacking = true
	
	var diamond_shader = load("res://assets/shaders/diamond_transition.gdshader")
	if rect.material and rect.material is ShaderMaterial:
		rect.material.shader = diamond_shader
	
	var tween = create_tween()
	tween.tween_property(rect.material, "shader_parameter/progress", 1.0, 0.4)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	player_node.global_position += teleport_offset
	
	if next_room and camera_node:
		var room_origin: Vector2 = next_room.global_position
		var room_size: Vector2 = next_room.size
		
		camera_node.limit_left = int(room_origin.x)
		camera_node.limit_top = int(room_origin.y)
		camera_node.limit_right = int(room_origin.x + room_size.x)
		camera_node.limit_bottom = int(room_origin.y + room_size.y)
	
	camera_node.global_position = player_node.global_position
	camera_node.reset_smoothing()
	
	var fade_tween = create_tween()
	fade_tween.tween_property(rect.material, "shader_parameter/progress", 0.0, 0.4)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await fade_tween.finished
	
	player_node.set_physics_process(true)
	if "is_attacking" in player_node: player_node.is_attacking = false

func play_iris_cut_transition(player_node: CharacterBody2D, target_level_path: String, spawn_coords: Vector2) -> void:
	if not player_node or not is_instance_valid(player_node): return
	player_node.set_physics_process(false)
	if "is_attacking" in player_node: player_node.is_attacking = true
	
	var iris_shader = load("res://assets/shaders/iris_transition.gdshader")
	if rect.material and rect.material is ShaderMaterial:
		rect.material.shader = iris_shader
		
	_update_shader_environment_parameters(player_node)
		
	rect.material.set_shader_parameter("progress", 0.0)
	
	var tween = create_tween()
	tween.tween_property(rect.material, "shader_parameter/progress", 1.0, 0.5)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	if "current_face_direction" in player_node:
		GlobalPlayerData.preserved_facing_direction = player_node.current_face_direction
	
	var game_manager = get_tree().root.get_node_or_null("Game")
	if game_manager and game_manager.has_method("execute_clean_map_switch"):
		game_manager.execute_clean_map_switch(target_level_path, spawn_coords)
	
	await get_tree().process_frame # Wait a split frame for tree mount stabilization
	var fresh_player = get_tree().get_first_node_in_group("Player")
	if fresh_player:
		fresh_player.set_physics_process(false)
		if "is_attacking" in fresh_player: fresh_player.is_attacking = true
		_update_shader_environment_parameters(fresh_player)
	
	var fade_tween = create_tween()
	fade_tween.tween_property(rect.material, "shader_parameter/progress", 0.0, 0.5)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await fade_tween.finished
	
	if fresh_player and is_instance_valid(fresh_player):
		fresh_player.set_physics_process(true)
		if "is_attacking" in fresh_player: fresh_player.is_attacking = false

func _update_shader_environment_parameters(target_character: CharacterBody2D) -> void:
	if not rect.material or not rect.material is ShaderMaterial: return
	var viewport_size: Vector2 = rect.get_viewport_rect().size
	rect.material.set_shader_parameter("screen_size", viewport_size)
	var player_canvas_pos: Vector2 = target_character.get_global_transform_with_canvas().origin
	var player_screen_uv: Vector2 = Vector2(
		player_canvas_pos.x / viewport_size.x,
		player_canvas_pos.y / viewport_size.y
	)
	rect.material.set_shader_parameter("player_screen_pos", player_screen_uv)
