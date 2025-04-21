"""
First Permanent Item, It trades attack area for a dmg buff
Authors: Jose Leyba
Creation Date: 04/17/2025
Revisions:
"""
extends Area2D

@export var damage_increase := 3
@export var attack_area_shrink := 0.7  # 70% of original size\
@onready var dialogue = preload("res://shovel.dialogue")
@onready var message = $UI/TextBoxBG/MessageLabel
@onready var ui = $UI
@onready var message_timer = $UI/MessageTimer
@onready var text_box_bg: TextureRect = $UI/TextBoxBG



func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	message.visible = false
	text_box_bg.visible = false

func _on_body_entered(body):
	if body is Player:
		body.shovel(damage_increase, attack_area_shrink)
		show_message("Tactical Shovel:\nAttack Damage Up, Attack Area Down")
		queue_free()

func show_message(text: String, duration: float = 3.0):
	message.text = text
	message.visible = true
	text_box_bg.visible = true
	message_timer.start(duration)

func _on_MessageTimer_timeout():
	message.visible = false
	text_box_bg.visible = false
