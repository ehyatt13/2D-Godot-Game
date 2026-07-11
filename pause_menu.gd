extends Control

@onready var coin_container: HBoxContainer = $MenuFrame/VBoxContainer/StatsHBox/CoinContainer
@onready var bomb_container: HBoxContainer = $MenuFrame/VBoxContainer/StatsHBox/BombContainer
@onready var coin_label: Label = $MenuFrame/VBoxContainer/StatsHBox/CoinContainer/CoinLabel
@onready var bomb_label: Label = $MenuFrame/VBoxContainer/StatsHBox/BombContainer/BombLabel
@onready var weapon_grid: GridContainer = $MenuFrame/VBoxContainer/WeaponGrid

var last_focused_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	GlobalPlayerData.coins_changed.connect(func(amt): _refresh_menu_display())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		get_viewport().set_input_as_handled()
		toggle_pause()

func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	
	visible = get_tree().paused
	
	if visible:
		last_focused_index = 0
		_refresh_menu_display()

func _refresh_menu_display() -> void:
	#coin_label.text = "Gold Coins: " + str(GlobalPlayerData.gold_coins)
	#bomb_label.text = "Bombs: " + str(GlobalPlayerData.bombs)
	coin_label.text = str(GlobalPlayerData.gold_coins)
	bomb_label.text = str(GlobalPlayerData.bombs)
	
	coin_container.visible = GlobalPlayerData.flags["discovered_coins"]
	bomb_container.visible = GlobalPlayerData.flags["discovered_bombs"]
	
	for child in weapon_grid.get_children():
		weapon_grid.remove_child(child)
		child.queue_free()
	
	var first_button: TextureButton = null
	
	for i in range(GlobalPlayerData.selectable_items.size()):
		var item: ItemData = GlobalPlayerData.selectable_items[i]	
		var item_info: Dictionary = ItemDatabase.get_item_data(item.id)
		if item_info.is_empty():
			continue
		
		var atlas_key: String = item_info["atlas"]
		var atlas_config: Dictionary = ItemDatabase.ATLAS_SHEETS[atlas_key]
		var master_texture: Texture2D = load(atlas_config["path"])
		
		var cell_width: float = master_texture.get_width() / float(atlas_config["hframes"])
		var cell_height: float = master_texture.get_height() / float(atlas_config["vframes"])
		
		var frame: int = item_info["frame"]
		var column: int = frame % atlas_config["hframes"]
		var row: int = frame / atlas_config["vframes"]
		
		var slice_region: Rect2 = Rect2(column * cell_width, row * cell_height, cell_width, cell_height)
		
		var item_icon: AtlasTexture = AtlasTexture.new()
		item_icon.atlas = master_texture
		item_icon.region = slice_region
		
		var item_slot: TextureButton = TextureButton.new()
		item_slot.texture_normal = item_icon
		item_slot.custom_minimum_size = Vector2(32, 32)
		item_slot.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		
		var scale_factor: float = item_info.get("visual_scale", 1.0)
		item_slot.scale = Vector2(scale_factor, scale_factor)
		item_slot.process_mode = Node.PROCESS_MODE_INHERIT
		item_slot.focus_mode = Control.FOCUS_ALL
		
		var capture_index: int = i
		item_slot.focus_entered.connect(func(): 
			last_focused_index = capture_index
			_on_slot_focused(item_slot))
		item_slot.focus_exited.connect(func(): _on_slot_focus_lost(item_slot, capture_index))
		
		item_slot.gui_input.connect(func(event: InputEvent):
			if event.is_action_pressed("ui_accept"):
				get_viewport().set_input_as_handled()
				
				_on_item_slot_selected(capture_index))
		
		if item_info.has("target_stat"):
			var stat_name: String = item_info["target_stat"]
			var ammo_count: int = GlobalPlayerData.get(stat_name)
			
			var ammo_label: Label = Label.new()
			ammo_label.text = str(ammo_count)
			ammo_label.add_theme_font_size_override("font_size", 10)
			
			ammo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			ammo_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			ammo_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
			
			item_slot.add_child(ammo_label)
		
		if i == GlobalPlayerData.equipped_item_index:
			var outline_frame: ReferenceRect = ReferenceRect.new()
			
			outline_frame.border_color = Color(0.2, 1.0, 0.3, 1.0)
			outline_frame.border_width = 1.5
			outline_frame.editor_only = false
			
			outline_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			outline_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
			item_slot.add_child(outline_frame)
		else:
			item_slot.modulate = Color.WHITE
		
		weapon_grid.add_child(item_slot)
		
		if first_button == null:
			first_button = item_slot
		
		for button in weapon_grid.get_children():
			if button is TextureButton:
				button.focus_neighbor_bottom = button.get_path()
	
	if weapon_grid.get_child_count() > 0:
		var target_index: int = clamp(last_focused_index, 0, weapon_grid.get_child_count() - 1)
		var target_button = weapon_grid.get_child(target_index)
		
		if target_button and target_button is TextureButton:
			target_button.call_deferred("grab_focus")

func _on_item_slot_selected(index: int) -> void:
	GlobalPlayerData.equipped_item_index = index
	print("Equipped tool: ", GlobalPlayerData.selectable_items[index].display_name)
	
	_refresh_menu_display()

func _on_slot_focused(slot_node: TextureButton) -> void:
	slot_node.self_modulate = Color(1.5, 1.5, 1.5, 1.0)

func _on_slot_focus_lost(slot_node: TextureButton, index: int) -> void:
	slot_node.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
