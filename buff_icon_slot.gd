extends Control

@onready var icon_texture: TextureRect = $IconTexture
@onready var radial_clock: TextureProgressBar = $RadialClock

var target_buff_id: String = ""
var total_max_duration: float = 1.0

func initialize_slot(buff_id: String, max_time: float) -> void:
	target_buff_id = buff_id
	total_max_duration = max_time
	
	var lookup_id: String = ""
	if buff_id == "speed_potion": lookup_id = "speed_potion"
	elif buff_id == "regeneration": lookup_id = "heart"
	
	var item_info = ItemDatabase.get_item_data(lookup_id)
	if not item_info.is_empty():
		var atlas_key: String = item_info["atlas"]
		var atlas_config = ItemDatabase.ATLAS_SHEETS[atlas_key]
		var master_texture = load(atlas_config["path"])
		
		var cell_width: float = master_texture.get_width() / float(atlas_config["hframes"])
		var cell_height: float = master_texture.get_height() / float(atlas_config["vframes"])
		
		var frame: int = item_info["frame"]
		var column: int = frame % atlas_config["hframes"]
		var row: int = frame / atlas_config["hframes"]
		var slice_region: Rect2 = Rect2(column * cell_width, row * cell_height, cell_width, cell_height)
		
		var icon_atlas: AtlasTexture = AtlasTexture.new()
		icon_atlas.atlas = master_texture
		icon_atlas.region = slice_region
		
		icon_texture.texture = icon_atlas

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not GlobalPlayerData.active_buffs.has(target_buff_id):
		queue_free()
		return
	
	var time_left: float = GlobalPlayerData.active_buffs[target_buff_id]
	var percentage_ratio: float = (time_left / total_max_duration) * 100.0
	radial_clock.value = percentage_ratio
