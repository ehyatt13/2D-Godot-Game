extends CharacterBody2D

@export var speed: float = 50.0
@export var max_health: int = 3

@onready var sprite: Sprite2D = $"Sprite2D"
@onready var detection_zone: Area2D = $"DetectionRange"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var health: int = max_health
var player_target: CharacterBody2D = null

var knockback_velocity: Vector2 = Vector2.ZERO
var is_stunned: bool = false

func _ready() -> void:
	health = max_health
	detection_zone.body_entered.connect(_on_player_detected)
	detection_zone.body_exited.connect(_on_player_lost)
	
	if animation_player.has_animation("idle_bounce"):
		animation_player.play("idle_bounce")


func _physics_process(delta: float) -> void:
	if is_stunned:
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 5.0 * delta)
		velocity = knockback_velocity
		move_and_slide()
		
		if knockback_velocity.length() < 10.0:
			is_stunned = false
			if animation_player.has_animation("chase_bounce"):
				animation_player.play("chase_bounce")
	
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
	
	if animation_player.is_playing():
		animation_player.stop()
	
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
		
		if animation_player.has_animation("chase_bounce"):
			animation_player.play("chase_bounce")

func _on_player_lost(body: Node2D) -> void:
	if body == player_target:
		player_target = null
		print("Player escaped slime sight lines.")
		
		if animation_player.has_animation("idle_bounce"):
			animation_player.play("idle_bounce")
