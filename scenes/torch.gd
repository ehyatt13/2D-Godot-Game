@tool
extends Node2D

enum TorchType {
	STANDING,
	WALL
}

@onready var sprite: Sprite2D = $"Sprite2D"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var type: TorchType = TorchType.STANDING:
	set(value):
		type = value
		_get_initial_position()

@export var flip: bool = false:
	set(value):
		flip = value
		$Sprite2D.flip_h = flip

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if has_node("Sprite2D") and not Engine.is_editor_hint():
		if type == TorchType.WALL:
			animation_player.play("wall_flicker")
		else:
			animation_player.play("standing_flicker")

func _get_initial_position() -> void:
	if has_node("Sprite2D"):
		if type == TorchType.WALL:
			$Sprite2D.frame = 2
		else:
			$Sprite2D.frame = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
