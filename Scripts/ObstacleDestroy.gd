extends Node2D

var is_destroyed = false
var gravity = 950
var velocity = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_destroyed:
		velocity += gravity * delta
		position.y += velocity * delta

func destroy():
	$Destroyable.queue_free()
	is_destroyed = true
