class_name ItemData
extends Resource

@export var id: String = ""

@export var display_name: String = ""

@export var description: String = ""

enum ItemType { WEAPON, TOOL, CONSUMABLE }

@export var type: ItemType = ItemType.WEAPON

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
