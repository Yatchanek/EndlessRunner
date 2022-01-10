extends Node

onready var distance_label = $GUI/ScoreLabel
onready var highscore_label = $GUI/HighscoreLabel
onready var continue_label = $GUI/ContinueLabel
onready var gameover_label = $GUI/GameOverLabel
onready var record_label = $GUI/NewRecordLabel
onready var speed_label = $GUI/SpeedLabel
onready var platforms = $World/Platforms
onready var player = $World/Player
onready var background = $World/ParallaxBackground

var platform = preload("res://Scenes/Platform.tscn")


export var MAX_GAP_X = 150.0
export var MIN_GAP_X = 60.0
export var MAX_GAP_Y = 65.0
export var MIN_GAP_Y = 35.0
export var initial_speed = 250.0
export var max_speed = 600
export var level_threshold = 2500
var speed = 0

var acc_factor = 1.0
var max_acc_factor
var acc_rate = 1 / initial_speed
var game_state
var change_theme = false
var spawn_exit = false
var exit_spawned = false
var exit_visible = false
var game_won = false
var raining = false
var next_level = level_threshold
var current_stage = 0
var run_direction = 1

var score = 0
var distance = 0
var best_distance = 0
var player_variant = 0
var last_rain_time = 0

enum States {
	IDLE,
	PLAYING,
	GAME_OVER,
	PAUSE,
	GAME_WON
}

enum {
	MONSTER_DEAD
}

func _ready():
	config()
	for _i in range(2):
		spawn_next_platform()
		
	enter_game_state(States.IDLE)
	acc_factor = 1.0
	$GUI.update_label($GUI/DebugLabel, "%s" % next_level)
	$GUI.update_label(highscore_label, "Best distance: %s" % int(best_distance))
	GameSounds.current_state = GameSounds.States.INGAME
	GameSounds.switch_track(GameSounds.INGAME1)

func config():
	speed = initial_speed
	MAX_GAP_X = floor(initial_speed * (sqrt(2 * player.jump_height / player.gravity) + sqrt(2 * (player.jump_height - 1.15 * MAX_GAP_Y) / player.gravity)))
	MIN_GAP_X = floor(MAX_GAP_X / 3)
	max_acc_factor = max_speed / initial_speed
	
	if Globals.game_mode & 0b1:
		run_direction = -1

	best_distance = Globals.game_data["high_score_%s" % Globals.game_mode]
	player.scale.x = run_direction
	$World/MoonLayer/Sprite.scale.x = run_direction
	last_rain_time = OS.get_unix_time()
			
func enter_game_state(state):
	match state:
		States.PLAYING:
			continue_label.hide()
			gameover_label.hide()
			record_label.hide()
			speed_label.show()
		
		States.IDLE:
			record_label.hide()
			speed_label.hide()
			player.position.x = 50 if run_direction > 0 else 518
			player.position.y = platforms.get_child(0).position.y
			continue_label.text = "Press mouse button to start running"
			continue_label.set_anchors_and_margins_preset(Control.PRESET_CENTER_BOTTOM)
			continue_label.show()
		
		States.PAUSE:
			speed = 0
		
		States.GAME_OVER:
			speed_label.hide()
			show_ending_message()
			
		States.GAME_WON:
			speed_label.hide()
			GameSounds.play_effect(GameSounds.GAME_WON)
			gameover_label.text = "You Won!"
			show_ending_message()
			
	game_state = state

func _process(delta):
	if game_state == States.PLAYING and !exit_visible:
		background.update(speed, delta, run_direction)
	if Input.is_action_just_pressed("ui_cancel"):
		player.prepare_to_quit = true
		Globals.current_theme = 0
		SceneChanger.change_scene("res://Scenes/TitleScreen.tscn")
		
	$GUI.update_label(distance_label, "Distance: %s" % int(distance))
	$GUI.update_label(speed_label, "Speed: %s" % int(speed))


func _physics_process(delta):
	if game_state == States.PLAYING:
		if !exit_visible:
			move_platforms(delta)

		distance += speed * delta * 0.1
		score += speed * delta * 0.1
		if distance > next_level:
			if !Globals.game_mode & 0b10 and Globals.current_theme == 4:
				spawn_exit = true
			else:
				Globals.current_theme = posmod(Globals.current_theme + 1, Globals.themes.size())
				change_theme = true
			next_level = INF
			
	

		acc_factor = wrapf(acc_factor + acc_rate * delta, 1.0, max_acc_factor)
		speed = acc_factor * initial_speed
		if MAX_GAP_X < 200:
			MAX_GAP_X = speed * (sqrt(2 * player.jump_height / player.gravity) + sqrt(2 * (player.jump_height - 1.15 * MAX_GAP_Y) / player.gravity))
			MIN_GAP_X = floor(MAX_GAP_X / 3)
		
		if Globals.particle_effects and !raining and OS.get_unix_time() - last_rain_time > 20:
			if randf() < 0.15:
				rain()
			else:
				last_rain_time = OS.get_unix_time()
		
	elif game_state == States.IDLE:
		if Input.is_action_just_pressed("Jump"):
			yield(get_tree().create_timer(0.1), "timeout")
			enter_game_state(States.PLAYING)
			player.enter_state(player.States.RUN)	
	
	elif game_state == States.GAME_OVER or game_state == States.GAME_WON:
		if Input.is_action_just_pressed("Jump"):
			yield(get_tree().create_timer(0.1), "timeout")
			Globals.current_theme = 0
			GameSounds.stop_all_effects()
			get_tree().reload_current_scene()
	
