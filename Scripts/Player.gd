extends KinematicBody2D

onready var jump_timer = $HalfJumpTimer
onready var game_manager = get_parent().get_parent()

var textures = [preload("res://Assets/Sprites/Warrior_Sheet-Effect-black.png"), preload("res://Assets/Sprites/Warrior_Sheet-Effect.png"), preload("res://Assets/Sprites/Warrior_Sheet-Effect-pink.png"), preload("res://Assets/Sprites/Warrior_Sheet-Effect-green.png"), preload("res://Assets/Sprites/Warrior_Sheet-Effect-gold.png")]

#var jump_sounds = [preload("res://Assets/Sounds/jump1.wav"), preload("res://Assets/Sounds/jump2.wav"), preload("res://Assets/Sounds/jump3.wav")]
#var attack_sounds = [preload("res://Assets/Sounds/attack1.wav"), preload("res://Assets/Sounds/attack2.wav"), preload("res://Assets/Sounds/attack3.wav")]
#var death_sounds = [preload("res://Assets/Sounds/damaged1.wav"), preload("res://Assets/Sounds/damaged2.wav"), preload("res://Assets/Sounds/damaged2.wav")]

export var gravity = 1250.0
export var jump_height = 95.0

var on_ground = false
var can_jump = false
var prepare_to_quit = false
var powerup = false

var velocity = Vector2(0, 0)
var max_velocity = 400
var current_state
var jump_power

signal enemy_killed
signal died
signal game_over
signal exited

enum States {
	IDLE,
	RUN,
	JUMP,
	FALL,
	SLIDE,
	ATTACK,
	DIE,
	CELEBRATE
}


func _ready():
	randomize()
	enter_state(States.IDLE)
	$AttackBox/CollisionShape2D.disabled = true
	jump_power = sqrt(2 * gravity * jump_height)

	
func _physics_process(delta):
	if game_manager.game_state != game_manager.States.PAUSE:
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, Vector2.UP)
		manage_states(delta)



func _on_HitBox_body_entered(_body):
	if current_state != States.DIE:
		enter_state(States.DIE)

func _on_HitBox_area_entered(area):
	if area.name == "Powerup":
		if !powerup:
			powerup = true
			area.get_parent().remove_child(area)
			call_deferred("add_child", area)#add_child(area)
			area.scale = Vector2(0.5, 0.5)
			area.position.y = -45
			area.position.x = -5
			area.name = "Powerup"
			GameSounds.play_effect(GameSounds.POWERUP)
		
	elif powerup:
		area.get_node("CollisionShape2D").set_deferred("disabled", true)
		yield(get_tree().create_timer(0.15), "timeout")
		powerup = false
		$Powerup.queue_free()
		
	elif current_state != States.DIE:
		enter_state(States.DIE)

func _on_AttackBox_area_entered(area):
	area.die()
	emit_signal("enemy_killed")

func enter_state(state):
	match state:
		States.IDLE:
			velocity = Vector2.ZERO
			$AnimationPlayer.set_speed_scale(1.0)
			$AnimationPlayer.play("Idle")
		States.RUN:
			$AnimationPlayer.set_speed_scale(game_manager.acc_factor)
			$AnimationPlayer.play("Run")
		States.SLIDE:
			GameSounds.play_effect(GameSounds.PLAYER_SLIDE)
			$AnimationPlayer.set_speed_scale(1.0)
			$AnimationPlayer.play("Slide")
			can_jump = false
		States.ATTACK:
			GameSounds.play_effect(GameSounds.PLAYER_ATTACK_1 + randi() % 3)
			GameSounds.play_effect(GameSounds.PLAYER_SWING)
			$AnimationPlayer.set_speed_scale(1.0)
			$AnimationPlayer.play("Attack")
			can_jump = false
		States.JUMP:
			GameSounds.play_effect(GameSounds.PLAYER_JUMP_1 + randi() % 3)
			$AnimationPlayer.set_speed_scale(1.0)
			$AnimationPlayer.play("Jump")
			can_jump = false
			jump_timer.start()
		States.FALL:
			$AnimationPlayer.set_speed_scale(1.0)
			$AnimationPlayer.play("Fall")
		States.DIE:
			if position.y < 360:
				GameSounds.play_effect(GameSounds.PLAYER_DIE_1 + randi() % 3)
				$AnimationPlayer.set_speed_scale(1.0)
				$AnimationPlayer.play("Die")
				emit_signal("died")
			else:
				if !prepare_to_quit:
					yield(get_tree().create_timer(0.2), "timeout")
					emit_signal("game_over")
		States.CELEBRATE:
			velocity = Vector2.ZERO
			$AnimationPlayer.set_speed_scale(1.0)
			$AnimationPlayer.play("Whirl")
			if has_node("Powerup"):
				$Powerup.queue_free()
			GameSounds.play_effect(GameSounds.WARPOUT)
			
	current_state = state

func manage_states(delta):
	match current_state:
		States.RUN:
			if !is_on_floor():
				enter_state(States.FALL)
			
			if Input.is_action_just_pressed("Attack"):
				enter_state(States.ATTACK)
				
			elif Input.is_action_just_pressed("Jump"):
				velocity.y = -jump_power
				enter_state(States.JUMP)
				
			elif Input.is_action_just_pressed("Slide"):
				enter_state(States.SLIDE)
		
		States.JUMP:
			if Input.is_action_just_released("Jump") and !jump_timer.is_stopped():
				velocity.y = -jump_power * 0.5 #(1 - jump_timer.time_left / jump_timer.wait_time)

			if velocity.y > 0:
				enter_state(States.FALL)
				
		States.FALL:
			if is_on_floor():
				if !game_manager.game_won:
					enter_state(States.RUN)
				else:
					enter_state(States.CELEBRATE)
					
			if position.y > 400:
				enter_state(States.DIE)
				
		States.SLIDE, States.ATTACK:
			if !is_on_floor():
				enter_state(States.FALL)
				
			if Input.is_action_just_pressed("Jump") and can_jump:
				velocity.y = -jump_power
				enter_state(States.JUMP)
		
#		States.CELEBRATE:
#			if is_on_floor():
#				velocity.y = (-jump_power / 1.5)
#				enter_state(States.JUMP)
			

func enable_jump():
	can_jump = true
			
func _on_AnimationPlayer_animation_finished(anim_name):		 
	if anim_name == "Slide" or anim_name == "Attack":
		if current_state != States.JUMP:
			enter_state(States.RUN)
			
	if anim_name == "Die":
		if !prepare_to_quit:
			yield(get_tree().create_timer(0.5), "timeout")
			emit_signal("game_over")

	if anim_name == "Whirl":
		emit_signal("exited")



