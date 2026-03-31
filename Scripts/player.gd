extends CharacterBody2D

var is_attacking = false
@export var speed = 400
@export var acceleration = 1500
@export var friction = 2500
@export var turn_acceleration = 2500

@onready var camera = $Camera2D

var facing_direction = Vector2.DOWN
var input_vector = Vector2.ZERO
var max_health = 6
var health = 6
var is_dead = false
var invincible = false
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay := 6000

func _ready():
	$SwordPivot/HitBox_Left/CollisionShape2D.disabled = true
	$SwordPivot/HitBox_Right/CollisionShape2D.disabled = true
	$SwordPivot/HitBox_Up/CollisionShape2D.disabled = true
	$SwordPivot/HitBox_Down/CollisionShape2D.disabled = true
	add_to_group("player")
	$Prompt/Open.modulate.a = 0.0

func enter_room():
	camera.enabled = false

func exit_room():
	camera.enabled = true

func start_attack():
	$AnimationPlayer.play("attack")
	is_attacking = true
	var anim_direction = ""
	if abs(facing_direction.x) > abs(facing_direction.y):
		if facing_direction.x > 0:
			anim_direction = "right"
		else:
				anim_direction = "left"
	else:
		if facing_direction.y > 0:
			anim_direction = "down"
		else:
			anim_direction = "up"
	$JohnP.play("attack_" + anim_direction)
	$JohnP.speed_scale = 2.0

func enable_hitbox():
	if abs(facing_direction.x) > abs(facing_direction.y):
		if facing_direction.x > 0:
			$SwordPivot/HitBox_Right/CollisionShape2D.disabled = false
		else:
			$SwordPivot/HitBox_Left/CollisionShape2D.disabled = false
	else:
		if facing_direction.y > 0:
			$SwordPivot/HitBox_Down/CollisionShape2D.disabled = false
		else:
			$SwordPivot/HitBox_Up/CollisionShape2D.disabled = false

func disable_hitbox():
	$SwordPivot/HitBox_Right/CollisionShape2D.disabled = true
	$SwordPivot/HitBox_Left/CollisionShape2D.disabled = true
	$SwordPivot/HitBox_Up/CollisionShape2D.disabled = true
	$SwordPivot/HitBox_Down/CollisionShape2D.disabled = true

func _on_animated_sprite_2d_animation_finished():
	if $JohnP.animation.begins_with("attack_"):
		is_attacking = false

func _physics_process(delta):
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()
	var input_direction = Vector2.ZERO
	input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
# X axis
	if input_direction.x != 0:
		var accel = acceleration
		if sign(input_direction.x) != sign(velocity.x) and velocity.x != 0:
			accel = turn_acceleration
		velocity.x = move_toward(velocity.x, input_direction.x * speed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
# Y axis
	if input_direction.y != 0:
		var accel = acceleration
		if sign(input_direction.y) != sign(velocity.y) and velocity.y != 0:
			accel = turn_acceleration
		velocity.y = move_toward(velocity.y, input_direction.y * speed, accel * delta)
	else:
		velocity.y = move_toward(velocity.y, 0, friction * delta)
	if input_direction != Vector2.ZERO:
		facing_direction = input_direction.normalized()
	velocity = velocity.limit_length(speed)
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
	move_and_slide()
	if not is_attacking:
		update_animation()
	if input_direction != Vector2.ZERO:
		facing_direction = input_direction.normalized()

func update_animation():
	var sprite = $JohnP
	var is_moving = velocity.length() > 0

	if abs(facing_direction.x) > abs(facing_direction.y):
		if facing_direction.x > 0:
			if is_moving:
				sprite.play("walk_right")
			else:
				sprite.play("idle_right")
		else:
			if is_moving:
				sprite.play("walk_left")
			else:
				sprite.play("idle_left")
	else:
		if facing_direction.y > 0:
			if is_moving:
				sprite.play("walk_down")
			else:
				sprite.play("idle_down")
		else:
			if is_moving:
				sprite.play("walk_up")
			else:
				sprite.play("idle_up")

func take_damage(amount: int, source_position: Vector2):
	if invincible or is_dead:
		return
	health -= amount
	var knock_dir = (global_position - source_position).normalized()
	knockback_velocity = knock_dir * 1000
	print("Player health:", health)
	if health <= 0:
		die()
	else:
		start_invincibility()

func start_invincibility():
	invincible = true
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.5).timeout
	modulate = Color(1,1,1)
	invincible = false

func die():
	var sprite = $JohnP
	if is_dead:
		return
	is_dead = true
	$Prompt/Open.visible = false
	sprite.play("death_forward")
	velocity = Vector2.ZERO
	get_tree().paused = true
	await get_tree().create_timer(2.0, true).timeout
	DeathUI.start_death(global_position)

func show_death_screen():
	get_tree().current_scene.get_node("DeathUI").show_death_screen()

func _on_hit_box_left_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(1, global_position)

func _on_hit_box_right_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(1, global_position)

func _on_hit_box_up_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(1, global_position)

func _on_hit_box_down_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(1, global_position)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		take_damage(1, body.global_position)

func show_interact_prompt():
	var prompt = $Prompt/Open
	var tween = create_tween()
	tween.tween_property(prompt, "modulate:a", 1.0, 0.05)

func hide_interact_prompt():
	var prompt = $Prompt/Open
	var tween = create_tween()
	tween.tween_property(prompt, "modulate:a", 0.0, 0.1)
