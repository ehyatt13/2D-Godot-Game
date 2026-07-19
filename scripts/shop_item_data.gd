class_name ShopItemData
extends Resource


@export_group("Merchant Form Entry")
## Type the exact key string tracking this item (e.g., "bombs" or "health_potion")
@export var item_id: String = ""

## The quantity provided to the player upon purchase
@export var quantity: int = 1

## The cost of the item bundle in gold coins
@export var cost: int = 10
