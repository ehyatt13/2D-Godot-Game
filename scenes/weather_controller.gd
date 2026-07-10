@tool
extends ColorRect

## If ON, the screen will be covered by fog
@export var enable_fog: bool = true:
	set(value):
		enable_fog = value
		visible = enable_fog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	visible = enable_fog


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
