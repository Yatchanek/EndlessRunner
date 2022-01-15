extends Control

onready var endless_mode_button = $MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/EndlessModeButton
onready var reverse_mode_button = $MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer2/ReverseModeButton
onready var particle_effects_button = $MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer3/ParticleEffectsButton
onready var dash_effect_button = $MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer3/DashEffectButton
onready var sound_volume_slider = $MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer/SoundVolume
onready var music_volume_slider = $MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer2/MusicVolume

var prevent_play = true
# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_tree().get_nodes_in_group("Buttons"):
		button.connect("pressed", self, "_on_Button_pressed", [button])
	endless_mode_button.pressed = Globals.game_mode & 0b10
	reverse_mode_button.pressed = Globals.game_mode & 0b1
	particle_effects_button.pressed = Globals.particle_effects
	dash_effect_button.pressed = Globals.dash_effect
	endless_mode_button.disabled = !Globals.game_data["endless_unlock"]
	reverse_mode_button.disabled = !Globals.game_data["reverse_unlock"]
	sound_volume_slider.value = GameSounds.effects_vol_modifier
	music_volume_slider.value = GameSounds.music_vol_modifier
	prevent_play = false

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
			Globals.game_data["game_mode"] = Globals.game_mode
		"EndlessModeButton":
			Globals.game_mode = Globals.game_mode ^ 0b10
			Globals.game_data["game_mode"] = Globals.game_mode
		"ParticleEffectsButton":
			Globals.particle_effects = !Globals.particle_effects
		"DashEffectsButton":
			Globals.dash_effect = !Globals.dash_effect


func _on_SoundVolume_value_changed(value):
	GameSounds.change_effects_volume(value)
	if !prevent_play:
		GameSounds.play_effect(GameSounds.PLAYER_JUMP_3)


func _on_MusicVolume_value_changed(value):
	GameSounds.change_music_volume(value)
	if !prevent_play and !GameSounds.music_manager.playing:
		GameSounds.music_manager.play()
