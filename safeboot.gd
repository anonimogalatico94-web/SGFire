extends Control

func _ready() -> void:
    var bg := ColorRect.new()
    bg.color = Color(0.01, 0.01, 0.02, 1.0)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var title := Label.new()
    title.text = "SGFIRE"
    title.position = Vector2(0, 220)
    title.size = Vector2(1280, 80)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 52)
    bg.add_child(title)

    var status := Label.new()
    status.text = "TESTE ANDROID • BUILD 110"
    status.position = Vector2(0, 315)
    status.size = Vector2(1280, 55)
    status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status.add_theme_font_size_override("font_size", 24)
    bg.add_child(status)

    var start := Button.new()
    start.text = "INICIAR TESTE"
    start.position = Vector2(440, 410)
    start.size = Vector2(400, 85)
    start.add_theme_font_size_override("font_size", 28)
    start.pressed.connect(_start_game)
    bg.add_child(start)

func _start_game() -> void:
    get_tree().change_scene_to_file("res://Main.tscn")
