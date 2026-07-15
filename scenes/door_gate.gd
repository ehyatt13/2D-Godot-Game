@tool
extends StaticBody2D

@export_group("Puzzle Integration")
## Type the exact puzzle tag this gate listens for (e.g., "gate_west_wing")
@export var puzzle_gate_id: String = ""

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var is_open: bool = false

func _ready() -> void:
	_evaluate_gate_persistence()

func _evaluate_gate_persistence() -> void:
	if Engine.is_editor_hint() or puzzle_gate_id == "": return
	
	var level_name: String = GlobalPlayerData.get_active_level_name()
	
	if GlobalPlayerData.has_been_triggered(level_name, puzzle_gate_id):
		is_open = true
		visible = false
		if collision_shape: collision_shape.disabled = true
	
func open_gate_via_gameplay() -> void:
	if is_open: return
	is_open = true
	
	var level_name: String = GlobalPlayerData.get_active_level_name()
	GlobalPlayerData.register_world_trigger(level_name, puzzle_gate_id)
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	
	if collision_shape: 
		collision_shape.disabled = true

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
