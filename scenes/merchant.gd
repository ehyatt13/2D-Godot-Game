extends StaticBody2D

@onready var interaction_area: Area2D = $InteractionArea

func interact(_player_node: CharacterBody2D) -> void:
	var shop_ui = get_tree().root.find_child("ShopMenu", true, false)
	if shop_ui and not shop_ui.visible:
		print("Merchant Matrix: Player triggered interaction. Opening storefront...")
		shop_ui.open_shop()
