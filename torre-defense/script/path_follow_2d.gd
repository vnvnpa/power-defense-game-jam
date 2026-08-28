extends PathFollow2D



@export var velocidade: float = 100.0

func _process(delta):
	progress += velocidade * delta

	if progress_ratio >= 1.0:
		queue_free()
