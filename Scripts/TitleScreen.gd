extends Control

onready var button_container = $CanvasLayer2/Control/CenterContainer/ButtonContainer
onready var ok_button = $CanvasLayer2/Control/InfoPanel/OKButton
onready var credits_button = $CanvasLayer2/Control/CreditsButton

var running_left = false
var acc_factor = 1.0
var speed = 250
var current_state = States.IDLE

enum States {
	IDLE,
	RUNNING,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	for button in get_tree().get_nodes_in_group("Buttons"):
		button.connect("pressed", self, "_on_Button_pressed", [button])
	$AnimationPlayer.play("Idle")
	$AnimTimer.wait_time = randi() % 5 + 5
	$AnimTimer.start()
	$CanvasLayer2/Control/VersionLabel.text = "Version %s" % Globals.version
	if GameSounds.current_state != GameSounds.States.TITLE_SCREEN:
		GameSounds.enter_state(GameSounds.States.TITLE_SCREEN)
	if !Globals.save_loaded:
		load_game_data()

func _process(delta):
	match current_state:
		States.IDLE:
			pass
		States.RUNNING:
			$ParallaxBackground.scroll_offset.x -= speed * delta
			for ground_tile in get_tree().get_nodes_in_group("Ground"):
				ground_tile.position.x -= speed * delta
				if ground_tile.position.x < -654:
					ground_tile.position.x += 1308

func load_game_data():
	var f = File.new()
	if !f.file_exists("user://highscore.sav"):
		create_game_data()
	else:
		f.open_encrypted_with_pass("user://highscore.sav", File.READ, OS.get_unique_id())
		var data = f.get_var()
		f.close()
		if typeof(data) == TYPE_DICTIONARY and data.has_all(["high_score_0", "high_score_1", "high_score_2", "high_score_3", "endless_unlock", "reverse_unlock", "game_mode", "version"]):
			if data["version"][0] != Globals.game_data["version"][0] or data["version"][2] != Globals.game_data["version"][2]:
				create_game_data()		
			else:
				Globals.game_data = data
				Globals.game_data["version"] = Globals.version
	Globals.game_mode = Globals.game_data["game_mode"]
	Globals.save_loaded = true

func create_game_data():
	$CanvasLayer2/Control/InfoPanel.show()
	save_game_data()
	
func save_game_data():
	var f = File.new()
	f.open_encrypted_with_pass("user://highscore.sav", File.WRITE, OS.get_unique_id())
	f.store_var(Globals.game_data)
	f.close()



func enter_state(state):
	match state:
		States.IDLE:
			speed = 0
			$AnimationPlayer.set_speed_scale(1.0)
			$AnimationPlayer.play("Idle")
		States.RUNNING:
			speed = randi() % 100 + 250
			acc_factor = speed / 250.0
			$AnimationPlayer.set_speed_scale(acc_factor)
			$AnimationPlayer.play("Run")
	current_state = state
	
func _on_Button_pressed(button):
	match button.name:
		"StartButton":
			save_game_data()
			SceneChanger.change_scene("res://Scenes/Main.tscn")
			GameSounds.stop_music()
		"InstructionsButton":
			SceneChanger.change_scene("res://Scenes/InstructionsScreen.tscn")
		"OptionsButton":
			SceneChanger.change_scene("res://Scenes/OptionsScreen.tscn")
		"CreditsButton":
			SceneChanger.change_scene("res://Scenes/Credits.tscn")
		"OKButton":
			$CanvasLayer2/Control/InfoPanel.hide()
	
	if button.name != "OKButton":		
		for button in button_container.get_children():
			button.disabled = true


func _on_AnimTimer_timeout():
	if current_state == States.IDLE:
		enter_state(States.RUNNING)
	else:
		enter_state(States.IDLE)
	$AnimTimer.wait_time = randi() % 5 + 5
	$AnimTimer.start()



func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Slide" or anim_name == "Attack":
		$AnimationPlayer.play("Run")
		$AnimTimer.wait_time = randi() % 2 + 2
		$AnimTimer.start()
	if anim_name == "Attack2":
		$AnimationPlayer.play("Idle")
		$AnimTimer.wait_time = randi() % 2 + 2
		$AnimTimer.start()


func _on_ActionTimer_timeout():
	if current_state == States.IDLE:
		$AnimationPlayer.play("Attack2")
	else:
		var chance = randi() % 100
		if chance <= 7:
			$AnimationPlayer.play("Slide")
		else:
			$AnimationPlayer.play("Attack")

	$ActionTimer.wait_time = rand_range(5, 10)
	$ActionTimer.start()
