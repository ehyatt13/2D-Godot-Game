extends CharacterBody2D


#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0

@export var speed: float = 50.0
@export var max_health: int = 3

@onready var sprite: Sprite2D = $"Sprite2D"
@onready var detection_zone: Area2D = $"DetectionRange"

var health: int = max_health
var player_target: CharacterBody2D = null

var knockback_velocity: Vector2 = Vector2.ZERO
var is_stunned: bool = false

func _ready() -> void:
	health = max_health
	detection_zone.body_entered.connect(_on_player_detected)
	detection_zone.body_exited.connect(_on_player_lost)


func _physics_process(delta: float) -> void:
	if is_stunned:
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 5.0 * delta)
		velocity = knockback_velocity
		move_and_slide()
		
		if knockback_velocity.length() < 10.0:
			is_stunned = false
	
	elif player_target:
		var chase_direction: Vector2 = (player_target.global_position - global_position).normalized()
		
		velocity = chase_direction * speed
		
		if velocity.x > 0:
			sprite.flip_h = false
		elif velocity.x < 0:
			sprite.flip_h = true
		
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		move_and_slide()
	
	
	_check_player_contact_damage()

func take_damage(amount: int) -> void:
	health -= amount
	print("Slime took damage! Remaining health: ", health)
	
	sprite.modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	
	var root_node = get_tree().root
	var game_manager = root_node.get_node_or_null("Game")
	var live_player: CharacterBody2D = null
	
	if game_manager:
		var world_container = game_manager.get_node_or_null("World")
		if world_container and world_container.get_child_count() > 0:
			var current_level_map = world_container.get_child(0)
			live_player = current_level_map.get_node_or_null("Entities/Player")
	
	if not live_player:
		live_player = get_parent().get_node_or_null("Player")
	
	if live_player:
		var push_direction: Vector2 = (global_position - live_player.global_position).normalized()
		if push_direction == Vector2.ZERO:
			push_direction = Vector2(0, 1)
		
		is_stunned = true
		
		knockback_velocity = push_direction * 200.0
		print("Slime successfully blasted backwards by: ", knockback_velocity)
	else:
		print("Error: Slime could not locate the Player node in the world tree hierarchy!")
	
	#var player_node = get_tree().current_scene.get_node_or_null("Game/World")
	#if player_node: 
		#var live_player = get_tree().get_first_node_in_group("Player") or get_parent().get_node_or_null("PLayer")
		#if live_player:
			#var push_direction: Vector2 = (global_position - live_player.global_position).normalized()
			#
			#is_stunned = true
			#knockback_velocity = push_direction * 800.0
	
	if health <= 0:
		print("Slime was defeated!")
		ItemDatabase.spawn_loot_drop("enemy_slime", global_position)
		queue_free()

func _check_player_contact_damage() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body is CharacterBody2D and body.name == "Player":
			if body.has_method("take_damage"):
				body.take_damage(1)

func _on_player_detected(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Player":
		player_target = body
		print("Slime targeted the player!")

func _on_player_lost(body: Node2D) -> void:
	if body == player_target:
		player_target = null
		print("Player escaped slime sight lines.")
	
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
