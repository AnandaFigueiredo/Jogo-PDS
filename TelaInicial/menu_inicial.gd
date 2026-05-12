extends Control

@onready var audio_titulo = $AudioTitulo
@onready var audio_jogar = $AudioJogar

func _on_botao_jogar_pressed():
	Global.acertos_fase = 0
	Global.erros = 0
	Global.rodada_atual = 0
	Global.palavra_atual = ""
	Global.imagem_atual = ""

	get_tree().change_scene_to_file("res://imagensColor/fase_cores.tscn")

func parar_audios_hover():
	audio_titulo.stop()
	audio_jogar.stop()
	
func _on_botao_jogar_mouse_entered():
	parar_audios_hover()
	audio_jogar.play()

func _on_titulo_mouse_entered():
	parar_audios_hover()
	audio_titulo.play()
