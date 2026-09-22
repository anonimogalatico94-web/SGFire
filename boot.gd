extends Control

var started := false

func _ready() -> void:
    get_viewport().set_embedding_subwindows(false)
    $Center/VBox/Status.text = "INICIALIZANDO SGFIRE..."
    await get_tree().create_timer(0.8).timeout
    _start_game()

func _start_game() -> void:
    if started:
        return
    started = true
    $Center/VBox/Status.text = "CARREGANDO CENÁRIO..."
    await get_tree().process_frame
    get_tree().change_scene_to_file("res://Main.tscn")
