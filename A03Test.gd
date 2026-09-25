extends Control

func _ready() -> void:
    var label := Label.new()
    label.text = "SGFIRE\nTESTE A03\n\nToque no botão para entrar"
    label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 28)
    add_child(label)

    var button := Button.new()
    button.text = "ENTRAR NO TESTE"
    button.size = Vector2(520, 100)
    button.position = Vector2(220, 360)
    button.add_theme_font_size_override("font_size", 26)
    button.pressed.connect(_start_game)
    add_child(button)

func _start_game() -> void:
    get_tree().change_scene_to_file("res://Prototype.tscn")
