extends Node

signal health_changed(current_health: int, max_health: int)

signal atmosphere_changed(preset_index: int)

var max_health: int = 6:
	set(value):
		max_health = clamp(value, 2, 40)
		health_changed.emit(health, max_health)

var health: int = max_health:
	set(value):
		health = clamp(value, 0, max_health)
		print("Player Health updated: ", health, "/", max_health)
		
		health_changed.emit(health, max_health)
		
		if health <= 0:
			_handle_player_death()

var gold_coins: int = 0:
	set(value):
		gold_coins = clamp(value, 0, 999)
		print("Coins Updated: ", gold_coins)

var bombs: int = 0:
	set(value):
		bombs = clamp(value, 0, 30)

var flags: Dictionary = {
	"has_shield_upgrade": false,
	"has_power_glove": false,
	"island_one_boss_defeated": false,
	"discovered_coins": false,
	"discovered_bombs": false
}

var selectable_items: Array[ItemData] = []
var equipped_item_index: int = -1

func _handle_player_death() -> void:
	print("GAME OVER")
	#fade out or reload

func receive_item(item_id: String, quantity: int) -> void:
	var item_info: Dictionary = ItemDatabase.get_item_data(item_id)
	if item_info.is_empty():
		print("Error: collected an invalid item ID: ", item_id)
		return
	
	var behavior: String = item_info.get("behavior", "selectable")
	
	match behavior:
		"automatic":
			var target_stat: String = item_info["target_stat"]
			if target_stat in self:
				self[target_stat] += quantity
			
			if item_id == "gold_coin" and not flags["discovered_coins"]:
				flags["discovered_coins"] = true
				print("UI Alert: Coins revealed via global flags dictionary!")
		
		"flag":
			var target_flag: String = item_info["target_flag"]
			if flags.has(target_flag):
				flags[target_flag] = true
				print("Progression Flag Flipped: ", target_flag, " is now TRUE")
		
		"selectable":
			if item_info.has("target_stat"):
				var stat_name: String = item_info["target_stat"]
				if stat_name in self:
					self[stat_name] += quantity
			
			if item_id == "bomb" and not flags["discovered_bombs"]:
				flags["discovered_bombs"] = true
				print("UI Alert: Bombs revealed via global flags dictionary!")
			
			var already_owned: bool = false
			for owned_item in selectable_items:
				if owned_item.id == item_id:
					already_owned = true
					break
			
			if not already_owned:
				var new_weapon: ItemData = ItemData.new()
				new_weapon.id = item_id
				new_weapon.display_name = item_info["name"]
				selectable_items.append(new_weapon)
				print("Unlocked selectable tool: ", new_weapon.display_name)

func has_upgrade(flag_name: String) -> bool:
	return flags.get(flag_name, false)

func unlock_upgrade(flag_name: String) -> void:
	if flags.has(flag_name):
		flags[flag_name] = true
		print("Permanently unlocked upgrade: ", flag_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
