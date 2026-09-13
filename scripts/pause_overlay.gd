extends Control

# Оверлей паузы. Показан при Game.paused, скрыт иначе.
# Работает даже при get_tree().paused, т.к. HUD в режиме ALWAYS.

@onready var resume_button: Button = $Panel/Margin/VBox/ResumeButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(_resume)
	$Shade.gui_input.connect(_resume)
	visible = false
	Game.paused_changed.connect(func(p: bool) -> void: visible = p)

func _resume(_e: InputEvent = null) -> void:
	Game.set_paused(false)