extends CharacterBody2D

@export var speed:float  = 250
@export var turn_speed: float = 5.0
@export var acceleration: float = 2000
@export var friction: float = 1000
@export var turn_acceleration: float = 1200
@export var knockback_strength: float = 1500.0
@export var knockback_decay: float = 2000.0
@export var stun_duration: float = 0.0
@export var separation_radius: float = 150.0
@export var separation_strength: float = 200.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var stun_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
var current_angle: float = 0.0
var health = 5
var player = null
var facing_direction = Vector2.DOWN
var flash_tween: Tween
var is_dead = false

func _physics_process(delta):
	if is_dead:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
		move_and_slide()
		return
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	var movement_velocity = Vector2.ZERO
	if stun_timer > 0:
		stun_timer -= delta
	else:
		if is_instance_valid(player):
			var diff = player.global_position - global_position
			if diff.length() > 0:
				var raw_angle = diff.angle()
				var snapped_angle = round(raw_angle / (PI / 4)) * (PI / 4)
				current_angle = lerp_angle(current_angle, snapped_angle, turn_speed * delta)
				var direction = Vector2.RIGHT.rotated(current_angle)
				facing_direction = direction
				movement_velocity = direction * speed
	velocity = movement_velocity + knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
	apply_separation()
	move_and_slide()
	update_animation()
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)

func apply_separation():
	var push_vector = Vector2.ZERO
	for other in get_tree().get_nodes_in_group("enemies"):
		if other == self:
			continue
		var distance = global_position.distance_to(other.global_position)
		if distance < separation_radius and distance > 0:
			var direction = (global_position - other.global_position).normalized()
			var strength = (separation_radius - distance) / separation_radius
			push_vector += direction * strength
	velocity += push_vector * separation_strength

func _ready():
	$Death.visible = false
	$AnimatedSprite2D.material = $AnimatedSprite2D.material.duplicate()
	add_to_group("enemies")

func update_animation():
	var is_moving = velocity.length() > 0
	if is_dead:
		return
	if abs(facing_direction.x) > abs(facing_direction.y):
		if facing_direction.x > 0:
			if is_moving:
				if sprite.animation != "walk_right":
					sprite.play("walk_right")
			else:
				if sprite.animation != "idle_right":
					sprite.play("idle_right")
		else:
			if is_moving:
				if sprite.animation != "walk_left":
					sprite.play("walk_left")
			else:
				if sprite.animation != "idle_left":
					sprite.play("idle_left")
	else:
		if facing_direction.y > 0:
			if is_moving:
				if sprite.animation != "walk_down":
					sprite.play("walk_down")
			else:
				if sprite.animation != "idle_down":
					sprite.play("idle_down")
		else:
			if is_moving:
				if sprite.animation != "walk_up":
					sprite.play("walk_up")
			else:
				if sprite.animation != "idle_up":
					sprite.play("idle_up")

func take_damage(amount, source_position: Vector2):
	if is_dead:
		return
	health -=amount
	var kb_direction = (global_position - source_position).normalized()
	knockback_velocity = kb_direction * knockback_strength
	print("Enemy health:", health)
	stun_timer = stun_duration
	if flash_tween:
		flash_tween.kill()
	flash_tween = create_tween()
	sprite.material.set_shader_parameter("flash_amount", 10.0)
	var flashes := 5
	var step_time := 0.07
	for i in range(flashes):
		flash_tween.tween_property(
			sprite.material,
			"shader_parameter/flash_amount",
			0.8,
			0.0
		)
		flash_tween.tween_property(
			sprite.material,
			"shader_parameter/flash_amount",
			0.0,
			step_time
		)
	flash_tween.tween_property(
		sprite.material,
		"shader_parameter/flash_amount",
		0.8,
		0.0
	)
	flash_tween.tween_property(
		sprite.material,
		"shader_parameter/flash_amount",
		0.0,
		0.15
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if health <= 0:
		die(source_position)

func die(source_position):
	if is_dead:
		return
	print("Enemy Died!")
	sprite = $Death
	is_dead = true
	knockback_decay *= 0.9
	var kb_direction = (global_position - source_position).normalized()
	knockback_velocity = kb_direction * (knockback_strength * 0.75)
	set_collision_mask(0)
	$Death.visible = true
	sprite.play ("death")
	await sprite.animation_finished
	queue_free()
