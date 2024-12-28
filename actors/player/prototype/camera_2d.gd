extends Camera2D

# Define the zoom limits and zoom step
const ZOOM_MIN: float = 0.8
const ZOOM_MAX: float = 1.6
const ZOOM_STEP: float = 0.1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		adjust_zoom(-ZOOM_STEP)
	elif event.is_action_pressed("zoom_out"):
		adjust_zoom(ZOOM_STEP)

func adjust_zoom(delta: float) -> void:
	var new_zoom = zoom.x + delta
	new_zoom = clamp(new_zoom, ZOOM_MIN, ZOOM_MAX)
	zoom = Vector2(new_zoom, new_zoom)
