extends Node2D

@export var enemy_scene: PackedScene
@export var player_safe_radius: float = 200.0
@export var max_spawn_attempts: int = 3
@export var max_enemies: int = 5

@onready var spawn_area: Area2D = $SpawnArea
@onready var collision_shape: CollisionShape2D = $SpawnArea/CollisionShape2D
@onready var timer: Timer = $Timer
@onready var player: Node2D = get_node("/root/House1/Player")

func _ready():
	timer.timeout.connect(_on_timer_timeout)

func get_enemy_count() -> int:
	return get_tree().get_nodes_in_group("enemies").size()

func _on_timer_timeout():
	spawn_enemy()

func spawn_enemy():
	if get_enemy_count() >= max_enemies:
		print ("Max Enemies Reached!")
		return
	var spawn_position = get_random_point_in_area()
	if spawn_position == null:
		print("No valid spawn position found.")
		return
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_position
	get_tree().current_scene.add_child(enemy)
	print("Enemy count:", get_enemy_count())

func get_random_point_in_area():
	var rect_shape := collision_shape.shape as RectangleShape2D
	var size: Vector2 = rect_shape.size
	var half_size: Vector2 = size / 2.0
	for i in range(max_spawn_attempts):
		var local_point := Vector2(
			randf_range(-half_size.x, half_size.x),
			randf_range(-half_size.y, half_size.y)
		)
		var global_point := spawn_area.to_global(local_point)
		if global_point.distance_to(player.global_position) > player_safe_radius:
			return global_point
	return null
