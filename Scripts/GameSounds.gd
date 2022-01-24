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

var ingame_tracks = [preload("res://Assets/Sounds/Dance and Jump.ogg"), preload("res://Assets/Sounds/New age.ogg"), preload("res://Assets/Sounds/run_under_fire.ogg"), preload("res://Assets/Sounds/Chase.ogg")]
var title_screen_tracks = [preload("res://Assets/Sounds/happy_adventure.ogg")]

var tracks = []

var switching = false
var mute_effects = false
var mute_music = false
var music_stopped = false
var effects_vol_modifier = 0
var music_vol_modifier = 0
var current_track = 0
var next_track
var current_state

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
	INGAME2,
	INGAME3
}

enum States {
	TITLE_SCREEN,
	INGAME,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

	
func change_effects_volume(value):
	effects_vol_modifier = value
	for channel in effects_manager.get_children():
		channel.volume_db = -20 + value
		if channel.volume_db < -35:
			mute_effects = true
		else:
			mute_effects = false

func change_music_volume(value):
	music_vol_modifier = value
	music_manager.volume_db = -20 + value
	if music_manager.volume_db < -35:
		mute_music = true
		music_manager.volume_db = -80
	else:
		mute_music = false

func stop_effects(effect):
	for channel in effects_manager.get_children():
		if channel.stream == sounds[effect]:
			channel.stop()

func stop_all_effects():
	for channel in effects_manager.get_children():
		channel.stop()

func play_effect(sound):
	if !mute_effects:
		for channel in effects_manager.get_children():
			if !channel.playing:
				channel.stream = sounds[sound]
				channel.play()
				break

func switch_track(track, is_first):
	next_track = track
	if !is_first:
		fade_out()
	else:
		play_track(next_track)
		fade_in()


func play_track(track):
	if !mute_music:
		#music_manager.volume_db = -15
		music_manager.stream = tracks[track]
		$MusicTimer.wait_time = music_manager.stream.get_length() - 2.5
		music_manager.play()
		$MusicTimer.start()
		switching = false

func stop_music():
	music_stopped = true
	$MusicTimer.stop()
	fade_out()
	
func fade_out():
	$Tween.interpolate_property($Music/Music, "volume_db", $Music/Music.volume_db, -80, 2.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	
func fade_in():
	music_stopped = false
	$Tween.interpolate_property($Music/Music, "volume_db", -80, -15 + music_vol_modifier, 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()

func enter_state(state):
	match state:
		States.TITLE_SCREEN:
			music_stopped = false
			tracks = title_screen_tracks
			next_track = 0
			if !$Tween.is_active():
				play_track(next_track)
		States.INGAME:
			tracks = ingame_tracks
			current_track = randi() % tracks.size()
			switch_track(current_track, true)

	current_state = state


func _on_Tween_tween_all_completed():
	if $Music/Music.volume_db < -70:
		music_manager.stop()
		if !music_stopped and next_track != null:
			play_track(next_track)
			fade_in()
		

func _on_MusicTimer_timeout():
	if current_state == States.INGAME:
		current_track += 1
		switch_track(current_track % tracks.size(), false)
		switching = true

