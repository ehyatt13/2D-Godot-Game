extends StaticBody2D

@export_group("Merchant Customization")
## Type the unique header name banner for this specific shopkeeper
@export var shop_display_title: String = "OUTPOST"

@export var merchandise_stock: Array[ShopItemData] = []

@onready var interaction_area: Area2D = $InteractionArea

func interact(_player_node: CharacterBody2D) -> void:
	var shop_ui = get_tree().root.find_child("ShopMenu", true, false)
	if shop_ui and not shop_ui.visible:
		var payload: Dictionary = {}
		for entry in merchandise_stock:
			if entry.item_id == "": continue
			
			# --- THE ITEM DATABASE INTEGRATION BRIDGE ---
			# We query your existing database object to automatically fetch textures and frames!
			var visual_data = ItemDatabase.get_item_visual_assets(entry.item_id)
			
			payload[entry.item_id] = {
				"qty": entry.quantity,
				"cost": entry.cost,
				"stock": entry.stock_available,
				"sheet": visual_data["sheet"],
				"frame": visual_data["frame"],
				"tile_size": visual_data["tile_size"]
			}
		print("Merchant Matrix: Player triggered interaction. Opening storefront...")
		shop_ui.open_shop(shop_display_title, payload)
