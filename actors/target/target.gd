extends Node2D

var target_center: Vector2 = global_position # Center of the target
var max_radius: float = 200.0 # Maximum radius of the target
var max_score: int = 100 # Maximum score at the center
var collidors = []

func calculate_score(hit_position: Vector2) -> int:
	var distance = target_center.distance_to(hit_position)
	if distance > max_radius:
		return 0 # No score if outside the target
	return int(max_score * (1 - (distance / max_radius)))

func _on_scoring_area_body_entered(body: Node2D) -> void:
	if body is Package:
		collidors.append(body)
		
func _check_score() -> void:
	for collidor in collidors:
		if collidor.can_score and not collidor.is_carried:
			print("Collidor Found: " + str(collidors[0]))
			print(calculate_score(collidor.position))
			collidor.queue_free()
		else:
			return
		
