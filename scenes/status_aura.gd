extends GPUParticles2D

var target_buff_id: String = ""

func initialize_aura(buff_id: String) -> void:
	target_buff_id = buff_id
	
	if process_material and process_material is ParticleProcessMaterial:
		var mat: ParticleProcessMaterial = process_material
		if buff_id == "speed_boost":
			texture = load("res://assets/sprites/circle_glow_particle.png")
			mat.color = Color(0.1, 0.6, 1.0, 1.0)
		elif buff_id == "regeneration":
			texture = load("res://assets/sprites/cross_glow_particle.png")
			mat.color = Color(0.2, 1.0, 0.4, 1.0)

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not GlobalPlayerData.active_buffs.has(target_buff_id):
		emitting = false
		var t = create_tween()
		t.tween_property(self, "modulate:a", 0.0, 0.3)
		t.finished.connect(queue_free)
		set_process(false)
