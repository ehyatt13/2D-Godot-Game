class_name ShopItemData
extends Resource


@export_group("Merchant Form Entry")
## Type the exact key string tracking this item (e.g., "bombs" or "health_potion")
@export var item_id: String = ""

## The quantity provided to the player upon purchase
@export var quantity: int = 1

## The cost of the item bundle in gold coins
@export var cost: int = 10

## The available stock quantity for sale. Type -1 for UNLIMITED stock!
@export var stock_available: int = -1
