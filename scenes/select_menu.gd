extends CanvasLayer

@onready var resume_btn: Button = $CenterContainer/MenuFrame/MarginContainer/VBoxContainer/ResumeButton
@onready var save_btn: Button = $CenterContainer/MenuFrame/MarginContainer/VBoxContainer/SaveButton
@onready var options_btn: Button = $CenterContainer/MenuFrame/MarginContainer/VBoxContainer/OptionsButton
@onready var exit_btn: Button = $CenterContainer/MenuFrame/MarginContainer/VBoxContainer/ExitButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	
	resume_btn.pressed.connect(_on_resume_pressed)
	save_btn.pressed.connect(_on_save_pressed)
	options_btn.pressed.connect(_on_options_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	
	for btn in [resume_btn, save_btn, options_btn, exit_btn]:
		btn.focus_mode = Control.FOCUS_ALL
		btn.focus_entered.connect(func(): _on_button_focused(btn))
		btn.focus_exited.connect(func(): _on_button_focus_lost(btn))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# Safety Lock: If your main Inventory PauseMenu is currently open, ignore this call
		var main_pause = get_tree().get_first_node_in_group("PauseMenu")
		if main_pause and main_pause.visible: return
		
		if not visible:
			open_menu()
		else:
			close_menu()

func open_menu() -> void:
	visible = true
	get_tree().paused = true
	
	resume_btn.grab_focus()
	print("Select Menu: System paused. Focus locked onto entry 0.")

func close_menu() -> void:
	visible = false
	get_tree().paused = false
	print("Select Menu: System resumed.")

func _on_resume_pressed() -> void:
	close_menu()

func _on_save_pressed() -> void:
	print("Select Menu: Save Game requested. (To be implemented later)")

func _on_options_pressed() -> void:
	print("Select Menu: Options Panel requested. (To be implemented later)")

func _on_exit_pressed() -> void:
	print("Select Menu: Exit to Title requested. (To be implemented later)")

func _on_button_focused(btn_node: Button) -> void:
	# Instantiate our customized, nested blue outline frame overlay dynamically [A]
	var blue_border: ReferenceRect = ReferenceRect.new()
	blue_border.name = "ActiveSelectBorder"
	blue_border.border_color = Color(0.1, 0.6, 1.0, 1.0) # Vibrant Retro Cyan Blue
	blue_border.border_width = 1.5
	blue_border.editor_only = false
	blue_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	blue_border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Nest the blue box inside your button boundaries cleanly [A]
	btn_node.add_child(blue_border)

func _on_button_focus_lost(btn_node: Button) -> void:
	var old_border = btn_node.get_node_or_null("ActiveSelectBorder")
	if old_border:
		old_border.queue_free() # Safely flush the border frame from RAM memory [A]
