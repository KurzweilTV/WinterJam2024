extends CharacterBody2D

@export var acceleration: float = 140.0
@export var drag: float = 2.0
@export var sink_force: float = 20.0
@export var wind_force: Vector2 = Vector2.ZERO
@export var max_tilt_degrees: float = 30.0
@export var tilt_speed: float = 0.3

var package: RigidBody2D = null
var joint: DampedSpringJoint2D = null

func _physics_process(delta: float) -> void:
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	input_dir = input_dir.normalized()

	# Movement
	velocity += input_dir * acceleration * delta
	velocity += wind_force * delta
	velocity.y += sink_force * delta
	velocity = velocity.move_toward(Vector2.ZERO, drag * delta)
	move_and_slide()

	# Tilt based on input
	var tween = create_tween()
	if Input.is_action_pressed("move_right"):
		tween.tween_property(self, "rotation_degrees", max_tilt_degrees, tilt_speed)
	if Input.is_action_pressed("move_left"):
		tween.tween_property(self, "rotation_degrees", -max_tilt_degrees, tilt_speed)
	else: tween.tween_property(self, "rotation_degrees", 0, tilt_speed)

	# Update rope position
	if package:
		$Rope.points = [global_position, package.global_position]

func grab_package(target: RigidBody2D) -> void:
	# Attach the package
	package = target
	joint = DampedSpringJoint2D.new()
	add_child(joint)
	joint.node_a = self.get_path()
	joint.node_b = package.get_path()
	joint.length = 100.0  # Adjust rope length
	joint.stiffness = 50.0  # Adjust stiffness
	joint.damping = 5.0  # Adjust damping

func release_package() -> void:
	# Detach the package
	if joint:
		remove_child(joint)
		joint.queue_free()
		joint = null
	package = null
