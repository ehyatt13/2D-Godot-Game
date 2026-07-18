@tool
extends ColorRect

## If ON, the screen will be covered by fog
@export var enable_fog: bool = true:
	set(value):
		enable_fog = value
		visible = enable_fog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = enable_fog
