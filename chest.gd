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

@export var is_hidden: bool = false

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

@onready var item_reward_sprite: Sprite2D = $"ItemRewardSprite"

var player_in_range: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_chest_item_visuals()
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

func _update_chest_item_visuals() -> void:
	if is_inside_tree() and has_node("ItemRewardSprite"):
		var item_data: Dictionary = ItemDatabase.get_item_data(item_id)
		if not item_data.is_empty():
			var atlas_key: String = item_data["atlas"]
			if ItemDatabase.ATLAS_SHEETS.has(atlas_key):
				var atlas_config: Dictionary = ItemDatabase.ATLAS_SHEETS[atlas_key]
				var sheet_path: String = atlas_config["path"]
				if ResourceLoader.exists(sheet_path):
					$ItemRewardSprite.hframes = atlas_config["hframes"]
					$ItemRewardSprite.vframes = atlas_config["vframes"]
					$ItemRewardSprite.texture = load(sheet_path)
			$"ItemRewardSprite".frame = item_data["frame"]
			var scale_factor: float = item_data.get("visual_scale", 1.0)
			$"ItemRewardSprite".scale = Vector2(scale_factor, scale_factor)
		else:
			$"ItemRewardSprite".frame = 0

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
				item_reward_sprite.position = Vector2.ZERO
				shape_template.size = Vector2(16.0, 8.0)
				collision_shape.position = Vector2(0.0, -4.0)
				interaction_template.size = Vector2(20.0, 12.0)
				interaction_shape.position = Vector2(0.0, -4.0)
				
			ChestSize.BIG:
				sprite.position = Vector2(8.0, 0.0)
				item_reward_sprite.position = Vector2(8.0, 0.0)
				shape_template.size = Vector2(32.0, 8.0)
				collision_shape.position = Vector2(8.0, -4.0)
				interaction_template.size = Vector2(36.0, 12.0)
				interaction_shape.position = Vector2(8.0, -4.0)

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	if event.is_action_pressed("ui_accept") and player_in_range and not is_open:
		if is_locked:
			print("The chest is locked...")
			return
		open_chest()

func open_chest() -> void:
	if Engine.is_editor_hint(): return
	
	is_open = true
	
	_spawn_loot_popup_visuals()
	_deliver_loot()
	
	#$"CollisionShape2D".disabled = true

func _spawn_loot_popup_visuals() -> void:
	item_reward_sprite.visible = true
	item_reward_sprite.z_as_relative = false
	item_reward_sprite.z_index = 1
	
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	
	var target_y: float = global_position.y - 24.0
	tween.tween_property(item_reward_sprite, "global_position:y", target_y, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(item_reward_sprite, "modulate:a", 1.0, 0.4)
	tween.set_parallel(false)
	tween.tween_interval(1.0)
	tween.tween_property(item_reward_sprite, "modulate:a", 0.0, 0.3)

func _deliver_loot() -> void:
	var clean_name: String = item_id
	var item_data: Dictionary = ItemDatabase.get_item_data(item_id)
	if not item_data.is_empty():
		clean_name = item_data["name"]
	
	print("Found: ", item_quantity, "x ", clean_name, "!")
	GlobalPlayerData.receive_item(item_id, item_quantity)

func _on_interaction_zone_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Player" and not is_open and not is_hidden:
		player_in_range = true
		print("Press Enter to open the chest.")

func _on_interaction_zone_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Player":
		player_in_range = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
