extends Control





# Called when the node enters the scene tree for the first time.
func _ready():
	update_hud_color()

func update_hud_color():
	$InnerRect.color = Globals.themes[Globals.current_theme]["hud-colors"][0]
	$OuterRect.color = Globals.themes[Globals.current_theme]["hud-colors"][1]

func update_label(label, value):
	label.text = value

func update_speed(value):
	$HBoxContainer/TextureProgress.value = value
