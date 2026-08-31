extends Node2D

@onready var Rodada: Label = $Rodada

@onready var path_follow_original: PathFollow2D = $Path2D/PathFollow2D

# --- Inimigos normais, cada um com peso de chance de aparecer ---
@export var inimigos_normais: Array[Dictionary] = [
	{"cena": preload("res://cenas/slime.tscn"), "peso": 10},
	
]

# --- Boss ---
@export var boss_scene: PackedScene
@export var boss_a_cada_x_rodadas: int = 5  # 0 = boss só na última rodada

# --- Tempo entre inimigos dentro da mesma rodada ---
@export var intervalo: float = 0.9

# --- Configuração de rodadas ---
@export var total_rodadas: int = 10
@export var min_inimigos_por_rodada: int = 5
@export var max_inimigos_por_rodada: int = 15

# --- Tempo aleatório de descanso entre rodadas ---
@export var tempo_min_entre_rodadas: float = 5.0
@export var tempo_max_entre_rodadas: float = 8.0



func _ready():
	var largura = get_viewport().get_visible_rect().size.x
	
	Rodada.position.x = (largura - Rodada.size.x) / 2
	Rodada.position.y = 20 # 20 pixels abaixo do topo
	

	
	path_follow_original.set_process(false)
	await iniciar_rodadas()


func iniciar_rodadas():
	for i in range(total_rodadas):
		var numero_da_rodada = i + 1
		Rodada.text = "Rodada " + str(numero_da_rodada)

		var quantidade = randi_range(min_inimigos_por_rodada, max_inimigos_por_rodada)
		await spawnar_rodada(quantidade, numero_da_rodada)

		var tempo_espera = randf_range(tempo_min_entre_rodadas, tempo_max_entre_rodadas)
		await get_tree().create_timer(tempo_espera).timeout

	Rodada.text = "Fim das rodadas"


func spawnar_rodada(quantidade: int, numero_da_rodada: int):
	var eh_rodada_de_boss = (numero_da_rodada == total_rodadas) or \
		(boss_a_cada_x_rodadas > 0 and numero_da_rodada % boss_a_cada_x_rodadas == 0)

	for j in range(quantidade):
		var novo_path_follow = path_follow_original.duplicate()
		novo_path_follow.progress = 0.0

		var cena_escolhida: PackedScene
		if eh_rodada_de_boss and j == quantidade - 1 and boss_scene != null:
			cena_escolhida = boss_scene
		else:
			cena_escolhida = sortear_inimigo(inimigos_normais)

		var inimigo = cena_escolhida.instantiate()
		novo_path_follow.add_child(inimigo)
		$Path2D.add_child(novo_path_follow)

		await get_tree().create_timer(intervalo).timeout


func sortear_inimigo(lista: Array[Dictionary]) -> PackedScene:
	var peso_total = 0
	for item in lista:
		peso_total += item["peso"]

	var sorteio = randi_range(1, peso_total)
	var acumulado = 0

	for item in lista:
		acumulado += item["peso"]
		if sorteio <= acumulado:
			return item["cena"]

	return lista[0]["cena"]  # fallback de segurança
