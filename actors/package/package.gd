class_name Package
extends RigidBody2D

@onready var speedo: Label = $Label
@onready var light: PointLight2D = $IndicatorLight/PointLight2D
@onready var health_bar: ProgressBar = %HealthBar

var package_hp : float = 1000
var impact_threshold = 150.0  # Minimum speed for collision
var pre_impact_velocity: float = 0.0  # Velocity just before the collision
var is_colliding = false
var can_score: bool = true
var is_carried: bool = false

func _ready() -> void:
	%HealthBar.max_value = package_hp
	%HealthBar.value = package_hp

func _physics_process(_delta: float) -> void:
	var current_speed = round(linear_velocity.length())
	speedo.text = str(current_speed) # Debug: Current speed
	check_safe(current_speed)
	
	# Track the last significant velocity before collision
	if current_speed > 0.1:  # Ignore extremely small velocities
		pre_impact_velocity = round(linear_velocity.length())
		can_score = false
	else: 
		if not is_carried: 
			can_score = true

func _on_body_entered(_body) -> void:
	if pre_impact_velocity > impact_threshold and !is_colliding:
		#print("Bonk! Collided with: ", body.name, " at speed: ", pre_impact_velocity)
		_handle_collision(pre_impact_velocity)
		is_colliding = true
		await get_tree().create_timer(0.5).timeout
		is_colliding = false

func _handle_collision(speed: float) -> void:
	package_hp -= speed
	%HealthBar.take_damage(package_hp)
	if package_hp <= 0:
		Message.emit_signal("package_broken")
		self.queue_free()

func set_carry(carried):
	is_carried = carried

func check_safe(speed) -> void:
	if speed > impact_threshold and is_carried:
		light.color = Color.RED
	elif speed < impact_threshold and is_carried: 
		light.color = Color.GREEN
	else: light.color = Color.NAVY_BLUE
