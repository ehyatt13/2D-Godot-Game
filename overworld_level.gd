class_name OverworldLevel
extends BaseLevel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	_initialize_overworld_systems()

func _initialize_overworld_systems() -> void:
	print("Overworld Engine: Initializing day/night lighting cycles and weather shaders.")
	# Wire up your sky managers, wildlife ambient sound arrays, and wind particles here...
