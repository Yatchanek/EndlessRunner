extends Control

onready var endless_mode_button = $MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/EndlessModeButton
onready var reverse_mode_button = $MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer2/ReverseModeButton
onready var particle_effects_button = $MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer3/ParticleEffectsButton

# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_tree().get_nodes_in_group("Buttons"):
		button.connect("pressed", self, "_on_Button_pressed", [button])
	endless_mode_button.pressed = Globals.game_mode & 0b10
	reverse_mode_button.pressed = Globals.game_mode & 0b1
	particle_effects_button.pressed = Globals.particle_effects
	endless_mode_button.disabled = !Globals.game_data["endless_unlock"]
	reverse_mode_button.disabled = !Globals.game_data["reverse_unlock"]

	if !endless_mode_button.disabled:
		$MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/Label.queue_free()
		
	if !reverse_mode_button.disabled:
		$MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer2/Label2.queue_free()



func _on_Button_pressed(button):
	match button.name:
		"BackToMenuButton":
			for button in get_tree().get_nodes_in_group("Buttons"):
				button.disabled = true
				SceneChanger.change_scene("res://Scenes/TitleScreen.tscn")
		"ReverseModeButton":
			Globals.game_mode = Globals.game_mode ^ 0b1		
		"EndlessModeButton":
			Globals.game_mode = Globals.game_mode ^ 0b10
		"ParticleEffectsButton":
			Globals.particle_effects = !Globals.particle_effects
	GameSounds.play_effect(GameSounds.INTERFACE1)		


func _on_HSlider_value_changed(value):
	GameSounds.change_volume(value)
	GameSounds.play_effect(GameSounds.PLAYER_JUMP_3)
