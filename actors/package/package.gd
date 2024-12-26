extends RigidBody2D

@export var weight: float = 10.0

func _ready() -> void:
	mass = weight
