extends Node2D

const START_MENU : PackedScene = preload("res://scenes/game/start_menu.tscn")


func _load_game() -> void:
	get_tree().change_scene_to_packed(START_MENU)
