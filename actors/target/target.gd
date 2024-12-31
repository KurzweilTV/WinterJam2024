extends Node2D

@onready var spotlight1: PointLight2D = $SpotlightPivot1/PointLight2D
@onready var spotlight2: PointLight2D = $SpotlightPivot2/PointLight2D2
@onready var scorer: Marker2D = $Scorer
var package : Package = null
var base_score : int = 100
var deactivated : bool = false

func _on_scoring_area_body_entered(body: Node2D) -> void:
	if body is Package and not deactivated:
		package = body
		
func calculate_score() -> float:
	if deactivated: return 0
	var dist = scorer.global_position.distance_to(package.global_position)
	print("BaseScore: %s" % base_score)
	print("Distance: %s" % dist)
	print("Mass: %s" % package.mass)
	print("HP: %s" % package.package_hp)

	var hp_weight = 2.0
	var distance_penalty = dist * 1.5
	var mass_influence = package.mass * 0.5
	
	var score = round((base_score - distance_penalty) * mass_influence + (package.package_hp * hp_weight))
	deactivate()
	return max(score, 50.0)
	
func deactivate() -> void:
	var tween = create_tween()
	$AnimationPlayer.stop()
	$Target.stop()
	tween.parallel().tween_property(spotlight1, "energy", 0, 2)
	tween.parallel().tween_property(spotlight2, "energy", 0, 2)
	$Target.frame = 0
	$AnimationPlayer.play("deactivate")
	deactivated = true
	
func _on_score_timer_timeout() -> void:
	if package and package.can_score:
		Game.score += calculate_score()
		package.queue_free()
		package = null
		
