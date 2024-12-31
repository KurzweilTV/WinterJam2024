extends Area2D

@export var wind: Vector2 = Vector2.ZERO
@onready var detector: CollisionShape2D = $Detector
@onready var particles: GPUParticles2D = $Particles

func _ready() -> void:
	var rect_size: Vector2 = detector.shape.get_rect().size * 0.5  # Get half the size for extents
	var particles_material: ParticleProcessMaterial = particles.process_material as ParticleProcessMaterial
	
	if particles_material:
		# Convert the 2D rect_size to a Vector3 for the particles_material
		particles_material.emission_box_extents = Vector3(rect_size.x, rect_size.y, 0)
	else:
		print("Error: ParticlesMaterial not found in process_material")

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.set_wind(wind)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.set_wind(Vector2.ZERO)
