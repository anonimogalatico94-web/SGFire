extends Control

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var background := ColorRect.new()
    background.color = Color(0.02, 0.02, 0.025, 1.0)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var title := Label.new()
    title.text = "SGFIRE"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    title.set_anchors_preset(Control.PRESET_CENTER)
    title.position = Vector2(-300, -100)
    title.size = Vector2(600, 100)
    title.add_theme_font_size_override("font_size", 52)
    add_child(title)

    var status := Label.new()
    status.text = "TESTE ANDROID"
    status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status.set_anchors_preset(Control.PRESET_CENTER)
    status.position = Vector2(-300, 0)
    status.size = Vector2(600, 60)
    status.add_theme_font_size_override("font_size", 24)
    add_child(status)

    var start := Button.new()
    start.text = "INICIAR SGFIRE"
    start.set_anchors_preset(Control.PRESET_CENTER)
    start.position = Vector2(-250, 80)
    start.size = Vector2(500, 100)
    start.add_theme_font_size_override("font_size", 28)
    start.pressed.connect(_start_game)
    add_child(start)

func _start_game() -> void:
    get_tree().change_scene_to_file("res://Main.tscn")
