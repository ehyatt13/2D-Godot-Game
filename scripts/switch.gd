extends Node2D

signal activated

@export var switch_unique_id: String = ""

@onready var sprite: Sprite2D = $"Sprite2D"


var pressed_frame: int = 9

var is_pressed: bool = false:
	set(value):
		is_pressed = value
		if is_pressed:
			sprite.frame = pressed_frame

func _ready() -> void:
	_evaluate_switch_persistence()

func _evaluate_switch_persistence() -> void:
	if switch_unique_id == "": return
	var level_name: String = GlobalPlayerData.get_active_level_name()
	if GlobalPlayerData.has_been_triggered(level_name, switch_unique_id):
		is_pressed = true

func _on_interaction_zone_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not is_pressed:
		is_pressed = true
		#sprite.frame = 9
		print("You pressed the switch.")
		#emit_signal("activated")
		activated.emit()
		var level_name: String = GlobalPlayerData.get_active_level_name()
		GlobalPlayerData.register_world_trigger(level_name, switch_unique_id)
