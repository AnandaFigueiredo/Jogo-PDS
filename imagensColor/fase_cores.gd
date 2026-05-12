extends Control

@onready var robo_body = $Robo
@onready var robo = $Robo/ImagemRobo

@onready var instrucao = $Instrucao
@onready var pontuacao = $Pontuacao
@onready var erros_label = $Erros
@onready var objetivo = $Objetivo
@onready var imagem_palavra = $ImagemPalavra

@onready var item1 = $Item1
@onready var item2 = $Item2
@onready var item3 = $Item3

var velocidade_robo = 300.0
var velocidade_queda = 80.0

var limite_esquerda = 80.0
var limite_direita = 1200.0
var limite_baixo = 760.0

var rodada_atual = 0
var acertos = 0
var erros = 0
var resposta_correta = ""
var rodada_ativa = true
var som_mutado = false

@onready var audio_silaba = $AudioSilaba
@onready var slider_som = $SliderSom
var item_hover_atual = null

var audios_silabas = {
	"BA": "res://audios/ba.mp3",
	"BE": "res://audios/be.mp3",
	"BO": "res://audios/bo.mp3",
	"CA": "res://audios/ca.mp3",
	"GA": "res://audios/ga.mp3",
	"LA": "res://audios/la.mp3",
	"LI": "res://audios/li.mp3",
	"MA": "res://audios/ma.mp3",
	"ME": "res://audios/me.mp3"
}

var fase_atual = 1

var rodadas_fase_1 = [
	{
		"instrucao": "Complete: __VALO",
		"correta": "CA",
		"opcoes": ["CA", "LA", "GA"],
		"imagem": "cavalo.png"
	},
	{
		"instrucao": "Complete: __NANA",
		"correta": "BA",
		"opcoes": ["BA", "CA", "MA"],
		"imagem": "banana.png"
	},
	{
		"instrucao": "Complete: __RANJA",
		"correta": "LA",
		"opcoes": ["LA", "BA", "MA"],
		"imagem": "laranja.png"
	},
	{
		"instrucao": "Complete: __TO",
		"correta": "GA",
		"opcoes": ["GA", "CA", "LA"],
		"imagem": "gato.png"
	},
	{
		"instrucao": "Complete: __CACO",
		"correta": "MA",
		"opcoes": ["MA", "BA", "GA"],
		"imagem": "macaco.png"
	}
]

var rodadas_fase_2 = [
	{
		"instrucao": "Complete: CA__NA",
		"correta": "BA",
		"opcoes": ["BA", "CA", "MA"],
		"imagem": "cabana.png"
	},
	{
		"instrucao": "Complete: A__LHA",
		"correta": "BE",
		"opcoes": ["BE", "BA", "LA"],
		"imagem": "abelha.png"
	},
	{
		"instrucao": "Complete: CE__LA",
		"correta": "BO",
		"opcoes": ["BO", "BE", "LA"],
		"imagem": "cebola.png"
	},
	{
		"instrucao": "Complete: CA__LO",
		"correta": "ME",
		"opcoes": ["ME", "MA", "BE"],
		"imagem": "camelo.png"
	},
	{
		"instrucao": "Complete: TO__TE",
		"correta": "MA",
		"opcoes": ["MA", "ME", "BA"],
		"imagem": "tomate.png"
	},
	{
		"instrucao": "Complete: GA__NHA",
		"correta": "LI",
		"opcoes": ["LI", "LA", "MA"],
		"imagem": "galinha.png"
	},
	{
		"instrucao": "Complete: BO__CHA",
		"correta": "LA",
		"opcoes": ["LA", "LI", "BA"],
		"imagem": "bolacha.png"
	}
]

func _ready():
	randomize()
	$SliderSom.value = 1.0

	fase_atual = Global.fase_atual
	acertos = Global.acertos_fase
	erros = Global.erros
	rodada_atual = Global.rodada_atual

	if rodada_atual >= get_rodadas_atuais().size():
		rodada_atual = 0

	atualizar_ui()
	carregar_rodada()

func verificar_hover_silabas():
	var mouse_pos = get_global_mouse_position()

	var item_em_hover = null

	if esta_mouse_sobre_item(item1, mouse_pos):
		item_em_hover = item1
	elif esta_mouse_sobre_item(item2, mouse_pos):
		item_em_hover = item2
	elif esta_mouse_sobre_item(item3, mouse_pos):
		item_em_hover = item3

	if item_em_hover != item_hover_atual:
		item_hover_atual = item_em_hover

		if item_hover_atual != null:
			tocar_audio_silaba(item_hover_atual)

func esta_mouse_sobre_item(item, mouse_pos):
	if item.texture == null:
		return false

	var tamanho = item.texture.get_size() * item.scale
	var metade = tamanho / 2.0

	var esquerda = item.global_position.x - metade.x
	var direita = item.global_position.x + metade.x
	var topo = item.global_position.y - metade.y
	var baixo = item.global_position.y + metade.y

	return mouse_pos.x >= esquerda and mouse_pos.x <= direita and mouse_pos.y >= topo and mouse_pos.y <= baixo

