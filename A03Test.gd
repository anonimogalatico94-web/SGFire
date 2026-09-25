extends Control

func _ready() -> void:
    var start := Button.new()
    start.text = "INICIAR TESTE 3D COM BOTS"
    start.position = Vector2(230, 360)
    start.size = Vector2(500, 80)
    start.add_theme_font_size_override("font_size", 24)
    start.pressed.connect(_start_game)
    add_child(start)

func _start_game() -> void:
    get_tree().change_scene_to_file("res://Prototype.tscn")
