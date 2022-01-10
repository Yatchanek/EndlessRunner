extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$Sprite.texture = Globals.themes[Globals.current_theme]["obstacles-low"][randi() % Globals.themes[Globals.current_theme]["obstacles-low"].size()]
	var x = $Sprite.texture.get_width()
	var y = $Sprite.texture.get_height()
	$Sprite.offset.y = -y
	if pow(-1, randi() % 2) > 0:
		$Sprite.flip_h = true
	$CollisionShape2D.shape.extents = Vector2(x / 2, y / 2)
	$CollisionShape2D.position = Vector2(x / 2, - y / 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
