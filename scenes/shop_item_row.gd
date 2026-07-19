extends Button

signal purchase_requested(item_id: String, quantity: int, cost: int)

var current_item_id: String = ""
var current_quantity: int = 1
var current_cost: int = 0

var current_stock: int = -1
@onready var stock_label: Label = $BtnLayout/StockLabel

@onready var item_icon: TextureRect = $BtnLayout/ItemIcon
@onready var quantity_text: Label = $BtnLayout/QuantityText
@onready var cost_text: Label = $BtnLayout/CostText

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed_callback)


func configure_row(item_id: String, qty: int, price: int, spritesheet: Texture2D, frame_index: int, initial_stock: int, tile_size: Vector2i) -> void:
	current_item_id = item_id
	current_quantity = qty
	current_cost = price
	current_stock = initial_stock
	
	quantity_text.text = "x" + str(qty)
	cost_text.text = str(price)
	
	if current_stock == -1:
		# UNLIMITED: Completely clear out the text text and hide the label to keep rows clean!
		stock_label.text = ""
		stock_label.visible = false
		#custom_minimum_size = Vector2(200, 32)
	else:
		# LIMITED: Render the remaining stock capacity numbers on screen
		stock_label.text = " (Stock: " + str(current_stock) + ")"
		stock_label.visible = true
		#custom_minimum_size = Vector2(200, 32)
		
		# Out of Stock Safeguard Visual Pass: If it's sold out on load, grey it out immediately!
		if current_stock <= 0:
			stock_label.text = " (SOLD OUT)"
			disabled = true # Turn OFF button interactions natively inside Godot's UI server!
	
	var atlas_cutout: AtlasTexture = AtlasTexture.new()
	atlas_cutout.atlas = spritesheet
	var sheet_columns: int = spritesheet.get_width() / tile_size.x
	
	var column_x: int = frame_index % sheet_columns
	var row_y: int = frame_index / sheet_columns
	
	var crop_region: Rect2 = Rect2(
		Vector2(column_x * tile_size.x, row_y * tile_size.y), # Top-Left starting pixel corner
		Vector2(tile_size.x, tile_size.y)                     # Width and Height depth limits (e.g. 16x16)
	)
	
	atlas_cutout.region = crop_region
	item_icon.texture = atlas_cutout

func _on_pressed_callback() -> void:
	# Shout up to the master menu that the player wants to buy this specific inventory index
	purchase_requested.emit(current_item_id, current_quantity, current_cost)
