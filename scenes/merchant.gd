extends StaticBody2D

@onready var interaction_area: Area2D = $InteractionArea
#var player_is_nearby: bool = false
#

func interact(_player_node: CharacterBody2D) -> void:
	var shop_ui = get_tree().root.find_child("ShopMenu", true, false)
	if shop_ui and not shop_ui.visible:
		print("Merchant Matrix: Player triggered interaction. Opening storefront...")
		shop_ui.open_shop()

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#interaction_area.body_entered.connect(_on_player_entered_zone)
	#interaction_area.body_exited.connect(_on_player_left_zone)
#
#func _on_player_entered_zone(body: Node2D) -> void:
	#if body.name == "Player":
		#player_is_nearby = true
		#print("Merchant Matrix: Player detected. Press 'Enter/Select' to unlock trades.")
#
#func _on_player_left_zone(body: Node2D) -> void:
	#if body.name == "Player":
		#player_is_nearby = false
		#
		## Safety Force Close: If the player walks away or gets pushed out, pull down screens!
		#var shop_ui = get_tree().root.find_child("ShopMenu", true, false)
		#if shop_ui and shop_ui.visible:
			#shop_ui.close_shop()
#
#func _input(event: InputEvent) -> void:
	## Open shop panel using your "ui_select" axis key (Enter/Select button) when nearby
	#if player_is_nearby and event.is_action_pressed("ui_select"):
		## Find our global overlay UI node mounted inside your master Game scene tree wrapper
		#var shop_ui = get_tree().root.find_child("ShopMenu", true, false)
		#
		#if shop_ui and not shop_ui.visible:
			## Prevent opening if other inventory layouts are actively blocking screen real estate
			#var inventory_menu = get_tree().root.find_child("PauseMenu", true, false)
			#if inventory_menu and inventory_menu.visible: return
			#
			#get_viewport().set_input_as_handled() # Intercept input action consumption
			#shop_ui.open_shop()
