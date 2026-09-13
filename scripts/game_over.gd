extends Control

@onready var panel: Panel = $Panel
@onready var score_value: Label = $Panel/Margin/VBox/ScoreRow/ScoreValue
@onready var best_value: Label = $Panel/Margin/VBox/BestRow/BestValue
@onready var new_best: Label = $Panel/Margin/VBox/NewBest
@onready var play_again: Button = $Panel/Margin/VBox/PlayButton

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_set_pass_through(panel)
	play_again.pressed.connect(Game.reset)

func _set_pass_through(node: Node) -> void:
	if node is Button:
		return
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_set_pass_through(child)

func setup(score: int, best: int, is_new_best: bool) -> void:
	score_value.text = str(score)
	best_value.text = str(best)
	new_best.visible = is_new_best
	await get_tree().process_frame
	if panel.pivot_offset == Vector2.ZERO:
		panel.pivot_offset = panel.size * 0.5
	panel.scale = Vector2(0.7, 0.7)
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.3)