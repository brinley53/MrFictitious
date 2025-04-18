"""
Script for the shadow bullets the crypt bos shoots
Authors: Brinley Hull, Jose Leyba
Creation Date: 04/17/2025
Revisions:
"""

extends Area2D
var velocity = Vector2.ZERO  
var damage = 100

func _physics_process(delta):	
	position += velocity * delta

# Deals damage to player when hit
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.reduce_player_health(damage)
		queue_free()

#Bullet disappears if nothing is hit in 4 seconds
func _on_timer_timeout() -> void:
	queue_free()
	
func initialize_bullet(target_position: Vector2, speed: float) -> void:
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
