extends StaticBody2D

#@onready var pickup_scene: PackedScene = preload("res://scenes/item_pickup.tscn")
@onready var sprite: Sprite2D = $"Sprite2D"

@export var frame_healthy: int = 0
@export var frame_cut: int = 1

var is_cut: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.frame = frame_healthy

func take_damage(amount: int) -> void:
	if is_cut: return
	is_cut = true
	print("The bush was destroyed!")
	sprite.frame = frame_cut
	$"CollisionShape2D".disabled = true
	ItemDatabase.spawn_loot_drop("breakable_bush", global_position)
