extends PanelContainer

@onready var coin_label: Label = $MarginContainer/HBoxContainer/CoinLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalPlayerData.coins_changed.connect(_on_wallet_updated)
	
	_on_wallet_updated(GlobalPlayerData.gold_coins)

func _on_wallet_updated(current_coins: int) -> void:
	coin_label.text = str(current_coins)
	visible = GlobalPlayerData.flags.get("discovered_coins", false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
