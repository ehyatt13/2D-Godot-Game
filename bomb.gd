extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

@onready var blast_zone: Area2D = $ExplosionRadius

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_player.play("fuse_tick")

func trigger_explosion() -> void:
	print("BOOM!")
	
	var root_node = get_tree().root
	var game_manager = root_node.get_node_or_null("Game")
	if game_manager:
		var world_container = game_manager.get_node_or_null("World")
		if world_container and world_container.get_child_count() > 0:
			var current_level_map = world_container.get_child(0)
			
			var camera = current_level_map.get_node_or_null("Camera2D")
			if camera and camera.has_method("trigger_screen_shake"):
				camera.trigger_screen_shake(0.6)
	
	var hit_bodies = blast_zone.get_overlapping_bodies()
	for body in hit_bodies:
		if body.has_method("take_damage"):
			body.take_damage(1)
	
	await get_tree().create_timer(0.25).timeout
	queue_free()
