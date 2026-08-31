extends CanvasLayer

const AVISO_INVALIDO = preload("uid://ix8tss3yf4ao")
const MENU_MORTE = preload("uid://cec6h86860yf")

var coin = 30
var esmeralda
signal invalido
signal theEnd

var vida = 5
var jogo_acabou: bool = false
var cenaAtual: String

func _ready() -> void:
	invalido.connect(criarfilhoInvalido)

func perder_vida(dano):
	vida -= dano
	if vida <= 0 and not jogo_acabou:
		fim_de_jogo()

func fim_de_jogo():
	jogo_acabou = true
	theEnd.emit()
	cenaAtual = get_tree().current_scene.scene_file_path
	get_tree().paused = true
	add_child(MENU_MORTE.instantiate())

func resetar_estado():
	vida = 5
	jogo_acabou = false
	coin = 30

func criarfilhoInvalido():
	add_child(AVISO_INVALIDO.instantiate())
