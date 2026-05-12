extends Control
@onready var audio_derrota = $AudioDerrota
@onready var audio_botao= $AudioBotao

func _ready():
	audio_derrota.play()
	
func _on_botao_continuar_pressed():
	Global.rodada_atual = 0
	Global.acertos_fase = 0
	Global.erros = 0
	Global.fase_concluida = false
	Global.palavra_atual = ""
	Global.imagem_atual = ""

	get_tree().change_scene_to_file("res://imagensColor/fase_cores.tscn")
