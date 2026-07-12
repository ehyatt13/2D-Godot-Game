extends Area2D

enum TRANSITION_DIRECTION {
	NORTH,
	SOUTH,
	EAST,
	WEST
}

const PRESET_COORDS: Dictionary = {
	TRANSITION_DIRECTION.NORTH: Vector2(0, -48),
	TRANSITION_DIRECTION.SOUTH: Vector2(0, 48),
	TRANSITION_DIRECTION.EAST: Vector2(48, 0),
	TRANSITION_DIRECTION.WEST: Vector2(-48, 0)
	
}

@export_group("Room Teleportation Settings")

@export var direction: TRANSITION_DIRECTION = TRANSITION_DIRECTION.NORTH

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_player_entered_doorway)


func _on_player_entered_doorway(body: Node2D) -> void:
	if body.name == "Player" and body is CharacterBody2D:
		print("Doorway Contact! Triggering internal grid room handoff.")
		
		var overlay = get_tree().get_first_node_in_group("TransitionEngine")
		var current_level_map = body.get_parent().get_parent()
		var camera = current_level_map.get_node_or_null("Camera2D") if current_level_map else null
		
		if not camera and current_level_map:
			camera = current_level_map.find_child("Camera2D", true, false)
		
		if overlay and camera:
			if PRESET_COORDS.has(direction):
				var player_teleport_push = PRESET_COORDS[direction]
				overlay.play_diamond_cut_transition(body, camera, player_teleport_push)
		#else:
			## Highly targeted debugging tracking prints: Tells you exactly which node failed to compile
			#if not overlay:
				#print("Handoff Error: Could not locate TransitionOverlay! Did you forget to add it to the 'TransitionEngine' group?")
			#if not camera:
				#print("Handoff Error: Could not locate Camera2D inside the current level map scene hierarchy!")
