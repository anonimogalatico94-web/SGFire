extends Node3D

const BOT_COUNT := 6
const MOVE_SPEED := 5.0
const BOT_SPEED := 2.1
const FIRE_COOLDOWN := 0.22

var player: CharacterBody3D
var camera: Camera3D
var player_health := 100
var player_score := 0
var mobile_fire := false
var mobile_forward := false
var mobile_back := false
var mobile_left := false
var mobile_right := false
var look_touch := -1
var last_look := Vector2.ZERO
var fire_timer := 0.0
var bots: Array[CharacterBody3D] = []
var bot_timers: Dictionary = {}
var hud_status: Label
var eliminated_bots := 0
var bot_flash: Dictionary = {}
var damage_flash: ColorRect
var health_label: Label
var score_label: Label

func _ready() -> void:
    _build_world()
    _build_player()
    _build_bots()
    _build_hud()

func _physics_process(delta: float) -> void:
    if player == null:
        return
    _player_move(delta)
    fire_timer = maxf(0.0, fire_timer - delta)
    if Input.is_action_pressed("ui_accept") or mobile_fire:
        _player_fire()
    _update_bots(delta)
    _update_effects(delta)
    _update_hud()

func _build_world() -> void:
    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("#050811")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#33405f")
    environment.ambient_light_energy = 0.46
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.environment = environment
    add_child(env)

    var moon := DirectionalLight3D.new()
    moon.rotation_degrees = Vector3(-55.0, -25.0, 0.0)
    moon.light_color = Color("#8ca6d8")
    moon.light_energy = 0.82
    moon.shadow_enabled = true
    add_child(moon)

    _make_box(Vector3(0,-0.25,0), Vector3(42,0.5,42), Color("#11151d"), true)

    # São Gabriel-inspired night street layout: blocks, walls and cover.
    var cover_positions := [
        Vector3(-10,1.5,-8), Vector3(0,1.5,-8), Vector3(10,1.5,-8),
        Vector3(-10,1.5,2), Vector3(10,1.5,2),
        Vector3(-7,1.5,11), Vector3(3,1.5,11), Vector3(12,1.5,11)
    ]
    for p in cover_positions:
        _make_box(p, Vector3(4,3,2), Color("#252a34"), true)

    for p in [Vector3(-15,2,-15), Vector3(15,2,-15), Vector3(-15,2,15), Vector3(15,2,15)]:
        var lamp := OmniLight3D.new()
        lamp.position = p
        lamp.light_color = Color("#ffd38a")
        lamp.light_energy = 3.8
        lamp.omni_range = 9.0
        add_child(lamp)

func _make_box(pos: Vector3, size: Vector3, color: Color, collision := false) -> Node3D:
    var body: Node3D = StaticBody3D.new() if collision else Node3D.new()
    body.position = pos
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.88
    box.material = mat
    body.add_child(mesh)
    if collision:
        var shape := CollisionShape3D.new()
        var box_shape := BoxShape3D.new()
        box_shape.size = size
        shape.shape = box_shape
        body.add_child(shape)
    add_child(body)
    return body

func _build_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Player"
    player.position = Vector3(0, 1.1, 16)
    add_child(player)

    var shape := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.42
    capsule.height = 1.8
    shape.shape = capsule
    shape.position.y = 0.0
    player.add_child(shape)

    var body_mesh := MeshInstance3D.new()
    var body := CapsuleMesh.new()
    body.radius = 0.42
    body.height = 1.8
    body_mesh.mesh = body
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color("#15191f")
    body.material = mat
    player.add_child(body_mesh)

    camera = Camera3D.new()
    camera.position = Vector3(0, 0.55, 0)
    camera.current = true
    player.add_child(camera)

func _build_bots() -> void:
    var positions := [
        Vector3(-9,1.1,-14), Vector3(0,1.1,-14), Vector3(9,1.1,-14),
        Vector3(-13,1.1,0), Vector3(13,1.1,0), Vector3(0,1.1,-4)
    ]
    for i in positions.size():
        var bot := CharacterBody3D.new()
        bot.name = "Bot_%02d" % (i + 1)
        bot.position = positions[i]
        add_child(bot)

        var shape := CollisionShape3D.new()
        var capsule := CapsuleShape3D.new()
        capsule.radius = 0.42
        capsule.height = 1.8
        shape.shape = capsule
        bot.add_child(shape)

        var mesh := MeshInstance3D.new()
        var capsule_mesh := CapsuleMesh.new()
        capsule_mesh.radius = 0.42
        capsule_mesh.height = 1.8
        mesh.mesh = capsule_mesh
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color("#b51f2d") if i % 2 == 0 else Color("#235fa8")
        capsule_mesh.material = mat
        bot.add_child(mesh)

        bots.append(bot)
        bot_timers[bot] = randf_range(0.4, 1.4)

