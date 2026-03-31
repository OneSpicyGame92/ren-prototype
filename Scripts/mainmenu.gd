extends Control

func _ready():
	get_tree().paused = false
	$Title.modulate.a = 0.0
	$CenterContainer/VBoxContainer.modulate.a = 0.0
	$FlameAnim.visible = false
	$Fade.modulate.a = 0.0
	if GameState.skip_main_menu_intro:
		load_instant()
		fade_from_black()
		GameState.skip_main_menu_intro = false
	else:
		on_start()

func on_start():
	await get_tree().create_timer(3.0, true).timeout
	$FlameAnim.visible = true
	$FlameAnim.play("flame_start")
	await $FlameAnim.animation_finished
	$FlameAnim.play("flame_on")
	await get_tree().create_timer(3.0, true).timeout
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Title, "modulate:a", 0.8, 2.0)
	tween.tween_property($CenterContainer/VBoxContainer, "modulate:a", 1.0, 0.8).set_delay(1.0)

func load_instant():
	$Title.modulate.a = 0.8
	$CenterContainer/VBoxContainer.modulate.a = 1.0
	$FlameAnim.visible = true
	$FlameAnim.play("flame_on")

func fade_from_black():
	var fade = $Fade
	fade.modulate.a = 1.0
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(fade, "modulate:a", 0.0, 1.0)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Rooms/house_1.tscn")

func _on_options_pressed() -> void:
	print("Options pressed")

func _on_exit_pressed() -> void:
	get_tree().quit()
