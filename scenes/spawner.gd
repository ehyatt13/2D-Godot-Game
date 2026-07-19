extends StaticBody2D

enum DIRECTIONS {
	NORTH,
	SOUTH,
	EAST,
	WEST
}

@export_group("Universal Spawner Config")
## DRAG AND DROP ANY ENEMY PREFAB HERE INSIDE THE INSPECTOR! [A]
## Example: Drag "EnemySlime.tscn", "SkeletonArcher.tscn", or "Bat.tscn" [A]
@export var enemy_prefab_to_spawn: PackedScene

@export var spawn_position: DIRECTIONS = DIRECTIONS.SOUTH

## The absolute max number of children this specific spawner can have alive at one time [A]
@export var max_active_entities: int = 3

## Adjust the spawning frequency directly per instance (e.g. 4.0 seconds) [A]
@export var spawn_cooldown_seconds: float = 4.0

@export var enabled: bool = true

@onready var spawn_point: Node2D = $SpawnPoint
@onready var spawn_timer: Timer = $SpawnTimer

var spawned_entities_tracker: Array[CharacterBody2D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not enemy_prefab_to_spawn:
		print("Spawner Alert: '", name, "' has no enemy prefab assigned in the Inspector! Disabling clock.")
		spawn_timer.stop()
		return
	
	spawn_timer.wait_time = spawn_cooldown_seconds
	spawn_timer.timeout.connect(_on_spawn_timer_tick)
	match spawn_position:
		DIRECTIONS.NORTH:
			$SpawnPoint.position = Vector2(0.0, -16.0)
		DIRECTIONS.SOUTH:
			$SpawnPoint.position = Vector2(0.0, 16.0)
		DIRECTIONS.EAST:
			$SpawnPoint.position = Vector2(16.0, 0.0)
		DIRECTIONS.WEST:
			$SpawnPoint.position = Vector2(-16.0, 0.0)

func _on_spawn_timer_tick() -> void:
	if not enabled: return
	var active_living_entities: Array[CharacterBody2D] = []
	for entity in spawned_entities_tracker:
		if is_instance_valid(entity) and not entity.is_queued_for_deletion():
			active_living_entities.append(entity)
	
	spawned_entities_tracker = active_living_entities
	
	if spawned_entities_tracker.size() >= max_active_entities:
		return
		
	_instantiate_generic_enemy()


func _instantiate_generic_enemy() -> void:
	var fresh_enemy_instance = enemy_prefab_to_spawn.instantiate()
	
	fresh_enemy_instance.global_position = spawn_point.global_position
	
	var current_level = get_parent().get_parent().get_parent() # Interactables folder -> Level Root Node
	if current_level:
		var entities_folder = current_level.get_node_or_null("Entities/Enemies")
		if entities_folder:
			entities_folder.add_child(fresh_enemy_instance)
			
			spawned_entities_tracker.append(fresh_enemy_instance)
			print("Spawner Matrix: Materialized '", fresh_enemy_instance.name, "' (", spawned_entities_tracker.size(), "/", max_active_entities, ").")

func take_damage_via_bomb() -> void:
	print("Spawner Matrix: Structural integrity compromised by bomb explosion. Purging node...")
	# [Trigger smoke particle clouds or rubble debris visual effect layouts here]
	queue_free()
