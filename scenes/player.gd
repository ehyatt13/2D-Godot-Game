extends CharacterBody2D

#const SPEED = 60

#@export_group("General")
### Speed of the player
#@export var speed: float = 60.0

var speed: float = 60.0

@export_group("Jump")

## How quick the player comes down after a jump
@export var jump_gravity: float = 850.0
## How high the player can jump (more negative equals higher)
@export var jump_velocity: float = -200.0

var z_height: float = 0.0
var z_velocity: float = 0.0
var is_jumping: bool = false

@onready var shadow_sprite: Sprite2D = $"Visuals/ShadowSprite"
@onready var sprite: Sprite2D = $"Visuals/Sprite2D"
@onready var animation_tree: AnimationTree = $"AnimationTree"
@onready var animation_state = animation_tree.get("parameters/playback")

@onready var bomb_scene: PackedScene = preload("res://scenes/bomb.tscn")

const STATUS_AURA_PREFAB: PackedScene = preload("res://scenes/status_aura.tscn")

@onready var sword_hitbox: Area2D = $"SwordHitbox"
@onready var sword_shape: CollisionShape2D = $"SwordHitbox/CollisionShape2D"

@onready var interaction_zone: Area2D = $InteractionZone
var overlapping_interactables: Array[Node2D] = []

var is_invincible: bool = false

var is_attacking: bool = false

var current_face_direction: Vector2 = GlobalPlayerData.preserved_facing_direction

func _ready() -> void:	
	add_to_group("Player")
	animation_tree.active = true
	
	current_face_direction = GlobalPlayerData.preserved_facing_direction
	
	animation_tree.set("parameters/Idle/blend_position", current_face_direction)
	animation_tree.set("parameters/Walk/blend_position", current_face_direction)
	
	interaction_zone.body_entered.connect(_on_interactable_entered)
	interaction_zone.body_exited.connect(_on_interactable_exited)
	synchronize_active_stats()

func synchronize_active_stats() -> void:
	speed = GlobalPlayerData.player_speed
	#print("Player Local Sync Completed: Active Speed is now ", speed)
	for buff_key in GlobalPlayerData.active_buffs.keys():
		var already_has_aura: bool = false
		for child in get_children():
			if "target_buff_id" in child and child.target_buff_id == buff_key:
				already_has_aura = true
				break
		
		if not already_has_aura:
			var new_aura = STATUS_AURA_PREFAB.instantiate()
			add_child(new_aura)
			new_aura.initialize_aura(buff_key)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("use_item"):
		_use_equipped_item()
	
	if event.is_action_pressed("attack") and not is_attacking:
		execute_sword_slash()
	
	if event.is_action_pressed("ui_accept") and not is_attacking and not get_tree().paused:
		_process_active_interaction()

func _process_active_interaction() -> void:
	if overlapping_interactables.is_empty():
		return
	
	var closest_object: Node2D = overlapping_interactables[0]
	var shortest_distance: float = global_position.distance_to(closest_object.global_position)
	
	for obj in overlapping_interactables:
		var test_dist: float = global_position.distance_to(obj.global_position)
		if test_dist < shortest_distance:
			shortest_distance = test_dist
			closest_object = obj
	
	if closest_object.has_method("interact"):
		closest_object.interact(self)

func _on_interactable_entered(body: Node2D) -> void:
	if body.has_method("interact") and not overlapping_interactables.has(body):
		overlapping_interactables.append(body)

func _on_interactable_exited(body: Node2D) -> void:
	if overlapping_interactables.has(body):
		overlapping_interactables.erase(body)

func execute_sword_slash() -> void:
	is_attacking = true
	
	sword_hitbox.position = Vector2.ZERO
	sword_hitbox.position = current_face_direction * 16.0
	
	var attack_angle: float = atan2(current_face_direction.y, current_face_direction.x)
	sword_hitbox.rotation = attack_angle - (PI / 2) # Offsets Godot's native 2D rotation math
	#animation_state.travel("Attack")
	sword_shape.disabled = false
	print("Sword swung: ", current_face_direction)
	
	await get_tree().create_timer(0.2).timeout
	
	sword_shape.disabled = true
	is_attacking = false
	
	_process_hitbox_impacts()

func _process_hitbox_impacts() -> void:
	var struck_bodies = sword_hitbox.get_overlapping_bodies()
	for body in struck_bodies:
		if body.has_method("take_damage"):
			body.take_damage(1)

