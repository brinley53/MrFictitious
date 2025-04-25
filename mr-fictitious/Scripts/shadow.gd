"""
Script for shadows and stealth
Authors: Brinley Hull
Creation Date: 04/14/2025
Revisions:
	Brinley Hull - 4/22/2025: Alternating shadows
"""
extends Node2D

@export var timeEnabled : int
@export var timeDisabled : int
@onready var timer = $Timer
@onready var collision_area = $CollisionPolygon2D
var monitorable = true
var enabled = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if timeEnabled > 0:
		timer.wait_time = timeEnabled
		timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func toggle_enable():
	enabled = !enabled
	visible = !visible

func _on_timer_timeout() -> void:
	pass
	#timer.wait_time = timeEnabled if timer.wait_time == timeDisabled else timeDisabled
	#timer.start()
	#toggle_enable()
	
