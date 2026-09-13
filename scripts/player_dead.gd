extends RigidBody2D

const BirdArt := preload("res://scripts/bird_art.gd")

var _t := 0.0

func _ready() -> void:
	contact_monitor = true

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()

func _draw() -> void:
	BirdArt.draw(self, _t, {"dead": true, "wing_speed": 0.0})