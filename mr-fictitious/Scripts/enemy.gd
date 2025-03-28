"""
Script focused on the enemy, for now it just has a function to deal damage to the oplayer when close
Authors: Jose Leyba
Creation Date: 03/27/2025
Revisions:
	[format: date - name, what you revised]
"""
extends CharacterBody2D


func _physics_process(delta: float) -> void:
	pass



func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.reduce_player_health(1)
