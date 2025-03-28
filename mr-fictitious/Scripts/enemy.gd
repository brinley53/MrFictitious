"""
Script focused on the enemy, for now it just has a function to deal damage to the oplayer when close and to die when taking too much damage
Authors: Jose Leyba
Creation Date: 03/27/2025
Revisions:
	[format: date - name, what you revised]
"""
extends CharacterBody2D
#GLOBAL VARIABLES
var health = 3

#NOTHING HERE YET
func _physics_process(delta: float) -> void:
	pass


#When player is inside the Attack Area, Take Damage (Will be change to something more later)
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.reduce_player_health(1)

#Takes damage, when life reaches 0 it dies
func reduce_enemy_health(damage):
	health = health - damage
	if health <= 0:
		queue_free()
