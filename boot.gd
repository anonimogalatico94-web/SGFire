extends Control

var started := false

func _ready() -> void:
    $Center/VBox/Status.text = "PRONTO PARA O TESTE"
    $Center/VBox/StartButton.pressed.connect(_start_game)

func _start_game() -> void:
    if started:
        return
    started = true
    $Center/VBox/StartButton.disabled = true
    $Center/VBox/Status.text = "CARREGANDO CENÁRIO..."
    await get_tree().process_frame
    var scene := load("res://Main.tscn") as PackedScene
    if scene == null:
        started = false
        $Center/VBox/StartButton.disabled = false
        $Center/VBox/Status.text = "ERRO AO CARREGAR O CENÁRIO"
        return
    get_tree().change_scene_to_packed(scene)
