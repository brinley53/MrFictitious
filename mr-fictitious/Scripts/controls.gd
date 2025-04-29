extends Node2D
@onready var up = $Up
@onready var down = $Down
@onready var left = $Left
@onready var right = $Right
@onready var melee = $Melee
@onready var attack_sprite = $AttackSprite
@onready var shoot = $Shoot
const PROJECTILE_SCENE = preload("res://Scenes/projectile.tscn")  
const PROJECTILE_SPEED = 600.0 
var time_since_last_shot = 0.0
const SHOOT_COOLDOWN = 2.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/title.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	up.play("walk_up")
	down.play("walk_down")
	left.play("walk_left")
	right.play("walk_right")
	melee.play("stand_right")
	attack_sprite.play("attacking")
	shoot.play("stand_right")
	time_since_last_shot += delta
	if time_since_last_shot >= SHOOT_COOLDOWN:
		var projectile = PROJECTILE_SCENE.instantiate()
		shoot.add_child(projectile)
		projectile.global_position = shoot.global_position
		var right_vector = shoot.get_global_transform().x.normalized()
		var offset = right_vector * 20
		projectile.velocity = right_vector * PROJECTILE_SPEED
		time_since_last_shot = 0.0
