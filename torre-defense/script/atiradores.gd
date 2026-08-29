extends Node2D

var arrastando: bool = true
var pronto_para_fixar: bool = false

@export var projetil_scene: PackedScene
@export var cadencia: float = 1.0
@export var velocidade_projetil: float = 400.0
@export var life: int = 50


@onready var area_alcance: Area2D = $are
@onready var ponto_de_tiro: Marker2D = $PontoDeTiro

@onready var area_de_receber_b_: Area2D = $"areaDeReceberB="


var inimigos_no_alcance: Array = []
var pode_atirar: bool = true

func _ready():
	await get_tree().process_frame
	pronto_para_fixar = true
	area_alcance.area_entered.connect(_on_inimigo_entrou)
	area_alcance.area_exited.connect(_on_inimigo_saiu)
	area_de_receber_b_.monitorable = false
	
func _process(_delta):
	if arrastando:
		global_position = get_global_mouse_position()
		return

	if inimigos_no_alcance.size() > 0:
		var alvo = inimigos_no_alcance[0]
		if is_instance_valid(alvo):
			rotacionar_para(alvo)
			if pode_atirar:
				atirar(alvo)
		else:
			inimigos_no_alcance.erase(alvo)

func rotacionar_para(alvo: Area2D):
	var direcao = alvo.global_position - global_position
	rotation = direcao.angle()

func atirar(alvo: Area2D):
	pode_atirar = false
	var direcao = (alvo.global_position - ponto_de_tiro.global_position).normalized()

	var projetil = projetil_scene.instantiate()
	get_tree().current_scene.add_child(projetil)
	projetil.global_position = ponto_de_tiro.global_position
	projetil.rotation = direcao.angle()
	projetil.setup(direcao, velocidade_projetil)

	await get_tree().create_timer(cadencia).timeout
	pode_atirar = true

func _on_inimigo_entrou(area):
	if area.is_in_group("inimigos"):
		inimigos_no_alcance.append(area)

func _on_inimigo_saiu(area):
	inimigos_no_alcance.erase(area)

func tomar_dano(dano: int):
	life -= dano
	if life <= 0:
		queue_free()

func _unhandled_input(event):
	if not arrastando or not pronto_para_fixar:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			colocar()
	elif event is InputEventScreenTouch:
		if event.pressed:
			global_position = event.position
			colocar()

func colocar():
	area_de_receber_b_.monitorable = true
	arrastando = false
