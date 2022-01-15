extends Control

onready var sound_volume_slider = $InfoPanel/VBoxContainer2/HBoxContainer/SoundVolume
onready var music_volume_slider = $InfoPanel/VBoxContainer2/HBoxContainer2/MusicVolume
onready var particle_effects_button = $InfoPanel/VBoxContainer2/ParticleEffectsButton
onready var dash_effect_button = $InfoPanel/VBoxContainer2/DashEffectButton

signal panel_closed

# Called when the node enters the scene tree for the first time.
func _ready():
	update_hud_color()
	connect("panel_closed", get_parent(), "_on_InfoPanel_closed")
	for button in get_tree().get_nodes_in_group("Buttons"):
		button.connect("pressed", self, "_on_Button_pressed", [button])
	sound_volume_slider.value = GameSounds.effects_vol_modifier
	music_volume_slider.value = GameSounds.music_vol_modifier
	particle_effects_button.pressed = Globals.particle_effects
	dash_effect_button.pressed = Globals.dash_effect

func update_hud_color():
	$InnerRect.color = Globals.themes[Globals.current_theme]["hud-colors"][0]
	$OuterRect.color = Globals.themes[Globals.current_theme]["hud-colors"][1]

func update_label(label, value):
	label.text = value

func update_speed(value):
	$HBoxContainer/TextureProgress.value = value

func _on_Button_pressed(button):
	match button.name:
		"ParticleEffectsButton":
			Globals.particle_effects = !Globals.particle_effects
		"DashEffectButton":
			Globals.dash_effect = !Globals.dash_effect
		"OKButton":
			$InfoPanel.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			emit_signal("panel_closed")


func _on_SoundVolume_value_changed(value):
	GameSounds.change_effects_volume(value)
	


func _on_MusicVolume_value_changed(value):
	GameSounds.change_music_volume(value)
