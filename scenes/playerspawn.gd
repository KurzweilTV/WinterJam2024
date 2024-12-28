class_name PlayerSpawn
extends Marker2D

var player_scene: PackedScene = preload("res://actors/player/prototype/player.tscn")

func _ready() -> void:
	Message.respawn_player.connect(Callable(self, "spawn_player"))
	spawn_player()

func spawn_player() -> void:
	var player = player_scene.instantiate()
	add_child(player)
	player.global_position = self.global_position
