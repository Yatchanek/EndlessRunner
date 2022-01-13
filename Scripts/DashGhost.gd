extends Sprite

var speed = 0

func _ready():
	$Tween.interpolate_property(self, "modulate:a", 1, 0, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()

func _process(delta):
	global_position.x -= speed * delta

func _on_Tween_tween_all_completed():
	queue_free()
