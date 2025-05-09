"""
Script for the final boss logic
Authors: Brinley Hull, Jose Leyba, Tej Gumaste, Sean Hammell
Creation Date: 04/28/2025
Revisions:
	Brinley Hull - 5/1/2025 - Update sprites and triple bullet attacks
"""

extends CharacterBody2D

signal dead

const BULLET_SCENE = preload("res://Scenes/Enemies/syringe.tscn")  
const EVIDENCE_SCENE = preload("res://Scenes/evidence.tscn")  

#GLOBAL VARIABLES
# stats attributes
var speed : float
@export var health : float
@export var damage : float
var attack = "Chase"
var syringe_types = ["Poison", "Snail", "Weak"]

#chase player variables
var chase_player = false
var attack_player = false
var stunned = false
var current_stun_timer: Timer = null
var num_shots = 0
var max_health:float
var prev_chase_variable:bool = false
# On ready attributes
@onready var attack_timer = $AttackTimer
@onready var top_sprite = $TopSprite
@onready var bottom_sprite = $BottomSprite
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player = players[0]
@onready var health_bar = $HealthContainer/HealthBar
@onready var attack_area = $AttackArea
@onready var switch_attack_timer = $BigAttackTimer
@onready var triple_timer = $TripleShotTimer

func _ready():
	#set initial variables
	speed = 150.0
	max_health=health
	health_bar.max_value = health
	health_bar.value = health
	Wwise.post_event_id(AK.EVENTS.MENDOZA_ALERT,self)
	
func change_attack(attack_type):
	if stunned:
		return
	attack = attack_type
	if attack == "Shot":
		shoot_player()
	
func shoot_player():
	if stunned or player.stealth or attack != "Shot" or player.in_dialogue:
		return
	top_sprite.play("projectile")
	triple_timer.start()
	
func shoot():
	Wwise.post_event_id(AK.EVENTS.SYRINGE,self)
	var to_bullet = (global_position - player.global_position).normalized()
	var angle_offset = deg_to_rad(30)
	# Slightly rotate left or right
	var left_offset = to_bullet.rotated(-angle_offset) * 100.0
	var right_offset = to_bullet.rotated(angle_offset) * 100.0
	add_bullet(player.global_position + left_offset)
	add_bullet(player.global_position)
	add_bullet(player.global_position + right_offset)

func _physics_process(_delta: float) -> void:
	if stunned or player.in_dialogue:
		return
	if !player.stealth and !prev_chase_variable:
		Wwise.post_event_id(AK.EVENTS.MENDOZA_ALERT,self)
		prev_chase_variable=true
		# Calculate the direction vector towards the player
		var direction = (player.global_position - global_position).normalized()
				
		if attack == "Chase":
			top_sprite.play("melee")
			bottom_sprite.play("walk")
			velocity = (player.global_position - global_position).normalized() * speed
			move_and_slide()
		else:
			bottom_sprite.play("default")
	elif prev_chase_variable:
		prev_chase_variable=false
		Wwise.post_event_id(AK.EVENTS.MENDOZA_PASSIVE,self)
		bottom_sprite.play("default")

#Takes damage, when life reaches 0 it dies
func reduce_enemy_health(damage_dealt):
	if health <= 0:
		return
	call_deferred("_apply_damage", damage_dealt)


func _apply_damage(damage_dealt):
	Wwise.post_event_id(AK.EVENTS.MENDOZA_HURT,self)
	health = health - damage_dealt
	health_bar.value = health
	if health <= 0:
		Wwise.post_event_id(AK.EVENTS.MENDOZA_HURT,self)
		queue_free()
		dead.emit()
	top_sprite.modulate = Color.RED
	bottom_sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	top_sprite.modulate=Color.WHITE
	bottom_sprite.modulate = Color.WHITE
	

func apply_stun(duration):
	if stunned and current_stun_timer:
		current_stun_timer.stop()
		current_stun_timer.queue_free()
	stunned = true
	current_stun_timer = Timer.new()
	current_stun_timer.one_shot = true
	current_stun_timer.wait_time = duration
	add_child(current_stun_timer)
	current_stun_timer.connect("timeout", Callable(self, "_on_stun_timeout"))
	current_stun_timer.start()

func _on_stun_timeout():
	stunned = false
	if current_stun_timer:
		current_stun_timer.queue_free()
		current_stun_timer = null

#When player is inside the Attack Area, Take Damage (Will be change to something more later)
func _on_attack_area_body_entered(body: Node2D) -> void:
	if stunned:
		return
	if body.name == "Player":
		attack_player = true
		player.reduce_player_health(damage)
		attack_timer.start()

func _on_attack_area_body_exited(body: Node2D) -> void:
	# When player escapes, don't reduce health anymore
	if body.name == "Player":
		attack_player = false
			
func _on_attack_timer_timeout() -> void:
	# timer to allow player iframes
	if stunned:
		return
	if attack_player:
		player.reduce_player_health(damage)
		attack_timer.start()
	
func add_bullet(target):
	var bullet = BULLET_SCENE.instantiate()
	bullet.body_entered.connect(bullet._on_body_entered)
	bullet.global_position = global_position
	bullet.initialize_bullet(target, syringe_types[randi_range(0, 2)])
	get_parent().add_child(bullet)

func _on_triple_shot_timer_timeout() -> void:
	# time between triple shotssss
	shoot_player()

func _on_big_attack_timer_timeout() -> void:
	if attack == "Shot":
		change_attack("Chase")
	else:
		change_attack("Shot")
	switch_attack_timer.start()

func _on_top_sprite_animation_finished() -> void:
	if top_sprite.animation == "projectile":
		shoot()
		top_sprite.play("end_projectile")
