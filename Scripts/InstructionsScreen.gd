extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	$MarginContainer3/BackToMenuButton.disabled = true
	SceneChanger.change_scene("res://Scenes/TitleScreen.tscn")
	GameSounds.play_effect(GameSounds.INTERFACE1)
