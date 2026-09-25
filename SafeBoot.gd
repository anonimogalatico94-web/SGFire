extends Control

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var bg := ColorRect.new()
    bg.color = Color(0.008, 0.012, 0.025, 1.0)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var title := Label.new()
    title.text = "SGFIRE"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.position = Vector2(80, 130)
    title.size = Vector2(800, 80)
    title.add_theme_font_size_override("font_size", 52)
    bg.add_child(title)

    var status := Label.new()
    status.text = "TESTE ANDROID A03 • BUILD 153"
    status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status.position = Vector2(80, 225)
    status.size = Vector2(800, 50)
    status.add_theme_font_size_override("font_size", 22)
    bg.add_child(status)

    var info := Label.new()
    info.text = "INICIALIZAÇÃO SEGURA OK • TESTE OFFLINE COM BOTS"
    info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    info.position = Vector2(80, 285)
    info.size = Vector2(800, 45)
    info.add_theme_font_size_override("font_size", 20)
    bg.add_child(info)

    var start := Button.new()
    start.text = "INICIAR TESTE COM BOTS"
    start.position = Vector2(250, 355)
    start.size = Vector2(460, 85)
    start.add_theme_font_size_override("font_size", 25)
    start.pressed.connect(_start_game)
    bg.add_child(start)

func _start_game() -> void:
    get_tree().change_scene_to_file("res://Prototype.tscn")
