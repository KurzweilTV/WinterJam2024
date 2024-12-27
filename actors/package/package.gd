class_name Package
extends RigidBody2D

@onready var speedo: Label = $Label
@export var weight: float = 10.0
@export var is_package: bool = true

func _ready() -> void:
	mass = weight

func _physics_process(delta: float) -> void:
	speedo.text = str(linear_velocity.length())
