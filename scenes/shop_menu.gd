extends CanvasLayer

@onready var wallet_label: Label = $CenterContainer/MenuFrame/MarginContainer/VBoxContainer/WalletLabel
@onready var buy_bomb_btn: Button = $CenterContainer/MenuFrame/MarginContainer/VBoxContainer/ItemsHBox/BuyBombButton
@onready var buy_heart_btn: Button = $CenterContainer/MenuFrame/MarginContainer/VBoxContainer/ItemsHBox/BuyHeartButton
@onready var close_btn: Button = $CenterContainer/MenuFrame/MarginContainer/VBoxContainer/CloseButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	
	buy_bomb_btn.pressed.connect(_on_buy_bombs_pressed)
	buy_heart_btn.pressed.connect(_on_buy_heart_pressed)
	close_btn.pressed.connect(close_shop)
	
	buy_heart_btn.focus_neighbor_left = buy_heart_btn.get_path_to(buy_bomb_btn)
	buy_bomb_btn.focus_neighbor_right = buy_bomb_btn.get_path_to(buy_heart_btn)
	close_btn.focus_neighbor_top = close_btn.get_path_to(buy_bomb_btn)
	
	for btn in [buy_bomb_btn, buy_heart_btn, close_btn]:
		btn.focus_mode = Control.FOCUS_ALL
		btn.focus_entered.connect(func(): _on_btn_focus_gained(btn))
		btn.focus_exited.connect(func(): _on_btn_focus_lost(btn))

func open_shop() -> void:
	visible = true
	get_tree().paused = true # Freeze overworld slimes and player physics loops
	GlobalPlayerData.is_menu_active = true
	_update_wallet_display()
	buy_bomb_btn.grab_focus()

func close_shop() -> void:
	visible = false
	get_tree().paused = false # Unfreeze world processing clocks safely
	print("Merchant Engine: Exited transaction panel.")
	GlobalPlayerData.is_menu_active = false

func _update_wallet_display() -> void:
	# Look up your player's live coin balances inside your global data autoload script
	var current_gold = GlobalPlayerData.get("gold_coins") if "gold_coins" in GlobalPlayerData else 0
	wallet_label.text = "Your Gold: " + str(current_gold) + "g"

func _on_buy_bombs_pressed() -> void:
	var current_gold = GlobalPlayerData.get("gold_coins") if "gold_coins" in GlobalPlayerData else 0
	
	# FINANCIAL BALANCE TRANSACTION CHECK
	if current_gold >= 20:
		# Deduct transaction fees natively inside your global data autoload script variables
		GlobalPlayerData.gold_coins -= 20
		
		# Replenish ammunition stocks
		if "bombs" in GlobalPlayerData:
			GlobalPlayerData.bombs += 5
			
		print("Merchant Engine: Purchased 5 Bombs. Transaction success.")
		_update_wallet_display()
	else:
		print("Merchant Engine: Transaction declined. Insufficient coin values.")

func _on_buy_heart_pressed() -> void:
	var current_gold = GlobalPlayerData.get("gold_coins") if "gold_coins" in GlobalPlayerData else 0
	
	if current_gold >= 15:
		GlobalPlayerData.gold_coins -= 15
		# Trigger health recovery updates straight into your core stat blocks
		if "health" in GlobalPlayerData:
			GlobalPlayerData.health = min(GlobalPlayerData.health + 4, GlobalPlayerData.max_health)
			
		print("Merchant Engine: Purchased Heart Potion. Transaction success.")
		_update_wallet_display()
	else:
		print("Merchant Engine: Transaction declined. Insufficient coin values.")

func _on_btn_focus_gained(btn_node: Button) -> void:
	var border: ReferenceRect = ReferenceRect.new()
	border.name = "ActiveShopBorder"
	border.border_color = Color(0.1, 0.6, 1.0, 1.0) # Vibrant Retro Cyan Blue
	border.border_width = 1.5
	border.editor_only = false
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn_node.add_child(border)

func _on_btn_focus_lost(btn_node: Button) -> void:
	var old_border = btn_node.get_node_or_null("ActiveShopBorder")
	if old_border: old_border.queue_free()
