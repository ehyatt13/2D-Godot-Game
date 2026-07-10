@tool
extends Area2D

## The ID of the item laying on the ground
@export var item_id: String = "gold_coin":
	set(value):
		item_id = value
		_update_pickup_visuals()

@export var quantity: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	body_entered.connect(_on_player_walked_over)
	_update_pickup_visuals()
	
	if not Engine.is_editor_hint():
		
		var item_info: Dictionary = ItemDatabase.get_item_data(item_id)
		var db_scale: float = item_info.get("visual_scale", 1.0)
		var target_scale_vector: Vector2 = Vector2(db_scale, db_scale)
		
		var target_y: float = $Sprite2D.position.y
		
		$Sprite2D.position.y -= 12.0
		$Sprite2D.scale = target_scale_vector * 0.5
		
		var tween = create_tween().set_parallel(true)
		tween.tween_property($Sprite2D, "position:y", target_y, 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property($Sprite2D, "scale", target_scale_vector, 0.20)

func _update_pickup_visuals() -> void:
	if is_inside_tree() and has_node("Sprite2D") and has_node("CollisionShape2D"):
		var item_info: Dictionary = ItemDatabase.get_item_data(item_id)
		if not item_info.is_empty():
			var atlas_key: String = item_info["atlas"]
			#print(atlas_key)
			var atlas_config: Dictionary = ItemDatabase.ATLAS_SHEETS[atlas_key]
			#print(atlas_config)
			
			$Sprite2D.hframes = atlas_config["hframes"]
			$Sprite2D.vframes = atlas_config["vframes"]
			$Sprite2D.texture = load(atlas_config["path"])
			$Sprite2D.frame = item_info["frame"]
			
			var scale_factor: float = item_info.get("visual_scale", 1.0)
			$Sprite2D.scale = Vector2(scale_factor, scale_factor)
			
			var tracking_shape = $CollisionShape2D.shape
			if tracking_shape is CircleShape2D:
				var baseline_radius: float = 8.0
				tracking_shape.radius = baseline_radius * scale_factor
			elif tracking_shape is RectangleShape2D:
				var baseline_size: Vector2 = Vector2(8.0, 8.0)
				tracking_shape.size = baseline_size * scale_factor

func _on_player_walked_over(body: Node2D) -> void:
	if Engine.is_editor_hint(): return
	
	if body is CharacterBody2D and body.name == "Player":
		GlobalPlayerData.receive_item(item_id, quantity)
		
		#pickup sound or effects
		
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
