extends Node

onready var distance_label = $GUI/ScoreLabel
onready var highscore_label = $GUI/HighscoreLabel
onready var continue_label = $GUI/ContinueLabel
onready var gameover_label = $GUI/GameOverLabel
onready var record_label = $GUI/NewRecordLabel
onready var speed_label = $GUI/SpeedLabel
onready var unlock_label = $GUI/UnlockLabel
onready var platforms = $World/Platforms
onready var player = $World/Player
onready var background = $World/ParallaxBackground

var platform = preload("res://Scenes/Platform.tscn")


var MAX_GAP_X = 150.0
var MIN_GAP_X = 60.0
var MAX_GAP_Y = 65.0
var MIN_GAP_Y = 35.0
var initial_speed = 250.0
var max_speed = 600
var speed = 0

var acc_factor = 1.0
var max_acc_factor
var acc_rate = 1 / initial_speed
var game_state
var previous_state
var change_theme = false
var spawn_exit = false
var exit_spawned = false
var exit_visible = false
var game_won = false
var raining = false
var first_unlock = true
var next_level = 2500
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
	for _i in range(3):
		spawn_next_platform()
		
	enter_game_state(States.IDLE)
	acc_factor = 1.0
	$GUI.update_label(highscore_label, "Best distance: %s" % int(best_distance))
	GameSounds.current_state = GameSounds.States.INGAME

func _input(event):
	if [States.IDLE, States.GAME_OVER, States.GAME_WON].has(game_state):
		if event is InputEventScreenTouch or event is InputEventMouseButton:
			if event.is_pressed():
				if game_state == States.IDLE:
					yield(get_tree().create_timer(0.1), "timeout")
					enter_game_state(States.PLAYING)
					player.enter_state(player.States.RUN)
					GameSounds.enter_state(GameSounds.States.INGAME)
				else:
					yield(get_tree().create_timer(0.1), "timeout")
					Globals.current_theme = 0
					GameSounds.stop_all_effects()
					get_tree().reload_current_scene()

func config():
	speed = initial_speed
	MAX_GAP_X = ceil(initial_speed * (sqrt(2 * player.jump_height / player.gravity) + sqrt(2 * (player.jump_height - 1.25 * MAX_GAP_Y) / player.gravity)))
	MIN_GAP_X = ceil(MAX_GAP_X / 2.25)
			
	if Globals.game_mode & 0b1:
		run_direction = -1
	
	if Globals.game_mode & 0b10:
		max_speed = INF

	if Globals.game_data["endless_unlock"] == true:
		first_unlock = false
	
	max_acc_factor = max_speed / initial_speed
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
			continue_label.text = "Press mouse button\nor tap screen to start running"
			#continue_label.set_anchors_and_margins_preset(Control.PRESET_CENTER_BOTTOM)
			continue_label.show()
		
		States.PAUSE:
			pass
		
		States.GAME_OVER:
			speed_label.hide()
			GameSounds.stop_music()
			show_ending_message()
			
		States.GAME_WON:
			speed_label.hide()
			GameSounds.stop_music()
			GameSounds.play_effect(GameSounds.GAME_WON)
			gameover_label.text = "You won!"
			show_ending_message()
			
	game_state = state

func _process(delta):
	if game_state == States.PLAYING and !exit_visible:
		background.update(speed, delta, run_direction)
	if Input.is_action_just_pressed("ui_cancel"):
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		player.prepare_to_quit = true
		Globals.current_theme = 0
		GameSounds.stop_music()
		save_game_data()
		SceneChanger.change_scene("res://Scenes/TitleScreen.tscn")
	
	if Input.is_action_just_pressed("pause"):
		if game_state != States.PAUSE:
			previous_state = game_state
			enter_game_state(States.PAUSE)
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			player.enter_state(player.States.PAUSE)
			$GUI/InfoPanel.show()
			
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
			
	

		acc_factor = clamp(acc_factor + acc_rate * delta, 1.0, max_acc_factor)
		speed = acc_factor * initial_speed
		if speed >= 500 and Globals.dash_effect and player.get_node("GhostTimer").is_stopped():
			player.get_node("GhostTimer").start()
		elif speed < 500 and !player.get_node("GhostTimer").is_stopped():
			player.get_node("GhostTimer").stop()
		
		
		MAX_GAP_X = min(Globals.BLOCK_SIZE * 10, ceil(initial_speed * (sqrt(2 * player.jump_height / player.gravity) + sqrt(2 * (player.jump_height - 1.25 * MAX_GAP_Y) / player.gravity))))
		MIN_GAP_X = min(floor(MAX_GAP_X / 2.25), Globals.BLOCK_SIZE * 4)
		
		if Globals.particle_effects and !raining and OS.get_unix_time() - last_rain_time > 20:
			if randf() < 0.125:
				rain()
			else:
				last_rain_time = OS.get_unix_time()

	
func show_ending_message():
			continue_label.text = "Press mouse button\nor tap screen to restart"
			#continue_label.set_anchors_and_margins_preset(Control.PRESET_CENTER_BOTTOM)
			continue_label.show()
			gameover_label.show()
			if game_won and first_unlock:
				unlock_label.show()
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
	
	if change_theme or spawn_exit or (distance == 0 and platforms.get_child_count() < 2):
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


func _on_Game_Over():
	enter_game_state(States.GAME_OVER)
	GameSounds.play_effect(GameSounds.GAME_OVER)

func _on_Enemy_killed():
	GameSounds.play_effect(GameSounds.MONSTER_DIE)
	acc_factor -= 0.0235
	if acc_factor < 1.0:
		acc_factor = 1.0

func _on_ThemeChangeArea_entered():
	$World/ParallaxBackground.change_theme()
	current_stage += 1
	acc_rate *= 1.025

func _on_ParallaxBackground_theme_changed():
	enter_game_state(States.PLAYING)
	background.reset()
	var new_color = randi() % player.textures.size()
	while player_variant == new_color:
		new_color = randi() % player.textures.size()
	player_variant = new_color
	player.get_node("Sprite").texture = player.textures[player_variant]
	$GUI.update_hud_color()
	next_level = distance + speed * 10


func save_game_data():
	var f = File.new()
	f.open_encrypted_with_pass("user://highscore.sav", File.WRITE, OS.get_unique_id())
	f.store_var(Globals.game_data)
	f.close()	

func _on_InfoPanel_closed():
	enter_game_state(previous_state)
	player.enter_state(player.previous_state)

func _on_Exit_spawned():
	exit_spawned = true

func _on_Exit_reached(_body):
	game_won = true
	speed = 0
	player.enter_state(player.States.CELEBRATE)
	Globals.game_data["endless_unlock"] = true
	Globals.game_data["reverse_unlock"] = true
	enter_game_state(States.PAUSE)
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
