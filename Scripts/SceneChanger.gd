extends Control

var target_scene = null
var active = false

func _ready():
	$CanvasLayer/ColorRect.modulate = Color(1,1,1,0)

func change_scene(scene_path):
	if !active:
		active = true
		$AnimationPlayer.play("FadeIn")
		yield(get_tree().create_timer(0.75), "timeout")
		GameSounds.stop_all_effects()
		get_tree().change_scene(scene_path)
		active = false
		$AnimationPlayer.play("FadeOut")
		yield(get_tree().create_timer(0.75), "timeout")
		


func change_theme():
	$AnimationPlayer.play("FastChange")
