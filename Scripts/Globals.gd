extends Node

const BLOCK_SIZE = 32

var current_theme = 0
var game_mode = GameModes.NORMAL
var version = "0.9.1"

enum GameModes {
	NORMAL,
	REVERSE,
	ENDLESS,
	ENDLESS_REVERSE
}

var game_data = {
	"high_score_0": 0,
	"high_score_1": 0,
	"high_score_2": 0,
	"high_score_3": 0,
	"endless_unlock": false,
	"reverse_unlock": false,
	"game_mode": GameModes.NORMAL,
	"version": version
}

var save_loaded = false
var particle_effects = true
var dash_effect = true

const rock = preload("res://Assets/Obstacles/rock.png")
const crate = preload("res://Assets/Obstacles/crate.png")
const grave = preload("res://Assets/Obstacles/grave.png")
const stump = preload("res://Assets/Obstacles/stump.png")
const bush = preload("res://Assets/Obstacles/Bush.png")
const green_hill = preload("res://Assets/Obstacles/hill.png")
const green_flatstone = preload("res://Assets/Obstacles/flatstone.png")
const cave_flatrock = preload("res://Assets/Obstacles/CaveFlatRock.png")
const cave_stump = preload("res://Assets/Obstacles/CaveStump.png")
const cave_crate = preload("res://Assets/Obstacles/CaveCrate.png")
const green_wall = preload("res://Assets/Obstacles/wall.png")
const green_wall2 = preload("res://Assets/Obstacles/GreenWall2.png")
const high_stumps = preload("res://Assets/Obstacles/ForestHighStumps.png")
const cave_wall = preload("res://Assets/Obstacles/CaveWall.png")
const cave_wall2 = preload("res://Assets/Obstacles/CaveWall2.png")
const cave_wall3 = preload("res://Assets/Obstacles/CaveWall3.png")
const barell = preload("res://Assets/Obstacles/VillageBarrel.png")
const fence = preload("res://Assets/Obstacles/VillageFence.png")
const logs = preload("res://Assets/Obstacles/VillageLogs.png")
const sack = preload("res://Assets/Obstacles/VillageSack.png")
const shroom = preload("res://Assets/Obstacles/VillageMushroom.png")
const village_wall = preload("res://Assets/Obstacles/VillageWall.png")
const village_wall2 = preload("res://Assets/Obstacles/VillageWall2.png")
const village_sign = preload("res://Assets/Obstacles/VillageSign.png")
const totem = preload("res://Assets/Obstacles/totem.png")
const dark_stump = preload("res://Assets/Obstacles/DarkStump.png")
const dark_spikes = preload("res://Assets/Obstacles/DarkSpikes.png")
const dark_blob = preload("res://Assets/Obstacles/DarkBlob.png")
const dark_wall = preload("res://Assets/Obstacles/DarkWall.png")
const dark_forest_stump = preload("res://Assets/Obstacles/DarkForestStump.png")
const dark_forest_branch = preload("res://Assets/Obstacles/DarkForestBranch.png")
const dark_forest_wall = preload("res://Assets/Obstacles/DarkForestWall.png")
const dark_forest_rock = preload("res://Assets/Obstacles/DarkForestRock.png")
const dark_forest_spikes = preload("res://Assets/Obstacles/DarkForestSpikes.png")
const dark_forest_tree = preload("res://Assets/Obstacles/DarkForestTree.png")