func tocar_audio_silaba(item):
	if audios_silabas.has(item.name):
		audio_silaba.stop()
		audio_silaba.stream = load(audios_silabas[item.name])
		audio_silaba.play()

func _process(delta):
	verificar_hover_silabas()
	if not rodada_ativa:
		return

	mover_robo(delta)
	fazer_itens_cairem(delta)
	verificar_colisoes()

func mover_robo(delta):
	if Input.is_action_pressed("ui_left"):
		robo_body.position.x -= velocidade_robo * delta
	if Input.is_action_pressed("ui_right"):
		robo_body.position.x += velocidade_robo * delta

	robo_body.position.x = clamp(robo_body.position.x, limite_esquerda, limite_direita)

func fazer_itens_cairem(delta):
	item1.position.y += velocidade_queda * delta
	item2.position.y += velocidade_queda * delta
	item3.position.y += velocidade_queda * delta

	if item1.position.y > limite_baixo:
		verificar_saida_tela(item1)
	if item2.position.y > limite_baixo:
		verificar_saida_tela(item2)
	if item3.position.y > limite_baixo:
		verificar_saida_tela(item3)

func verificar_saida_tela(item):
	if not rodada_ativa:
		return

	if item.name == resposta_correta:
		registrar_erro()
	else:
		resetar_item_errado(item)

func verificar_colisoes():
	if not rodada_ativa:
		return

	if colidiu(robo, item1):
		processar_colisao(item1)
		return

	if colidiu(robo, item2):
		processar_colisao(item2)
		return

	if colidiu(robo, item3):
		processar_colisao(item3)
		return

func processar_colisao(item):
	if not rodada_ativa:
		return

	rodada_ativa = false

	if item.name == resposta_correta:
		registrar_acerto()
	else:
		registrar_erro()

func registrar_acerto():
	rodada_ativa = false
	acertos += 1
	atualizar_ui()

	var rodada = get_rodadas_atuais()[rodada_atual]
	var base_palavra = rodada["instrucao"].replace("Complete: ", "")
	var palavra_completa = base_palavra.replace("__", rodada["correta"])

	Global.acertos_fase = acertos
	Global.erros = erros
	Global.palavra_atual = palavra_completa
	Global.imagem_atual = rodada["imagem"]

	if acertos >= get_objetivo_atual():
		Global.fase_concluida = true
		Global.rodada_atual = rodada_atual
	else:
		Global.fase_concluida = false
		Global.rodada_atual = rodada_atual + 1

	get_tree().change_scene_to_file("res://acertos/acerto.tscn")
func registrar_erro():
	erros += 1
	Global.erros = erros
	atualizar_ui()

	if erros >= 2:
		get_tree().change_scene_to_file("res://derrota/tela_derrota.tscn")
		return

	carregar_rodada()

func carregar_rodada():
	rodada_ativa = false

	var rodada = get_rodadas_atuais()[rodada_atual]
	instrucao.text = rodada["instrucao"]
	resposta_correta = rodada["correta"]

	var caminho_imagem = "res://imagensColor/" + rodada["imagem"]
	imagem_palavra.texture = load(caminho_imagem)

	var opcoes = rodada["opcoes"].duplicate()
	opcoes.shuffle()

	configurar_item(item1, opcoes[0], 470, 160)
	configurar_item(item2, opcoes[1], 680, 160)
	configurar_item(item3, opcoes[2], 900, 160)

	rodada_ativa = true

func configurar_item(item, silaba, pos_x, pos_y):
	item.name = silaba
	item.texture = load("res://imagensColor/" + silaba.to_lower() + ".png")
	item.position.x = pos_x
	item.position.y = pos_y

func resetar_item_errado(item):
	item.position.y = -50
	item.position.x = randf_range(350, 1050)

func colidiu(no1, no2):
	return no1.global_position.distance_to(no2.global_position) < 120

func atualizar_ui():
	pontuacao.text = "Acertos: " + str(acertos)
	objetivo.text = "Objetivo: " + str(get_objetivo_atual())
	erros_label.text = "Erros: " + str(erros) + "/2"

func get_rodadas_atuais():
	if fase_atual == 1:
		return rodadas_fase_1
	return rodadas_fase_2

func get_objetivo_atual():
	if fase_atual == 1:
		return 5
	return 7

func _on_slider_som_value_changed(value):
	var volume_db = linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)

	if value <= 0.01:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		som_mutado = true
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		som_mutado = false

func _on_botao_som_pressed():
	som_mutado = !som_mutado
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus_index, som_mutado)

	if som_mutado:
		slider_som.value = 0.0
	else:
		slider_som.value = 1.0
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(1.0))

func _on_botao_sair_pressed():
	get_tree().change_scene_to_file("res://TelaInicial/menu_inicial.tscn")
