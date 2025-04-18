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


#Bullet dissapear if nothing is hit in 4 seconds


func _on_body_entered(body: Node2D) -> void:
	print("Body entered:", body.name)
	if body.is_in_group("Enemies"):
		print("Hit an Enemy!")
		if body.has_method("reduce_enemy_health"):
			body.reduce_enemy_health(10)
			print("Enemy health reduced.")
			queue_free()
