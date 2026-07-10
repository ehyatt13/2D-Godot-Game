extends CharacterBody2D

#const SPEED = 60

@export_group("General")
## Speed of the player
@export var speed: float = 60.0

@export_group("Jump")

## How quick the player comes down after a jump
@export var jump_gravity: float = 850.0
## How high the player can jump (more negative equals higher)
@export var jump_velocity: float = -200.0

var z_height: float = 0.0
var z_velocity: float = 0.0
var is_jumping: bool = false

#@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var shadow_sprite: Sprite2D = $"Visuals/ShadowSprite"
@onready var sprite: Sprite2D = $"Visuals/Sprite2D"
#@onready var animation_player: AnimationPlayer = $"AnimationPlayer"
@onready var animation_tree: AnimationTree = $"AnimationTree"
@onready var animation_state = animation_tree.get("parameters/playback")

@onready var bomb_scene: PackedScene = preload("res://scenes/bomb.tscn")

@onready var sword_hitbox: Area2D = $"SwordHitbox"
@onready var sword_shape: CollisionShape2D = $"SwordHitbox/CollisionShape2D"

var is_invincible: bool = false

var is_attacking: bool = false

var current_face_direction: Vector2 = Vector2(0, 1)

func _ready() -> void:
	animation_tree.active = true
	
	animation_tree.set("parameters/Idle/blend_position", Vector2(0, 1))
	animation_tree.set("parameters/Walk/blend_position", Vector2(0, 1))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("use_item"):
		_use_equipped_item()
	
	if event.is_action_pressed("attack") and not is_attacking:
		execute_sword_slash()

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
	
	if active_item.id == "bomb":
		if GlobalPlayerData.bombs > 0:
			GlobalPlayerData.bombs -= 1
			_spawn_bomb_in_world()
		else:
			print("Out of bombs!")

func _spawn_bomb_in_world() -> void:
	var new_bomb = bomb_scene.instantiate()
	
	var spawn_offset: Vector2 = current_face_direction * 10.0
	var absolute_target_position: Vector2 = global_position + spawn_offset
	new_bomb.global_position = absolute_target_position
	#if "last_direction" in self:
		#match last_direction:
			#"down": spawn_offset = Vector2(0, 16)
			#"up": spawn_offset = Vector2(0, -16)
			#"left": spawn_offset = Vector2(-16, 0)
			#"right": spawn_offset = Vector2(16, 0)
	
	#var interactables_folder = get_parent()
	#var map_root = interactables_folder.get_parent()
	#var target_folder = map_root.get_node_or_null("Interactables")
	#var current_level = get_tree().current_scene.get_child(0)
	#var target_folder = current_level.get_node_or_null("Interactables")
	
	var root_node = get_tree().root
	var game_manager = root_node.get_node_or_null("Game")
	
	if game_manager:
		var world_container = game_manager.get_node_or_null("World")
		if world_container and world_container.get_child_count() > 0:
			var current_level_map = world_container.get_child(0)
			
			var target_folder = current_level_map.get_node_or_null("Interactables")
			
			if target_folder:
				target_folder.add_child(new_bomb)
				#new_bomb.global_position = global_position + spawn_offset
				print("Successfully spawned the bomb!")
				return
	
	get_parent().add_child(new_bomb)
	#new_bomb.global_position = global_position + spawn_offset
	print("Warning: 'Interactables' folder not found. Spawned on Level Root instead.")

func take_damage(amount: int) -> void:
	if is_invincible:
		return
	
	is_invincible = true
	
	#sprite.modulate = Color.RED
	#var tween = create_tween()
	#tween.tween_property($Visuals/Sprite2D, "modulate", Color.WHITE, 0.15)
	
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
	#var x_direction := Input.get_axis("move_left", "move_right")
	#if x_direction > 0:
		#animated_sprite_2d.flip_h = false
	#elif x_direction < 0:
		#animated_sprite_2d.flip_h = true
	#
	#var y_direction := Input.get_axis("move_up", "move_down")
	#
	#if x_direction:
		#velocity.x = x_direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#
	#if y_direction:
		#velocity.y = y_direction * SPEED
	#else:
		#velocity.y = move_toward(velocity.y, 0, SPEED)
		#
	#if velocity.x != 0 || velocity.y != 0:
		#animated_sprite_2d.animation = 'run'
		#animated_sprite_2d.speed_scale = 3
	#else:
		#animated_sprite_2d.animation = 'default'
		
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
		#if abs(direction.x) > abs(direction.y):
			#if direction.x > 0:
				#sprite.flip_h = false
				#animation_player.play("walk_right")
			#else:
				##animation_player.play("walk_left")
				#sprite.flip_h = true
				#animation_player.play("walk_right")
		#else:
			#if direction.y > 0:
				##animation_player.play("walk_down")
				#animation_player.play("walk_right")
			#else:
				##animation_player.play("walk_up")
				#animation_player.play("walk_right")
	#else:
		#animation_player.stop()
		##or play an idle animation
	
	if Input.is_action_just_pressed("jump") and not is_jumping:
		z_velocity = jump_velocity
		is_jumping = true
		
		set_collision_mask_value(4, false)
	
	if is_jumping:
		z_velocity += jump_gravity * delta
		z_height += z_velocity * delta
		
		#print("Height: ", z_height, " | Velocity: ", z_velocity)
		
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
