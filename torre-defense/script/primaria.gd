extends Node2D

@export var inimigo_scene: PackedScene
@export var intervalo: float = 1.0

@onready var path_follow_original: PathFollow2D = $Path2D/PathFollow2D

var inimigos_spawnados = 0

func _ready():
	$Path2D/PathFollow2D.set_process(false)
	spawn_inimigo()
	
func spawn_inimigo():
	var novo_path_follow = path_follow_original.duplicate()

	novo_path_follow.progress = 0.0

	var inimigo = inimigo_scene.instantiate()
	novo_path_follow.add_child(inimigo)

	$Path2D.add_child(novo_path_follow)
	inimigos_spawnados += 1

	await get_tree().create_timer(intervalo).timeout
	spawn_inimigo()
