extends Node2D

@onready var scorer: Marker2D = $Scorer
var package : Package = null
var base_score : int = 100

func _on_scoring_area_body_entered(body: Node2D) -> void:
	if body is Package:
		package = body
		
func calculate_score() -> float:
	var dist = scorer.global_position.distance_to(package.global_position)
	var score = (base_score - dist) * package.mass
	return max(score, 50.0)
	
func _on_score_timer_timeout() -> void:
	if package and package.can_score:
		print("Score: " + str(calculate_score()))
		package.queue_free()
		package = null
		
