extends Node2D

@onready var vida: Label = $ColorRect/vida

var posicao_x_anterior: float = 0.0
var life = 100

func _ready():
	posicao_x_anterior = global_position.x
	vida.text = str(life) 

func _process(delta):
	var posicao_x_atual = global_position.x
	
	#if posicao_x_atual < posicao_x_anterior:
		#$AnimatedSprite2D.flip_h = true
	#elif posicao_x_atual > posicao_x_anterior:
		#$AnimatedSprite2D.flip_h = false
		#
	#posicao_x_anterior = posicao_x_atual
