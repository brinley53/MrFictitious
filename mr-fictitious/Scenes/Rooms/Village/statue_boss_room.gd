'''
Logic for statue boss room -- mini statues enable.
Authors: Brinley Hull
Creation date: 5/1/2025
Revisions:
'''

extends Node2D
@onready var first_wave = $FirstWave
@onready var second_wave = $SecondWave
@onready var boss = $Statue
var wave1 = false
var wave2 = false

var blocking_edges = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boss.broken.connect(enable_wave)

func enable_wave():
	if !wave1:
		enable_first_wave()
		wave1 = true
	elif !wave2:
		enable_second_wave()
		wave2 = true

func enable_first_wave():
	# function to call first wave of griffins
	var griffins = first_wave.get_children()
	for griffin in griffins:
		griffin.disabled = false
		
func enable_second_wave():
	# function to call second wave of griffins
	var griffins = second_wave.get_children()
	for griffin in griffins:
		griffin.disabled = false
		
func block_edges(edges:Array) -> void:
	if boss != null:
		for edge in edges:
			blocking_edges.append(edge)
			add_child(edge)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