func _build_hud() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)

    var panel := ColorRect.new()
    panel.color = Color(0.0, 0.0, 0.0, 0.30)
    panel.position = Vector2(16,16)
    panel.size = Vector2(330,92)
    layer.add_child(panel)

    var title := Label.new()
    title.text = "SGFIRE  •  TESTE DE CAMPO"
    title.position = Vector2(14,8)
    title.add_theme_font_size_override("font_size", 18)
    panel.add_child(title)

    health_label = Label.new()
    health_label.position = Vector2(14,38)
    health_label.add_theme_font_size_override("font_size", 17)
    panel.add_child(health_label)

    score_label = Label.new()
    score_label.position = Vector2(14,64)
    score_label.add_theme_font_size_override("font_size", 17)
    panel.add_child(score_label)

    hud_status = Label.new()
    hud_status.text = "NOITE • SÃO GABRIEL–RS • BOTS • COMBATE"
    hud_status.position = Vector2(18,104)
    hud_status.add_theme_font_size_override("font_size", 15)
    layer.add_child(hud_status)

    # HUD revisado para o Galaxy A03: sem polígonos/triângulos, apenas botões circulares.
    _make_touch_button(layer, "▲", Vector2(58,365), "forward")
    _make_touch_button(layer, "▼", Vector2(58,439), "back")
    _make_touch_button(layer, "◀", Vector2(8,402), "left")
    _make_touch_button(layer, "▶", Vector2(108,402), "right")
    _make_touch_button(layer, "FIRE", Vector2(812,424), "fire")

    var hint := Label.new()
    hint.text = "TOQUE/ARRASTE NO LADO DIREITO PARA MIRAR"
    hint.position = Vector2(550,500)
    hint.add_theme_font_size_override("font_size", 13)
    hint.modulate = Color(1,1,1,0.55)
    layer.add_child(hint)

    var crosshair := Label.new()
    crosshair.text = "+"
    crosshair.position = Vector2(468,238)
    crosshair.size = Vector2(30,60)
    crosshair.add_theme_font_size_override("font_size", 28)
    crosshair.modulate = Color(1,1,1,0.85)
    layer.add_child(crosshair)

    damage_flash = ColorRect.new()
    damage_flash.color = Color(0.8, 0.0, 0.0, 0.0)
    damage_flash.position = Vector2.ZERO
    damage_flash.size = Vector2(960,540)
    damage_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(damage_flash)

func _make_touch_button(layer: CanvasLayer, label_text: String, pos: Vector2, action: String) -> void:
    var b := Button.new()
    b.text = label_text
    b.position = pos
    b.size = Vector2(68,68)
    b.custom_minimum_size = Vector2(68,68)
    b.focus_mode = Control.FOCUS_NONE
    b.mouse_filter = Control.MOUSE_FILTER_STOP
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color(0.12, 0.14, 0.18, 0.62)
    normal.border_color = Color(1,1,1,0.30)
    normal.set_border_width_all(2)
    normal.set_corner_radius_all(34)
    var pressed := StyleBoxFlat.new()
    pressed.bg_color = Color(0.35, 0.38, 0.45, 0.78)
    pressed.border_color = Color(1,1,1,0.55)
    pressed.set_border_width_all(2)
    pressed.set_corner_radius_all(34)
    b.add_theme_stylebox_override("normal", normal)
    b.add_theme_stylebox_override("hover", normal)
    b.add_theme_stylebox_override("pressed", pressed)
    b.add_theme_font_size_override("font_size", 21 if action != "fire" else 17)
    b.button_down.connect(func(): _set_mobile(action, true))
    b.button_up.connect(func(): _set_mobile(action, false))
    layer.add_child(b)

