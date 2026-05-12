extends Control

@onready var audio_vitoria = $AudioVitoria
@onready var audio_botao = $AudioBotao

func _ready():
	audio_vitoria.play()

func _on_botao_continuar_pressed():
	var tree = get_tree()

	audio_botao.stop()
	audio_botao.play()
	await audio_botao.finished

	if Global.fase_atual == 1:
		Global.fase_atual = 2
		Global.rodada_atual = 0
		Global.acertos_fase = 0
		Global.erros = 0
		Global.fase_concluida = false

		tree.change_scene_to_file("res://imagensColor/fase_cores.tscn")
	else:
		Global.fase_atual = 1
		Global.rodada_atual = 0
		Global.acertos_fase = 0
		Global.erros = 0
		Global.fase_concluida = false
		Global.palavra_atual = ""
		Global.imagem_atual = ""

		tree.change_scene_to_file("res://TelaInicial/menu_inicial.tscn")
