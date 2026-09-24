extends Control

func _ready() -> void:
    await get_tree().create_timer(0.8).timeout
    if ResourceLoader.exists("res://main.tscn"):
        get_tree().change_scene_to_file("res://main.tscn")
