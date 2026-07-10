extends Camera2D

@export_group("Target Tracking")
## Target for the camera to follow
@export var player_target: CharacterBody2D
#@export var smooth_speed: float = 5.0

@export_group("Manual Override Bounds")
@export var manual_left: int = -1000
@export var manual_right: int = 1000
@export var manual_top: int = -1000
@export var manual_bottom: int = 1000

@export_group("Dynamic Detection")
## TileLayer to be the bound for the camera
@export var target_map: TileMapLayer

var shake_intensity: float = 0.0
var shake_decay: float = 5.0
var max_shake_offset: float = 15.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	if target_map:
		_calculate_dynamic_bounds()
	else:
		_apply_manual_bounds()
	
	#if player_target:
	#	global_position = player_target.global_position
	
	position_smoothing_enabled = true
	position_smoothing_speed = 2.0


func _apply_manual_bounds() -> void:
	limit_left = manual_left
	limit_right = manual_right
	limit_top = manual_top
	limit_bottom = manual_bottom

func _calculate_dynamic_bounds() -> void:
	var map_rect: Rect2i = target_map.get_used_rect()
	var cell_size: Vector2i = target_map.tile_set.tile_size
	
	limit_left = map_rect.position.x * cell_size.x
	limit_right = map_rect.end.x * cell_size.x
	limit_top = map_rect.position.y * cell_size.y
	limit_bottom = map_rect.end.y * cell_size.y
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#pass
	if player_target:
		#var target_position: Vector2 = player_target.global_position
		
		#var new_position = global_position.lerp(target_position, smooth_speed * delta)
		
		#global_position = new_position.round()
		
		global_position = player_target.global_position
	
	if shake_intensity > 0.0:
		shake_intensity = move_toward(shake_intensity, 0.0, shake_decay * delta)
		
		var random_x: float = randf_range(-1.0, 1.0) * max_shake_offset * shake_intensity
		var random_y: float = randf_range(-1.0, 1.0) * max_shake_offset * shake_intensity
		
		offset = Vector2(random_x, random_y)
	else:
		offset = Vector2.ZERO

func trigger_screen_shake(strength: float) -> void:
	shake_intensity = clamp(shake_intensity + strength, 0.0, 1.0)
