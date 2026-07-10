@tool
extends StaticBody2D


@export_group("Chest Contents")
## Id of the item within the chest corresponding with the ItemDatabase
@export var item_id: String = "golden_key":
	set(value):
		item_id = value
		_update_chest_visuals()
## Quantity of the item
@export var item_quantity: int = 1

@export var key_item: bool = false
## If ON, the chest cannot be opened
@export var is_locked: bool = false

@export var is_hidden: bool = false
## Origin of the item within's sprite
@export var item_atlas_sheet: Texture2D:
	set(value):
		item_atlas_sheet = value
		if is_inside_tree() and has_node("ItemRewardSprite"):
			$"ItemRewardSprite".texture = item_atlas_sheet
#@export var item_frame_index: int = 0:
	#set(value):
		#item_frame_index = value
		#if is_inside_tree() and has_node("ItemRewardSprite"):
			#$"ItemRewardSprite".frame = item_frame_index
@export_group("Animation Frames")
## Frame of the closed chest on the sprite sheet
@export var frame_closed: int = 0:
	set(value):
		frame_closed = value
		# The 'set' block triggers instantly when you change the value in the Inspector
		if is_inside_tree() and has_node("Sprite2D"):
			$Sprite2D.frame = frame_closed

## Frame of the open chest on the sprite sheet
@export var frame_open: int = 1

@onready var sprite: Sprite2D = $"Sprite2D"

@onready var item_reward_sprite: Sprite2D = $"ItemRewardSprite"

var is_open: bool = false
var player_in_range: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	if has_node("Sprite2D"):
		sprite.frame = frame_closed
	#if has_node("ItemRewardSprite"):
		#$"ItemRewardSprite".texture = item_atlas_sheet
		#$"ItemRewardSprite".frame = item_frame_index
	_update_chest_visuals()

func _update_chest_visuals() -> void:
	#if is_inside_tree() and has_node("ItemRewardSprite") and "ItemDatabase" in Engine.get_main_loop().root:
	if is_inside_tree() and has_node("ItemRewardSprite"):
		#$"ItemRewardSprite".texture = item_atlas_sheet
		var item_data: Dictionary = ItemDatabase.get_item_data(item_id)
		if not item_data.is_empty():
			#var sheet_path: String = item_data["sheet_path"]
			var atlas_key: String = item_data["atlas"]
			#if ResourceLoader.exists(sheet_path):
				#$"ItemRewardSprite".texture = load(sheet_path)
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
		#if ItemDatabase.ITEMS.has(item_id):
			#var item_data: Dictionary  = ItemDatabase.ITEMS[item_id]
			#$"ItemRewardSprite".frame = item_data["frame"]
			#$"ItemRewardSprite".texture = item_atlas_sheet
	
	
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
	#if has_node("Sprite2D"):
		#$Sprite2D.frame = frame_open
	$Sprite2D.frame = frame_open
	
	var clean_name: String = item_id
	var item_data: Dictionary = ItemDatabase.get_item_data(item_id)
	if not item_data.is_empty():
		clean_name = item_data["name"]
	#if ItemDatabase.ITEMS.has(item_id):
		#clean_name = ItemDatabase.ITEMS[item_id]["name"]
	
	item_reward_sprite.visible = true
	#item_reward_sprite.top_level = true
	item_reward_sprite.z_as_relative = false
	item_reward_sprite.z_index = 1
	#item_reward_sprite.global_position = global_position
	
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	
	var target_y: float = global_position.y - 24.0
	tween.tween_property(item_reward_sprite, "global_position:y", target_y, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(item_reward_sprite, "modulate:a", 1.0, 0.4)
	tween.set_parallel(false)
	tween.tween_interval(1.0)
	tween.tween_property(item_reward_sprite, "modulate:a", 0.0, 0.3)
	
	print("Found: ", item_quantity, "x ", clean_name, "!")
	GlobalPlayerData.receive_item(item_id, item_quantity)
	#_grant_chest_reward()
	
	#$"CollisionShape2D".disabled = true
	
#func _grant_chest_reward() -> void:
	#if item_id == "gold_coin":
		#GlobalPlayerData.gold_coins += item_quantity
		#return
	#
	#if item_id == "bomb":
		#GlobalPlayerData.bombs += item_quantity
		#return
	#
	#if item_id == "power_glove":
		#GlobalPlayerData.unlock_upgrade("has_power_glove")
		#return
	#
	#
	#var item_info: Dictionary = ItemDatabase.get_item_data(item_id)
	#if not item_info.is_empty():
		#var new_item: ItemData = ItemData.new()
		#new_item.id = item_id
		#new_item.display_name = item_info["name"]
		#
		#GlobalPlayerData.selectable_items.append(new_item)
		#print("Added selectable equipment: ", new_item.display_name)

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
