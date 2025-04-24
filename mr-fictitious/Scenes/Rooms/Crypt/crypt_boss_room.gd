"""
Script for the shadow crypt maze and boss attack times
Authors: Brinley Hull
Creation Date: 04/23/2025
Revisions:
"""

extends Node2D

var color = "Gray"
var prev_color = "Gray"
var attacks = ["Default", "Split", "Target"]
@onready var maze_timer = $MazeTimer
@onready var transition_timer = $TransitionTimer
@onready var attack_timer = $AttackTimer
@onready var boss = $ShadowBoss

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set the shadows to hidden initially except for the gray parts
	var shadows = get_node("Red").get_children()
	for shadow in shadows:
		shadow.toggle_enable()
	shadows = get_node("Blue").get_children()
	for shadow in shadows:
		shadow.toggle_enable()
	shadows = get_node("Green").get_children()
	for shadow in shadows:
		shadow.toggle_enable()


func _on_maze_timer_timeout() -> void:
	# set the next group of shadows to visible
	prev_color = color
	if color == "Gray":
		color = "Red"
	elif color == "Red":
		color = "Blue"
	elif color == "Blue":
		color = "Green"
	else:
		color = "Gray"
	var shadows = get_node(color).get_children()
	for shadow in shadows:
		shadow.toggle_enable()
	maze_timer.start()
	transition_timer.start()


func _on_transition_timer_timeout() -> void:
	# hide the previous shadow group after a second
	var shadows = get_node(prev_color).get_children()
	for shadow in shadows:
		shadow.toggle_enable()
	transition_timer.stop()
	

func _on_attack_timer_timeout() -> void:
	# change attack type for the boss
	boss.change_attack(attacks[randi_range(0, 2)])
	attack_timer.start()
	
