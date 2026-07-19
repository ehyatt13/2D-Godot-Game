extends CanvasLayer

const ROW_PREFAB: PackedScene = preload("res://scenes/shop_item_row.tscn")

@onready var wallet_label: Label = $CenterContainer/MenuFrame/MarginContainer/VBoxContainer/WalletHBox/WalletLabel
@onready var dynamic_list: VBoxContainer = $CenterContainer/MenuFrame/MarginContainer/VBoxContainer/ScrollContainer/DynamicList
@onready var close_btn: Button = $CenterContainer/MenuFrame/MarginContainer/VBoxContainer/CloseButton

var cached_stock_data: Dictionary = {}

#var last_focused_row_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	close_btn.pressed.connect(close_shop)

func open_shop(merchant_title: String, stock_data: Dictionary) -> void:
	visible = true
	get_tree().paused = true
	GlobalPlayerData.is_menu_active = true
	
	cached_stock_data = stock_data
	
	$CenterContainer/MenuFrame/MarginContainer/VBoxContainer/ShopTitle.text = merchant_title
	_update_wallet_display()
	
	for child in dynamic_list.get_children():
		child.queue_free()
	
	# Expects dictionary format: {"bombs": {"qty": 5, "cost": 20, "icon": Texture}, "potion": {...}}
	var buttons_built: Array[Button] = []
	
	for item_id in stock_data.keys():
		var data = stock_data[item_id]
		var new_row = ROW_PREFAB.instantiate()
		
		dynamic_list.add_child(new_row)
		new_row.configure_row(
			item_id, 
			data["qty"], 
			data["cost"], 
			data["sheet"], 
			data["frame"], 
			data["stock"],
			data.get("tile_size", Vector2i(16, 16)) # Default safeguard to standard 16x16 pixel blocks
		)
		
		# Wire up the row's purchase signal straight into our global data vault
		new_row.purchase_requested.connect(_on_item_purchase_triggered)
		
		# Set up custom blue outline highlights on focus gain/loss
		new_row.focus_entered.connect(func(): _on_btn_focus_gained(new_row))
		new_row.focus_exited.connect(func(): _on_btn_focus_lost(new_row))
		
		buttons_built.append(new_row)
	
	if not buttons_built.is_empty():
		# Loop down the newly generated vertical stack to lock manual directional shortcuts
		for i in range(buttons_built.size()):
			if i > 0:
				buttons_built[i].focus_neighbor_top = buttons_built[i].get_path_to(buttons_built[i-1])
			if i < buttons_built.size() - 1:
				buttons_built[i].focus_neighbor_bottom = buttons_built[i].get_path_to(buttons_built[i+1])
				
		# Force the absolute bottom Exit shop button to point up to the last generated item row
		close_btn.focus_neighbor_top = close_btn.get_path_to(buttons_built.back())
		buttons_built.back().focus_neighbor_bottom = buttons_built.back().get_path_to(close_btn)
		
		# Instantly lock controller cursor focus onto item row #1
		buttons_built[0].grab_focus()
	else:
		close_btn.grab_focus()

func close_shop() -> void:
	visible = false
	get_tree().paused = false # Unfreeze world processing clocks safely
	#print("Merchant Engine: Exited transaction panel.")
	GlobalPlayerData.is_menu_active = false

func _update_wallet_display() -> void:
	# Look up your player's live coin balances inside your global data autoload script
	var current_gold = GlobalPlayerData.get("gold_coins") if "gold_coins" in GlobalPlayerData else 0
	wallet_label.text = str(current_gold)