func _set_mobile(action: String, value: bool) -> void:
    match action:
        "forward": mobile_forward = value
        "back": mobile_back = value
        "left": mobile_left = value
        "right": mobile_right = value
        "fire": mobile_fire = value

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and event.position.x > 420:
            look_touch = event.index
            last_look = event.position
        elif not event.pressed and event.index == look_touch:
            look_touch = -1
    elif event is InputEventScreenDrag and event.index == look_touch:
        var delta: Vector2 = event.position - last_look
        last_look = event.position
        player.rotate_y(-delta.x * 0.006)
        camera.rotation.x = clampf(camera.rotation.x - delta.y * 0.004, -1.15, 1.15)

func _player_move(_delta: float) -> void:
    var input_vec := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var x := input_vec.x
    var z := input_vec.y
    if mobile_left: x -= 1.0
    if mobile_right: x += 1.0
    if mobile_forward: z -= 1.0
    if mobile_back: z += 1.0
    var dir := Vector3(x, 0, z).normalized()
    var world_dir := (player.global_transform.basis * dir)
    world_dir.y = 0
    player.velocity.x = world_dir.x * MOVE_SPEED
    player.velocity.z = world_dir.z * MOVE_SPEED
    player.velocity.y = 0
    player.move_and_slide()

func _player_fire() -> void:
    if fire_timer > 0.0:
        return
    fire_timer = FIRE_COOLDOWN
    var origin := camera.global_position
    var target := origin + (-camera.global_transform.basis.z * 60.0)
    var query := PhysicsRayQueryParameters3D.create(origin, target)
    query.exclude = [player]
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    _spawn_tracer(origin, hit.get("position", target), Color("#fff1a8"))
    if hit.has("collider") and hit.collider in bots:
        player_score += 100
        eliminated_bots += 1
        var bot: CharacterBody3D = hit.collider
        bot_flash[bot] = 0.14
        _respawn_bot(bot)

func _update_bots(delta: float) -> void:
    for bot in bots:
        if not is_instance_valid(bot):
            continue
        var to_player := player.global_position - bot.global_position
        to_player.y = 0
        if to_player.length() > 3.0:
            bot.velocity = to_player.normalized() * BOT_SPEED
            bot.look_at(Vector3(player.global_position.x, bot.global_position.y, player.global_position.z), Vector3.UP)
            bot.move_and_slide()
        bot_timers[bot] = float(bot_timers.get(bot, 1.0)) - delta
        if bot_timers[bot] <= 0.0:
            bot_timers[bot] = randf_range(0.8, 1.8)
            _bot_fire(bot)

func _bot_fire(bot: CharacterBody3D) -> void:
    var origin := bot.global_position + Vector3.UP * 0.5
    var target := player.global_position + Vector3.UP * 0.5
    var query := PhysicsRayQueryParameters3D.create(origin, target)
    query.exclude = [bot]
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    _spawn_tracer(origin, target, Color("#ff5a5a"))
    if hit.has("collider") and hit.collider == player:
        player_health = max(0, player_health - 5)
        damage_flash.color.a = 0.28
        if player_health == 0:
            player_health = 100
            player.position = Vector3(0, 1.1, 16)

func _respawn_bot(bot: CharacterBody3D) -> void:
    bot.position = Vector3(randf_range(-15,15), 1.1, randf_range(-15,-5))
    bot.velocity = Vector3.ZERO

func _update_hud() -> void:
    health_label.text = "VIDA: %d" % player_health
    score_label.text = "PONTOS: %d  •  ELIMINADOS: %d/%d" % [player_score, eliminated_bots, bots.size()]

func _spawn_tracer(from_pos: Vector3, to_pos: Vector3, color: Color) -> void:
    var length := from_pos.distance_to(to_pos)
    if length < 0.1:
        return
    var tracer := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = Vector3(0.045, 0.045, length)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.emission_enabled = true
    mat.emission = color
    mat.emission_energy_multiplier = 2.0
    mesh.material = mat
    tracer.mesh = mesh
    tracer.global_position = (from_pos + to_pos) * 0.5
    add_child(tracer)
    tracer.look_at(to_pos, Vector3.UP)
    get_tree().create_timer(0.055).timeout.connect(tracer.queue_free)

func _update_effects(delta: float) -> void:
    if damage_flash != null:
        damage_flash.color.a = move_toward(damage_flash.color.a, 0.0, delta * 2.8)
    for bot in bots:
        if not is_instance_valid(bot):
            continue
        var t := float(bot_flash.get(bot, 0.0))
        if t > 0.0:
            t -= delta
            bot_flash[bot] = t
        elif bot_flash.has(bot):
            bot_flash.erase(bot)
