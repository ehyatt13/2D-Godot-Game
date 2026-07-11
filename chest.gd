@tool
extends StaticBody2D

enum ChestSize {
	NORMAL,
	BIG
}

@export_group("Chest Contents")
## Id of the item within the chest corresponding with the ItemDatabase
@export var item_id: String = "golden_key"
	#set(value):
		#item_id = value
		#_update_chest_visuals()
## Quantity of the item
@export var item_quantity: int = 1

@export_group("Chest Behavior")
@export var key_item: bool = false
## If ON, the chest cannot be opened
@export var is_locked: bool = false

@export var is_hidden: bool = false:
	set(value):
		is_hidden = value
		visible = !value
		#set_collision_layer_value(4, visible)

@export var collision_toggle: bool = true:
	set(value):
		collision_toggle = value
		set_collision_layer_value(4, collision_toggle)

@export var is_open: bool = false:
	set(value):
		is_open = value
		#if is_inside_tree() and has_node("Sprite2D"):
			#if is_open:
				#$Sprite2D.frame = frame_open
			#else:
				#$Sprite2D.frame = frame_closed
		_update_chest_state()

### Origin of the item within's sprite
#@export var item_atlas_sheet: Texture2D:
	#set(value):
		#item_atlas_sheet = value
		#if is_inside_tree() and has_node("ItemRewardSprite"):
			#$"ItemRewardSprite".texture = item_atlas_sheet

@export_group("Chest Sizing Configuration")
@export var chest_size: ChestSize = ChestSize.NORMAL:
	set(value):
		chest_size = value
		_update_chest_state()
		
## Set to true if you are using a single master sheet with manual coordinate slices
#@export var use_atlas_regions: bool = false

## The pixel width/height of a single animation block frame (e.g., 16 for normal, 32 for big)
#@export var frame_pixel_size: int = 16

@export_group("Animation Frames")
## Frame of the closed chest on the sprite sheet
@export var frame_closed: int = 0:
	set(value):
		frame_closed = value
		# The 'set' block triggers instantly when you change the value in the Inspector
		#if is_inside_tree() and has_node("Sprite2D") and not is_open:
			#$Sprite2D.frame = frame_closed
		_update_chest_state()

## Frame of the open chest on the sprite sheet
@export var frame_open: int = 1:
	set(value):
		frame_open = value
		# The 'set' block triggers instantly when you change the value in the Inspector
		#if is_inside_tree() and has_node("Sprite2D") and is_open:
			#$Sprite2D.frame = frame_open
		_update_chest_state()

@onready var sprite: Sprite2D = $"Sprite2D"

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var interaction_shape: CollisionShape2D = $"InteractionZone/CollisionShape2D"

#@onready var item_reward_sprite: Sprite2D = $"ItemRewardSprite"

#var player_in_range: bool = false

#var player_facing_chest: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_update_chest_item_visuals()
	_update_chest_state()

func _update_chest_state() -> void:
	_update_chest_sprite_visuals()
	_recalibrate_physics_hitboxes()

func _update_chest_sprite_visuals() -> void:
	if not is_inside_tree() or not sprite: return
	
	if chest_size == ChestSize.NORMAL:
		sprite.region_enabled = false
		sprite.vframes = 5
		sprite.hframes = 5
		if is_open == false:
			sprite.frame = frame_closed
		else:
			sprite.frame = frame_open
	else:
		var current_frame_index: int = 1 if is_open else 0
		
		#if use_atlas_regions:
		sprite.hframes = 1
		sprite.vframes = 1
		sprite.region_enabled = true

		var horizontal_offset_x: float = 32 * current_frame_index
		var vertical_offset_y: float = 0.0 if chest_size == ChestSize.NORMAL else 32.0
		sprite.region_rect = Rect2(horizontal_offset_x, vertical_offset_y, 32, 16)
	
	#else:
		#sprite.region_enabled = false
		#sprite.frame = current_frame_index

#func _update_chest_item_visuals() -> void:
	#if is_inside_tree() and has_node("ItemRewardSprite"):
		#var item_data: Dictionary = ItemDatabase.get_item_data(item_id)
		#if not item_data.is_empty():
			#var atlas_key: String = item_data["atlas"]
			#if ItemDatabase.ATLAS_SHEETS.has(atlas_key):
				#var atlas_config: Dictionary = ItemDatabase.ATLAS_SHEETS[atlas_key]
				#var sheet_path: String = atlas_config["path"]
				#if ResourceLoader.exists(sheet_path):
					#$ItemRewardSprite.hframes = atlas_config["hframes"]
					#$ItemRewardSprite.vframes = atlas_config["vframes"]
					#$ItemRewardSprite.texture = load(sheet_path)
			#$"ItemRewardSprite".frame = item_data["frame"]
			#var scale_factor: float = item_data.get("visual_scale", 1.0)
			#$"ItemRewardSprite".scale = Vector2(scale_factor, scale_factor)
		#else:
			#$"ItemRewardSprite".frame = 0

