extends Control

@onready var coin_container: HBoxContainer = $MenuFrame/VBoxContainer/StatsHBox/CoinContainer
@onready var bomb_container: HBoxContainer = $MenuFrame/VBoxContainer/StatsHBox/BombContainer
@onready var coin_label: Label = $MenuFrame/VBoxContainer/StatsHBox/CoinContainer/CoinLabel
@onready var bomb_label: Label = $MenuFrame/VBoxContainer/StatsHBox/BombContainer/BombLabel
@onready var weapon_grid: GridContainer = $MenuFrame/VBoxContainer/WeaponGrid
@onready var key_item_grid: GridContainer = $MenuFrame/VBoxContainer/KeyItemGrid
@onready var description_label: Label = $MenuFrame/VBoxContainer/DescriptionMargin/DescriptionPanel/MarginContainer/DescriptionLabel

var last_focused_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	GlobalPlayerData.coins_changed.connect(func(_amt): _refresh_menu_display())

func _input(event: InputEvent) -> void:
	if GlobalPlayerData.is_menu_active and not visible: return
	
	if event.is_action_pressed("pause_game"):
		var select_menu = get_tree().get_first_node_in_group("SelectMenu")
		if select_menu and select_menu.visible: return
		
		get_viewport().set_input_as_handled()
		toggle_pause()

func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	
	visible = get_tree().paused
	
	if visible:
		last_focused_index = 0
		_refresh_menu_display()

func _refresh_menu_display() -> void:
	coin_label.text = str(GlobalPlayerData.gold_coins)
	bomb_label.text = str(GlobalPlayerData.bombs)
	
	coin_container.visible = GlobalPlayerData.flags["discovered_coins"]
	bomb_container.visible = GlobalPlayerData.flags["discovered_bombs"]
	
	for child in weapon_grid.get_children():
		weapon_grid.remove_child(child)
		child.queue_free()
	
	for child in key_item_grid.get_children():
		key_item_grid.remove_child(child)
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
		#print(cell_width, cell_height)
		
		var frame: int = item_info["frame"]
		var column: int = frame % atlas_config["hframes"]
		var row: int = frame / atlas_config["hframes"]
		#print("Row : ", row, ", Column: ", column)
		
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
		
		var item_description: String = item_info.get("description", "A mysterious treasure item.")
		var item_title_name: String = item_info.get("name", "Item")
		
		var capture_index: int = i
		item_slot.focus_entered.connect(func(): 
			last_focused_index = capture_index
			_on_slot_focused(item_slot, item_title_name, item_description))
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
			ammo_label.offset_bottom -= 2
			ammo_label.offset_right -= 2
			
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
		
	var key_item_registry: Dictionary = {
		"magic_torch": "has_torch",
		# "power_glove": "has_power_glove" <-- You can easily append future relics here!
	}
	
	for item_id in key_item_registry.keys():
		var associated_flag: String = key_item_registry[item_id]
		if GlobalPlayerData.flags.get(associated_flag, false):
			var item_info: Dictionary = ItemDatabase.get_item_data(item_id)
			if item_info.is_empty(): continue
			
			var cell_frame: Control = Control.new()
			cell_frame.custom_minimum_size = Vector2(64, 64)
			cell_frame.focus_mode = Control.FOCUS_NONE
			cell_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			var anim_name: String = item_info.get("animation_name", "")
			var shared_frames = load("res://assets/items/item_animations.tres")
			
			if anim_name != "" and shared_frames:
				var menu_anim_sprite: AnimatedSprite2D = AnimatedSprite2D.new()
				menu_anim_sprite.sprite_frames = shared_frames
				
				#menu_anim_sprite.position = Vector2(16, 16)
				
				#var scale_factor: float = item_info.get("visual_scale", 1.0)
				#menu_anim_sprite.scale = Vector2(scale_factor, scale_factor)
				
				var menu_scale_multiplier: float = 3.0
				menu_anim_sprite.scale = Vector2(menu_scale_multiplier, menu_scale_multiplier)
				
				menu_anim_sprite.position = Vector2(32, 32)
				
				cell_frame.add_child(menu_anim_sprite)
				menu_anim_sprite.play(anim_name)
			
			else:
				var static_img: TextureRect = TextureRect.new()
			
				var atlas_key: String = item_info["atlas"]
				var atlas_config: Dictionary = ItemDatabase.ATLAS_SHEETS[atlas_key]
				var master_texture: Texture2D = load(atlas_config["path"])
				
				var cell_width: float = master_texture.get_width() / float(atlas_config["hframes"])
				var cell_height: float = master_texture.get_height() / float(atlas_config["vframes"])
				
				var frame: int = item_info["frame"]
				var column: int = frame % atlas_config["hframes"]
				var row: int = frame / atlas_config["hframes"]
				var slice_region: Rect2 = Rect2(column * cell_width, row * cell_height, cell_width, cell_height)
				
				var item_icon: AtlasTexture = AtlasTexture.new()
				item_icon.atlas = master_texture
				item_icon.region = slice_region
				
				#var key_slot: TextureRect = TextureRect.new()
				static_img.texture = item_icon
				static_img.custom_minimum_size = Vector2(32, 32)
				static_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				
				var scale_factor: float = item_info.get("visual_scale", 1.0)
				static_img.scale = Vector2(scale_factor, scale_factor)
				
				#static_img.focus_mode = Control.FOCUS_NONE
				#static_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
				cell_frame.add_child(static_img)
			
			key_item_grid.add_child(cell_frame)
	
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

func _on_slot_focused(slot_node: TextureButton, title: String, description: String) -> void:
	slot_node.self_modulate = Color(1.5, 1.5, 1.5, 1.0)
	description_label.text = "[" + title + "] - " + description
	
	var selection_border: ReferenceRect = ReferenceRect.new()
	selection_border.name = "ActiveSelectionBorder"
	selection_border.border_color = Color(0.1, 0.6, 1.0, 1.0) 
	selection_border.border_width = 2.0
	selection_border.editor_only = false 
	selection_border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	selection_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot_node.add_child(selection_border)
	
	selection_border.offset_left = 2
	selection_border.offset_top = 2
	selection_border.offset_right = -2
	selection_border.offset_bottom = -2

func _on_slot_focus_lost(slot_node: TextureButton, _index: int) -> void:
	slot_node.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	description_label.text = ""
	
	var old_border = slot_node.get_node_or_null("ActiveSelectionBorder")
	if old_border:
		old_border.queue_free()
