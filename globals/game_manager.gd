extends Node

var pause_scene : PackedScene = preload("res://scenes/game/Pause_Screen.tscn")
var gamewon_scene : PackedScene = preload("res://scenes/game/game_won.tscn")
var game_paused : bool = false
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
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause") and not game_paused:
		pause_game()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_wingame"):
		game_won()
	
func pause_game() -> void:
	var pause_screen = pause_scene.instantiate()
	get_parent().add_child(pause_screen)
	game_paused = true
	get_tree().paused = true
