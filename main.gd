extends Node3D

const WEAPONS = {
    "REVOLVER": {"body":20.0, "head":40.0, "ammo":6, "cooldown":0.38, "range":45.0},
    "44": {"body":50.0, "head":100.0, "ammo":6, "cooldown":0.55, "range":55.0},
    "PUMA": {"body":34.0, "head":68.0, "ammo":8, "cooldown":0.22, "range":70.0},
    "FACAO": {"body":34.0, "head":100.0, "ammo":1, "cooldown":0.65, "range":3.2}
}

var player: CharacterBody3D
var camera: Camera3D
var yaw := 0.0
var pitch := -0.05
var health := 100.0
var weapon := "REVOLVER"
var ammo := 6
var cooldown := 0.0
var enemies: Array[Node3D] = []
var kills := 0
var game_over := false
var joystick_id := -1
var joystick_origin := Vector2.ZERO
var joystick_pos := Vector2.ZERO
var look_id := -1
var last_look := Vector2.ZERO
var move_input := Vector2.ZERO
var look_sensitivity := 0.006
var match_time := 180.0
var recoil := 0.0
var sprint := false
var pickup_text: Label
var hud: Label
var message: Label
var fire_button: Button
var reload_button: Button
var weapon_button: Button
var restart_button: Button
var joystick_base: ColorRect
var joystick_knob: ColorRect
var fps_label: Label
var crosshair: Label
var hit_marker: Label
var damage_flash: ColorRect
var lobby_music: AudioStreamPlayer

func _ready() -> void:
    _build_world()
    _build_player()
    _build_enemies()
    _build_hud()
    _start_lobby_audio()


func _start_lobby_audio() -> void:
    # Áudio opcional: o APK deve iniciar mesmo sem arquivo externo.
    lobby_music = AudioStreamPlayer.new()
    lobby_music.name = "LobbyAmbient"
    add_child(lobby_music)

func _physics_process(delta: float) -> void:
    if game_over:
        return
    cooldown = maxf(0.0, cooldown - delta)
    _player_move(delta)
    _enemy_ai(delta)
    if damage_flash and damage_flash.color.a > 0.0:
        var fc := damage_flash.color
        fc.a = maxf(0.0, fc.a - delta * 2.5)
        damage_flash.color = fc
    if hit_marker and hit_marker.visible:
        hit_marker.modulate.a = maxf(0.0, hit_marker.modulate.a - delta * 3.0)
        if hit_marker.modulate.a <= 0.0:
            hit_marker.visible = false
    match_time = maxf(0.0, match_time - delta)
    recoil = maxf(0.0, recoil - delta * 8.0)
    camera.rotation.x = pitch - recoil
    _update_hud()
    if match_time <= 0.0 and kills < 5:
        _finish(false, "TEMPO ESGOTADO")
    if health <= 0.0:
        _finish(false)

func _build_world() -> void:
    var env := WorldEnvironment.new()
    var e := Environment.new()
    e.background_mode = Environment.BG_COLOR
    e.background_color = Color(0.015,0.02,0.045)
    e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    e.ambient_light_color = Color(0.18,0.22,0.38)
    e.ambient_light_energy = 0.32
    env.environment = e
    add_child(env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-55,-30,0)
    sun.light_energy = 0.18
    sun.light_color = Color(0.45,0.52,0.75)
    add_child(sun)

    _box("Ground", Vector3(0,-0.5,0), Vector3(80,1,80), Color(0.24,0.27,0.24))
    # Marcos de entrada e pontos de cobertura para a vertical slice 2.0.
    _box("SpawnGate", Vector3(0,2,34), Vector3(12,4,1), Color(0.20,0.22,0.24))
    _box("SouthBlock", Vector3(22,2,10), Vector3(10,4,8), Color(0.38,0.34,0.30))
    # Fictionalized Zona Sul layout: roads + compact blocks, not a real navigable copy.
    _box("Road_A", Vector3(0,0,0), Vector3(78,0.08,9), Color(0.09,0.10,0.10))
    _box("Road_B", Vector3(0,0,18), Vector3(78,0.08,7), Color(0.10,0.10,0.10))
    _box("Road_C", Vector3(-22,0,-22), Vector3(7,0.08,44), Color(0.10,0.10,0.10))
    for p in [Vector3(-9,0.75,5),Vector3(8,0.75,5),Vector3(25,0.75,20),Vector3(-30,0.75,20),Vector3(5,0.75,-20),Vector3(30,0.75,-20)]:
        _box("Cover", p, Vector3(5,1.5,2), Color(0.32,0.29,0.25))
    for p in [Vector3(-32,2,-15),Vector3(-17,2,-15),Vector3(0,2,-15),Vector3(18,2,-15),Vector3(32,2,-15),Vector3(-32,2,28),Vector3(-12,2,28),Vector3(10,2,28),Vector3(31,2,28)]:
        _box("Building", p, Vector3(12,4,9), Color(0.34,0.36,0.38))
    for p in [Vector3(-32,0.8,-4),Vector3(-16,0.8,-4),Vector3(2,0.8,-4),Vector3(20,0.8,-4),Vector3(35,0.8,-4)]:
        _box("Wall", p, Vector3(5,1.6,2), Color(0.42,0.39,0.33))

