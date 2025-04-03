"""
Script focused on the bullets the player can shoot
Authors: Jose Leyba
Creation Date: 04/03/2025
Revisions:
"""

extends Node2D
var velocity = Vector2.ZERO  

func _physics_process(delta):
	position += velocity * delta

# Deals damage to enemy when hit
func _on_area_2d_area_entered(body):
	print("Collided with:", body.name)
	if (body.name != "Player") and (body.name != "AttackArea"):
		if body.has_method("reduce_enemy_health"):
			body.reduce_enemy_health(1)
		queue_free()


#Bullet dissapear if nothing is hit in 4 seconds
func _on_timer_timeout() -> void:
	queue_free()