func _on_item_purchase_triggered(item_id: String, quantity: int, cost: int) -> void:
	var active_button = get_viewport().gui_get_focus_owner()
	
	var current_gold = GlobalPlayerData.get("gold_coins") if "gold_coins" in GlobalPlayerData else 0
	
	var item_stock_record = cached_stock_data.get(item_id, null)
	if not item_stock_record: return
	
	if item_stock_record["stock"] != -1 and item_stock_record["stock"] <= 0:
		print("Shop System: Denied. Item bundle is completely sold out.")
		return
	
	if current_gold >= cost:
		GlobalPlayerData.gold_coins -= cost
		
		# POLYMORPHIC WALLET TRANSACTION INJECTION:
		# Use Godot's safe key detection checks to insert data straight into the autoload variables
		#if item_id in GlobalPlayerData:
			#GlobalPlayerData[item_id] += quantity
		#elif item_id == "health_potion" and "health" in GlobalPlayerData:
			## If it's a healing potion, consume immediately to update core stat gauges
			#GlobalPlayerData.health = min(GlobalPlayerData.health + (quantity * 4), GlobalPlayerData.max_health)
		
		GlobalPlayerData.receive_item(item_id, quantity)
		
		if item_stock_record["stock"] != -1:
			item_stock_record["stock"] -= 1 # Subtract 1 available stock unit from memory!
			
			# Dynamically update your active button row's visual text strings instantly!
			if active_button and active_button.has_node("BtnLayout/StockLabel"):
				var label_node = active_button.get_node("BtnLayout/StockLabel")
				label_node.text = " (Stock: " + str(item_stock_record["stock"]) + ")"
				
				# If the customer just bought the absolute last remaining unit...
				if item_stock_record["stock"] <= 0:
					label_node.text = " (SOLD OUT)"
					active_button.disabled = true # Turn OFF button interactions safely in real-time!
		
		print("Shop Purchase Success: Bought ", item_id, " x", quantity)
		_update_wallet_display()
		#_redraw_shop_menu_elements()
		if active_button and is_instance_valid(active_button):
			active_button.grab_focus.call_deferred() # Safely defer back into the focus server track [A, 1.3.3]
			print("Focus Safeguard: Re-anchored cursor to active element -> ", active_button.name)
	else:
		print("Shop System: Refused transaction. Insufficient gold balances.")

#func _redraw_shop_menu_elements() -> void:
	#_update_wallet_display()
	#
	## Clear out the previous button row instances from RAM memory completely
	#for child in dynamic_list.get_children():
		#child.queue_free()
		#
	#var buttons_built: Array[Button] = []
	#
	## Re-instantiate your fresh rows from your cached merchant stock data payload
	#for item_id in cached_stock_data.keys():
		#var data = cached_stock_data[item_id]
		#var new_row = ROW_PREFAB.instantiate()
		#dynamic_list.add_child(new_row)
		#new_row.configure_row(item_id, data["qty"], data["cost"], data["sheet"], data["frame"], data.get("tile_size", Vector2i(16, 16)))
		#new_row.purchase_requested.connect(_on_item_purchase_triggered)
		#new_row.focus_entered.connect(func(): _on_btn_focus_gained(new_row))
		#new_row.focus_exited.connect(func(): _on_btn_focus_lost(new_row))
		#buttons_built.append(new_row)
	#
	#if not buttons_built.is_empty():
		#for i in range(buttons_built.size()):
			#if i > 0: buttons_built[i].focus_neighbor_up = buttons_built[i].get_path_to(buttons_built[i-1])
			#if i < buttons_built.size() - 1: buttons_built[i].focus_neighbor_down = buttons_built[i].get_path_to(buttons_built[i+1])
		#close_btn.focus_neighbor_up = close_btn.get_path_to(buttons_built.back())
		#buttons_built.back().focus_neighbor_down = buttons_built.back().get_path_to(close_btn)
		#
		## --- THE ANTI-SOFTLOCK FOCUS SNAP OVERRIDE ---
		## Clamp the saved index target so it never exceeds your total button count if stock drops
		#var target_index: int = clamp(last_focused_row_index, 0, buttons_built.size() - 1)
		#
		## Hard-force the engine focus server to grab our newly instantiated replacement button row!
		#buttons_built[target_index].grab_focus()
		#print("Focus Server Re-sync: Locked focus back onto row index -> ", target_index)
	#else:
		#close_btn.grab_focus()

func _on_btn_focus_gained(btn_node: Button) -> void:
	#var border: ReferenceRect = ReferenceRect.new()
	#border.name = "ActiveShopBorder"
	#border.border_color = Color(0.1, 0.6, 1.0, 1.0) # Vibrant Retro Cyan Blue
	#border.border_width = 1.5
	#border.editor_only = false
	#border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	#btn_node.add_child(border)
	
	var custom_outline: StyleBoxFlat = StyleBoxFlat.new()
	custom_outline.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	custom_outline.set_border_width_all(1)
	custom_outline.border_color = Color(0.1, 0.6, 1.0, 1.0)
	custom_outline.anti_aliasing = false # Disable anti-alias blur to protect retro pixels!
	btn_node.add_theme_stylebox_override("focus", custom_outline)
	btn_node.add_theme_stylebox_override("hover", custom_outline)

func _on_btn_focus_lost(btn_node: Button) -> void:
	#var old_border = btn_node.get_node_or_null("ActiveShopBorder")
	#if old_border: old_border.queue_free()
	btn_node.remove_theme_stylebox_override("focus")
	btn_node.remove_theme_stylebox_override("hover")