func _recalibrate_physics_hitboxes() -> void:
	if not is_inside_tree() or not collision_shape or not interaction_shape: return
	
	var shape_template = collision_shape.shape
	var interaction_template = interaction_shape.shape
	
	if shape_template and not shape_template.resource_local_to_scene: 
		shape_template.resource_local_to_scene = true
	
	if interaction_template and not interaction_template.resource_local_to_scene:
		interaction_template.resource_local_to_scene = true
	
	if shape_template is RectangleShape2D and interaction_template is RectangleShape2D:
		match chest_size:
			ChestSize.NORMAL:
				sprite.position = Vector2.ZERO
				#item_reward_sprite.position = Vector2.ZERO
				shape_template.size = Vector2(16.0, 8.0)
				collision_shape.position = Vector2(0.0, -4.0)
				interaction_template.size = Vector2(20.0, 12.0)
				interaction_shape.position = Vector2(0.0, -4.0)
				
			ChestSize.BIG:
				sprite.position = Vector2(8.0, 0.0)
				#item_reward_sprite.position = Vector2(8.0, 0.0)
				shape_template.size = Vector2(32.0, 8.0)
				collision_shape.position = Vector2(8.0, -4.0)
				interaction_template.size = Vector2(36.0, 12.0)
				interaction_shape.position = Vector2(8.0, -4.0)

#func _unhandled_input(event: InputEvent) -> void:
	#if Engine.is_editor_hint():
		#return
	#
	#if event.is_action_pressed("ui_accept") and player_in_range and not is_open:
		#if is_locked:
			#print("The chest is locked...")
			#return
		#if not player_facing_chest:
			#print("Please face the chest.")
			#return
		#open_chest()

func interact(player_node: CharacterBody2D) -> void:
	if is_open or Engine.is_editor_hint() or is_locked: return
	
	var player_facing: Vector2 = player_node.current_face_direction
	var test_interaction_point: Vector2 = player_node.global_position + (player_facing * 8.0)
	
	var chest_width: float = 32.0 if (chest_size == ChestSize.BIG) else 16.0
	
	var visual_offset_x: float = 8.0 if (chest_size == ChestSize.BIG) else 0.0
	var min_x: float = global_position.x + visual_offset_x - (chest_width / 2.0)
	var max_x: float = global_position.x + visual_offset_x + (chest_width / 2.0)
	
	var min_y: float = global_position.y - (16.0 / 2.0)
	var max_y: float = global_position.y + (16.0 / 2.0)
	
	var is_pointing_at_chest: bool = (
	test_interaction_point.x >= min_x and test_interaction_point.x <= max_x and
	test_interaction_point.y >= min_y and test_interaction_point.y <= max_y
)
	
	if is_pointing_at_chest:
		open_chest()

func open_chest() -> void:
	if Engine.is_editor_hint(): return
	
	is_open = true
	
	_spawn_loot_popup_visuals()
	_deliver_loot()
	
	#$"CollisionShape2D".disabled = true

