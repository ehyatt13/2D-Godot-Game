extends StaticBody2D

#@onready var pickup_scene: PackedScene = preload("res://scenes/item_pickup.tscn")
@onready var sprite: Sprite2D = $"Sprite2D"

@export var frame_healthy: int = 0
@export var frame_cut: int = 1

var is_cut: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	sprite.frame = frame_healthy

func take_damage(amount: int) -> void:
	if is_cut: return
	is_cut = true
	
	print("The bush was destroyed!")
	
	sprite.frame = frame_cut
	
	$"CollisionShape2D".disabled = true
	
	#_roll_loot_drop()
	
	ItemDatabase.spawn_loot_drop("breakable_bush", global_position)

#func _roll_loot_drop() -> void:
	#var random_chance: float = randf()
	#
	#var chosen_item_id: String = ""
	#
	#if random_chance < 0.4:
		#chosen_item_id = "gold_coin"
	#elif random_chance < 0.6:
		#chosen_item_id = "bomb"
	#
	#if chosen_item_id != "":
		#var drop = pickup_scene.instantiate()
		#drop.item_id = chosen_item_id
		#drop.quantity = 1
		#
		#var root_node = get_tree().root
		#var game_manager = root_node.get_node_or_null("Game")
	#
		#if game_manager:
			#var world_container = game_manager.get_node_or_null("World")
			#if world_container and world_container.get_child_count() > 0:
		#
				#var current_level = world_container.get_child(0)
				#var target_folder = current_level.get_node_or_null("Interactables")
		#
				#if target_folder:
					#drop.global_position = global_position
					#target_folder.add_child(drop)
					#
					#print(ItemDatabase.get_item_data(chosen_item_id)["name"], " was spawned.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
