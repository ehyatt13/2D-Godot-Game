extends PointLight2D

@export_group("Flicker Tuning")
## The baseline brightness of your light source
@export var base_energy: float = 1.0
## How intensely the light dims and brightens (higher = more erratic chaos)
@export var flicker_intensity: float = 0.15
## How rapidly the flame dances (higher = faster crackling)
@export var flicker_speed: float = 12.0

@export_group("Scale Pulse")
## Set to true if you want the visual light circle radius to expand and shrink slightly
@export var pulse_scale: bool = true
## Size of the pulsing circle
@export var base_scale: float = 1.0
## How wildly the circle shrinks and expands
@export var scale_intensity: float = 0.05

@export_group("Identity Configuration")
## Turn this ON for stationary wall torches, campfires, and dungeon lanterns!
## Turn this OFF only for the light child node attached to the moving player.
@export var is_environment_light: bool = false

var time_passed: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	if is_environment_light:
		enabled = true
		return
	
	if "GlobalPlayerData" in Engine.get_main_loop().root:
		GlobalPlayerData.atmosphere_changed.connect(_on_world_lighting_updated)
	
	var current_preset = 0
	var current_scene = get_tree().current_scene
	
	if current_scene and current_scene.get_child_count() > 0:
		var parent_map = get_tree().current_scene.get_child(0)
		var modulator = parent_map.get_node_or_null("CanvasModulate") if parent_map else null
		if modulator and "lighting_preset" in modulator:
			current_preset = modulator.lighting_preset
	_on_world_lighting_updated(current_preset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#pass
	if enabled:
		time_passed += delta * flicker_speed
		var flicker_wave: float = sin(time_passed) + sin(time_passed * 0.7) + cos(time_passed * 1.5)
		flicker_wave = flicker_wave / 3.0
		energy = base_energy + (flicker_wave * flicker_intensity)
		
		if pulse_scale:
			var target_scale: float = base_scale + (flicker_wave * scale_intensity)
			scale = Vector2(target_scale, target_scale)

func force_initial_preset(preset_index: int) -> void:
	_on_world_lighting_updated(preset_index)

func _on_world_lighting_updated(preset_index: int) -> void:
	if is_environment_light: return
	
	if preset_index == 0:
		enabled = false
	else:
		enabled = true
