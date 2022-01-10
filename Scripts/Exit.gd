extends Area2D


signal exit_visible

var dir


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	if (dir > 0 and global_position.x < 504) or (dir < 0 and global_position.x > 64):
		emit_signal("exit_visible")
		set_process(false)
