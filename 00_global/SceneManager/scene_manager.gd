extends CanvasLayer



func transition_scene(new_scene : String) -> void:
	
	get_tree().change_scene_to_file(new_scene)
	
	pass
