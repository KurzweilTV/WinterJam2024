class_name Package
extends RigidBody2D

@onready var speedo: Label = $Label
@onready var light: PointLight2D = $IndicatorLight/PointLight2D
@onready var health_bar: ProgressBar = %HealthBar
@onready var cracks: AnimatedSprite2D = $DamageArt

var max_package_hp: float = 1000.0
var package_hp : float = 1000
var impact_threshold = 200.0  # Minimum speed for collision
var pre_impact_velocity: float = 0.0  # Velocity just before the collision
var is_colliding = false
var can_score: bool = true
var is_carried: bool = false
func _ready() -> void:
	Game.package_total += 1
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
	%DamageParticles.emitting = true
	package_hp -= (speed * 0.7) #Nerf Package Damage here
	package_hp = clamp(package_hp, 0, max_package_hp) 
	
	var hp_percentage = package_hp / max_package_hp
	
	if hp_percentage > 0.9:
		cracks.frame = 0  # No visible damage
	elif hp_percentage > 0.50:
		cracks.frame = 1  # Minor damage
	elif hp_percentage > 0.25:
		cracks.frame = 2  # Moderate damage
	else:
		cracks.frame = 3  # Severe damage
	
	%HealthBar.take_damage(package_hp)
	if package_hp <= 0:
		Message.emit_signal("package_broken")
		is_carried = false
		$Art.hide()
		$DamageArt.hide()
		%DamageParticles.amount = 50
		%DamageParticles.emitting = true
		await get_tree().create_timer(3).timeout
		self.queue_free()

func set_carry(carried):
	is_carried = carried

func check_safe(speed) -> void:
	if speed > impact_threshold and is_carried:
		light.color = Color.RED
	elif speed < impact_threshold and is_carried: 
		light.color = Color.GREEN
	else: light.color = Color.NAVY_BLUE
