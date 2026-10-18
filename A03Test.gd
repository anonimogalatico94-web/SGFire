extends Control

var elapsed := 0.0

func _ready() -> void:
    set_process(true)
    queue_redraw()

func _process(delta: float) -> void:
    elapsed += delta
    queue_redraw()

func _draw() -> void:
    var screen := get_viewport_rect().size
    draw_rect(Rect2(Vector2.ZERO, screen), Color("#080d18"), true)

    # Large, unmistakable moving 2D test shapes.
    var red_x := screen.x * 0.28 + sin(elapsed * 1.8) * screen.x * 0.12
    var blue_x := screen.x * 0.72 + cos(elapsed * 1.4) * screen.x * 0.12
    var mid_y := screen.y * 0.52
    var red_points := PackedVector2Array([
        Vector2(red_x, mid_y - 75),
        Vector2(red_x - 58, mid_y + 45),
        Vector2(red_x + 58, mid_y + 45)
    ])
    var blue_points := PackedVector2Array([
        Vector2(blue_x, mid_y - 75),
        Vector2(blue_x - 58, mid_y + 45),
        Vector2(blue_x + 58, mid_y + 45)
    ])
    draw_colored_polygon(red_points, Color("#ff303f"))
    draw_colored_polygon(blue_points, Color("#2688ff"))

    draw_string(ThemeDB.fallback_font, Vector2(24, 42), "SGFIRE • TESTE 2D ANDROID 9+", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color.WHITE)
    draw_string(ThemeDB.fallback_font, Vector2(24, 76), "Se os dois cones se movem, a tela 2D está funcionando.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#d6e0f5"))
    draw_string(ThemeDB.fallback_font, Vector2(24, screen.y - 24), "DIAGNÓSTICO DE INICIALIZAÇÃO • BUILD 176", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#aab6ce"))
