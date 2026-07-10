extends Node2D

@onready var floor_switch: Node2D = $"Interactables/Switch"

@onready var locked_chest: Node2D = $"Interactables/Chest2"

@onready var test_torch_light: Node2D = $"Entities/Torch2/FlickeringLight"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	locked_chest.is_locked = true
	locked_chest.visible = false
	locked_chest.is_hidden = true
	locked_chest.set_collision_layer_value(4, false)
	
	floor_switch.activated.connect(_switch_activated)
	
	#test_torch_light.blend_mode = Light2D.BLEND_MODE_MIX

func _switch_activated() -> void:
	print("A secret chest appeared!")
	
	locked_chest.is_locked = false
	locked_chest.visible = true
	locked_chest.is_hidden = false
	locked_chest.set_collision_layer_value(4, true)
	
	locked_chest.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(locked_chest, "modulate:a", 1.0, 0.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
