@tool
extends Node

const ATLAS_SHEETS: Dictionary = {
	"objects": {
		"path": "res://assets/sprites/objects.png",
		"hframes" : 5,
		"vframes" : 5
	},
	"bomb": {
		"path": "res://assets/sprites/bomb.png",
		"hframes": 3,
		"vframes": 2
	},
	"heart": {
		"path": "res://assets/sprites/heart.png",
		"hframes": 3,
		"vframes": 1
	},
	"magic_torch": {
		"path": "res://assets/sprites/player_torch.png",
		"hframes": 2,
		"vframes": 1
	}
}

const ITEMS: Dictionary = {
	"heart": {
		"name": "Recovery Heart",
		"frame": 0,
		"atlas": "heart",
		"behavior": "automatic",
		"target_stat": "health",
		"visual_scale": 0.7
	},
	"heart_upgrade": {
		"name": "Heart Upgrade",
		"frame": 0,
		"atlas": "objects",
		"behavior": "automatic",
		"target_stat": "max_health"
	},
	"crystal": {
		"name": "Crystal",
		"frame": 1,
		"atlas": "objects",
		"behavior": "selectable"
	},
	"gold_coin": {
		"name": "Gold Coin",
		"frame": 2,
		"atlas": "objects",
		"behavior": "automatic",
		"target_stat": "gold_coins",
		"visual_scale": 0.5
	},
	"key": {
		"name": "Key",
		"frame": 5,
		"atlas": "objects",
		"behavior": "none"
	},
	"golden_key": {
		"name": "Golden Key",
		"frame": 6,
		"atlas": "objects",
		"behavior": "flag",
		"target_flag": "has_golden_key"
	},
	"bomb": {
		"name": "Bomb",
		"frame": 0,
		"atlas": "bomb",
		"behavior": "selectable",
		"target_stat": "bombs"
	},
	"magic_torch": {
		"name": "Magic Torch",
		"frame": 0,
		"atlas": "magic_torch",
		"behavior": "flag",
		"target_flag": "has_torch"
	}
}

const LOOT_TABLES: Dictionary = {
	"breakable_bush": [
		["gold_coin", 1, 0.35],
		["bomb", 1, 0.15],
		["heart", 2, 0.20],
		["", 0, 0.30]
	],
	"enemy_slime": [
		["gold_coin", 1, 0.40],
		["bomb", 3, 0.15],
		["heart", 2, 0.20],
		["", 0, 0.25]
	]
}

static func get_item_data(id: String) -> Dictionary:
	if ITEMS.has(id):
		return ITEMS[id]
	return {}


func spawn_loot_drop(table_id: String, world_coordinates: Vector2) -> void:
	if not LOOT_TABLES.has(table_id):
		print("Error: Requested loot table '", table_id, "' does not exist in the database.")
		return
	
	var chosen_table: Array = LOOT_TABLES[table_id]
	var random_roll: float = randf()
	
	var running_total: float = 0.0
	var selected_item_id: String = ""
	var selected_quantity: int = 0
	
	for drop in chosen_table:
		running_total += drop[2]
		if random_roll <= running_total:
			selected_item_id = drop[0]
			selected_quantity = drop[1]
			break
	
	if selected_item_id == "":
		return
	
	var pickup_scene: PackedScene = load("res://scenes/item_pickup.tscn")
	if pickup_scene:
		var drop_instance = pickup_scene.instantiate()
		drop_instance.item_id = selected_item_id
		drop_instance.quantity = selected_quantity
		
		var root_node = get_tree().root
		var game_manager = root_node.get_node_or_null("Game")
		if game_manager:
			var world_container = game_manager.get_node_or_null("World")
			if world_container and world_container.get_child_count() > 0:
				var current_level_map = world_container.get_child(0)
				var target_folder = current_level_map.get_node_or_null("Interactables")
				
				if target_folder:
					drop_instance.global_position = world_coordinates
					target_folder.add_child(drop_instance)
					print("Loot Engine: Spawned ", selected_quantity, "x ", selected_item_id, " via table '", table_id, "'")


## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
