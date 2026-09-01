extends CanvasLayer
var pressed = false

func _on_button_pressed() -> void:
	fechar_abrirLoja()

func fechar_abrirLoja():
	if pressed:
		offset.y += 200
		pressed = false
	else:
		offset.y += -200
		pressed = true

## - - - área de compra
@export var atirador_scene: PackedScene  # arrasta a cena da torre aqui no Inspector

func _on_texture_button_pressed() -> void:
	if ControleDeTudo.coin >= 10:
		var torre = atirador_scene.instantiate()
		get_tree().current_scene.add_child(torre)
		torre.global_position = get_tree().current_scene.get_global_mouse_position()
		fechar_abrirLoja()
	else:
		ControleDeTudo.invalido.emit()
