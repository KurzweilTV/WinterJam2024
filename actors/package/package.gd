class_name Package
extends RigidBody2D

@onready var speedo: Label = $Label

var impact_threshold = 200.0  # Minimum speed for collision
var is_colliding = false
var pre_impact_velocity: float = 0.0  # Velocity just before the collision
var can_score: bool = true
var is_carried: bool = false

func _physics_process(_delta: float) -> void:
	speedo.text = str(round(linear_velocity.length()))  # Debug: Current speed

	# Track the last significant velocity before collision
	if linear_velocity.length() > 0.1:  # Ignore extremely small velocities
		pre_impact_velocity = round(linear_velocity.length())
		can_score = false
		$CanScore.text = str(can_score)
	else: 
		if not is_carried: 
			can_score = true
			$CanScore.text = str(can_score)

func _on_body_entered(body) -> void:
	if pre_impact_velocity > impact_threshold and !is_colliding:
		print("Bonk! Collided with: ", body.name, " at speed: ", pre_impact_velocity)
		_handle_collision(body)
		is_colliding = true
		await get_tree().create_timer(0.5).timeout
		is_colliding = false

func _handle_collision(_collider: Object) -> void:
	pass

func set_carry(carried):
	is_carried = carried
