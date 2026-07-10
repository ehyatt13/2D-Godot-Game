extends Area2D

## Path of the level to change to
@export_file("*.tscn") var target_level_path: String
## Spawn location on the chosen level
@export var spawn_coordinates: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		var game_manager = get_tree().root.get_node_or_null("Game")
		if game_manager:
			game_manager.change_level(target_level_path, spawn_coordinates)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
