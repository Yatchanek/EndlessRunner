extends ParallaxBackground

onready var game_manager = get_parent().get_parent()
signal theme_changed

func _ready():
	generate_background()
	pass

func change_theme():
	SceneChanger.change_theme()
	yield(get_tree().create_timer(0.3), "timeout")
	game_manager.enter_game_state(game_manager.States.PAUSE)
	generate_background()
	emit_signal("theme_changed")
	
func generate_background():
	reset_layers()
	for i in range (Globals.themes[Globals.current_theme]["textures"].size()):
		var layer = get_child(i)
		var sprite = layer.get_node("Sprite")
		sprite.texture = Globals.themes[Globals.current_theme]["textures"][i]
		sprite.position.y = Globals.themes[Globals.current_theme]["y-position"][i]
		sprite.modulate = Globals.themes[Globals.current_theme]["modulate"][i]
		sprite.scale.x = Globals.themes[Globals.current_theme]["bkg-scale"]
		layer.motion_mirroring.x = sprite.texture.get_width() * Globals.themes[Globals.current_theme]["bkg-scale"]
	
func reset_layers():
	for layer in get_children():
		layer.get_node("Sprite").texture = null

func update(speed, delta, run_direction):
	scroll_offset.x -= run_direction * speed * delta

func reset():
	scroll_offset.x = 0