func show_ending_message():
			continue_label.text = "Press mouse button to restart"
			continue_label.set_anchors_and_margins_preset(Control.PRESET_CENTER_BOTTOM)
			continue_label.show()
			gameover_label.show()
			$GUI/AnimationPlayer.play("FadeIn")
			if distance > best_distance:
				best_distance = distance
				Globals.game_data["high_score_%s" % Globals.game_mode] = distance
				save_game_data()
				$GUI.update_label(highscore_label, "Highscore: %s" % int(best_distance))
				record_label.show()
				$GUI/AnimationPlayer.queue("Blink")
	
func move_platforms(delta):
	for p in platforms.get_children():
		p.position.x -= run_direction * speed * delta
		#if !exit_spawned:
		if run_direction < 0:
			if p.position.x - p.length * Globals.BLOCK_SIZE> 568:
				p.queue_free()
				spawn_next_platform()
		else:
			if p.position.x + p.length * Globals.BLOCK_SIZE < 0:
				p.queue_free()
				spawn_next_platform()

func spawn_next_platform():
	var with_obstacle = true
	var with_roadsign = false
	var p = platform.instance()
			
	var x = 0 if run_direction > 0 else 586

	var y = 360 - 2 * Globals.BLOCK_SIZE
	if platforms.get_child_count() > 0:
		var last_platform = platforms.get_child(platforms.get_child_count() - 1)
		x = last_platform.position.x + run_direction * last_platform.length * Globals.BLOCK_SIZE + run_direction * (randf() * (MAX_GAP_X - MIN_GAP_X) + MIN_GAP_X)
		y = last_platform.position.y + pow(-1, randi() % 2 + 1) * (randf() * (MAX_GAP_Y - MIN_GAP_Y) + MIN_GAP_Y)
		if y > 360 - Globals.BLOCK_SIZE:
			y = 360 - Globals.BLOCK_SIZE - (randf() * (MAX_GAP_Y - MIN_GAP_Y) + MIN_GAP_Y)
		if y < 40 + Globals.BLOCK_SIZE * 3:
			y = 40 + Globals.BLOCK_SIZE * 3 + (randf() * (MAX_GAP_Y - MIN_GAP_Y) + MIN_GAP_Y)
	
	if change_theme or spawn_exit or distance == 0:
		with_obstacle = false
		
	if change_theme:
		with_roadsign = true
		
	if platforms.get_child_count() == 0:
		with_roadsign = true	
	platforms.add_child(p)
	p.spawn_platform(x, y, with_obstacle, with_roadsign, change_theme, spawn_exit)
	change_theme = false
	

func rain():
	$RainTimer.wait_time = rand_range(15, 25)
	$World/CPUParticles2D.amount = 256 / pow(2, randi() % 3)
	$World/CPUParticles2D.emitting = true
	$RainTimer.start()
	raining = true

func _on_Player_died():
	enter_game_state(States.PAUSE)
	GameSounds.stop_music()

func _on_Game_Over():
	enter_game_state(States.GAME_OVER)
	GameSounds.play_effect(GameSounds.GAME_OVER)

func _on_Enemy_killed():
	GameSounds.play_effect(GameSounds.MONSTER_DIE)
	acc_factor -= 0.0225

func _on_ThemeChangeArea_entered():
	$World/ParallaxBackground.change_theme()
	current_stage += 1

func _on_ParallaxBackground_theme_changed():
	enter_game_state(States.PLAYING)
	background.reset()
	var new_color = randi() % player.textures.size()
	while player_variant == new_color:
		new_color = randi() % player.textures.size()
	player_variant = new_color
	player.get_node("Sprite").texture = player.textures[player_variant]
	$GUI.update_hud_color()
	next_level = distance + level_threshold * acc_factor
	$GUI.update_label($GUI/DebugLabel, "%s" % next_level)

func save_game_data():
	var f = File.new()
	f.open("user://highscore.sav", File.WRITE)
	f.store_var(Globals.game_data)
	f.close()	

func _on_Exit_spawned():
	exit_spawned = true

func _on_Exit_reached(_body):
	game_won = true
	player.enter_state(player.States.CELEBRATE)
	Globals.game_data["endless_unlock"] = true
	Globals.game_data["reverse_unlock"] = true
	GameSounds.stop_music()
	save_game_data()

func _on_Player_exited():
	enter_game_state(States.GAME_WON)


func _on_Exit_visible():
	player.velocity.x = speed * run_direction
	exit_visible = true

func _on_RainTimer_timeout():
	$World/CPUParticles2D.emitting = false
	raining = false
	last_rain_time = OS.get_unix_time()
