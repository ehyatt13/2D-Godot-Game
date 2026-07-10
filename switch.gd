extends Node2D

signal activated

@onready var sprite: Sprite2D = $"Sprite2D"

var is_pressed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interaction_zone_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not is_pressed:
		is_pressed = true
		sprite.frame = 9
		print("You pressed the switch.")
		emit_signal("activated")
