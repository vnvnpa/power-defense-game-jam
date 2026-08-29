extends Control

var pressed = false

func _on_button_pressed() -> void:
	if pressed:
		position.y += 200
		pressed = false
	elif pressed == false:
		position.y += -200
		pressed = true
