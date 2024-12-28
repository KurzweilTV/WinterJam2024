extends CharacterBody2D

@export_category("Flight")
@export var acceleration: float = 140.0
@export var drag: float = 5.0
@export var wind_force: Vector2 = Vector2.ZERO
@export_category("Gameplay")
@export var health : float = 100.0
@export var collision_damage : int = 50

var death_scene : PackedScene = preload("res://actors/player/explosion/player_death.tscn")
var is_alive : bool = true
var max_tilt_degrees: float = 25.0
var tilt_speed: float = 0.3
var pixels_per_meter = 50 #scale for what a meter is
var package: RigidBody2D = null
var joint: DampedSpringJoint2D = null
var base_sink_force: float = 10.0
var sink_force: float = base_sink_force
var carried_mass: float = 0.0 :
	set(value):
		carried_mass = value
		sink_force = (base_sink_force * value) * 0.8

func _ready() -> void:
	$Sprite2D.show()
	is_alive = true

func _physics_process(delta: float) -> void:
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
		$Sprite2D.flip_h = false
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
		$Sprite2D.flip_h = true
	input_dir = input_dir.normalized()

	# Movementa
	velocity += input_dir * acceleration * delta
	velocity += wind_force * delta
	velocity.y += sink_force * delta
	if is_alive:
		velocity = velocity.move_toward(Vector2.ZERO, drag * delta)

	var collision_info = move_and_collide(velocity * delta)

	if collision_info: # bounce if you hit a building
		take_damage(collision_damage)
		velocity = velocity.bounce(collision_info.get_normal()) / 2
		

	# Tilt when moving for extra juice
	var tween = create_tween()
	if Input.is_action_pressed("move_right"):
		tween.tween_property($Sprite2D, "rotation_degrees", max_tilt_degrees, tilt_speed)
	if Input.is_action_pressed("move_left"):
		tween.tween_property($Sprite2D, "rotation_degrees", -max_tilt_degrees, tilt_speed)
	else: tween.tween_property($Sprite2D, "rotation_degrees", 0, tilt_speed)

	# Update rope position
	if package:
		var start = self.to_local($Anchor.global_position)
		var end = self.to_local(package.global_position)
		var mid = (start + end) / 2
		var sag_amount = 15.0
		mid.y += sag_amount  

		$Rope.points = [start, mid, end]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("drop") and package:
		release_package()

func grab_package(target: RigidBody2D) -> void:
	# Attach the package
	package = target
	joint = DampedSpringJoint2D.new()
	add_child(joint)
	joint.node_a = self.get_path()
	joint.node_b = package.get_path()
	joint.length = 10.0  # Adjust rope length
	joint.stiffness = 100.0  # Adjust stiffness
	joint.damping = 2.0  # Adjust damping
	carried_mass = package.mass
	package.set_carry(true)

func release_package() -> void:
	package.set_carry(false)
	carried_mass = 0.0
	if joint:
		remove_child(joint)
		joint.queue_free()
		joint = null
	package = null
	$Rope.points = []

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 50:
		%DamageEffect.emitting = true
	if health <= 0:
		var death_anim = death_scene.instantiate()
		get_parent().add_child(death_anim)
		death_anim.global_position = global_position
		self.queue_free()
		
# signal functions
func _on_pickup_range_body_entered(body: Node2D) -> void:
	if package == null and body is Package:
		grab_package(body)

func _on_player_tick() -> void: # update UI on timer
	# Handle Altitude
	var meters_per_pixel = 1.0 / pixels_per_meter
	var alt = (global_position.y * -meters_per_pixel) + 100 # offset for starting on a building
	if alt > 121.0:
		wind_force.y = 300
		%AltLabel.modulate = Color.RED
	else: 
		wind_force.y = 0
		%AltLabel.modulate = Color.WHITE
	%AltLabel.text = str("%sm") % snapped(alt, 0.1)
