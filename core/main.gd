extends Node

var current_map: Node3D = null


func _ready() -> void:
	SignalBus.load_map.connect(_on_load_map)

func _on_load_map(map_name: String) -> void:
	var level_scene: PackedScene = load("res://maps/%s" + map_name)
	if level_scene != null:
		current_map = level_scene.instantiate()
		%Map.add_child(current_map, true)
