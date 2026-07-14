class_name IndoorLevel
extends BaseLevel

#@export_group("Indoor Lighting Configuration")
### Enforce a dark environmental baseline (e.g. NIGHT or PITCH_BLACK) upon walking through a door
#@export var indoor_lighting_preset: int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	_initialize_indoor_systems()


func _initialize_indoor_systems() -> void:
	print("Indoor Engine: Configuring strict room bounds and dungeon audio reverb.")
	
	# Automatically push the dungeon's dark lighting preset to the active world canvas layer
	#var overlay = get_tree().get_first_node_in_group("TransitionEngine")
	#if overlay:
		#overlay.atmosphere_changed.emit(indoor_lighting_preset)
