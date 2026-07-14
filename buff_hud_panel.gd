extends HBoxContainer

const BUFF_SLOT_PREFAB: PackedScene = preload("res://scenes/buff_icon_slot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalPlayerData.buffs_updated.connect(synchronize_buff_display_row)
	synchronize_buff_display_row()

func synchronize_buff_display_row() -> void:
	for buff_key in GlobalPlayerData.active_buffs.keys():
		if GlobalPlayerData.active_buffs[buff_key] <= 0.0:
			continue
		var already_exists: bool = false
		for active_cell in get_children():
			if "target_buff_id" in active_cell and active_cell.target_buff_id == buff_key:
				already_exists = true
				break
		
		if not already_exists:
			var new_slot = BUFF_SLOT_PREFAB.instantiate()
			add_child(new_slot)
			
			var duration_length: float = GlobalPlayerData.active_buffs[buff_key]
			new_slot.initialize_slot(buff_key, duration_length)
