extends Node2D

@onready var spotlight1: PointLight2D = $SpotlightPivot1/PointLight2D
@onready var spotlight2: PointLight2D = $SpotlightPivot2/PointLight2D2
@onready var scorer: Marker2D = $Scorer
@onready var distance_label: Label = $DistanceLabel
@onready var text_anim: AnimationPlayer = $DistanceLabel/TextAnim

var package : Package = null
var base_score : int = 100
var deactivated : bool = false

func _on_scoring_area_body_entered(body: Node2D) -> void:
	if body is Package and not deactivated:
		package = body
		
func calculate_score() -> float:
	var dist = scorer.global_position.distance_to(package.global_position)
	print("BaseScore: %s" % base_score)
	print("Distance: %s" % dist)
	print("HP: %s" % package.package_hp)

	var hp_weight = 2.0
	var distance_penalty = dist
	
	if dist < 75:
		print("Perfect!")
		distance_label.text = "Perfect!"
		text_anim.play("float_text")
	elif dist < 85:
		print("Good!")
		distance_label.text = "Good!"
		text_anim.play("float_text")
	elif dist < 95:
		print("Almost")
		distance_label.text = "Almost"
		text_anim.play("float_text")
	else:
		print("Yikes!")
		distance_label.text = "Yikes!"
		text_anim.play("float_text")
	
	var score = round((base_score - distance_penalty * 3) + (package.package_hp * hp_weight))
	%ScoreParticles.emitting = true
	Game.package_collected += 1
	
	deactivate()
	$ScorePoints.play()
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
		Game.score += int(calculate_score())
		package.queue_free()
		package = null
		Game.check_victory()
		


func _on_scoring_area_body_exited(body: Node2D) -> void:
	if body is Package and not deactivated:
		package = null
