extends Node2D

var is_dead = false
var type 


func _ready():
	$AnimationPlayer.play("Idle")

func die():
	$AnimationPlayer.play("Die")
