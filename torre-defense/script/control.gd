extends Control

var pressed = false
func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_button_pressed() -> void:
	if pressed:
		position.y += 200
		pressed = false
	else:
		position.y += -200
		pressed = true
	
	

## - - - área de compra

@export var atirador_scene: PackedScene  # arrasta a cena da torre aqui no Inspector

func _on_texture_button_pressed() -> void:
	if ControleDeTudo.coin >= 10:
		var torre = atirador_scene.instantiate()
		get_tree().current_scene.add_child(torre)
		torre.global_position = get_global_mouse_position()
	
	else:
		ControleDeTudo.invalido.emit()
