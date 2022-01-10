extends Node

onready var effects_manager = $Effects
onready var music_manager = $Music/Music

var sounds = [preload("res://Assets/Sounds/monster_die.ogg"), 
preload("res://Assets/Sounds/jump1.ogg"), preload("res://Assets/Sounds/jump2.ogg"), 
preload("res://Assets/Sounds/jump3.ogg"), preload("res://Assets/Sounds/attack1.ogg"), 
preload("res://Assets/Sounds/attack2.ogg"), preload("res://Assets/Sounds/attack3.ogg"), 
preload("res://Assets/Sounds/damaged1.ogg"), preload("res://Assets/Sounds/damaged2.ogg"), 
preload("res://Assets/Sounds/damaged3.ogg"), preload("res://Assets/Sounds/slide.ogg"), 
preload("res://Assets/Sounds/swing.ogg"), preload("res://Assets/Sounds/game_over.ogg"),
preload("res://Assets/Sounds/game_won.ogg"), preload("res://Assets/Sounds/interface1.ogg"), 
preload("res://Assets/Sounds/coin.ogg"), preload("res://Assets/Sounds/warp.ogg")]
var tracks = [preload("res://Assets/Sounds/Battle Theme.ogg"), preload("res://Assets/Sounds/The Battle of Atheria.ogg")]
var next_track
var current_track_length = 0
var current_track = 0
var current_state
var mute = false

enum {
	MONSTER_DIE,
	PLAYER_JUMP_1,
	PLAYER_JUMP_2,
	PLAYER_JUMP_3,
	PLAYER_ATTACK_1,
	PLAYER_ATTACK_2,
	PLAYER_ATTACK_3,
	PLAYER_DIE_1,
	PLAYER_DIE_2,
	PLAYER_DIE_3,
	PLAYER_SLIDE,
	PLAYER_SWING,
	GAME_OVER,
	GAME_WON,
	INTERFACE1,
	POWERUP,
	WARPOUT
}

enum {
	INGAME1,
	INGAME2
}

enum States {
	TITLE_SCREEN,
	INGAME,
	GAME_OVER,
	GAME_WON
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if current_track_length > 0 and abs(current_track_length - music_manager.get_playback_position()) < 2.5:
		match current_state:
			States.INGAME:
				current_track += 1
				switch_track((INGAME1 + current_track) % 2)
	
func change_volume(value):
	for channel in effects_manager.get_children():
		channel.volume_db = -20 + value
		if channel.volume_db < -35:
			mute = true
		else:
			mute = false

func stop_effects(effect):
	for channel in effects_manager.get_children():
		if channel.stream == sounds[effect]:
			channel.stop()

func stop_all_effects():
	for channel in effects_manager.get_children():
		channel.stop()

func play_effect(sound):
	if !mute:
		for channel in effects_manager.get_children():
			if not channel.playing:
				channel.stream = sounds[sound]
				channel.play()
				break

func switch_track(track):
	next_track = track
	$AnimationPlayer.play("FadeOut")

func play_track(track):
	music_manager.volume_db = -15
	music_manager.stream = tracks[track]
	current_track_length = music_manager.stream.get_length()
	music_manager.play()

func stop_music():
	switch_track(null)

func enter_state(state):
	match state:
		States.TITLE_SCREEN:
			pass
		States.INGAME:
			pass
		States.GAME_OVER:
			pass
		States.GAME_OVER:
			pass
	current_state = state

func _on_AnimationPlayer_animation_finished(_anim_name):
	music_manager.stop()
	if next_track:
		play_track(next_track)


func _on_Music_finished():
	pass # Replace with function body.
