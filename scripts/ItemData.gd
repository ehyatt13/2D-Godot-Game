class_name ItemData
extends Resource

@export var id: String = ""

@export var display_name: String = ""

@export var description: String = ""

enum ItemType { WEAPON, TOOL, CONSUMABLE }

@export var type: ItemType = ItemType.WEAPON
