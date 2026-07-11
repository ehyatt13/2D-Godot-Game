extends PanelContainer

enum HUDBehaviorPreset {
	ALWAYS_ON,
	AUTO_HIDE
}

@export_group("Behavior Configurations")
@export var hud_behavior: HUDBehaviorPreset = HUDBehaviorPreset.AUTO_HIDE
@export var display_duration: float = 3.0

@onready var coin_label: Label = $MarginContainer/HBoxContainer/CoinLabel

var active_tween: Tween = null
var current_hide_timer: SceneTreeTimer = null

@onready var target_show_y: float = global_position.y
@onready var target_hide_y: float = target_show_y + 60.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalPlayerData.coins_changed.connect(_on_wallet_updated)
	
	_on_wallet_updated(GlobalPlayerData.gold_coins)
	
	if not GlobalPlayerData.flags.get("discovered_coins", false):
		global_position.y = target_hide_y
		visible = false
	else:
		_apply_baseline_layout_position()

func _on_wallet_updated(current_coins: int) -> void:
	coin_label.text = str(current_coins)
	
	if not GlobalPlayerData.flags.get("discovered_coins", false):
		return
	
	visible = true
	
	match hud_behavior:
		HUDBehaviorPreset.ALWAYS_ON:
			_slide_hud_to(target_show_y)
		
		HUDBehaviorPreset.AUTO_HIDE:
			_slide_hud_to(target_show_y)
			
			current_hide_timer = get_tree().create_timer(display_duration)
			var active_timer_id = current_hide_timer
			await active_timer_id.timeout
			
			if current_hide_timer == active_timer_id and hud_behavior == HUDBehaviorPreset.AUTO_HIDE:
				_slide_hud_to(target_hide_y)

func _slide_hud_to(destination_y: float) -> void:
	if active_tween:
		active_tween.kill()
	
	active_tween = create_tween()
	active_tween.tween_property(self, "global_position:y", destination_y, 0.25)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

func _apply_baseline_layout_position() -> void:
	if hud_behavior == HUDBehaviorPreset.ALWAYS_ON:
		global_position.y = target_show_y
	else:
		global_position.y = target_hide_y
