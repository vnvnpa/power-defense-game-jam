extends Node2D

@onready var vida: Label = $ColorRect/vida
@onready var color_rect: ColorRect = $ColorRect

var posicao_x_anterior: float = 0.0
var life = 50

func _ready():
	posicao_x_anterior = global_position.x
	color_rect.position.y = -50  # alinha ColorRect (e o Label, que é filho dele) 5px acima
	vida.text = str(life)

func _process(_delta):
	var posicao_x_atual = global_position.x
	posicao_x_anterior = posicao_x_atual

func tomar_dano(dano: int):
	life -= dano
	vida.text = str(life)
	if life <= 0:
		queue_free()