func _box(n: String, pos: Vector3, size: Vector3, color: Color) -> StaticBody3D:
    var body := StaticBody3D.new()
    body.name = n
    body.position = pos
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mesh.material_override = mat
    body.add_child(mesh)
    var shape := CollisionShape3D.new()
    var cs := BoxShape3D.new()
    cs.size = size
    shape.shape = cs
    body.add_child(shape)
    add_child(body)
    return body

func _build_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Player"
    player.position = Vector3(0,1.0,30)
    add_child(player)
    var shape := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.35
    capsule.height = 1.8
    shape.shape = capsule
    shape.position.y = 0.9
    player.add_child(shape)
    camera = Camera3D.new()
    camera.position = Vector3(0,1.55,0)
    player.add_child(camera)
    camera.current = true

func _build_enemies() -> void:
    var positions = [Vector3(-25,1,-10),Vector3(-7,1,-12),Vector3(12,1,-8),Vector3(28,1,5),Vector3(-25,1,15)]
    for i in positions.size():
        var enemy := CharacterBody3D.new()
        enemy.name = "Enemy_%02d" % (i+1)
        enemy.position = positions[i]
        enemy.set_meta("health",100.0)
        enemy.set_meta("hit_zone", "body")
        enemy.set_meta("attack_cd", 0.0)
        enemy.set_meta("shoot_cd", 0.0)
        add_child(enemy)
        var body_shape := CollisionShape3D.new()
        var body_cap := CapsuleShape3D.new()
        body_cap.radius = 0.38
        body_cap.height = 1.45
        body_shape.shape = body_cap
        body_shape.position.y = 0.78
        enemy.add_child(body_shape)
        var body_mesh := MeshInstance3D.new()
        var cap := CapsuleMesh.new()
        cap.radius = 0.38
        cap.height = 1.45
        body_mesh.mesh = cap
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.18,0.08,0.08)
        body_mesh.material_override = mat
        body_mesh.position.y = 0.78
        enemy.add_child(body_mesh)
        var head := Area3D.new()
        head.name = "Head"
        head.set_meta("hit_zone", "head")
        head.position.y = 1.7
        var hs := CollisionShape3D.new()
        var sph := SphereShape3D.new()
        sph.radius = 0.24
        hs.shape = sph
        head.add_child(hs)
        enemy.add_child(head)
        var hm := MeshInstance3D.new()
        var sm := SphereMesh.new()
        sm.radius = 0.24
        sm.height = 0.48
        hm.mesh = sm
        var hmat := StandardMaterial3D.new()
        hmat.albedo_color = Color(0.45,0.34,0.25)
        hm.material_override = hmat
        hm.position.y = 1.7
        enemy.add_child(hm)
        enemies.append(enemy)

