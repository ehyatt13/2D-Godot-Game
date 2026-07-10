@tool
extends CanvasModulate

enum EnvironmentPreset {
	OFF,
	DARKNESS,
	NIGHT,
	PITCH_BLACK
}

const PRESET_COLORS: Dictionary = {
	EnvironmentPreset.OFF: Color(1.0, 1.0, 1.0, 1.0),
	EnvironmentPreset.DARKNESS: Color(0.08, 0.08, 0.12, 1.0),
	EnvironmentPreset.NIGHT: Color(0.2, 0.2, 0.35, 1.0),
	EnvironmentPreset.PITCH_BLACK: Color(0.0, 0.0, 0.0, 1.0)
}

## Select the global lighting environment for this map layout
@export var lighting_preset: EnvironmentPreset = EnvironmentPreset.OFF:
	set(value):
		lighting_preset = value
		_apply_atmosphere()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	_apply_atmosphere()

func _apply_atmosphere() -> void:
	if is_inside_tree():
		if PRESET_COLORS.has(lighting_preset):
			color = PRESET_COLORS[lighting_preset]
			
			if "GlobalPlayerData" in Engine.get_main_loop().root:
				GlobalPlayerData.atmosphere_changed.emit(lighting_preset)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
