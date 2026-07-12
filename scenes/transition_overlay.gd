extends CanvasLayer

@onready var rect: ColorRect = $ShaderRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rect.material.set_shader_parameter("progress", 0.0)


func play_diamond_cut_transition(player_node: CharacterBody2D, camera_node: Camera2D, teleport_offset: Vector2) -> void:
	player_node.set_physics_process(false)
	if "is_attacking" in player_node: player_node.is_attacking = true
	
	var tween = create_tween()
	tween.tween_property(rect.material, "shader_parameter/progress", 1.0, 0.4)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	player_node.global_position += teleport_offset
	
	camera_node.global_position = player_node.global_position
	camera_node.reset_smoothing()
	
	var fade_tween = create_tween()
	fade_tween.tween_property(rect.material, "shader_parameter/progress", 0.0, 0.4)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await fade_tween.finished
	
	player_node.set_physics_process(true)
	if "is_attacking" in player_node: player_node.is_attacking = false
