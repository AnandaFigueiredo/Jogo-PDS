extends Control

@onready var palavra = $CaixaTitulo/CenterContainer/ConteudoPalavra/Palavra
@onready var imagem_palavra = $CaixaTitulo/CenterContainer/ConteudoPalavra/ImagemPalavra
@onready var audio_palavra = $AudioPalavra

func _ready():
	palavra.text = Global.palavra_atual
	imagem_palavra.texture = load("res://imagensColor/" + Global.imagem_atual)

	var caminho_audio = "res://audios/" + Global.palavra_atual.to_lower() + ".mp3"
	audio_palavra.stream = load(caminho_audio)
	audio_palavra.play()

	await get_tree().create_timer(1.8).timeout

	if Global.fase_concluida:
		get_tree().change_scene_to_file("res://Win/tela_vitoria.tscn")
	else:
		get_tree().change_scene_to_file("res://imagensColor/fase_cores.tscn")
