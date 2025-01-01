extends Node

var gamewon_scene : PackedScene = preload("res://scenes/game/game_won.tscn")
var score : int
var package_total : int = 0
var package_collected : int 

func check_victory() -> void:
	if package_collected == package_total:
		game_won()

func game_won() -> void:
	await get_tree().create_timer(2).timeout
	var game_won_ui = gamewon_scene.instantiate()
	get_parent().add_child(game_won_ui)
	game_won_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_wingame"):
		game_won()
