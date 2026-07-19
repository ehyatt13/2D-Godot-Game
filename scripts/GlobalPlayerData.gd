extends Node

signal health_changed(current_health: int, max_health: int)
signal coins_changed(current_coins: int)

signal atmosphere_changed(preset_index: int)

signal buffs_updated()

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
		coins_changed.emit(gold_coins)
		#print("Coins Updated: ", gold_coins)

var bombs: int = 0:
	set(value):
		bombs = clamp(value, 0, 30)

var flags: Dictionary = {
	"has_shield_upgrade": false,
	"has_power_glove": false,
	"island_one_boss_defeated": false,
	"discovered_coins": false,
	"discovered_bombs": false,
	"has_torch": false
}

var active_buffs: Dictionary = {}

const BASE_SPEED = 60

var player_speed: float:
	get:
		var current_speed: float = BASE_SPEED
		if active_buffs.has("speed_potion"):
			current_speed += 40
		
		return current_speed

var preserved_facing_direction: Vector2 = Vector2.DOWN

var is_menu_active: bool = false

func apply_status_buff(buff_id: String, duration: float) -> void:
	print("Buff Matrix: Applying '", buff_id, "' for ", duration, " seconds.")
	
	active_buffs[buff_id] = duration
	#var live_player = get_tree().get_first_node_in_group("Player")
	#if live_player and live_player.has_method("synchronize_active_stats"):
		#live_player.synchronize_active_stats()
	_force_live_player_stat_sync()
	
	if buff_id == "regeneration":
		_run_regeneration_heartbeat_loop()
	
	buffs_updated.emit()
	
	while active_buffs.has(buff_id) and active_buffs[buff_id] > 0.0:
		await get_tree().create_timer(0.1, false).timeout
		
		if active_buffs.has(buff_id):
			active_buffs[buff_id] -= 0.1
			
			if active_buffs[buff_id] <= 0.0:
				active_buffs.erase(buff_id)
				print("Buff Matrix: '", buff_id, "' expired.")
				
				buffs_updated.emit()
				
				_force_live_player_stat_sync()
				break
				#var active_player = get_tree().get_first_node_in_group("Player")
				#if active_player and is_instance_valid(active_player):
					#if active_player.has_method("synchronize_active_stats"):
						#active_player.synchronize_active_stats()
				#if live_player and is_instance_valid(live_player) and live_player.has_method("synchronize_active_stats"):
					#live_player.synchronize_active_stats()
				#break

func _force_live_player_stat_sync() -> void:
	var active_player = get_tree().get_first_node_in_group("Player")
	if active_player and is_instance_valid(active_player):
		if active_player.has_method("synchronize_active_stats"):
			active_player.synchronize_active_stats()

func _run_regeneration_heartbeat_loop() -> void:
	while active_buffs.has("regeneration") and active_buffs["regeneration"] > 0.0:
		await get_tree().create_timer(2.0, false).timeout
		if active_buffs.has("regeneration") and active_buffs["regeneration"] > 0.0:
			if health <= 0:
				active_buffs.erase("regeneration")
				break
			
			health += 1
			print("Global Buff Tick: Healed 1 HP. Total Health: ", health, "/", max_health)

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
			if item_id == "gold_coin" and not flags["discovered_coins"]:
				flags["discovered_coins"] = true
				print("UI Alert: Coins revealed via global flags dictionary!")
			
			var target_stat: String = item_info["target_stat"]
			if target_stat in self:
				if target_stat == "max_health":
					quantity *= 2
				self[target_stat] += quantity
		
		"flag":
			var target_flag: String = item_info["target_flag"]
			if flags.has(target_flag):
				flags[target_flag] = true
				print("Progression Flag Flipped: ", target_flag, " is now TRUE")
				
				if target_flag == "has_torch":
					var root_window = get_tree().root
					var game_manager = root_window.get_node_or_null("Game")
					
					if game_manager:
						var world_container = game_manager.get_node_or_null("World")
						if world_container and world_container.get_child_count() > 0:
							var current_level_map = world_container.get_child(0)
							
							var modulator = current_level_map.get_node_or_null("CanvasModulate")
							if modulator and "lighting_preset" in modulator:
								print("Loot Engine: Torch unlocked! Broadcasting atmosphere shift code.")
								var player_character = current_level_map.get_node_or_null("Entities/Player")
								if player_character:
									var player_light = player_character.get_node_or_null("PointLight2D")
									if player_light and player_light.has_method("force_initial_preset"):
										# Force push the active room's dark preset directly to the script!
										player_light.force_initial_preset(modulator.lighting_preset)
								atmosphere_changed.emit(modulator.lighting_preset)
		
		"selectable":
			if item_id == "bomb" and not flags["discovered_bombs"]:
				flags["discovered_bombs"] = true
				print("UI Alert: Bombs revealed via global flags dictionary!")
			
			if item_info.has("target_stat"):
				var stat_name: String = item_info["target_stat"]
				if stat_name in self:
					self[stat_name] += quantity
			
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

var world_persistence: Dictionary = {}

func has_been_triggered(level_id: String, object_id: String) -> bool:
	var unique_key: String = level_id + "_" + object_id
	return world_persistence.get(unique_key, false)

func register_world_trigger(level_id: String, object_id: String) -> void:
	var unique_key = level_id + "_" + object_id
	world_persistence[unique_key] = true
	print("Persistence Engine: Recorded change -> ", unique_key)

func get_active_level_name() -> String:
	var root_window = get_tree().root
	var game_manager = root_window.get_node_or_null("Game")
	if game_manager:
		var world_container = game_manager.get_node_or_null("World")
		if world_container and world_container.get_child_count() > 0:
			return world_container.get_child(0).name
	return "GlobalWorld"
