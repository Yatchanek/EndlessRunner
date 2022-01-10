extends Node2D

onready var game_manager = get_parent().get_parent().get_parent()
var obstacle_chance

var obstacles = [preload("res://Scenes/ObstacleHigh.tscn"), 
preload("res://Scenes/ObstacleLow.tscn"), [preload("res://Scenes/Goblin.tscn"), preload("res://Scenes/Skeleton.tscn"), preload("res://Scenes/FlyingEye.tscn")] ]

var left_corner = Globals.themes[Globals.current_theme]["left-block"]
var right_corner = Globals.themes[Globals.current_theme]["right-block"]
var middle_block = Globals.themes[Globals.current_theme]["mid-block"]


const MIN_LENGTH = 12
var MAX_LENGTH = 50
var MIN_OBSTACLE_GAP = 8

var length = 0
var obstacle_locations = []
signal theme_changed
signal exit_spawned


func _ready():
	randomize()
	obstacle_chance = 75 * game_manager.acc_factor
	MAX_LENGTH = floor(MAX_LENGTH * game_manager.acc_factor)
	MIN_OBSTACLE_GAP = floor(MIN_OBSTACLE_GAP * game_manager.acc_factor  - game_manager.current_stage)
	if MIN_OBSTACLE_GAP < 8:
		MIN_OBSTACLE_GAP = 8

func spawn_platform(x, y, with_obstacle, with_roadsign, change_theme, spawn_exit):
	length = MIN_LENGTH + randi() % int(MAX_LENGTH - MIN_LENGTH)
	if change_theme or spawn_exit:
		length = MAX_LENGTH
	
	var left = Sprite.new()
	left.texture = left_corner
	left.centered = false
	left.position = Vector2(0,0)
	add_child(left)
	
	for i in range(length - 2):
		var block = Sprite.new()
		
		block.texture = middle_block[randi() % middle_block.size()]
		block.centered = false
		block.position = Vector2(Globals.BLOCK_SIZE + i * Globals.BLOCK_SIZE, 0)
		add_child(block)

	var right = Sprite.new()
	right.texture = right_corner
	right.centered = false
	right.position = Vector2(Globals.BLOCK_SIZE * (length - 1), 0)
	add_child(right)
	
	$StaticBody2D/CollisionShape2D.shape.extents.x = (Globals.BLOCK_SIZE * 0.5) * length
	$StaticBody2D/CollisionShape2D.shape.extents.y = (Globals.BLOCK_SIZE * 0.5)
	$StaticBody2D/CollisionShape2D.position.x = $StaticBody2D/CollisionShape2D.shape.extents.x
	$StaticBody2D/CollisionShape2D.position.y = $StaticBody2D/CollisionShape2D.shape.extents.y + 5

	position = Vector2(x, y)
	scale.x = game_manager.run_direction
		
	if with_obstacle:
		generate_obstacles()
	
	if change_theme:
		$ThemeChanger/CollisionShape2D.set_deferred("disabled", false)
		connect("theme_changed", game_manager, "_on_ThemeChangeArea_entered")
	
	if with_roadsign:
		place_roadsign()
		
	if spawn_exit:
		var exit = load("res://Scenes/Exit.tscn").instance()
		exit.position = Vector2(Globals.BLOCK_SIZE * (length - 3), 0)
		add_child(exit)
		exit.dir = scale.x
		exit.connect("body_entered", game_manager, "_on_Exit_reached")
		connect("exit_spawned", game_manager, "_on_Exit_spawned")
		exit.connect("exit_visible", game_manager, "_on_Exit_visible")		
		emit_signal("exit_spawned")
	
	if game_manager.distance > 2000 and randf() < 0.025:
		generate_powerup()
		
func generate_powerup():
	var tries = 1
	var collides = true
	var x = rand_range(0, length * Globals.BLOCK_SIZE + rand_range(50, 100))
	while collides:
		collides = false
		for location in obstacle_locations:
			if abs(x - location) < Globals.BLOCK_SIZE * 3:
				collides = true
				tries += 1
				x = rand_range(0, length * Globals.BLOCK_SIZE + rand_range(50, 100))
				break
		if tries > 10:
			print("Failed")
			break
	var powerup = load("res://Scenes/Powerup.tscn").instance()
	add_child(powerup)
	powerup.position.x = x
	powerup.position.y = rand_range(-60, -85)
	

func generate_obstacles():
	if length <= 14:
		return
	var obstacle_count = 0
	var start = floor(6 * game_manager.acc_factor) + randi() % 10
	if start > length - 7:
		start = length - 7
	while randi() % 100 < obstacle_chance - 0.2 * obstacle_count:
		add_obstacle(start)
		obstacle_count += 1
		start = start + MIN_OBSTACLE_GAP + randi() % 10
		if start > length - 7:
			break

func add_obstacle(start):
		var o
		if randf() < 0.80:
			o = obstacles[randi() % 2].instance()
		else:
			var index = randi() % obstacles[2].size()
			o = obstacles[2][index].instance()
			o.type = index
		add_child(o)
		o.position.x = Globals.BLOCK_SIZE * start
		o.position.y = Globals.themes[Globals.current_theme]["obstacles-offset"]
		obstacle_locations.push_back(o.position.x)

func place_roadsign():
	var roadsign = Sprite.new()
	roadsign.texture = load("res://Assets/Obstacles/RoadSign.png")
	roadsign.centered = 0
	roadsign.offset.y = -30
	add_child(roadsign)
	roadsign.position.y = Globals.themes[Globals.current_theme]["obstacles-offset"]
	roadsign.position.x = 100


func _on_ThemeChanger_body_entered(_body):
	emit_signal("theme_changed")
