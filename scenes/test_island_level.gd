extends OverworldLevel

@onready var floor_switch: Node2D = $"Interactables/Switches/Switch"

@onready var locked_chest: Node2D = $"Interactables/Chests/Chest2"

@onready var test_torch_light: Node2D = $"Entities/Torches/Torch2/FlickeringLight"

@onready var canvas_modulate: CanvasModulate = $CanvasModulate

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	floor_switch.activated.connect(locked_chest.reveal_chest_by_gameplay)
	if GlobalPlayerData.has_upgrade("has_torch"):
		canvas_modulate.lighting_preset = 2

func _switch_activated() -> void:
	print("A secret chest appeared!")
	
	locked_chest.is_locked = false
	locked_chest.reveal_chest_by_gameplay()