func _use_equipped_item() -> void:
	if GlobalPlayerData.equipped_item_index == -1:
		print("No item equipped!")
		return
	
	var active_item: ItemData = GlobalPlayerData.selectable_items[GlobalPlayerData.equipped_item_index]
	
	match active_item.id:
		"bomb":
			if GlobalPlayerData.bombs > 0:
				GlobalPlayerData.bombs -= 1
				_spawn_bomb_in_world()
			else:
				print("Out of bombs!")
		
		"health_potion":
			GlobalPlayerData.health += 6
			active_item.id = "empty_bottle"
		
		"speed_potion":
			active_item.id = "empty_bottle"
			GlobalPlayerData.apply_status_buff("speed_potion", 10.0)
		
		"regen_potion":
			active_item.id = "empty_bottle"
			GlobalPlayerData.apply_status_buff("regeneration", 24.0)

func _spawn_bomb_in_world() -> void:
	var new_bomb = bomb_scene.instantiate()
	
	var spawn_offset: Vector2 = current_face_direction * 10.0
	var absolute_target_position: Vector2 = global_position + spawn_offset
	new_bomb.global_position = absolute_target_position #+ Vector2(0.0, 6.0)
	#if "last_direction" in self:
		#match last_direction:
			#"down": spawn_offset = Vector2(0, 16)
			#"up": spawn_offset = Vector2(0, -16)
			#"left": spawn_offset = Vector2(-16, 0)
			#"right": spawn_offset = Vector2(16, 0)
	
	var active_map = get_parent().get_parent()
	if active_map:
		var target_folder = active_map.get_node_or_null("Interactables")
		
		if target_folder:
			#print("still works")
			target_folder.add_child(new_bomb)
			target_folder.move_child(new_bomb, -1)

func take_damage(amount: int) -> void:
	if is_invincible:
		return
	
	is_invincible = true
	
	GlobalPlayerData.health -= amount
	
	_start_flicker_animation(1.0)
	
	await get_tree().create_timer(1.0).timeout
	is_invincible = false

func _start_flicker_animation(duration: float) -> void:
	var tween = create_tween()
	
	var steps: int = int(duration / 0.1)
	for i in range(steps):
		var target_alpha: float = 0.2 if (i % 2 == 0) else 1.0
		tween.tween_property(sprite, "modulate:a", target_alpha, 0.05)
	
	tween.tween_property(sprite, "modulate:a", 1.0, 0.05)

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if is_attacking:
		velocity = Vector2.ZERO
	else:
		velocity = direction * speed
		move_and_slide()
	
	if direction != Vector2.ZERO and not is_attacking:
		var look_direction: Vector2 = direction.normalized()
		
		if abs(look_direction.x) > abs(look_direction.y):
			# Mostly moving horizontally
			look_direction = Vector2(sign(look_direction.x), 0)
		else:
			# Mostly moving vertically
			look_direction = Vector2(0, sign(look_direction.y))
		
		current_face_direction = look_direction
		
		animation_tree.set("parameters/Idle/blend_position", look_direction)
		animation_tree.set("parameters/Walk/blend_position", look_direction)
		
		if animation_state.get_current_node() != "Walk":
			animation_state.travel("Walk")
	elif not is_attacking:
		if animation_state.get_current_node() != "Idle":
			animation_state.travel("Idle")
	
	if Input.is_action_just_pressed("jump") and not is_jumping:
		z_velocity = jump_velocity
		is_jumping = true
		
		set_collision_mask_value(4, false)
	
	if is_jumping:
		z_velocity += jump_gravity * delta
		z_height += z_velocity * delta
		
		if z_velocity > 0.0 and z_height > 0.0:
			z_height = 0.0
			z_velocity = 0.0
			is_jumping = false
			
			set_collision_mask_value(4, true)
	
	sprite.position.y = z_height
	
	if is_jumping:
		var jump_percentage: float = clamp(abs(z_height) / 60.0, 0.0, 1.0)
		var shadow_scale: float = lerp(1.0, 0.6, jump_percentage)
		shadow_sprite.scale = Vector2(shadow_scale, shadow_scale)
		shadow_sprite.modulate.a = lerp(1.0, 0.3, jump_percentage)
	else:
		shadow_sprite.scale = Vector2(1.0, 1.0)
		shadow_sprite.modulate.a = 1.0
