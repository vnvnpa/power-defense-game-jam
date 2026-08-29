extends Node2D

@onready var Rodada: Label = $Rodada

@onready var path_follow_original: PathFollow2D = $Path2D/PathFollow2D

@export var inimigos_scenes: Array[PackedScene]
@export var intervalo: float = 1.0  # tempo entre cada inimigo dentro da rodada

@export var total_rodadas: int = 4
@export var min_inimigos_por_rodada: int = 5
@export var max_inimigos_por_rodada: int = 15

@export var tempo_min_entre_rodadas: float = 2.0
@export var tempo_max_entre_rodadas: float = 5.0

func _ready():
	path_follow_original.set_process(false)
	await iniciar_rodadas()

func iniciar_rodadas():
	for i in range(total_rodadas):
		Rodada.text = "Rodada " + str(i + 1)

		var quantidade = randi_range(min_inimigos_por_rodada, max_inimigos_por_rodada)
		await spawnar_rodada(quantidade)

		var tempo_espera = randf_range(tempo_min_entre_rodadas, tempo_max_entre_rodadas)
		await get_tree().create_timer(tempo_espera).timeout

	##Rodada.text = "Fim das rodadas"

func spawnar_rodada(quantidade: int):
	for j in range(quantidade):
		var novo_path_follow = path_follow_original.duplicate()
		novo_path_follow.progress = 0.0

		var cena_escolhida = inimigos_scenes[randi() % inimigos_scenes.size()]
		var inimigo = cena_escolhida.instantiate()
		novo_path_follow.add_child(inimigo)

		$Path2D.add_child(novo_path_follow)

		await get_tree().create_timer(intervalo).timeout