func _spawn_loot_popup_visuals() -> void:
	#item_reward_sprite.visible = true
	#item_reward_sprite.z_as_relative = false
	#item_reward_sprite.z_index = 1
	#
	#var tween: Tween = create_tween().set_parallel(true)
	#
	#var target_y: float = global_position.y - 24.0
	#tween.tween_property(item_reward_sprite, "global_position:y", target_y, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	#tween.tween_property(item_reward_sprite, "modulate:a", 1.0, 0.4)
	#tween.set_parallel(false)
	#tween.tween_interval(1.0)
	#tween.tween_property(item_reward_sprite, "modulate:a", 0.0, 0.3)
	
	var floating_container: Node2D = Node2D.new()
	if chest_size == ChestSize.NORMAL:
		floating_container.global_position = global_position + Vector2(0.0, -8.0)
	else:
		floating_container.global_position = global_position + Vector2(8.0, -8.0)
	
	floating_container.top_level = true
	
	var item_info: Dictionary = ItemDatabase.get_item_data(item_id)
	if item_info.is_empty(): return
	
	var scale_factor: float = item_info.get("visual_scale", 1.0)
	floating_container.scale = Vector2(scale_factor, scale_factor)
	
	var anim_name: String = item_info.get("animation_name", "")
	var shared_frames = load("res://assets/items/item_animations.tres")
	if anim_name != "" and shared_frames:
		var moving_sprite: AnimatedSprite2D = AnimatedSprite2D.new()
		
		moving_sprite.sprite_frames = shared_frames
		
		floating_container.add_child(moving_sprite)
		moving_sprite.play(anim_name)
	else:
		var fallback_sprite: Sprite2D = Sprite2D.new()
		var atlas_config = ItemDatabase.ATLAS_SHEETS[item_info["atlas"]]
		fallback_sprite.texture = load(atlas_config["path"])
		fallback_sprite.hframes = atlas_config["hframes"]
		fallback_sprite.vframes = atlas_config["vframes"]
		fallback_sprite.frame = item_info["frame"]
		floating_container.add_child(fallback_sprite)
	
	if item_id == "magic_torch":
		var reward_light: PointLight2D = PointLight2D.new()
		reward_light.texture = load("res://assets/lighting/light_gradient.png")
		reward_light.color = Color(1.0, 0.6, 0.3, 1.0)
		var flicker_script = load("res://flickering_light.gd")
		reward_light.set_script(flicker_script)
		reward_light.is_environment_light = true
		reward_light.base_energy = 0.8
		floating_container.add_child(reward_light)
	
	var world_container = get_tree().root.get_node_or_null("Game/World")
	if world_container and world_container.get_child_count() > 0:
		world_container.get_child(0).get_node("Interactables").add_child(floating_container)
	
	var target_y: float = floating_container.position.y - 16.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(floating_container, "position:y", target_y, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	var baseline_scale = floating_container.scale
	floating_container.scale = baseline_scale * 0.5
	tween.tween_property(floating_container, "scale", baseline_scale, 0.4)
	
	await get_tree().create_timer(1.5).timeout
	
	var fade_tween = create_tween()
	fade_tween.tween_property(floating_container, "modulate:a", 0.0, 0.3)
	await fade_tween.finished
	floating_container.queue_free()

func _deliver_loot() -> void:
	var clean_name: String = item_id
	var item_data: Dictionary = ItemDatabase.get_item_data(item_id)
	if not item_data.is_empty():
		clean_name = item_data["name"]
	
	print("Found: ", item_quantity, "x ", clean_name, "!")
	GlobalPlayerData.receive_item(item_id, item_quantity)

#func _on_interaction_zone_body_entered(body: Node2D) -> void:
	#if body is CharacterBody2D and body.name == "Player" and not is_open and not is_hidden and not Engine.is_editor_hint():
		#player_in_range = true
		#print("Press Enter to open the chest.")
		#
		##var direction_to_chest: Vector2 = (global_position - body.global_position).normalized()
		#
		#
		#var player_facing: Vector2 = body.current_face_direction
		#var test_interaction_point: Vector2 = body.global_position + (player_facing * 8.0)
		#
		#var chest_width: float = 32.0 if (chest_size == ChestSize.BIG) else 16.0
		#
		#var visual_offset_x: float = 8.0 if (chest_size == ChestSize.BIG) else 0.0
		#var min_x: float = global_position.x + visual_offset_x - (chest_width / 2.0)
		#var max_x: float = global_position.x + visual_offset_x + (chest_width / 2.0)
		#
		#var min_y: float = global_position.y - (16.0 / 2.0)
		#var max_y: float = global_position.y + (16.0 / 2.0)
		#
		#var is_pointing_at_chest: bool = (
		#test_interaction_point.x >= min_x and test_interaction_point.x <= max_x and
		#test_interaction_point.y >= min_y and test_interaction_point.y <= max_y
	#)
		#
		#if is_pointing_at_chest:
			#player_facing_chest = true
		#
		##var alignment_score: float = player_facing.dot(direction_to_chest)
		##
		##if alignment_score > 0.5:
			###print("Player is facing the chest. Opening lockbox!")
			##player_facing_chest = true
			##open_chest()
		##else:
			##print("Interaction Blocked: Player must turn around to face the chest.")

#func _on_interaction_zone_body_exited(body: Node2D) -> void:
	#if body is CharacterBody2D and body.name == "Player":
		#player_in_range = false
		#player_facing_chest = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