func _build_hud() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    crosshair = Label.new()
    crosshair.text = "+"
    crosshair.position = Vector2(633,348)
    crosshair.add_theme_font_size_override("font_size",28)
    crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(crosshair)
    var lobby_title := Label.new()
    lobby_title.position = Vector2(430,24)
    lobby_title.text = "SGFIRE • 5 VS 5 • TESTE LOCAL"
    lobby_title.add_theme_font_size_override("font_size",22)
    layer.add_child(lobby_title)

    hud = Label.new()
    hud.position = Vector2(20,18)
    hud.add_theme_font_size_override("font_size",24)
    layer.add_child(hud)
    fps_label = Label.new()
    fps_label.position = Vector2(20,145)
    fps_label.add_theme_font_size_override("font_size",16)
    layer.add_child(fps_label)
    pickup_text = Label.new()
    pickup_text.position = Vector2(20,680)
    pickup_text.add_theme_font_size_override("font_size",18)
    pickup_text.text = "Vertical Slice 2.0 • 180s"
    layer.add_child(pickup_text)
    message = Label.new()
    message.position = Vector2(360,220)
    message.size = Vector2(560,120)
    message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message.add_theme_font_size_override("font_size",42)
    layer.add_child(message)
    hit_marker = Label.new()
    hit_marker.text = "X"
    hit_marker.position = Vector2(625,335)
    hit_marker.add_theme_font_size_override("font_size",34)
    hit_marker.visible = false
    hit_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(hit_marker)
    damage_flash = ColorRect.new()
    damage_flash.size = Vector2(1280,720)
    damage_flash.color = Color(0.8,0.0,0.0,0.0)
    damage_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(damage_flash)

    joystick_base = ColorRect.new()
    joystick_base.position = Vector2(45,535)
    joystick_base.size = Vector2(150,150)
    joystick_base.color = Color(0.15,0.15,0.15,0.55)
    layer.add_child(joystick_base)
    joystick_knob = ColorRect.new()
    joystick_knob.position = Vector2(95,585)
    joystick_knob.size = Vector2(50,50)
    joystick_knob.color = Color(0.65,0.65,0.65,0.75)
    layer.add_child(joystick_knob)

    fire_button = _button(layer,"ATIRAR", Vector2(1060,555), Vector2(180,70), _fire)
    reload_button = _button(layer,"RECARREGAR", Vector2(1060,475), Vector2(180,60), _reload)
    weapon_button = _button(layer,"ARMA: REVOLVER", Vector2(20,90), Vector2(220,55), _switch_weapon)
    restart_button = _button(layer,"REINICIAR", Vector2(540,365), Vector2(200,65), _restart)
    restart_button.visible = false

func _button(parent: Node, text: String, pos: Vector2, size: Vector2, action: Callable) -> Button:
    var b := Button.new()
    b.text = text
    b.position = pos
    b.size = size
    b.add_theme_font_size_override("font_size",22)
    b.pressed.connect(action)
    parent.add_child(b)
    return b

func _player_move(delta: float) -> void:
    var v := move_input
    var dir := Vector3(v.x,0,v.y)
    dir = dir.rotated(Vector3.UP, yaw).normalized() if dir.length() > 0.01 else Vector3.ZERO
    sprint = v.length() > 0.85
    var speed := 6.5 if sprint else 4.8
    player.velocity.x = dir.x * speed
    player.velocity.z = dir.z * speed
    player.velocity.y = -0.2
    player.move_and_slide()
    player.rotation.y = yaw

func _enemy_ai(delta: float) -> void:
    for enemy in enemies.duplicate():
        if not is_instance_valid(enemy):
            enemies.erase(enemy)
            continue
        var attack_cd := float(enemy.get_meta("attack_cd", 0.0))
        var shoot_cd := float(enemy.get_meta("shoot_cd", 0.0))
        attack_cd = maxf(0.0, attack_cd - delta)
        shoot_cd = maxf(0.0, shoot_cd - delta)
        enemy.set_meta("attack_cd", attack_cd)
        enemy.set_meta("shoot_cd", shoot_cd)
        var to_player: Vector3 = player.global_position - enemy.global_position
        var dist: float = to_player.length()
        if dist > 2.1:
            enemy.velocity = to_player.normalized() * 1.15
            enemy.move_and_slide()
        else:
            enemy.velocity = Vector3.ZERO
        enemy.look_at(Vector3(player.global_position.x, enemy.global_position.y, player.global_position.z), Vector3.UP)
        if dist <= 28.0 and shoot_cd <= 0.0:
            var from: Vector3 = enemy.global_position + Vector3.UP * 1.15
            var to := player.global_position + Vector3.UP * 1.0
            var query := PhysicsRayQueryParameters3D.create(from, to)
            var hit := get_world_3d().direct_space_state.intersect_ray(query)
            if not hit.is_empty() and hit["collider"] == player:
                health = maxf(0.0, health - 7.0)
                var fc := damage_flash.color
                fc.a = 0.22
                damage_flash.color = fc
            enemy.set_meta("shoot_cd", 1.25)
        elif dist <= 2.1 and attack_cd <= 0.0:
            health = maxf(0.0, health - 10.0)
            var fc := damage_flash.color
            fc.a = 0.28
            damage_flash.color = fc
            enemy.set_meta("attack_cd", 1.0)

