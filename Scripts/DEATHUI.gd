extends CanvasLayer

@onready var overlay = $BlackOverlay
@onready var flame_holder = $FlameHolder
@onready var respawn_menu = $RespawnMenu
@onready var ghost = $JohnPGhost

func _ready():
	visible = false
	$FlameHolder/FlameDeath.visible = false
	respawn_menu.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Fade.modulate.a = 0.0

func start_death(player_position: Vector2):
	var screen_pos = get_viewport().get_canvas_transform() * player_position
	$JohnPGhost.global_position = screen_pos
	$JohnPGhost.play("death_forward")
	get_tree().paused = true
	visible = true
	flame_holder.global_position = player_position
	await get_tree().create_timer(2.0, true).timeout
	play_flame(player_position)

func play_flame(player_position):
	$JohnPGhost.play("death_Fstart")
	await get_tree().create_timer(1.0, true).timeout
	$FlameHolder/FlameDeath.visible = true
	var screen_pos = get_viewport().get_canvas_transform() * player_position
	$FlameHolder/FlameDeath.global_position = screen_pos
	var flame = flame_holder.get_node("FlameDeath")
	flame.play("flame_death")
	await flame.animation_finished
	flame.play("flame_smoke")
	await get_tree().create_timer(3.0, true).timeout
	show_menu()
	print("Showing Menu")

func show_menu():
	respawn_menu.visible = true
	var title = respawn_menu.get_node("TitleFlame")
	var title2 = respawn_menu.get_node("TitleExt")
	var buttons = respawn_menu.get_node("BottomContainer")
	title.modulate.a = 0.0
	title2.modulate.a = 0.0
	buttons.modulate.a = 0.0
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(title, "modulate:a", 1.0, 1.0)
	tween.tween_property(title2, "modulate:a", 1.0, 1.2)
	tween.tween_property(buttons, "modulate:a", 1.0, 0.8).set_delay(0.3)

func hide_menu():
	respawn_menu.visible = true
	var title = respawn_menu.get_node("TitleFlame")
	var title2 = respawn_menu.get_node("TitleExt")
	var buttons = respawn_menu.get_node("BottomContainer")
	title.modulate.a = 0.0
	title2.modulate.a = 0.0
	buttons.modulate.a = 0.0
	$FlameHolder/FlameDeath.visible = false

func reset():
	visible = false
	$Fade.modulate.a = 0

func _on_respawn_button_pressed() -> void:
	get_tree().paused = false
	var fade = $Fade
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(fade, "modulate:a", 1.0, 0.75)
	await tween.finished
	reset()
	hide_menu()
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	var fade = $Fade
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(fade, "modulate:a", 1.0, 2.0)
	await tween.finished
	GameState.skip_main_menu_intro = true
	reset()
	hide_menu()
	get_tree().change_scene_to_file("res://main_menu.tscn")
