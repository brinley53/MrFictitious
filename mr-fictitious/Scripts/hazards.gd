"""
Script for items, for now they dissapear when walking over them
Authors: Jose Leyba
Creation Date: 04/17/2025
Revisions:
	[format: date - name, what you revised]
"""
extends Area2D

@export_enum("Spikes", "Goo", "Nothing fr") var type : String

var damage_per_tick: int = 4
var tick_interval: float = 1
var slow_multiplier: float = 0.5
var player_in_area: Player = null

@onready var damage_timer = $DamageTimer

func _ready():
	damage_timer.wait_time = tick_interval
	damage_timer.timeout.connect(_on_damage_tick)

func _on_body_entered(body: Node2D) -> void:
	
	if body.name == "Player":
		player_in_area = body
		if type == "Spikes":
			damage_timer.start()
		if type == "Spikes":
			player_in_area.set_speed_multiplier(slow_multiplier)

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_area:
		if type == "Spikes":
			damage_timer.stop()
		if type == "Spikes":
			player_in_area.set_speed_multiplier(1)
		player_in_area = null


func _on_damage_tick():
	if player_in_area and type == "Spikes":
		player_in_area.reduce_player_health(damage_per_tick)