func _fire() -> void:
    if game_over or cooldown > 0.0:
        return
    var data: Dictionary = WEAPONS[weapon]
    cooldown = data.cooldown
    recoil = 0.035 if weapon == "REVOLVER" else (0.055 if weapon == "44" else 0.018)
    if weapon != "FACAO":
        if ammo <= 0:
            return
        ammo -= 1
    var from := camera.global_position
    var to: Vector3 = from + -camera.global_transform.basis.z * float(data.range)
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.collide_with_areas = true
    var hit := get_world_3d().direct_space_state.intersect_ray(query)

    if hit.is_empty():
        return

    var obj = hit["collider"]
    var target: Node = obj
    var zone := "body"

    if obj is Area3D and obj.has_meta("hit_zone"):
        zone = str(obj.get_meta("hit_zone"))
        target = obj.get_parent()

    if target != null and target.has_meta("health"):
        var dmg: float = data.head if zone == "head" else data.body
        var hp: float = float(target.get_meta("health")) - dmg
        target.set_meta("health", hp)
        if hit_marker:
            hit_marker.visible = true
            hit_marker.modulate = Color(1,1,1,1)
        if hp <= 0.0:
            kills += 1
            enemies.erase(target)
            target.queue_free()
            if kills >= 5:
                _finish(true)
func _reload() -> void:
    if weapon != "FACAO":
        ammo = int(WEAPONS[weapon].ammo)

func _switch_weapon() -> void:
    var keys = ["REVOLVER","44","PUMA","FACAO"]
    var idx := keys.find(weapon)
    weapon = keys[(idx + 1) % keys.size()]
    ammo = int(WEAPONS[weapon].ammo)
    weapon_button.text = "ARMA: " + weapon

func _update_hud() -> void:
    if crosshair:
        crosshair.visible = not game_over
    var mins := int(match_time) / 60
    var secs := int(match_time) % 60
    hud.text = "SGFire • Zona Sul — São Gabriel/RS (ficcional)\nVida: %d   Abates: %d/5   %s: %s   Tempo: %02d:%02d" % [int(health),kills,weapon,("∞" if weapon == "FACAO" else "%d/%d" % [ammo,WEAPONS[weapon].ammo]),mins,secs]
    if pickup_text:
        pickup_text.text = ("CORRA • velocidade aumentada" if sprint else "Vertical Slice 2.0 • 180s")
    fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _finish(win: bool, reason: String = "") -> void:
    if game_over:
        return
    game_over = true
    message.text = "MISSÃO CONCLUÍDA" if win else (reason if reason != "" else "VOCÊ FOI ELIMINADO")
    message.text += "\nToque em REINICIAR"
    restart_button.visible = true
    fire_button.disabled = true
    reload_button.disabled = true
    weapon_button.disabled = true

func _restart() -> void:
    get_tree().reload_current_scene()

func _input(event: InputEvent) -> void:
    if game_over:
        return
    if event is InputEventScreenTouch:
        if event.pressed:
            if event.position.x < 300 and event.position.y > 480:
                joystick_id = event.index
                joystick_origin = Vector2(120,610)
                joystick_pos = event.position
                _update_joystick()
            elif event.position.x > 300:
                look_id = event.index
                last_look = event.position
        else:
            if event.index == joystick_id:
                joystick_id = -1
                move_input = Vector2.ZERO
                joystick_knob.position = Vector2(95,585)
            if event.index == look_id:
                look_id = -1
    elif event is InputEventScreenDrag:
        if event.index == joystick_id:
            joystick_pos = event.position
            _update_joystick()
        elif event.index == look_id:
            var d: Vector2 = event.position - last_look
            last_look = event.position
            yaw -= d.x * look_sensitivity
            pitch = clampf(pitch - d.y * look_sensitivity, -1.2, 1.2)
            camera.rotation.x = pitch

func _update_joystick() -> void:
    var delta := joystick_pos - joystick_origin
    if delta.length() > 55.0:
        delta = delta.normalized() * 55.0
    move_input = Vector2(delta.x / 55.0, delta.y / 55.0)
    joystick_knob.position = joystick_origin + delta - Vector2(25,25)
