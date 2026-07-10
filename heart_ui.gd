extends HBoxContainer

@export var texture_full: Texture2D = preload("res://assets/ui/heart_full.tres")
@export var texture_half: Texture2D = preload("res://assets/ui/heart_half.tres")
@export var texture_empty: Texture2D = preload("res://assets/ui/heart_empty.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	GlobalPlayerData.health_changed.connect(_update_heart_display)
	_update_heart_display(GlobalPlayerData.health, GlobalPlayerData.max_health)

func _update_heart_display(current_health: int, max_health: int) -> void:
	for child in get_children():
		child.queue_free()
	
	var total_hearts: int = max_health / 2
	
	for i in range(total_hearts):
		var new_heart_slot: TextureRect = TextureRect.new()
		new_heart_slot.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		
		var slot_hp: int = current_health - (i * 2)
		
		if slot_hp >= 2:
			new_heart_slot.texture = texture_full
		elif slot_hp == 1:
			new_heart_slot.texture = texture_half
		else:
			new_heart_slot.texture = texture_empty
		
		add_child(new_heart_slot)
	
	#var heart_nodes: Array = get_children()
	#
	#for i in range(total_hearts):
		#if i >= heart_nodes.size(): break
		#
		#var target_rect: TextureRect = heart_nodes[i]
		#var slot_hp: int = current_health - (i * 2)
		#
		#if slot_hp >= 2:
			#target_rect.texture = texture_full
		#elif slot_hp == 1:
			#target_rect.texture = texture_half
		#else:
			#target_rect.texture = texture_empty

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