const themes = {
	0: {
		"textures": [preload("res://Assets/Backgrounds/ForestBackground1.png"), preload("res://Assets/Backgrounds/ForestBackground2.png"), preload("res://Assets/Backgrounds/ForestBackground3.png"),
	preload("res://Assets/Backgrounds/ForestBackground4.png")],
		
		"y-position": [40, 40, 40, 40],
		"modulate": [Color(0.3, 0.3, 0.3), Color(0.3, 0.3, 0.3), Color(0.3, 0.3, 0.3), Color(0.5, 0.5, 0.5)],
		"bkg-scale": 1,
		"hud-colors": [Color(0.08, 0.1, 0.09), Color(0.15, 0.18, 0.17)],
		"left-block": preload("res://Assets/Ground Tiles/GrassLeft2.png"),
		"mid-block": [preload("res://Assets/Ground Tiles/GrassMid12.png"), preload("res://Assets/Ground Tiles/GrassMid22.png")],
		"right-block": preload("res://Assets/Ground Tiles/GrassRight2.png"),
		"obstacles-low": [green_flatstone, stump, green_hill],
		"obstacles-offset": 5,
		"obstacles-high": {
			"textures": [green_wall, high_stumps, green_wall2],
			"positions": [Vector2(0, -160), Vector2(-25, -143), Vector2(-0, -170)],
			"scale": [Vector2(1, 1), Vector2(1, 1), Vector2(0.8, 1)]
		}		
	},
	
	1: {
		"textures": [preload("res://Assets/Backgrounds/CaveBackground1.png"), 
		preload("res://Assets/Backgrounds/CaveBackground2.png"), preload("res://Assets/Backgrounds/CaveBackground3.png"), 
		preload("res://Assets/Backgrounds/CaveBackground4.png")],
		"y-position": [10, 10, 10, 10],
		"bkg-scale": 1,
		"modulate": [Color(1, 1, 1), Color(1, 1, 1), Color(1, 1, 1), Color(1,1,1,1)],
		"hud-colors": [Color(0.15, 0.13, 0.16), Color(0.22, 0.26, 0.31)],
		"left-block": preload("res://Assets/Ground Tiles/CaveLeft.png"),
		"mid-block": [preload("res://Assets/Ground Tiles/CaveMid1.png"), preload("res://Assets/Ground Tiles/CaveMid2.png")],
		"right-block": preload("res://Assets/Ground Tiles/CaveRight.png"),
		"obstacles-low": [cave_flatrock, cave_stump, grave, cave_crate],
		"obstacles-offset": 0,
		"obstacles-high": {
			"textures": [cave_wall, cave_wall2, cave_wall3],
			"positions": [Vector2(0, -165), Vector2(0, -195), Vector2(4, -145)],
			"scale": [Vector2(1, 1), Vector2(1, 1), Vector2(1, 1)]
		}
	},
	
	2: {
		"textures": [preload("res://Assets/Backgrounds/VillageBackground1.png"), 
		preload("res://Assets/Backgrounds/VillageBackground2.png"),
		preload("res://Assets/Backgrounds/VillageBackground3.png")],
		
		"y-position": [0, 120, 160],
		"bkg-scale": 1,
		"modulate": [Color(1, 1, 1), Color(1, 1, 1), Color(1, 1, 1), Color(1,1,1,1)],
		"hud-colors": [Color(0.1, 0.15, 0.17), Color(0.18, 0.27, 0.3)],
		"left-block": preload("res://Assets/Ground Tiles/GroundLeft.png"),
		"mid-block": [preload("res://Assets/Ground Tiles/GroundMid.png")],
		"right-block": preload("res://Assets/Ground Tiles/GroundRight.png"),
		"obstacles-low": [crate, sack, logs, barell, rock, shroom],
		"obstacles-offset": 0,
		"obstacles-high": {
			"textures": [village_wall, village_sign, village_wall2],
			"positions": [Vector2(0, -155), Vector2(0, -115), Vector2(0, -145)],
			"scale": [Vector2(1, 1), Vector2(1, 1), Vector2(1, 1)]
		}
	},
	
	3: {
		"textures": [preload("res://Assets/Backgrounds/DarkBackground1.png"), 
		preload("res://Assets/Backgrounds/DarkBackground2.png"), preload("res://Assets/Backgrounds/DarkBackground3.png"), 
		preload("res://Assets/Backgrounds/DarkBackground4.png")],
		"y-position": [40, -40, -25, -10],
		"bkg-scale": 1.4,
		"modulate": [Color(1, 1, 1), Color(1, 1, 1), Color(1, 1, 1), Color(1,1,1,1)],
		"hud-colors": [Color(0.16, 0.07, 0.07), Color(0.25, 0.11, 0.12)],
		"left-block": preload("res://Assets/Ground Tiles/DarkLeft.png"),
		"mid-block": [preload("res://Assets/Ground Tiles/DarkMid1.png"), preload("res://Assets/Ground Tiles/DarkMid2.png")],
		"right-block": preload("res://Assets/Ground Tiles/DarkRight.png"),
		"obstacles-low": [totem, dark_stump, grave, rock, dark_spikes],
		"obstacles-offset": 5,
		"obstacles-high": {
			"textures": [dark_wall, dark_blob],
			"positions": [Vector2(0, -165), Vector2(-18, -155)],
			"scale": [Vector2(1, 1), Vector2(1, 1)]
		}
	},

	4: {
		"textures": [preload("res://Assets/Backgrounds/DarkForestBackground4.png"), 
		preload("res://Assets/Backgrounds/DarkForestBackground2.png"), preload("res://Assets/Backgrounds/DarkForestBackground3.png"), 
		preload("res://Assets/Backgrounds/DarkForestBackground1.png")],
		"y-position": [52, 52, 52, 92],
		"bkg-scale": 1.4,
		"modulate": [Color(1, 1, 1), Color(1, 1, 1), Color(1, 1, 1), Color(1,1,1,1)],
		"hud-colors": [Color(0.16, 0.07, 0.07), Color(0.25, 0.11, 0.12)],
		"left-block": preload("res://Assets/Ground Tiles/DarkForestLeft.png"),
		"mid-block": [preload("res://Assets/Ground Tiles/DarkForestMid1.png"), preload("res://Assets/Ground Tiles/DarkForestMid2.png")],
		"right-block": preload("res://Assets/Ground Tiles/DarkForestRight.png"),
		"obstacles-low": [dark_forest_rock, dark_forest_stump, dark_forest_branch, dark_forest_spikes],
		"obstacles-offset": 0,
		"obstacles-high": {
			"textures": [dark_forest_wall, dark_forest_tree],
			"positions": [Vector2(0, -150), Vector2(5, -175)],
			"scale": [Vector2(1, 1), Vector2(1, 1)]
		}
	}
}
