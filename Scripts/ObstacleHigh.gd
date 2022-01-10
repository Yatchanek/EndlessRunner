extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var index = randi() % Globals.themes[Globals.current_theme]["obstacles-high"]["textures"].size()
	
	var s = Sprite.new()
	add_child(s)
	s.centered = false
	s.texture = Globals.themes[Globals.current_theme]["obstacles-high"]["textures"][index]
	if s.texture == Globals.dark_spikes:
		s.z_index = 10
		s.z_as_relative = false
	s.position =  Globals.themes[Globals.current_theme]["obstacles-high"]["positions"][index]
	s.scale =  Globals.themes[Globals.current_theme]["obstacles-high"]["scale"][index]
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
