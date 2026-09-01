extends Node

# ============================================================
# NetworkManager - Autoload para multiplayer (Godot 4)
# ============================================================
# Adicione este script em Project > Project Settings > Autoload
# com o nome "NetworkManager"
#
# Ele cuida SÓ da camada de rede. O ControleDeTudo continua
# cuidando do estado do jogo (vida, coin, etc), mas agora só o HOST
# (peer com autoridade) pode alterar valores compartilhados,
# através das funções gastar_coin() / ganhar_coin() / perder_vida()
# que já deixamos autoritativas nele.
# ============================================================

const PORTA := 7777
const MAX_JOGADORES := 4

var peer: ENetMultiplayerPeer

signal jogador_conectou(id: int)
signal jogador_desconectou(id: int)
signal conexao_falhou
signal conectado_ao_servidor
signal servidor_criado

var jogadores := {} # id -> nome (ou dados customizados)


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


# ------------------------------------------------------------
# CRIAR SERVIDOR (host)
# ------------------------------------------------------------
func criar_servidor() -> void:
	peer = ENetMultiplayerPeer.new()
	var erro := peer.create_server(PORTA, MAX_JOGADORES)
	if erro != OK:
		push_error("Falha ao criar servidor: %s" % erro)
		return

	multiplayer.multiplayer_peer = peer
	jogadores[1] = "Host" # id 1 é sempre o servidor
	servidor_criado.emit()
	print("Servidor criado na porta %d" % PORTA)


# ------------------------------------------------------------
# ENTRAR COMO CLIENTE
# ------------------------------------------------------------
func entrar_servidor(ip: String) -> void:
	peer = ENetMultiplayerPeer.new()
	var erro := peer.create_client(ip, PORTA)
	if erro != OK:
		push_error("Falha ao conectar: %s" % erro)
		return

	multiplayer.multiplayer_peer = peer
	print("Tentando conectar a %s..." % ip)


func desconectar() -> void:
	if peer:
		peer.close()
	jogadores.clear()


# ------------------------------------------------------------
# CALLBACKS DE CONEXÃO
# ------------------------------------------------------------
func _on_peer_connected(id: int) -> void:
	print("Jogador conectou: %d" % id)
	jogador_conectou.emit(id)
	# Se eu sou o host, mando o estado atual pro novo jogador
	if multiplayer.is_server():
		_sincronizar_estado_para.rpc_id(id, ControleDeTudo.vida, ControleDeTudo.coin)


func _on_peer_disconnected(id: int) -> void:
	print("Jogador saiu: %d" % id)
	jogadores.erase(id)
	jogador_desconectou.emit(id)


func _on_connected_ok() -> void:
	print("Conectado ao servidor!")
	conectado_ao_servidor.emit()


func _on_connection_failed() -> void:
	push_error("Não foi possível conectar ao servidor.")
	conexao_falhou.emit()
	multiplayer.multiplayer_peer = null


func _on_server_disconnected() -> void:
	push_error("Servidor desconectou.")
	multiplayer.multiplayer_peer = null


# ------------------------------------------------------------
# SINCRONIZAÇÃO DE ESTADO (host -> cliente que acabou de entrar)
# ------------------------------------------------------------
@rpc("authority", "call_remote", "reliable")
func _sincronizar_estado_para(vida: int, coin: int) -> void:
	ControleDeTudo.vida = vida
	ControleDeTudo.coin = coin


# ------------------------------------------------------------
# EXEMPLO: SPAWN DE TORRE AUTORITATIVO
# ------------------------------------------------------------
# Fluxo:
# 1. Cliente arrasta a torre e solta -> chama pedir_spawn_torre()
# 2. pedir_spawn_torre roda LOCAL primeiro (call_local) então
#    envia pro servidor via RPC "any_peer"
# 3. Só quem tem is_server() == true realmente valida e decide
# 4. Se validado, o servidor chama spawnar_torre.rpc() pra
#    replicar em TODOS os clientes (incluindo ele mesmo)
# ------------------------------------------------------------

@rpc("any_peer", "call_local", "reliable")
func pedir_spawn_torre(tipo_torre: String, posicao: Vector2) -> void:
	# Só o servidor processa a validação
	if not multiplayer.is_server():
		return

	var custo := _custo_da_torre(tipo_torre)

	if not ControleDeTudo.gastar_coin(custo):
		# sem grana: avisa só quem pediu
		var id_solicitante := multiplayer.get_remote_sender_id()
		if id_solicitante != 0:
			_spawn_negado.rpc_id(id_solicitante)
		return

	# Validado (coin já foi descontado e sincronizado por gastar_coin): replica o spawn
	spawnar_torre.rpc(tipo_torre, posicao)


@rpc("authority", "call_local", "reliable")
func spawnar_torre(tipo_torre: String, posicao: Vector2) -> void:
	# Roda em TODOS os peers (inclusive o host), efeito visual real
	# Troque isso pela sua lógica real de instanciar a cena da torre
	print("Spawnando torre %s em %s" % [tipo_torre, posicao])
	# Exemplo:
	# var torre = preload("res://cenas/torres/%s.tscn" % tipo_torre).instantiate()
	# torre.global_position = posicao
	# get_tree().current_scene.add_child(torre)


@rpc("authority", "call_remote", "reliable")
func _spawn_negado() -> void:
	# Roda só no cliente que pediu e foi negado
	ControleDeTudo.invalido.emit()


func _custo_da_torre(tipo: String) -> int:
	# Ajuste conforme sua tabela de custos real
	match tipo:
		"basica":
			return 10
		"canhao":
			return 25
		_:
			return 999999


# ------------------------------------------------------------
# EXEMPLO: DANO AUTORITATIVO EM INIMIGO
# ------------------------------------------------------------
@rpc("any_peer", "call_local", "reliable")
func pedir_dano_inimigo(caminho_inimigo: NodePath, dano: int) -> void:
	if not multiplayer.is_server():
		return

	var inimigo := get_node_or_null(caminho_inimigo)
	if inimigo == null:
		return

	aplicar_dano_inimigo.rpc(caminho_inimigo, dano)


@rpc("authority", "call_local", "reliable")
func aplicar_dano_inimigo(caminho_inimigo: NodePath, dano: int) -> void:
	var inimigo := get_node_or_null(caminho_inimigo)
	if inimigo and inimigo.has_method("tomar_dano"):
		inimigo.tomar_dano(dano)
