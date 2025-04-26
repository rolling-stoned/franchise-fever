extends Control

func _on_NewGame_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/team_select.tscn")

func _on_LoadGame_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/load_game.tscn")

func _on_Options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")

func _on_Quit_pressed() -> void:
	get_tree().quit()
