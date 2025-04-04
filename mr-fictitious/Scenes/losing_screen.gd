extends Control

func _ready():
	# Start timer to quit game
	$Timer.start()

func _on_timer_timeout():
	get_tree().quit()
