@tool

class_name LevelTransition extends Node2D
enum SIDE {LEFT, RIGHT, TOP, BOTTOM}

@export_range(2, 12, 1, "or_greater") var size : int = 2 : 
	set(value):
		size = value
		apply_area_settings()

@export var location : SIDE = SIDE.LEFT :
	set(value):
		location = value
		apply_area_settings()

@export_file("*.tscn") var target_level : String = ""
@export var target_area_name : String = "LevelTransition"

@onready var area_2d: Area2D = $Area2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	area_2d.body_entered.connect(_on_player_entered)

func apply_area_settings() -> void:
	area_2d = get_node_or_null("Area2D")
	if not area_2d:
		return
	if location == SIDE.LEFT or location == SIDE.RIGHT:
		area_2d.scale.y = size
		if location == SIDE.LEFT:
			area_2d.scale.x = -1
		else:
			area_2d.scale.x = 1
	else:
		area_2d.scale.x = size
		if location == SIDE.LEFT:
			area_2d.scale.y = 1
		else:
			area_2d.scale.y = -1
	pass

func _on_player_entered(_n : Node2D):
	#Transition to the attached level
	SceneManager.transition_scene(target_level)
	print("Changed Scene!")
	print("Target Scene:", scene_file_path)
	pass
