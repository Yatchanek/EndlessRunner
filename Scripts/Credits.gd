extends Control



var delay = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		SceneChanger.change_scene("res://Scenes/TitleScreen.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$VBoxContainer.rect_position.y -= 20 * delta
	if $VBoxContainer.rect_position.y < -448:
		$VBoxContainer.rect_position.y = 360
